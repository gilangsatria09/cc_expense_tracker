import '../../core/utils/date_utils.dart';
import '../../core/utils/formatters.dart';
import '../entities/enums.dart';
import '../entities/subscription.dart';
import '../entities/reminder.dart';

class SubscriptionReminderPlanner {
  const SubscriptionReminderPlanner._();

  static const reminderHour = 9;

  static const maxTotal = 60;

  static int cyclesAhead(SiklusBilling siklus) =>
      siklus == SiklusBilling.bulanan ? 6 : 2;

  static List<Reminder> plan(List<Subscription> subscriptions, DateTime now) {
    final reminders = <Reminder>[];

    for (final sub in subscriptions) {
      if (sub.status != StatusSubscription.aktif || sub.id == 0) continue;

      var due = dateOnly(sub.tanggalTagihanBerikutnya);
      final limit = cyclesAhead(sub.siklusBilling);
      var kept = 0;
      var guard = 0;
      while (kept < limit && guard++ < 1200) {
        final at = DateTime(due.year, due.month, due.day - 1, reminderHour);
        if (at.isAfter(now)) {
          reminders.add(
            Reminder(
              id: sub.id * 100 + kept,
              at: at,
              title: 'Tagihan subscription besok',
              body: _body(sub, due),
            ),
          );
          kept++;
        }
        due = sub.nextBillingAfter(due);
      }
    }

    reminders.sort((a, b) => a.at.compareTo(b.at));
    return reminders.take(maxTotal).toList();
  }

  static String _body(Subscription sub, DateTime due) {
    final harga = sub.hargaTetap;
    final tanggal = formatDate(due);
    return harga == null
        ? '${sub.namaLayanan} ditagih besok ($tanggal), nominal bisa berbeda'
        : '${sub.namaLayanan} ${formatRupiah(harga)} ditagih besok ($tanggal)';
  }
}
