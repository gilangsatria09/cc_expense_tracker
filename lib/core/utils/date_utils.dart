DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime monthOf(DateTime d) => DateTime(d.year, d.month);

DateTime bulanTagihanFor(DateTime tanggal, int cutoffDay) =>
    cutoffDay > 0 && tanggal.day <= cutoffDay
    ? DateTime(tanggal.year, tanggal.month - 1)
    : monthOf(tanggal);

bool isSameMonth(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month;

DateTime addMonths(DateTime d, int months, {int? day}) {
  final anchor = day ?? d.day;
  final total = d.year * 12 + (d.month - 1) + months;
  final year = total ~/ 12;
  final month = total % 12 + 1;
  final lastDay = DateTime(year, month + 1, 0).day;
  return DateTime(year, month, anchor > lastDay ? lastDay : anchor);
}
