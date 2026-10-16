import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../domain/entities/akun.dart';
import '../../common/widgets/rupiah_field.dart';
import '../bloc/akun_form_cubit.dart';

class AkunFormPage extends StatelessWidget {
  const AkunFormPage({super.key, this.initial});

  final Akun? initial;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => AkunFormCubit(getIt(), getIt(), initial: initial),
    child: const _AkunFormView(),
  );
}

class _AkunFormView extends StatelessWidget {
  const _AkunFormView();

  Future<void> _confirmDelete(BuildContext context, AkunFormCubit cubit) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus akun?'),
        content: const Text(
          'Akun hanya bisa dihapus kalau tidak dipakai transaksi, cicilan, '
          'atau subscription mana pun.',
        ),
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

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AkunFormCubit>();
    final initial = cubit.state.draft;

    return BlocConsumer<AkunFormCubit, AkunFormState>(
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
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: Text(state.isEdit ? 'Edit Akun' : 'Akun Baru'),
          actions: [
            if (state.isEdit)
              IconButton(
                tooltip: 'Hapus',
                icon: const Icon(Icons.delete_outline),
                onPressed: state.submitting
                    ? null
                    : () => _confirmDelete(context, cubit),
              ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              initialValue: initial.nama,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nama akun',
                hintText: 'mis. Kartu Kredit, SPayLater',
              ),
              onChanged: cubit.setNama,
            ),
            const SizedBox(height: 16),
            RupiahField(
              label: 'Limit',
              initialValue: initial.limitKredit,
              hint: 'Kosongkan kalau belum tahu',
              onChanged: (v) => cubit.setLimit(v ?? 0),
            ),
            const SizedBox(height: 16),
            RupiahField(
              label: 'Saldo outstanding sebelum tracker',
              initialValue: initial.saldoAwal,
              hint: 'Tagihan yang sudah ada sebelum mulai mencatat',
              onChanged: (v) => cubit.setSaldoAwal(v ?? 0),
            ),
            const SizedBox(height: 16),
            RupiahField(
              label: 'Tanggal tutup buku tagihan',
              prefix: null,
              initialValue: initial.tanggalCutoff,
              hint: '0 = ikut bulan kalender',
              onChanged: (v) => cubit.setTanggalCutoff(v ?? 0),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Transaksi sampai tanggal ini (termasuk) masuk tagihan bulan '
                'sebelumnya. Contoh: diisi 10, maka transaksi tanggal 1–10 '
                'Agustus masuk tagihan Juli.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 16),
            RupiahField(
              label: 'Tanggal jatuh tempo tagihan',
              prefix: null,
              initialValue: initial.tanggalJatuhTempo,
              hint: '0 = tanpa pengingat',
              onChanged: (v) => cubit.setTanggalJatuhTempo(v ?? 0),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Tanggal tagihan harus dibayar tiap bulan. Pengingat muncul '
                'sehari sebelumnya pukul 09.00. Ini berbeda dari tanggal tutup buku.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
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
      ),
    );
  }
}
