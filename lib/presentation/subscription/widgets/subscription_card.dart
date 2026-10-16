import 'package:flutter/material.dart';

import '../../../core/utils/formatters.dart';
import '../../../domain/entities/subscription.dart';
import '../../common/widgets/badge_chip.dart';

class SubscriptionCard extends StatelessWidget {
  const SubscriptionCard({
    super.key,
    required this.subscription,
    required this.onTap,
    this.akunNama,
  });

  final Subscription subscription;
  final VoidCallback onTap;

  final String? akunNama;

  @override
  Widget build(BuildContext context) {
    final s = subscription;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.namaLayanan, style: textTheme.titleMedium),
                    if (akunNama != null)
                      Text(akunNama!, style: textTheme.bodySmall),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        BadgeChip(label: s.status.label, color: s.status.color),
                        BadgeChip(
                          label: s.autoGenerate ? 'Auto' : 'Manual',
                          color: s.autoGenerate ? Colors.teal : Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tagihan berikutnya ${formatDate(s.tagihanBerikutnya(DateTime.now()))}',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    s.hargaTetap == null
                        ? 'Variable'
                        : formatRupiah(s.hargaTetap!),
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(s.siklusBilling.label, style: textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
