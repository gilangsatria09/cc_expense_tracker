import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/di/injection.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/split_group_order.dart';
import '../bloc/split_bill_cubit.dart';
import '../widgets/participant_input.dart';

class PickedImage {
  const PickedImage({required this.bytes, required this.mimeType});

  final Uint8List bytes;
  final String mimeType;
}

typedef ImagePickCallback = Future<PickedImage?> Function(ImageSource source);

Future<PickedImage?> defaultPickImage(ImageSource source) async {
  final file = await ImagePicker().pickImage(
    source: source,
    maxWidth: 1600,
    imageQuality: 85,
  );
  if (file == null) return null;
  final bytes = await file.readAsBytes();
  return PickedImage(
    bytes: bytes,
    mimeType: file.mimeType ?? _mimeFromName(file.name),
  );
}

String _mimeFromName(String name) {
  final ext = name.toLowerCase().split('.').last;
  return switch (ext) {
    'png' => 'image/png',
    'webp' => 'image/webp',
    'heic' => 'image/heic',
    _ => 'image/jpeg',
  };
}

class SplitBillPage extends StatelessWidget {
  const SplitBillPage({
    super.key,
    required this.totalTagihan,
    required this.ongkirFee,
    this.initialSplits = const [],
    this.pickImage = defaultPickImage,
  });

  final int totalTagihan;
  final int ongkirFee;
  final List<SplitGroupOrder> initialSplits;
  final ImagePickCallback pickImage;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => SplitBillCubit(
      getIt(),
      getIt(),
      totalTagihan: totalTagihan,
      ongkirFee: ongkirFee,
      initial: initialSplits,
    )..loadKnownNames(),
    child: _SplitBillView(pickImage: pickImage),
  );
}

class _SplitBillView extends StatefulWidget {
  const _SplitBillView({required this.pickImage});

  final ImagePickCallback pickImage;

  @override
  State<_SplitBillView> createState() => _SplitBillViewState();
}

class _SplitBillViewState extends State<_SplitBillView> {
  Future<void> _pickAndExtract(SplitBillCubit cubit, ImageSource source) async {
    final image = await widget.pickImage(source);
    if (image != null) await cubit.extract(image.bytes, image.mimeType);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SplitBillCubit>();

    return BlocConsumer<SplitBillCubit, SplitBillState>(
      listenWhen: (a, b) => a.error != b.error && b.error != null,
      listener: (context, state) => ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(state.error!))),
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Split ke Teman')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Summary(state: state),
            const SizedBox(height: 16),
            SegmentedButton<SplitMode>(
              segments: const [
                ButtonSegment(value: SplitMode.rata, label: Text('Split Rata')),
                ButtonSegment(value: SplitMode.ai, label: Text('Foto / AI')),
              ],
              selected: {state.mode},
              onSelectionChanged: (s) => cubit.setMode(s.first),
            ),
            if (state.mode == SplitMode.ai) ...[
              const SizedBox(height: 16),
              _aiPanel(cubit, state),
            ],
            const SizedBox(height: 16),
            for (final row in state.rows)
              _RowEditor(key: ValueKey(row.id), row: row, state: state),
            const SizedBox(height: 8),
            const ParticipantInput(),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: state.extracting
                  ? null
                  : () {
                      final result = cubit.confirm();
                      if (result != null) Navigator.of(context).pop(result);
                    },
              child: const Text('Simpan split'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _aiPanel(SplitBillCubit cubit, SplitBillState state) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<SumberEkstraksi>(
            segments: const [
              ButtonSegment(
                value: SumberEkstraksi.aiStruk,
                label: Text('Struk'),
              ),
              ButtonSegment(
                value: SumberEkstraksi.aiChatGroup,
                label: Text('Chat grup'),
              ),
            ],
            selected: {state.sumberAi},
            onSelectionChanged: (s) => cubit.setSumberAi(s.first),
          ),
          const SizedBox(height: 12),
          if (state.extracting)
            const Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('AI sedang membaca gambar…'),
              ],
            )
          else
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Galeri'),
                  onPressed: () => _pickAndExtract(cubit, ImageSource.gallery),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Kamera'),
                  onPressed: () => _pickAndExtract(cubit, ImageSource.camera),
                ),
              ],
            ),
          const SizedBox(height: 8),
          Text(
            'Hasil AI menggantikan daftar di bawah dan bisa kamu edit. '
            'Ongkir ${formatRupiah(state.ongkirFee)} dibagi rata ke semua peserta.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    ),
  );
}

class _Summary extends StatelessWidget {
  const _Summary({required this.state});

  final SplitBillState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selisih = state.selisih;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total order ${formatRupiah(state.totalTagihan)}',
              style: theme.textTheme.titleMedium,
            ),
            if (state.ongkirFee > 0)
              Text(
                'sudah termasuk ongkir ${formatRupiah(state.ongkirFee)}',
                style: theme.textTheme.bodySmall,
              ),
            const SizedBox(height: 4),
            Text(
              '${state.jumlahOrang} orang · rata ${formatRupiah(state.bagianRata)}',
              style: theme.textTheme.bodyMedium,
            ),
            if (selisih != 0)
              _warning(
                context,
                selisih > 0
                    ? 'Total split kurang ${formatRupiah(selisih)} dari total order'
                    : 'Total split lebih ${formatRupiah(-selisih)} dari total order',
              ),
            if (!state.hasSelf)
              _warning(
                context,
                'Belum ada baris "Gilang" untuk bagianmu sendiri',
              ),
          ],
        ),
      ),
    );
  }

  Widget _warning(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.warning_amber_rounded,
          size: 18,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
      ],
    ),
  );
}

class _RowEditor extends StatelessWidget {
  const _RowEditor({super.key, required this.row, required this.state});

  final SplitRowDraft row;
  final SplitBillState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SplitBillCubit>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextFormField(
              key: ValueKey('nama-${row.id}'),
              initialValue: row.nama,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nama'),
              onChanged: (v) => cubit.rename(row.id, v),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextFormField(
              key: ValueKey('amt-${row.id}'),
              initialValue: row.amount?.toString() ?? '',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Nominal',
                prefixText: 'Rp ',
                hintText: '${state.bagianRata}',
              ),
              onChanged: (v) => cubit.setAmount(row.id, int.tryParse(v)),
            ),
          ),
          IconButton(
            tooltip: 'Hapus ${row.nama}',
            icon: const Icon(Icons.close),
            onPressed: () => cubit.removeRow(row.id),
          ),
        ],
      ),
    );
  }
}
