import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../domain/entities/import_summary.dart';
import '../bloc/backup_cubit.dart';
import '../bloc/import_cubit.dart';

class ImportPage extends StatelessWidget {
  const ImportPage({super.key});

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => ImportCubit(getIt(), getIt(), getIt())),
      BlocProvider(create: (_) => BackupCubit(getIt(), getIt())),
    ],
    child: const _ImportView(),
  );
}

class _ImportView extends StatelessWidget {
  const _ImportView();

  Future<void> _confirmReplace(BuildContext context) async {
    final cubit = context.read<ImportCubit>();
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Ganti semua data?'),
        content: const Text(
          'App sudah berisi data. Semua transaksi, split, cicilan, dan '
          'subscription yang ada akan DIHAPUS lalu diganti isi file. '
          'Buat backup dulu kalau data sekarang masih dibutuhkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus & import'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await cubit.confirmReplace();
    } else {
      cubit.cancelReplace();
    }
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<ImportCubit, ImportState>(
    listenWhen: (a, b) =>
        a.status != b.status && b.status == ImportStatus.needsConfirm,
    listener: (context, state) => _confirmReplace(context),
    builder: (context, state) {
      final busy = state.status == ImportStatus.working;
      final scheme = Theme.of(context).colorScheme;
      return Scaffold(
        appBar: AppBar(title: const Text('Backup & Import')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _BackupSection(),
            const Divider(height: 40),
            Text(
              'Import / Restore',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Pilih file .json: hasil backup di atas, atau hasil '
              'tool/xlsx_to_json.py dari sheet CC_Expense_Tracker.xlsx. '
              'Semua-atau-tidak-sama-sekali: kalau ada baris yang salah, '
              'tidak ada data yang masuk.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload_file),
              label: const Text('Pilih file JSON'),
              onPressed: busy
                  ? null
                  : context.read<ImportCubit>().pickAndImport,
            ),
            const SizedBox(height: 24),
            if (state.status == ImportStatus.success)
              _SuccessCard(
                summary: state.summary!,
                generatedBills: state.generatedBills,
              ),
            if (state.status == ImportStatus.failure)
              Card(
                color: scheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    state.message ?? 'Import gagal',
                    style: TextStyle(color: scheme.onErrorContainer),
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );
}

class _SuccessCard extends StatelessWidget {
  const _SuccessCard({required this.summary, required this.generatedBills});

  final ImportSummary summary;
  final int generatedBills;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Import berhasil',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text('${summary.akun} akun'),
          Text('${summary.transaksi} transaksi'),
          Text('${summary.split} peserta split'),
          Text('${summary.cicilan} cicilan'),
          Text('${summary.subscription} subscription'),
          if (generatedBills > 0)
            Text('+ $generatedBills tagihan subscription dibuat otomatis'),
        ],
      ),
    ),
  );
}

class _BackupSection extends StatelessWidget {
  const _BackupSection();

  @override
  Widget build(BuildContext context) => BlocBuilder<BackupCubit, BackupState>(
    builder: (context, state) {
      final busy = state.status == BackupStatus.working;
      final scheme = Theme.of(context).colorScheme;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Backup', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Simpan seluruh data (transaksi, split, cicilan, subscription, '
            'pengaturan) ke satu file .json. Simpan di tempat aman di luar '
            'app, misalnya Drive atau iCloud. Restore lewat Import di bawah.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            icon: busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download),
            label: const Text('Simpan backup'),
            onPressed: busy ? null : context.read<BackupCubit>().backup,
          ),
          if (state.status == BackupStatus.success)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Backup tersimpan: ${state.fileName}',
                style: TextStyle(color: scheme.primary),
              ),
            ),
          if (state.status == BackupStatus.failure)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                state.message ?? 'Backup gagal',
                style: TextStyle(color: scheme.error),
              ),
            ),
        ],
      );
    },
  );
}
