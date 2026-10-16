import 'package:flutter/material.dart';

import '../../../core/utils/date_utils.dart';
import '../../../core/utils/formatters.dart';

class MonthSelector extends StatelessWidget {
  const MonthSelector({
    super.key,
    required this.month,
    required this.onChanged,
  });

  final DateTime month;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        tooltip: 'Bulan sebelumnya',
        icon: const Icon(Icons.chevron_left),
        onPressed: () => onChanged(addMonths(month, -1)),
      ),
      Text(formatMonthYear(month)),
      IconButton(
        tooltip: 'Bulan berikutnya',
        icon: const Icon(Icons.chevron_right),
        onPressed: () => onChanged(addMonths(month, 1)),
      ),
    ],
  );
}
