import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../domain/entities/dashboard_summary.dart';
import '../../akun/pages/akun_list_page.dart';
import '../../common/widgets/akun_filter_chips.dart';
import '../../common/widgets/month_selector.dart';
import '../../import_data/pages/import_page.dart';
import '../bloc/dashboard_cubit.dart';
import '../widgets/dashboard_section.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<DashboardCubit>()..start(),
    child: const _DashboardView(),
  );
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<DashboardCubit, DashboardState>(
    builder: (context, state) {
      final cubit = context.read<DashboardCubit>();
      return Scaffold(
        appBar: AppBar(
          title: MonthSelector(month: state.month, onChanged: cubit.setMonth),
          actions: [
            IconButton(
              tooltip: 'Kelola akun',
              icon: const Icon(Icons.account_balance_wallet_outlined),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const AkunListPage()),
              ),
            ),
            IconButton(
              tooltip: 'Backup & import',
              icon: const Icon(Icons.settings_backup_restore),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const ImportPage()),
              ),
            ),
          ],
        ),
        body: switch (state.status) {
          DashboardStatus.loading => const Center(
            child: CircularProgressIndicator(),
          ),
          DashboardStatus.failure => const Center(
            child: Text('Gagal memuat dashboard'),
          ),
          DashboardStatus.success => Column(
            children: [
              AkunFilterChips(
                akuns: state.akuns,
                selected: state.akunFilter,
                onSelected: cubit.setAkunFilter,
              ),
              Expanded(child: _Content(summary: state.summary!)),
            ],
          ),
        },
      );
    },
  );
}

class _Content extends StatelessWidget {
  const _Content({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final s = summary;

    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        DashboardSection(
          title: '0. LIMIT PER AKUN (kumulatif)',
          action: IconButton(
            tooltip: 'Kelola akun',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const AkunListPage()),
            ),
          ),
          children: [
            for (final (i, limit) in s.akunLimits.indexed) ...[
              if (i > 0) const Divider(height: 24),
              _AkunLimitBlock(limit: limit),
            ],
            if (s.akunLimits.length > 1) ...[
              const Divider(height: 24),
              DashboardRow(
                label: 'TOTAL SEMUA AKUN: outstanding',
                value: s.totalOutstanding,
                bold: true,
              ),
              DashboardRow(
                label: 'TOTAL SEMUA AKUN: sisa limit',
                value: s.totalSisaLimit,
                bold: true,
                color: s.totalSisaLimit < 0
                    ? Theme.of(context).colorScheme.error
                    : null,
              ),
            ],
          ],
        ),
        DashboardSection(
          title: '1. TOTAL YANG PERLU DIBAYAR BULAN INI',
          children: [
            DashboardRow(
              label: 'Tagihan (Personal/Group/Sub/Lainnya, belum dibayar)',
              value: s.tagihanBulanIni,
            ),
            DashboardRow(label: 'Cicilan bulan ini', value: s.cicilanBulanIni),
            const Divider(),
            DashboardRow(
              label: 'TOTAL YANG PERLU DIBAYAR',
              value: s.totalPerluDibayar,
              bold: true,
            ),
          ],
        ),
        DashboardSection(
          title: '2. SUDAH DIBAYAR SEMENTARA',
          children: [
            DashboardRow(
              label: 'Tagihan yang sudah dibayar sementara',
              value: s.dibayarSementara,
            ),
          ],
        ),
        DashboardSection(
          title: '3. BREAKDOWN PER JENIS (di luar cicilan)',
          children: [
            DashboardRow(label: 'Personal (belum lunas)', value: s.personal),
            DashboardRow(
              label: 'Group Order (total dibayar duluan)',
              value: s.groupOrder,
            ),
            DashboardRow(label: 'Subscription', value: s.subscription),
            DashboardRow(label: 'Pembayaran tagihan', value: s.pembayaran),
            DashboardRow(label: 'Lainnya', value: s.lainnya),
          ],
        ),
        DashboardSection(
          title: '4. BEBAN SENDIRI vs PIUTANG TEMAN',
          children: [
            DashboardRow(
              label: 'Net beban sendiri (bagian saya)',
              value: s.bebanSendiri,
            ),
            DashboardRow(
              label: 'Total piutang ke teman (Group Order)',
              value: s.piutangTotal,
            ),
            DashboardRow(
              label: 'Sudah dibayar (Paid)',
              value: s.piutangPaid,
              indent: true,
            ),
            DashboardRow(
              label: 'Paid Temp (masuk pocket, belum settle)',
              value: s.piutangPaidTemp,
              indent: true,
            ),
            DashboardRow(
              label: 'Belum dibayar',
              value: s.piutangBelumDibayar,
              indent: true,
            ),
          ],
        ),
        DashboardSection(
          title: '5. PERKIRAAN DISIAPKAN AWAL BULAN DEPAN',
          children: [
            DashboardRow(
              label: 'Perlu dibayar + dibayar sementara − piutang Paid',
              value: s.perkiraanBulanDepan,
              bold: true,
            ),
          ],
        ),
      ],
    );
  }
}

class _AkunLimitBlock extends StatelessWidget {
  const _AkunLimitBlock({required this.limit});

  final AkunLimit limit;

  @override
  Widget build(BuildContext context) {
    final a = limit.akun;
    final scheme = Theme.of(context).colorScheme;
    final persen = limit.persentaseLimitTerpakai;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          a.nama,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        DashboardRow(label: 'Limit', value: a.limitKredit),
        DashboardRow(
          label: 'Saldo outstanding sebelum tracker',
          value: a.saldoAwal,
        ),
        DashboardRow(
          label: 'Total transaksi baru (non-cicilan)',
          value: limit.totalTransaksiBaru,
        ),
        DashboardRow(
          label: 'Total harga cicilan (sekali kena limit)',
          value: limit.totalHargaCicilan,
        ),
        DashboardRow(
          label: 'Total pembayaran tagihan',
          value: limit.totalPembayaran,
        ),
        const Divider(),
        DashboardRow(
          label: 'Outstanding balance',
          value: limit.outstanding,
          bold: true,
        ),
        DashboardRow(
          label: 'Sisa limit / bisa dipakai',
          value: limit.sisaLimit,
          bold: true,
          color: limit.sisaLimit < 0 ? scheme.error : null,
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: persen.clamp(0.0, 1.0),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
          color: persen >= 0.9 ? scheme.error : null,
        ),
        const SizedBox(height: 4),
        Text(
          a.limitKredit <= 0
              ? 'Limit belum diisi'
              : '${(persen * 100).toStringAsFixed(1)}% limit terpakai',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
