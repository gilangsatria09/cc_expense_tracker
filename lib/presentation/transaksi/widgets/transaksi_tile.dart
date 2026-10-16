import 'package:flutter/material.dart';

import '../../../core/utils/date_utils.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/transaksi.dart';
import '../../common/widgets/badge_chip.dart';

class TransaksiTile extends StatelessWidget {
  const TransaksiTile({
    super.key,
    required this.transaksi,
    required this.onTap,
    this.onLongPress,
    this.akunNama,
    this.selectionMode = false,
    this.selected = false,
  });

  final Transaksi transaksi;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  final String? akunNama;

  final bool selectionMode;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final t = transaksi;
    final textTheme = Theme.of(context).textTheme;
    final showSplit = t.isGroupOrder && t.splits.isNotEmpty;

    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: selected ? scheme.secondaryContainer : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (selectionMode)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    selected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    semanticLabel: selected ? 'Dipilih' : 'Belum dipilih',
                    color: selected ? scheme.primary : scheme.outline,
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.deskripsi,
                      style: textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        BadgeChip(label: t.jenis.label, color: t.jenis.color),
                        BadgeChip(label: t.status.label, color: t.status.color),
                      ],
                    ),
                    if (!isSameMonth(t.effectiveBulan, t.tanggal)) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Masuk tagihan ${formatMonthYear(t.effectiveBulan)}',
                        style: textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ],
                    if (showSplit) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Bagianmu ${formatRupiah(t.bagianSaya)} · '
                        'Teman ${formatRupiah(t.ditagihKeTeman)}',
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatRupiah(t.totalTagihan),
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (akunNama != null)
                    Text(akunNama!, style: textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
