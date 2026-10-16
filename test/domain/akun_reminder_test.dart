import 'package:cc_expense_tracker/core/services/reminder_sync_runner.dart';
import 'package:cc_expense_tracker/data/database/app_database.dart';
import 'package:cc_expense_tracker/data/repositories/akun_repository_impl.dart';
import 'package:cc_expense_tracker/data/repositories/subscription_repository_impl.dart';
import 'package:cc_expense_tracker/domain/entities/akun.dart';
import 'package:cc_expense_tracker/domain/entities/enums.dart';
import 'package:cc_expense_tracker/domain/entities/reminder.dart';
import 'package:cc_expense_tracker/domain/entities/subscription.dart';
import 'package:cc_expense_tracker/domain/services/reminder_scheduler.dart';
import 'package:cc_expense_tracker/domain/usecases/akun_reminder_planner.dart';
import 'package:cc_expense_tracker/domain/usecases/save_akun.dart';
import 'package:cc_expense_tracker/domain/usecases/sync_reminders.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

class FakeScheduler implements ReminderScheduler {
  final calls = <List<Reminder>>[];

  @override
  Future<void> replaceAll(List<Reminder> reminders) async =>
      calls.add(reminders);
}

Akun akun({int id = 1, String nama = 'SPayLater', int jatuhTempo = 25}) =>
    Akun(id: id, nama: nama, tanggalJatuhTempo: jatuhTempo);

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));

  final now = DateTime(2026, 9, 26, 10);

  group('AkunReminderPlanner', () {
    test(
      'H-1 jam 09.00 sebelum tanggal jatuh tempo; isi menyebut akun & tanggal',
      () {
        final r = AkunReminderPlanner.plan([akun(jatuhTempo: 5)], now).first;
        expect(r.at, DateTime(2026, 10, 4, 9));
        expect(r.title, 'Tagihan jatuh tempo besok');
        expect(r.body, contains('SPayLater'));
        expect(r.body, contains('5 Okt 2026'));
      },
    );

    test(
      'bulan berjalan: pengingat yang sudah lewat dilewati, bulan depan dipakai',
      () {
        final r = AkunReminderPlanner.plan([akun(jatuhTempo: 25)], now);
        expect(r.first.at, DateTime(2026, 10, 24, 9));
        expect(
          AkunReminderPlanner.plan([akun(jatuhTempo: 28)], now).first.at,
          DateTime(2026, 9, 27, 9),
        );
      },
    );

    test('tanggal 1: pengingat jatuh di akhir bulan sebelumnya', () {
      final r = AkunReminderPlanner.plan([akun(jatuhTempo: 1)], now).first;
      expect(r.at, DateTime(2026, 9, 30, 9));
    });

    test('tanggal 31 dipotong ke akhir bulan pendek; 6 bulan ke depan', () {
      final r = AkunReminderPlanner.plan([
        akun(jatuhTempo: 31),
      ], DateTime(2027, 1, 1));
      expect(r, hasLength(AkunReminderPlanner.monthsAhead));
      expect(r.take(3).map((x) => x.at), [
        DateTime(2027, 1, 30, 9),
        DateTime(2027, 2, 27, 9),
        DateTime(2027, 3, 30, 9),
      ]);
    });

    test(
      'tanggal jatuh tempo 0 (atau akun belum tersimpan): tanpa pengingat',
      () {
        expect(AkunReminderPlanner.plan([akun(jatuhTempo: 0)], now), isEmpty);
        expect(AkunReminderPlanner.plan([akun(id: 0)], now), isEmpty);
      },
    );

    test(
      'beberapa akun: terurut waktu; ID unik dan terpisah dari ID subscription',
      () {
        final r = AkunReminderPlanner.plan([
          akun(id: 1, nama: 'A', jatuhTempo: 30),
          akun(id: 2, nama: 'B', jatuhTempo: 28),
        ], now);
        for (var i = 1; i < r.length; i++) {
          expect(r[i].at.isBefore(r[i - 1].at), isFalse);
        }
        expect(r.map((x) => x.id).toSet().length, r.length);
        expect(r.every((x) => x.id >= AkunReminderPlanner.idBase), isTrue);
        expect(r.first.body, contains('B'));
      },
    );
  });

  group('SyncReminders & runner dengan database', () {
    late AppDatabase db;
    late AkunRepositoryImpl akunRepo;
    late SubscriptionRepositoryImpl subRepo;
    late FakeScheduler scheduler;

    setUp(() {
      db = AppDatabase.inMemory();
      akunRepo = AkunRepositoryImpl(db);
      subRepo = SubscriptionRepositoryImpl(db);
      scheduler = FakeScheduler();
    });
    tearDown(() => db.close());

    Future<void> settle() =>
        Future<void>.delayed(const Duration(milliseconds: 150));

    test(
      'menggabungkan pengingat subscription dan akun, terurut, tanpa ID bentrok',
      () async {
        await akunRepo.save(akun(id: 0, jatuhTempo: 28));
        await subRepo.save(
          Subscription(
            namaLayanan: 'Netflix',
            akunId: 1,
            hargaTetap: 54000,
            siklusBilling: SiklusBilling.bulanan,
            tanggalTagihanBerikutnya: DateTime(2026, 10, 3),
          ),
        );

        await SyncReminders(subRepo, akunRepo, scheduler)(now: now);

        final r = scheduler.calls.single;
        expect(r.any((x) => x.body.contains('Netflix')), isTrue);
        expect(r.any((x) => x.body.contains('SPayLater')), isTrue);
        expect(r.map((x) => x.id).toSet().length, r.length);
        for (var i = 1; i < r.length; i++) {
          expect(r[i].at.isBefore(r[i - 1].at), isFalse);
        }
        expect(r.first.body, contains('SPayLater'));
      },
    );

    test('total dibatasi, yang terdekat diprioritaskan', () async {
      for (var i = 0; i < 12; i++) {
        await akunRepo.save(akun(id: 0, nama: 'Akun $i', jatuhTempo: 28));
      }
      await SyncReminders(subRepo, akunRepo, scheduler)(now: now);
      expect(scheduler.calls.single, hasLength(SyncReminders.maxTotal));
    });

    test(
      'runner: sinkron saat tanggal jatuh tempo diisi, diubah, dan dikosongkan',
      () async {
        final runner = ReminderSyncRunner(
          subRepo,
          akunRepo,
          SyncReminders(subRepo, akunRepo, scheduler),
          debounce: const Duration(milliseconds: 20),
        )..start();
        addTearDown(runner.stop);

        await settle();
        expect(scheduler.calls.last, isEmpty);

        final bawaan = (await akunRepo.getAll()).single;
        await akunRepo.save(bawaan.copyWith(tanggalJatuhTempo: 5));
        await settle();
        expect(scheduler.calls.last, isNotEmpty);
        expect(scheduler.calls.last.first.body, contains('Kartu Kredit'));

        await akunRepo.save(bawaan.copyWith(tanggalJatuhTempo: 0));
        await settle();
        expect(scheduler.calls.last, isEmpty);
      },
    );
  });

  group('SaveAkun: tanggal jatuh tempo', () {
    late AppDatabase db;
    late SaveAkun save;

    setUp(() {
      db = AppDatabase.inMemory();
      save = SaveAkun(AkunRepositoryImpl(db));
    });
    tearDown(() => db.close());

    test('0–31 diterima, di luar itu ditolak', () async {
      for (final ok in [0, 1, 31]) {
        final id = await save(Akun(nama: 'Akun $ok', tanggalJatuhTempo: ok));
        expect(
          (await AkunRepositoryImpl(db).getById(id))!.tanggalJatuhTempo,
          ok,
        );
      }
      for (final bad in [-1, 32]) {
        await expectLater(
          save(Akun(nama: 'X$bad', tanggalJatuhTempo: bad)),
          throwsA(isA<Exception>()),
        );
      }
    });
  });
}
