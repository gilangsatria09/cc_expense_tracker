import 'package:cc_expense_tracker/core/services/reminder_sync_runner.dart';
import 'package:cc_expense_tracker/data/database/app_database.dart';
import 'package:cc_expense_tracker/data/repositories/akun_repository_impl.dart';
import 'package:cc_expense_tracker/data/repositories/subscription_repository_impl.dart';
import 'package:cc_expense_tracker/domain/entities/enums.dart';
import 'package:cc_expense_tracker/domain/entities/subscription.dart';
import 'package:cc_expense_tracker/domain/entities/reminder.dart';
import 'package:cc_expense_tracker/domain/services/reminder_scheduler.dart';
import 'package:cc_expense_tracker/domain/usecases/subscription_reminder_planner.dart';
import 'package:cc_expense_tracker/domain/usecases/sync_reminders.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

Subscription sub({
  int id = 1,
  String nama = 'Netflix',
  int? harga = 54000,
  SiklusBilling siklus = SiklusBilling.bulanan,
  required DateTime next,
  StatusSubscription status = StatusSubscription.aktif,
  int? hari,
}) => Subscription(
  id: id,
  namaLayanan: nama,
  akunId: 1,
  hargaTetap: harga,
  siklusBilling: siklus,
  tanggalTagihanBerikutnya: next,
  hariTagihan: hari,
  status: status,
);

class FakeScheduler implements ReminderScheduler {
  final calls = <List<Reminder>>[];

  @override
  Future<void> replaceAll(List<Reminder> reminders) async =>
      calls.add(reminders);
}

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));

  final now = DateTime(2026, 9, 26, 10);

  group('SubscriptionReminderPlanner', () {
    test('H-1 jam 09.00, isi pesan harga tetap', () {
      final r = SubscriptionReminderPlanner.plan([
        sub(next: DateTime(2026, 10, 3)),
      ], now).first;

      expect(r.at, DateTime(2026, 10, 2, 9));
      expect(r.title, 'Tagihan subscription besok');
      expect(r.body, contains('Netflix'));
      expect(r.body, contains('54.000'));
      expect(r.body, contains('3 Okt 2026'));
    });

    test('harga variable: pesan tanpa nominal', () {
      final r = SubscriptionReminderPlanner.plan([
        sub(nama: 'Getcontact', harga: null, next: DateTime(2026, 10, 19)),
      ], now).first;
      expect(r.body, contains('Getcontact'));
      expect(r.body, isNot(contains('Rp')));
      expect(r.body, contains('nominal bisa berbeda'));
    });

    test('pengingat yang waktunya sudah lewat dilewati', () {
      final r = SubscriptionReminderPlanner.plan([
        sub(next: DateTime(2026, 9, 27)),
      ], now);
      expect(r.first.at, DateTime(2026, 10, 26, 9));
    });

    test('tagihan tanggal 1: pengingat jatuh di akhir bulan sebelumnya', () {
      final r = SubscriptionReminderPlanner.plan([
        sub(next: DateTime(2026, 11, 1)),
      ], now).first;
      expect(r.at, DateTime(2026, 10, 31, 9));
    });

    test('bulanan 6 siklus ke depan; tahunan 2', () {
      final monthly = SubscriptionReminderPlanner.plan([
        sub(next: DateTime(2026, 10, 3)),
      ], now);
      expect(monthly, hasLength(6));
      expect(monthly.last.at, DateTime(2027, 3, 2, 9));

      final yearly = SubscriptionReminderPlanner.plan([
        sub(siklus: SiklusBilling.tahunan, next: DateTime(2027, 1, 15)),
      ], now);
      expect(yearly.map((r) => r.at), [
        DateTime(2027, 1, 14, 9),
        DateTime(2028, 1, 14, 9),
      ]);
    });

    test('hari jangkar 31: mengikuti akhir bulan pendek', () {
      final r = SubscriptionReminderPlanner.plan([
        sub(next: DateTime(2027, 1, 31), hari: 31),
      ], DateTime(2027, 1, 1));
      expect(r.take(3).map((x) => x.at), [
        DateTime(2027, 1, 30, 9),
        DateTime(2027, 2, 27, 9),
        DateTime(2027, 3, 30, 9),
      ]);
    });

    test('harga variable dengan tanggal tersimpan yang sudah lama lewat', () {
      final r = SubscriptionReminderPlanner.plan([
        sub(harga: null, next: DateTime(2026, 3, 19)),
      ], now);
      expect(r.first.at, DateTime(2026, 10, 18, 9));
      expect(r, hasLength(6));
    });

    test('hanya subscription Aktif yang punya pengingat', () {
      final r = SubscriptionReminderPlanner.plan([
        sub(id: 1, next: DateTime(2026, 10, 3)),
        sub(
          id: 2,
          next: DateTime(2026, 10, 3),
          status: StatusSubscription.nonaktif,
        ),
        sub(
          id: 3,
          next: DateTime(2026, 10, 3),
          status: StatusSubscription.dibatalkan,
        ),
        sub(id: 0, next: DateTime(2026, 10, 3)),
      ], now);
      expect(r.map((x) => (x.id ~/ 100)).toSet(), {1});
    });

    test('ID stabil per subscription + urutan siklus, unik', () {
      final r = SubscriptionReminderPlanner.plan([
        sub(id: 7, next: DateTime(2026, 10, 3)),
        sub(id: 8, next: DateTime(2026, 10, 5)),
      ], now);
      expect(r.map((x) => x.id).toSet().length, r.length);
      expect(r.where((x) => (x.id ~/ 100) == 7).map((x) => x.id), [
        700,
        701,
        702,
        703,
        704,
        705,
      ]);
    });

    test('dibatasi 60 terdekat, terurut waktu', () {
      final many = [
        for (var i = 1; i <= 12; i++)
          sub(id: i, nama: 'S$i', next: DateTime(2026, 10, 3)),
      ];
      final r = SubscriptionReminderPlanner.plan(many, now);
      expect(r, hasLength(SubscriptionReminderPlanner.maxTotal));
      for (var i = 1; i < r.length; i++) {
        expect(r[i].at.isBefore(r[i - 1].at), isFalse);
      }
    });
  });

  group('Subscription.tagihanBerikutnya (untuk tampilan)', () {
    test('harga tetap: tanggal tersimpan apa adanya', () {
      expect(
        sub(next: DateTime(2026, 10, 3)).tagihanBerikutnya(now),
        DateTime(2026, 10, 3),
      );
    });

    test('harga variable: dimajukan ke siklus terdekat yang belum lewat', () {
      final s = sub(harga: null, next: DateTime(2026, 7, 19));
      expect(s.tagihanBerikutnya(now), DateTime(2026, 10, 19));
      expect(
        sub(harga: null, next: DateTime(2026, 9, 26)).tagihanBerikutnya(now),
        DateTime(2026, 9, 26),
      );
    });
  });

  group('SyncReminders & ReminderSyncRunner', () {
    late AppDatabase db;
    late SubscriptionRepositoryImpl repo;
    late AkunRepositoryImpl akunRepo;
    late FakeScheduler scheduler;

    setUp(() {
      db = AppDatabase.inMemory();
      repo = SubscriptionRepositoryImpl(db);
      akunRepo = AkunRepositoryImpl(db);
      scheduler = FakeScheduler();
    });
    tearDown(() => db.close());

    Future<void> settle() =>
        Future<void>.delayed(const Duration(milliseconds: 150));

    test('usecase menjadwalkan hasil planner dari data di database', () async {
      await repo.save(sub(id: 0, next: DateTime(2026, 10, 3)));
      await repo.save(
        sub(
          id: 0,
          nama: 'Yellow',
          next: DateTime(2026, 10, 1),
          status: StatusSubscription.dibatalkan,
        ),
      );

      await SyncReminders(repo, akunRepo, scheduler)(now: now);

      expect(scheduler.calls, hasLength(1));
      expect(scheduler.calls.single, hasLength(6));
      expect(scheduler.calls.single.first.body, contains('Netflix'));
    });

    test('tanpa subscription: jadwal dikosongkan', () async {
      await SyncReminders(repo, akunRepo, scheduler)(now: now);
      expect(scheduler.calls.single, isEmpty);
    });

    test('runner: sinkron awal, lalu tiap data berubah', () async {
      final runner = ReminderSyncRunner(
        repo,
        akunRepo,
        SyncReminders(repo, akunRepo, scheduler),
        debounce: const Duration(milliseconds: 20),
      )..start();
      addTearDown(runner.stop);

      await settle();
      expect(scheduler.calls, hasLength(1));
      expect(scheduler.calls.last, isEmpty);

      final id = await repo.save(sub(id: 0, next: DateTime(2035, 1, 3)));
      await settle();
      expect(scheduler.calls.last, isNotEmpty);
      expect(scheduler.calls.last.first.id ~/ 100, id);

      final saved = (await repo.getById(id))!;
      await repo.save(saved.copyWith(status: StatusSubscription.nonaktif));
      await settle();
      expect(scheduler.calls.last, isEmpty);

      await repo.save(saved.copyWith(status: StatusSubscription.aktif));
      await settle();
      expect(scheduler.calls.last, isNotEmpty);
      await repo.delete(id);
      await settle();
      expect(scheduler.calls.last, isEmpty);
    });

    test(
      'runner: rangkaian perubahan cepat digabung jadi satu sinkron',
      () async {
        final runner = ReminderSyncRunner(
          repo,
          akunRepo,
          SyncReminders(repo, akunRepo, scheduler),
          debounce: const Duration(milliseconds: 100),
        )..start();
        addTearDown(runner.stop);
        await settle();
        scheduler.calls.clear();

        for (var i = 0; i < 5; i++) {
          await repo.save(sub(id: 0, nama: 'S$i', next: DateTime(2035, 1, 3)));
        }
        await Future<void>.delayed(const Duration(milliseconds: 400));

        expect(scheduler.calls, hasLength(1));
        expect(
          scheduler.calls.single.map((r) => (r.id ~/ 100)).toSet(),
          hasLength(5),
        );
      },
    );

    test(
      'runner: kegagalan scheduler tidak menghentikan sinkron berikutnya',
      () async {
        final failing = _FlakyScheduler();
        final runner = ReminderSyncRunner(
          repo,
          akunRepo,
          SyncReminders(repo, akunRepo, failing),
          debounce: const Duration(milliseconds: 20),
        )..start();
        addTearDown(runner.stop);
        await settle();

        await repo.save(sub(id: 0, next: DateTime(2035, 1, 3)));
        await settle();
        expect(failing.successes, 1);
      },
    );
  });
}

class _FlakyScheduler implements ReminderScheduler {
  int attempts = 0;
  int successes = 0;

  @override
  Future<void> replaceAll(List<Reminder> reminders) async {
    attempts++;
    if (attempts == 1) throw StateError('izin ditolak');
    successes++;
  }
}
