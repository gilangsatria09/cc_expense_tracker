import 'package:flutter/material.dart';

import '../../../domain/entities/akun.dart';

class AkunDropdown extends StatelessWidget {
  const AkunDropdown({
    super.key,
    required this.akuns,
    required this.value,
    required this.onChanged,
    this.label = 'Akun',
  });

  final List<Akun> akuns;

  final int value;
  final ValueChanged<int> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    final selected = akuns.any((a) => a.id == value) ? value : null;
    return DropdownButtonFormField<int>(
      key: ValueKey('akun-$selected-${akuns.length}'),
      initialValue: selected,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final a in akuns)
          DropdownMenuItem(value: a.id, child: Text(a.nama)),
      ],
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
