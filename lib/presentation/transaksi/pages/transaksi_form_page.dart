import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/transaksi.dart';
import '../../common/widgets/akun_dropdown.dart';
import '../../common/widgets/badge_chip.dart';
import '../../split_bill/bloc/split_bill_cubit.dart';
import '../../subscription/bloc/subscription_form_cubit.dart';
import '../../subscription/pages/subscription_form_page.dart';
import '../../split_bill/pages/split_bill_page.dart';
import '../bloc/transaksi_form_cubit.dart';

class TransaksiFormPage extends StatelessWidget {
  const TransaksiFormPage({super.key, this.initial});

  final Transaksi? initial;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        TransaksiFormCubit(getIt(), getIt(), getIt(), getIt(), initial: initial)
          ..load(),
    child: const _TransaksiFormView(),
  );
}

class _TransaksiFormView extends StatefulWidget {
  const _TransaksiFormView();

  @override
  State<_TransaksiFormView> createState() => _TransaksiFormViewState();
}

const _newSubscription = -1;

class _TransaksiFormViewState extends State<_TransaksiFormView> {
  int _subscriptionDropdownEpoch = 0;

  late final TextEditingController _deskripsi;
  late final TextEditingController _total;
  late final TextEditingController _merchant;
  late final TextEditingController _ongkir;
  late final TextEditingController _catatan;

  @override
  void initState() {
    super.initState();
    final d = context.read<TransaksiFormCubit>().state.draft;
    _deskripsi = TextEditingController(text: d.deskripsi);
    _total = TextEditingController(
      text: d.totalTagihan == 0 ? '' : '${d.totalTagihan}',
    );
    _merchant = TextEditingController(text: d.merchant ?? '');
    _ongkir = TextEditingController(
      text: d.ongkirFee == 0 ? '' : '${d.ongkirFee}',
    );
    _catatan = TextEditingController(text: d.catatan ?? '');
  }

  @override
  void dispose() {
    _deskripsi.dispose();
    _total.dispose();
    _merchant.dispose();
    _ongkir.dispose();
    _catatan.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TransaksiFormCubit cubit, DateTime current) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) cubit.setTanggal(picked);
  }

  Future<void> _confirmDelete(TransaksiFormCubit cubit) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus transaksi?'),
        content: const Text('Transaksi dan split-nya akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok == true) await cubit.delete();
  }

  int _parse(String s) => int.tryParse(s) ?? 0;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TransaksiFormCubit>();

    return BlocConsumer<TransaksiFormCubit, TransaksiFormState>(
      listenWhen: (a, b) => a.done != b.done || a.error != b.error,
      listener: (context, state) {
        if (state.done) {
          Navigator.of(context).pop();
        } else if (state.error != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      builder: (context, state) {
        final d = state.draft;
        return Scaffold(
          appBar: AppBar(
            title: Text(state.isEdit ? 'Edit Transaksi' : 'Tambah Transaksi'),
            actions: [
              if (state.isEdit)
                IconButton(
                  tooltip: 'Hapus',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: state.submitting
                      ? null
                      : () => _confirmDelete(cubit),
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              InkWell(
                onTap: () => _pickDate(cubit, d.tanggal),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tanggal',
                    suffixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(formatDate(d.tanggal)),
                ),
              ),
              const SizedBox(height: 16),
              AkunDropdown(
                akuns: state.akuns,
                value: d.akunId,
                label: d.jenis == JenisTransaksi.pembayaran
                    ? 'Akun yang dibayar'
                    : 'Akun',
                onChanged: cubit.setAkun,
              ),
              const SizedBox(height: 16),
              _bulanTagihanField(cubit, state),
              const SizedBox(height: 16),
              TextField(
                controller: _deskripsi,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                onChanged: cubit.setDeskripsi,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<JenisTransaksi>(
                initialValue: d.jenis,
                decoration: const InputDecoration(labelText: 'Jenis'),
                items: [
                  for (final j in JenisTransaksi.values)
                    DropdownMenuItem(value: j, child: Text(j.label)),
                ],
                onChanged: (v) {
                  if (v != null) cubit.setJenis(v);
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _total,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: d.isGroupOrder ? 'Total order' : 'Total tagihan',
                  prefixText: 'Rp ',
                ),
                onChanged: (v) => cubit.setTotal(_parse(v)),
              ),
              if (d.jenis == JenisTransaksi.groupOrder)
                ..._groupOrderFields(cubit, state),
              if (d.jenis == JenisTransaksi.subscription) ...[
                const SizedBox(height: 16),
                _subscriptionField(cubit, state),
              ],
              const SizedBox(height: 16),
              DropdownButtonFormField<StatusBayar>(
                initialValue: d.status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: [
                  for (final s in StatusBayar.values)
                    DropdownMenuItem(value: s, child: Text(s.label)),
                ],
                onChanged: (v) {
                  if (v != null) cubit.setStatus(v);
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _catatan,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Catatan'),
                onChanged: cubit.setCatatan,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: state.submitting ? null : cubit.submit,
                child: state.submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Simpan'),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _groupOrderFields(
    TransaksiFormCubit cubit,
    TransaksiFormState state,
  ) {
    final d = state.draft;
    return [
      const SizedBox(height: 16),
      TextField(
        controller: _merchant,
        decoration: const InputDecoration(labelText: 'Merchant'),
        onChanged: cubit.setMerchant,
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _ongkir,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          labelText: 'Ongkir / fee',
          prefixText: 'Rp ',
        ),
        onChanged: (v) => cubit.setOngkir(_parse(v)),
      ),
      const SizedBox(height: 16),
      OutlinedButton.icon(
        icon: const Icon(Icons.group_outlined),
        label: Text(
          d.splits.isEmpty
              ? 'Split ke teman'
              : 'Ubah split (${d.splits.length} orang)',
        ),
        onPressed: () => _openSplit(cubit, state),
      ),
      for (var i = 0; i < d.splits.length; i++) _splitTile(cubit, d, i),
    ];
  }

  Widget _bulanTagihanField(
    TransaksiFormCubit cubit,
    TransaksiFormState state,
  ) {
    final helper = state.bulanManual
        ? 'Diubah manual'
        : state.cutoff > 0
        ? 'Otomatis (statement tutup tgl ${state.cutoff})'
        : 'Otomatis (bulan kalender)';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputDecorator(
          decoration: InputDecoration(
            labelText: 'Bulan tagihan',
            helperText: helper,
            contentPadding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
          ),
          child: Row(
            children: [
              Expanded(child: Text(formatMonthYear(state.bulanTagihan))),
              IconButton(
                tooltip: 'Bulan tagihan sebelumnya',
                icon: const Icon(Icons.chevron_left),
                onPressed: () =>
                    cubit.setBulanTagihan(addMonths(state.bulanTagihan, -1)),
              ),
              IconButton(
                tooltip: 'Bulan tagihan berikutnya',
                icon: const Icon(Icons.chevron_right),
                onPressed: () =>
                    cubit.setBulanTagihan(addMonths(state.bulanTagihan, 1)),
              ),
            ],
          ),
        ),
        if (state.bulanManual)
          TextButton(
            onPressed: cubit.resetBulanTagihan,
            child: const Text('Kembalikan ke otomatis'),
          ),
      ],
    );
  }

  Widget _splitTile(TransaksiFormCubit cubit, Transaksi d, int index) {
    final split = d.splits[index];
    final isSelf = split.nama == namaSaya;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(split.nama),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(formatRupiah(d.tagihanUntuk(split))),
          if (!isSelf) ...[
            const SizedBox(width: 8),
            PopupMenuButton<StatusBayar>(
              tooltip: 'Ubah status ${split.nama}',
              initialValue: split.status,
              onSelected: (status) => cubit.setSplitStatus(index, status),
              itemBuilder: (_) => [
                for (final status in StatusBayar.values)
                  PopupMenuItem(value: status, child: Text(status.label)),
              ],
              child: BadgeChip(
                label: split.status.label,
                color: split.status.color,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openSplit(
    TransaksiFormCubit cubit,
    TransaksiFormState state,
  ) async {
    final d = state.draft;
    if (d.totalTagihan <= 0) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Isi total order dulu sebelum split')),
        );
      return;
    }
    final result = await Navigator.of(context).push<SplitResult>(
      MaterialPageRoute(
        builder: (_) => SplitBillPage(
          totalTagihan: d.totalTagihan,
          ongkirFee: d.ongkirFee,
          initialSplits: d.splits,
        ),
      ),
    );
    if (result != null) cubit.setSplits(result.splits, result.sumberEkstraksi);
  }

  Future<void> _createSubscription(TransaksiFormCubit cubit) async {
    final result = await Navigator.of(context).push<SubscriptionFormResult>(
      MaterialPageRoute(builder: (_) => const SubscriptionFormPage()),
    );
    final id = result?.savedId;
    if (id != null) {
      cubit.setSubscription(id);
      await cubit.load();
    }
    if (mounted) setState(() => _subscriptionDropdownEpoch++);
  }

  Widget _subscriptionField(
    TransaksiFormCubit cubit,
    TransaksiFormState state,
  ) {
    if (state.subscriptions.isEmpty) {
      return OutlinedButton.icon(
        icon: const Icon(Icons.add),
        label: const Text('Buat subscription baru'),
        onPressed: () => _createSubscription(cubit),
      );
    }
    return DropdownButtonFormField<int>(
      key: ValueKey(
        'sub-${state.subscriptions.length}-$_subscriptionDropdownEpoch',
      ),
      initialValue: state.draft.subscriptionId,
      decoration: const InputDecoration(labelText: 'Subscription'),
      items: [
        for (final s in state.subscriptions)
          DropdownMenuItem(value: s.id, child: Text(s.namaLayanan)),
        const DropdownMenuItem(
          value: _newSubscription,
          child: Text('+ Subscription baru'),
        ),
      ],
      onChanged: (v) {
        if (v == _newSubscription) {
          _createSubscription(cubit);
        } else {
          cubit.setSubscription(v);
        }
      },
    );
  }
}
