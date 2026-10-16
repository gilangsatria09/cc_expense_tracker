import 'package:flutter/material.dart';

import '../../../core/utils/formatters.dart';
import '../../../domain/entities/cicilan.dart';
import '../../common/widgets/badge_chip.dart';

class CicilanCard extends StatelessWidget {
  const CicilanCard({
    super.key,
    required this.cicilan,
    required this.now,
    required this.onTap,
    required this.onPay,
    this.akunNama,
  });

  final Cicilan cicilan;
  final DateTime now;
  final VoidCallback onTap;
  final VoidCallback onPay;

  final String? akunNama;

  @override
  Widget build(BuildContext context) {
    final c = cicilan;
    final textTheme = Theme.of(context).textTheme;
    final progress = c.tenor == 0
        ? 0.0
        : (c.cicilanKe / c.tenor).clamp(0.0, 1.0);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(c.namaCicilan, style: textTheme.titleMedium),
                  ),
                  if (c.lunas)
                    const BadgeChip(label: 'Lunas', color: Colors.green),
                ],
              ),
              if (akunNama != null) Text(akunNama!, style: textTheme.bodySmall),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Text(
                '${c.cicilanKe} dari ${c.tenor} cicilan terbayar · '
                '${formatRupiah(c.jumlahPerBulan)}/bulan',
                style: textTheme.bodyMedium,
              ),
              Text(
                'Sisa ${formatRupiah(c.sisaCicilan)}',
                style: textTheme.bodySmall,
              ),
              if (!c.lunas) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.tonal(
                    onPressed: c.bisaBayar(now) ? onPay : null,
                    child: Text(
                      c.sudahBayarBulanIni(now)
                          ? 'Sudah dibayar bulan ini'
                          : 'Sudah Bayar Bulan Ini',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
