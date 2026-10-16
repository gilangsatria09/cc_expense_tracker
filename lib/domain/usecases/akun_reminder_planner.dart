import '../../core/utils/formatters.dart';
import '../entities/akun.dart';
import '../entities/reminder.dart';

class AkunReminderPlanner {
  const AkunReminderPlanner._();

  static const reminderHour = 9;

  static const monthsAhead = 6;

  static const idBase = 900000000;

  static List<Reminder> plan(List<Akun> akuns, DateTime now) {
    final reminders = <Reminder>[];

    for (final akun in akuns) {
      final hari = akun.tanggalJatuhTempo;
      if (akun.id == 0 || hari < 1 || hari > 31) continue;

      var bulan = DateTime(now.year, now.month);
      var kept = 0;
      var guard = 0;
      while (kept < monthsAhead && guard++ < 24) {
        final due = _dueIn(bulan, hari);
        final at = DateTime(due.year, due.month, due.day - 1, reminderHour);
        if (at.isAfter(now)) {
          reminders.add(
            Reminder(
              id: idBase + akun.id * 100 + kept,
              at: at,
              title: 'Tagihan jatuh tempo besok',
              body:
                  'Tagihan ${akun.nama} jatuh tempo besok (${formatDate(due)}). '
                  'Siapkan dananya',
            ),
          );
          kept++;
        }
        bulan = DateTime(bulan.year, bulan.month + 1);
      }
    }

    reminders.sort((a, b) => a.at.compareTo(b.at));
    return reminders;
  }

  static DateTime _dueIn(DateTime bulan, int hari) {
    final lastDay = DateTime(bulan.year, bulan.month + 1, 0).day;
    return DateTime(bulan.year, bulan.month, hari > lastDay ? lastDay : hari);
  }
}
