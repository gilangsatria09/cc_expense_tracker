import 'package:cc_expense_tracker/core/error/domain_exception.dart';
import 'package:cc_expense_tracker/data/database/app_database.dart';
import 'package:cc_expense_tracker/data/repositories/cicilan_repository_impl.dart';
import 'package:cc_expense_tracker/data/repositories/akun_repository_impl.dart';
import 'package:cc_expense_tracker/data/repositories/subscription_repository_impl.dart';
import 'package:cc_expense_tracker/data/repositories/transaksi_repository_impl.dart';
import 'package:cc_expense_tracker/domain/entities/cicilan.dart';
import 'package:cc_expense_tracker/domain/entities/enums.dart';
import 'package:cc_expense_tracker/domain/entities/split_group_order.dart';
import 'package:cc_expense_tracker/domain/entities/subscription.dart';
import 'package:cc_expense_tracker/domain/entities/transaksi.dart';
import 'package:cc_expense_tracker/domain/usecases/generate_subscription_bills.dart';
import 'package:cc_expense_tracker/domain/usecases/pay_cicilan.dart';
import 'package:cc_expense_tracker/domain/usecases/save_transaksi.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/akun_helpers.dart';

void main() {
  late AppDatabase db;
  late TransaksiRepositoryImpl transaksiRepo;
  late SubscriptionRepositoryImpl subRepo;
  late CicilanRepositoryImpl cicilanRepo;
  late AkunRepositoryImpl akunRepo;

  setUp(() {
    db = AppDatabase.inMemory();
    transaksiRepo = TransaksiRepositoryImpl(db);
    subRepo = SubscriptionRepositoryImpl(db);
    cicilanRepo = CicilanRepositoryImpl(db);
    akunRepo = AkunRepositoryImpl(db);
  });
  tearDown(() => db.close());

  Subscription sub({
    String nama = 'Netflix',
    int? harga = 54000,
    SiklusBilling siklus = SiklusBilling.bulanan,
    required DateTime next,
    StatusSubscription status = StatusSubscription.aktif,
  }) => Subscription(
    namaLayanan: nama,
    akunId: 1,
    hargaTetap: harga,
    siklusBilling: siklus,
    tanggalTagihanBerikutnya: next,
    status: status,
  );

  group('GenerateSubscriptionBills', () {
    test(
      'buat transaksi & majukan tanggal; kedua kali dijalankan no-op',
      () async {
        final id = await subRepo.save(sub(next: DateTime(2026, 9, 10)));
        final usecase = GenerateSubscriptionBills(subRepo, akunRepo);
        final now = DateTime(2026, 9, 25);

        expect(await usecase(now), 1);
        expect(await usecase(now), 0);

        final bills = await transaksiRepo.getBySubscription(id);
        expect(bills, hasLength(1));
        expect(bills.single.tanggal, DateTime(2026, 9, 10));
        expect(bills.single.totalTagihan, 54000);
        expect(bills.single.status, StatusBayar.belumDibayar);
        expect(bills.single.sumberEkstraksi, SumberEkstraksi.autoSubscription);
        expect(
          (await subRepo.getById(id))!.tanggalTagihanBerikutnya,
          DateTime(2026, 10, 10),
        );
      },
    );

    test('jatuh tempo hari ini ikut dibuat', () async {
      await subRepo.save(sub(next: DateTime(2026, 9, 25)));
      expect(
        await GenerateSubscriptionBills(subRepo, akunRepo)(
          DateTime(2026, 9, 25, 8),
        ),
        1,
      );
    });

    test(
      'app tidak dibuka berbulan-bulan: semua bulan terlewat dibuat',
      () async {
        final id = await subRepo.save(sub(next: DateTime(2026, 6, 10)));
        expect(
          await GenerateSubscriptionBills(subRepo, akunRepo)(
            DateTime(2026, 9, 25),
          ),
          4,
        );
        expect(await transaksiRepo.getBySubscription(id), hasLength(4));
        expect(
          (await subRepo.getById(id))!.tanggalTagihanBerikutnya,
          DateTime(2026, 10, 10),
        );
      },
    );

    test('hari 31 tidak bergeser permanen setelah bulan pendek', () async {
      final id = await subRepo.save(sub(next: DateTime(2026, 1, 31)));
      await GenerateSubscriptionBills(subRepo, akunRepo)(DateTime(2026, 5, 1));

      final bills = await transaksiRepo.getBySubscription(id);
      expect(bills.map((b) => b.tanggal).toSet(), {
        DateTime(2026, 1, 31),
        DateTime(2026, 2, 28),
        DateTime(2026, 3, 31),
        DateTime(2026, 4, 30),
      });
      expect(
        (await subRepo.getById(id))!.tanggalTagihanBerikutnya,
        DateTime(2026, 5, 31),
      );
    });

    test(
      'tahunan 29 Feb: 28 Feb di tahun biasa, kembali 29 Feb di kabisat',
      () async {
        final id = await subRepo.save(
          sub(siklus: SiklusBilling.tahunan, next: DateTime(2028, 2, 29)),
        );
        await GenerateSubscriptionBills(subRepo, akunRepo)(
          DateTime(2032, 3, 1),
        );

        final dates = (await transaksiRepo.getBySubscription(
          id,
        )).map((b) => b.tanggal).toSet();
        expect(dates, contains(DateTime(2029, 2, 28)));
        expect(dates, contains(DateTime(2032, 2, 29)));
      },
    );

    test('tahunan maju 12 bulan', () async {
      final id = await subRepo.save(
        sub(siklus: SiklusBilling.tahunan, next: DateTime(2026, 9, 1)),
      );
      await GenerateSubscriptionBills(subRepo, akunRepo)(DateTime(2026, 9, 25));
      expect(
        (await subRepo.getById(id))!.tanggalTagihanBerikutnya,
        DateTime(2027, 9, 1),
      );
    });

    test(
      'harga variable, nonaktif, dibatalkan, belum jatuh tempo: dilewati',
      () async {
        await subRepo.save(sub(harga: null, next: DateTime(2026, 9, 1)));
        await subRepo.save(
          sub(status: StatusSubscription.nonaktif, next: DateTime(2026, 9, 1)),
        );
        await subRepo.save(
          sub(
            status: StatusSubscription.dibatalkan,
            next: DateTime(2026, 9, 1),
          ),
        );
        await subRepo.save(sub(next: DateTime(2026, 9, 26)));

        expect(
          await GenerateSubscriptionBills(subRepo, akunRepo)(
            DateTime(2026, 9, 25),
          ),
          0,
        );
        expect(await transaksiRepo.getAll(), isEmpty);
      },
    );
  });

  group('PayCicilan', () {
    Cicilan cicilan({int ke = 0, DateTime? terakhir}) => Cicilan(
      namaCicilan: 'HP',
      akunId: 1,
      totalHargaBarang: 300000,
      tenor: 3,
      cicilanKe: ke,
      jumlahPerBulan: 100000,
      tanggalMulai: DateTime(2026, 7, 1),
      tanggalBayarTerakhir: terakhir,
    );

    test(
      'naikkan cicilanKe & catat tanggal; klik kedua bulan sama ditolak',
      () async {
        final id = await cicilanRepo.save(cicilan());
        final pay = PayCicilan(cicilanRepo);
        final now = DateTime(2026, 9, 25);

        final updated = await pay(id, now: now);
        expect(updated.cicilanKe, 1);
        expect((await cicilanRepo.getById(id))!.tanggalBayarTerakhir, now);
        expect(() => pay(id, now: now), throwsA(isA<DomainException>()));
        expect((await pay(id, now: DateTime(2026, 10, 1))).cicilanKe, 2);
      },
    );

    test('lunas ditolak', () async {
      final id = await cicilanRepo.save(cicilan(ke: 3));
      expect(
        () => PayCicilan(cicilanRepo)(id, now: DateTime(2026, 9, 25)),
        throwsA(isA<DomainException>()),
      );
    });
  });

  group('SaveTransaksi', () {
    SaveTransaksi save() => SaveTransaksi(transaksiRepo, akunRepo);

    Transaksi trx(JenisTransaksi jenis, {int total = 100000}) => Transaksi(
      tanggal: DateTime(2026, 9, 1),
      deskripsi: 'tes',
      jenis: jenis,
      akunId: 1,
      totalTagihan: total,
    );

    test('total <= 0 ditolak', () {
      expect(
        () => save()(trx(JenisTransaksi.personal, total: 0)),
        throwsA(isA<DomainException>()),
      );
    });

    test('Subscription tanpa subscriptionId ditolak', () {
      expect(
        () => save()(trx(JenisTransaksi.subscription)),
        throwsA(isA<DomainException>()),
      );
    });

    test('akun wajib dipilih dan harus ada', () {
      expect(
        () => save()(trx(JenisTransaksi.personal).copyWith(akunId: 0)),
        throwsA(isA<DomainException>()),
      );
      expect(
        () => save()(trx(JenisTransaksi.personal).copyWith(akunId: 999)),
        throwsA(
          isA<DomainException>().having(
            (e) => e.message,
            'message',
            contains('tidak ditemukan'),
          ),
        ),
      );
    });

    test(
      'Pembayaran menyimpan akun yang dibayar; akun diingat sebagai bawaan',
      () async {
        final spay = await tambahAkun(db);
        final id = await save()(
          trx(JenisTransaksi.pembayaran).copyWith(akunId: spay),
        );
        expect((await transaksiRepo.getById(id))!.akunId, spay);
        expect(await akunRepo.getLastUsedId(), spay);
      },
    );

    test('GroupOrder menyimpan split; ubah jenis membersihkannya', () async {
      final id = await save()(
        trx(JenisTransaksi.groupOrder).copyWith(
          merchant: () => 'Warung',
          ongkirFee: 5000,
          splits: const [
            SplitGroupOrder(nama: 'Gilang', hargaManual: 60000),
            SplitGroupOrder(nama: 'Budi', hargaManual: 40000),
          ],
        ),
      );
      final saved = (await transaksiRepo.getById(id))!;
      expect(saved.splits, hasLength(2));
      expect(saved.bagianSaya, 60000);
      expect(await transaksiRepo.getKnownParticipantNames(), [
        'Budi',
        'Gilang',
      ]);

      await save()(saved.copyWith(jenis: JenisTransaksi.personal));
      final cleared = (await transaksiRepo.getById(id))!;
      expect(cleared.splits, isEmpty);
      expect(cleared.merchant, isNull);
      expect(cleared.ongkirFee, 0);
    });

    test('update mengganti split (tanpa duplikat)', () async {
      final id = await save()(
        trx(
          JenisTransaksi.groupOrder,
        ).copyWith(splits: const [SplitGroupOrder(nama: 'Gilang')]),
      );
      final saved = (await transaksiRepo.getById(id))!;
      await save()(
        saved.copyWith(
          splits: const [
            SplitGroupOrder(nama: 'Gilang'),
            SplitGroupOrder(nama: 'Ani'),
          ],
        ),
      );
      expect((await transaksiRepo.getById(id))!.splits, hasLength(2));
    });
  });
}
