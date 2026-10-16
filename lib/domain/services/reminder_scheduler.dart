import '../entities/reminder.dart';

abstract interface class ReminderScheduler {
  Future<void> replaceAll(List<Reminder> reminders);
}
