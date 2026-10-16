import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/utils/formatters.dart';
import '../../common/widgets/badge_chip.dart';
import '../bloc/subscription_detail_cubit.dart';
import '../bloc/subscription_form_cubit.dart';
import 'subscription_form_page.dart';

class SubscriptionDetailPage extends StatelessWidget {
  const SubscriptionDetailPage({super.key, required this.subscriptionId});

  final int subscriptionId;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        SubscriptionDetailCubit(getIt(), getIt(), subscriptionId)..load(),
    child: const _DetailView(),
  );
}

class _DetailView extends StatelessWidget {
  const _DetailView();

  Future<void> _edit(BuildContext context) async {
    final cubit = context.read<SubscriptionDetailCubit>();
    final subscription = cubit.state.subscription;
    if (subscription == null) return;
    final result = await Navigator.of(context).push<SubscriptionFormResult>(
      MaterialPageRoute(
        builder: (_) => SubscriptionFormPage(initial: subscription),
      ),
    );
    if (!context.mounted) return;
    if (result?.deleted == true) {
      Navigator.of(context).pop();
    } else {
      await cubit.load();
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<SubscriptionDetailCubit, SubscriptionDetailState>(
    builder: (context, state) {
      final s = state.subscription;
      final textTheme = Theme.of(context).textTheme;
      return Scaffold(
        appBar: AppBar(
          title: Text(s?.namaLayanan ?? 'Subscription'),
          actions: [
            if (s != null)
              IconButton(
                tooltip: 'Edit',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _edit(context),
              ),
          ],
        ),
        body: state.loading
            ? const Center(child: CircularProgressIndicator())
            : s == null
            ? const Center(child: Text('Subscription tidak ditemukan'))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Wrap(
                    spacing: 6,
                    children: [
                      BadgeChip(label: s.status.label, color: s.status.color),
                      BadgeChip(
                        label: s.siklusBilling.label,
                        color: Colors.indigo,
                      ),
                      BadgeChip(
                        label: s.autoGenerate ? 'Auto-generate' : 'Manual',
                        color: s.autoGenerate ? Colors.teal : Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    s.hargaTetap == null
                        ? 'Harga variable'
                        : formatRupiah(s.hargaTetap!),
                    style: textTheme.headlineSmall,
                  ),
                  Text(
                    'Tagihan berikutnya ${formatDate(s.tagihanBerikutnya(DateTime.now()))}',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tercatat bulan ini ${formatRupiah(state.totalTercatat(DateTime.now()))}',
                    style: textTheme.titleMedium,
                  ),
                  if (s.catatan != null) ...[
                    const SizedBox(height: 8),
                    Text(s.catatan!, style: textTheme.bodySmall),
                  ],
                  const Divider(height: 32),
                  Text('Riwayat transaksi', style: textTheme.titleSmall),
                  if (state.transaksis.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('Belum ada transaksi'),
                    ),
                  for (final t in state.transaksis)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(t.deskripsi),
                      subtitle: Text(formatDate(t.tanggal)),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(formatRupiah(t.totalTagihan)),
                          Text(
                            t.status.label,
                            style: textTheme.labelSmall?.copyWith(
                              color: t.status.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
      );
    },
  );
}
