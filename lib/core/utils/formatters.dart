import 'package:intl/intl.dart';

const _locale = 'id_ID';

final _rupiah = NumberFormat.currency(
  locale: _locale,
  symbol: 'Rp ',
  decimalDigits: 0,
);

String formatRupiah(int value) => _rupiah.format(value);

String formatMonthYear(DateTime d) =>
    DateFormat('MMMM yyyy', _locale).format(d);

String formatDateHeader(DateTime d) =>
    DateFormat('EEEE, d MMMM yyyy', _locale).format(d);

String formatDate(DateTime d) => DateFormat('d MMM yyyy', _locale).format(d);
