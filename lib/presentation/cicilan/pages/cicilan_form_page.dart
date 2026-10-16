import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/cicilan.dart';
import '../../common/widgets/akun_dropdown.dart';
import '../../common/widgets/rupiah_field.dart';
import '../bloc/cicilan_form_cubit.dart';

class CicilanFormPage extends StatelessWidget {
  const CicilanFormPage({super.key, this.initial});

  final Cicilan? initial;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        CicilanFormCubit(getIt(), getIt(), getIt(), initial: initial)..load(),
    child: const _CicilanFormView(),
  );
}

class _CicilanFormView extends StatelessWidget {
  const _CicilanFormView();

  Future<void> _pickDate(BuildContext context, CicilanFormCubit cubit) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: cubit.state.draft.tanggalMulai,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) cubit.setTanggalMulai(picked);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    CicilanFormCubit cubit,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus cicilan?'),
        content: const Text('Cicilan ini akan dihapus permanen.'),
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
    final cubit = context.read<CicilanFormCubit>();
    final initial = cubit.state.draft;

    return BlocConsumer<CicilanFormCubit, CicilanFormState>(
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
          title: Text(state.isEdit ? 'Edit Cicilan' : 'Cicilan Baru'),
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
              initialValue: initial.namaCicilan,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Nama cicilan'),
              onChanged: cubit.setNama,
            ),
            const SizedBox(height: 16),
            AkunDropdown(
              akuns: state.akuns,
              value: state.draft.akunId,
              onChanged: cubit.setAkun,
            ),
            const SizedBox(height: 16),
            RupiahField(
              label: 'Total harga barang',
              initialValue: initial.totalHargaBarang,
              onChanged: (v) => cubit.setTotal(v ?? 0),
            ),
            const SizedBox(height: 16),
            RupiahField(
              label: 'Tenor (bulan)',
              prefix: null,
              initialValue: initial.tenor,
              onChanged: (v) => cubit.setTenor(v ?? 0),
            ),
            const SizedBox(height: 16),
            RupiahField(
              label: 'Jumlah per bulan',
              initialValue: initial.jumlahPerBulan,
              hint: state.suggestedPerBulan > 0
                  ? '${state.suggestedPerBulan}'
                  : null,
              onChanged: (v) => cubit.setJumlahPerBulan(v ?? 0),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _pickDate(context, cubit),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Tanggal mulai',
                  suffixIcon: Icon(Icons.calendar_today_outlined),
                ),
                child: Text(formatDate(state.draft.tanggalMulai)),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: initial.catatan ?? '',
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Catatan'),
              onChanged: cubit.setCatatan,
            ),
            if (state.isEdit) ...[
              const SizedBox(height: 16),
              Text(
                'Cicilan terbayar: ${state.draft.cicilanKe} dari ${state.draft.tenor} '
                '(diubah lewat tombol "Sudah Bayar Bulan Ini")',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
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
