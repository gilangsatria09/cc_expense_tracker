import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RupiahField extends StatelessWidget {
  const RupiahField({
    super.key,
    required this.label,
    required this.onChanged,
    this.initialValue,
    this.hint,
    this.prefix = 'Rp ',
  });

  final String label;
  final int? initialValue;
  final String? hint;
  final String? prefix;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) => TextFormField(
    initialValue: initialValue == null || initialValue == 0
        ? ''
        : '$initialValue',
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    decoration: InputDecoration(
      labelText: label,
      prefixText: prefix,
      hintText: hint,
    ),
    onChanged: (v) => onChanged(int.tryParse(v)),
  );
}
