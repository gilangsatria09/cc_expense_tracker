import 'package:cc_expense_tracker/core/utils/date_utils.dart';
import 'package:cc_expense_tracker/data/database/app_database.dart';
import 'package:cc_expense_tracker/data/repositories/akun_repository_impl.dart';
import 'package:cc_expense_tracker/data/repositories/subscription_repository_impl.dart';
import 'package:cc_expense_tracker/data/repositories/transaksi_repository_impl.dart';
import 'package:cc_expense_tracker/domain/entities/enums.dart';
import 'package:cc_expense_tracker/domain/entities/subscription.dart';
import 'package:cc_expense_tracker/domain/entities/transaksi.dart';
import 'package:cc_expense_tracker/domain/usecases/generate_subscription_bills.dart';
import 'package:cc_expense_tracker/domain/usecases/save_transaksi.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/akun_helpers.dart';

void main() {
  group('bulanTagihanFor', () {
    test('cutoff 4: tanggal 1–4 masuk tagihan bulan sebelumnya', () {
      expect(bulanTagihanFor(DateTime(2026, 8, 1), 4), DateTime(2026, 7));
      expect(bulanTagihanFor(DateTime(2026, 8, 4), 4), DateTime(2026, 7));
      expect(bulanTagihanFor(DateTime(2026, 8, 5), 4), DateTime(2026, 8));
      expect(bulanTagihanFor(DateTime(2026, 8, 31), 4), DateTime(2026, 8));
    });

    test('awal Januari mundur ke Desember tahun sebelumnya', () {
      expect(bulanTagihanFor(DateTime(2027, 1, 2), 4), DateTime(2026, 12));
    });

    test('cutoff 0: ikut bulan kalender', () {
      expect(bulanTagihanFor(DateTime(2026, 8, 1), 0), DateTime(2026, 8));
    });
  });

  group('Transaksi.effectiveBulan', () {
    Transaksi trx({DateTime? bulan}) => Transaksi(
      tanggal: DateTime(2026, 8, 5),
      bulanTagihan: bulan,
      deskripsi: 'x',
      jenis: JenisTransaksi.pembayaran,
      akunId: 1,
      totalTagihan: 1000,
    );

    test('null → bulan dari tanggal; diisi → dipakai apa adanya', () {
      expect(trx().effectiveBulan, DateTime(2026, 8));
      expect(trx(bulan: DateTime(2026, 7)).effectiveBulan, DateTime(2026, 7));
    });

    test('copyWith bisa mengosongkan bulan tagihan kembali ke otomatis', () {
      final t = trx(
        bulan: DateTime(2026, 7),
      ).copyWith(bulanTagihan: () => null);
      expect(t.bulanTagihan, isNull);
    });
  });

  group('dengan database', () {
    late AppDatabase db;
    late TransaksiRepositoryImpl trxRepo;
    late AkunRepositoryImpl settings;

    setUp(() {
      db = AppDatabase.inMemory();
      trxRepo = TransaksiRepositoryImpl(db);
      settings = AkunRepositoryImpl(db);
    });
    tearDown(() => db.close());

    Transaksi trx(DateTime tanggal, {DateTime? bulan}) => Transaksi(
      tanggal: tanggal,
      bulanTagihan: bulan,
      deskripsi: 'x',
      jenis: JenisTransaksi.personal,
      akunId: 1,
      totalTagihan: 10000,
    );

    test(
      'SaveTransaksi mengisi bulan dari cutoff; override manual dihormati',
      () async {
        await setCutoff(db, 4);
        final save = SaveTransaksi(trxRepo, settings);

        final auto = await save(trx(DateTime(2026, 9, 2)));
        final manual = await save(
          trx(DateTime(2026, 8, 30), bulan: DateTime(2026, 9)),
        );

        expect((await trxRepo.getById(auto))!.bulanTagihan, DateTime(2026, 8));
        expect(
          (await trxRepo.getById(manual))!.bulanTagihan,
          DateTime(2026, 9),
        );
      },
    );

    test('tanpa cutoff (default 0): bulan kalender', () async {
      final id = await SaveTransaksi(trxRepo, settings)(
        trx(DateTime(2026, 9, 2)),
      );
      expect((await trxRepo.getById(id))!.bulanTagihan, DateTime(2026, 9));
    });

    test('repository selalu menyimpan bulan tagihan walau null', () async {
      final id = await trxRepo.save(trx(DateTime(2026, 9, 2)));
      expect(
        (await db.transaksiDao.getById(id))!.bulanTagihan,
        DateTime(2026, 9),
      );
    });

    test(
      'auto-generate subscription memakai cutoff untuk bulan tagihan',
      () async {
        await setCutoff(db, 4);
        final subRepo = SubscriptionRepositoryImpl(db);
        final id = await subRepo.save(
          Subscription(
            namaLayanan: 'Claude',
            akunId: 1,
            hargaTetap: 349000,
            siklusBilling: SiklusBilling.bulanan,
            tanggalTagihanBerikutnya: DateTime(2026, 9, 3),
          ),
        );

        await GenerateSubscriptionBills(subRepo, settings)(
          DateTime(2026, 9, 25),
        );

        final bill = (await trxRepo.getBySubscription(id)).single;
        expect(bill.tanggal, DateTime(2026, 9, 3));
        expect(bill.bulanTagihan, DateTime(2026, 8));
      },
    );
  });

  group('per akun: tanggal tutup buku berbeda', () {
    late AppDatabase db;
    late TransaksiRepositoryImpl trxRepo;
    late AkunRepositoryImpl akunRepo;
    late int spay;

    setUp(() async {
      db = AppDatabase.inMemory();
      trxRepo = TransaksiRepositoryImpl(db);
      akunRepo = AkunRepositoryImpl(db);
      await setCutoff(db, 4);
      spay = await tambahAkun(db, cutoff: 10);
    });
    tearDown(() => db.close());

    Transaksi trx(DateTime tanggal, int akunId) => Transaksi(
      tanggal: tanggal,
      deskripsi: 'x',
      jenis: JenisTransaksi.personal,
      akunId: akunId,
      totalTagihan: 10000,
    );

    test(
      'tanggal 10 (termasuk) masuk tagihan bulan sebelumnya; tanggal 11 tidak',
      () {
        expect(bulanTagihanFor(DateTime(2026, 9, 10), 10), DateTime(2026, 8));
        expect(bulanTagihanFor(DateTime(2026, 9, 11), 10), DateTime(2026, 9));
        expect(bulanTagihanFor(DateTime(2026, 9, 1), 10), DateTime(2026, 8));
      },
    );

    test(
      'tanggal yang sama jatuh di bulan tagihan berbeda tergantung akun',
      () async {
        final save = SaveTransaksi(trxRepo, akunRepo);
        final idCc = await save(trx(DateTime(2026, 9, 8), akunBawaanId));
        final idSpay = await save(trx(DateTime(2026, 9, 8), spay));

        expect((await trxRepo.getById(idCc))!.bulanTagihan, DateTime(2026, 9));
        expect(
          (await trxRepo.getById(idSpay))!.bulanTagihan,
          DateTime(2026, 8),
        );
      },
    );

    test(
      'auto-generate subscription memakai tanggal tutup buku akun subscription-nya',
      () async {
        final subRepo = SubscriptionRepositoryImpl(db);
        Future<int> sub(int akunId, String nama) => subRepo.save(
          Subscription(
            namaLayanan: nama,
            akunId: akunId,
            hargaTetap: 10000,
            siklusBilling: SiklusBilling.bulanan,
            tanggalTagihanBerikutnya: DateTime(2026, 9, 8),
          ),
        );
        final idCc = await sub(akunBawaanId, 'Di CC');
        final idSpay = await sub(spay, 'Di SPayLater');

        await GenerateSubscriptionBills(subRepo, akunRepo)(
          DateTime(2026, 9, 9),
        );

        final cc = (await trxRepo.getBySubscription(idCc)).single;
        final sp = (await trxRepo.getBySubscription(idSpay)).single;
        expect(cc.akunId, akunBawaanId);
        expect(cc.bulanTagihan, DateTime(2026, 9));
        expect(sp.akunId, spay);
        expect(sp.bulanTagihan, DateTime(2026, 8));
      },
    );

    test(
      'daftar transaksi per bulan tagihan memisahkan akun dengan benar',
      () async {
        final save = SaveTransaksi(trxRepo, akunRepo);
        await save(trx(DateTime(2026, 9, 8), akunBawaanId));
        await save(trx(DateTime(2026, 9, 8), spay));

        final agustus = await trxRepo.watchByMonth(DateTime(2026, 8)).first;
        final september = await trxRepo.watchByMonth(DateTime(2026, 9)).first;
        expect(agustus.map((t) => t.akunId), [spay]);
        expect(september.map((t) => t.akunId), [akunBawaanId]);
      },
    );
  });
}
