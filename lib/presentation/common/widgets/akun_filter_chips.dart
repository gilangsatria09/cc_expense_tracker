import 'package:flutter/material.dart';

import '../../../domain/entities/akun.dart';

class AkunFilterChips extends StatelessWidget {
  const AkunFilterChips({
    super.key,
    required this.akuns,
    required this.selected,
    required this.onSelected,
  });

  final List<Akun> akuns;

  final int? selected;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) {
    if (akuns.length < 2) return const SizedBox.shrink();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('Semua'),
            selected: selected == null,
            onSelected: (_) => onSelected(null),
          ),
          for (final a in akuns) ...[
            const SizedBox(width: 8),
            ChoiceChip(
              label: Text(a.nama),
              selected: selected == a.id,
              onSelected: (_) => onSelected(a.id),
            ),
          ],
        ],
      ),
    );
  }
}
