import 'package:flutter/material.dart';

import '../../../domain/entities/enums.dart';
import '../../common/widgets/badge_chip.dart';

class StatusFilterChips extends StatelessWidget {
  const StatusFilterChips({
    super.key,
    required this.counts,
    required this.selected,
    required this.onSelected,
  });

  final Map<StatusBayar, int> counts;

  final StatusBayar? selected;
  final ValueChanged<StatusBayar?> onSelected;

  static const _urutan = [
    StatusBayar.belumDibayar,
    StatusBayar.paidTemp,
    StatusBayar.paid,
  ];

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: Wrap(
      spacing: 8,
      children: [
        ChoiceChip(
          label: const Text('Semua status'),
          selected: selected == null,
          onSelected: (_) => onSelected(null),
        ),
        for (final status in _urutan)
          ChoiceChip(
            avatar: Icon(Icons.circle, size: 10, color: status.color),
            label: Text('${status.label} (${counts[status] ?? 0})'),
            selected: selected == status,
            onSelected: (_) => onSelected(status),
          ),
      ],
    ),
  );
}
