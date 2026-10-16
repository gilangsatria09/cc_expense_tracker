import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/subscription.dart';
import '../../common/widgets/badge_chip.dart';
import '../../common/widgets/akun_dropdown.dart';
import '../../common/widgets/rupiah_field.dart';
import '../bloc/subscription_form_cubit.dart';

class SubscriptionFormPage extends StatelessWidget {
  const SubscriptionFormPage({super.key, this.initial});

  final Subscription? initial;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        SubscriptionFormCubit(getIt(), getIt(), getIt(), initial: initial)
          ..load(),
    child: const _SubscriptionFormView(),
  );
}

class _SubscriptionFormView extends StatelessWidget {
  const _SubscriptionFormView();

  Future<void> _pickDate(
    BuildContext context,
    SubscriptionFormCubit cubit,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: cubit.state.draft.tanggalTagihanBerikutnya,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) cubit.setTanggal(picked);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    SubscriptionFormCubit cubit,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus subscription?'),
        content: const Text(
          'Transaksi yang sudah tercatat tetap ada, hanya tidak tertaut lagi.',
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
    final cubit = context.read<SubscriptionFormCubit>();
    final initial = cubit.state.draft;

    return BlocConsumer<SubscriptionFormCubit, SubscriptionFormState>(
      listenWhen: (a, b) => a.result != b.result || a.error != b.error,
      listener: (context, state) {
        if (state.result != null) {
          Navigator.of(context).pop(state.result);
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
            title: Text(
              state.isEdit ? 'Edit Subscription' : 'Subscription Baru',
            ),
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
                initialValue: initial.namaLayanan,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Nama layanan'),
                onChanged: cubit.setNama,
              ),
              const SizedBox(height: 16),
              AkunDropdown(
                akuns: state.akuns,
                value: d.akunId,
                label: 'Akun yang ditagih',
                onChanged: cubit.setAkun,
              ),
              const SizedBox(height: 16),
              RupiahField(
                label: 'Harga tetap',
                initialValue: initial.hargaTetap,
                hint: 'Kosongkan kalau harga berubah-ubah',
                onChanged: cubit.setHarga,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  d.autoGenerate
                      ? 'Transaksi dibuat otomatis tiap jatuh tempo'
                      : 'Hanya reminder; transaksi diinput manual',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 16),
              SegmentedButton<SiklusBilling>(
                segments: [
                  for (final s in SiklusBilling.values)
                    ButtonSegment(value: s, label: Text(s.label)),
                ],
                selected: {d.siklusBilling},
                onSelectionChanged: (s) => cubit.setSiklus(s.first),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _pickDate(context, cubit),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tanggal tagihan berikutnya',
                    suffixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(formatDate(d.tanggalTagihanBerikutnya)),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<StatusSubscription>(
                initialValue: d.status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: [
                  for (final s in StatusSubscription.values)
                    DropdownMenuItem(value: s, child: Text(s.label)),
                ],
                onChanged: (v) {
                  if (v != null) cubit.setStatus(v);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: initial.catatan ?? '',
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
}
