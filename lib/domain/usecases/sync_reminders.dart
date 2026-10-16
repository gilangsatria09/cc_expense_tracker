import '../repositories/akun_repository.dart';
import '../repositories/subscription_repository.dart';
import '../services/reminder_scheduler.dart';
import 'akun_reminder_planner.dart';
import 'subscription_reminder_planner.dart';

class SyncReminders {
  const SyncReminders(this._subscriptions, this._akuns, this._scheduler);

  final SubscriptionRepository _subscriptions;
  final AkunRepository _akuns;
  final ReminderScheduler _scheduler;

  static const maxTotal = 60;

  Future<void> call({DateTime? now}) async {
    final waktu = now ?? DateTime.now();
    final reminders = [
      ...SubscriptionReminderPlanner.plan(await _subscriptions.getAll(), waktu),
      ...AkunReminderPlanner.plan(await _akuns.getAll(), waktu),
    ]..sort((a, b) => a.at.compareTo(b.at));

    await _scheduler.replaceAll(reminders.take(maxTotal).toList());
  }
}
