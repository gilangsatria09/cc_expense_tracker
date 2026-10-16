import 'package:cc_expense_tracker/data/database/app_database.dart';
import 'package:cc_expense_tracker/data/database/daos/settings_dao.dart';
import 'package:cc_expense_tracker/domain/entities/enums.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.inMemory());
  tearDown(() => db.close());

  TransaksisCompanion trx({
    required DateTime tanggal,
    DateTime? bulan,
    JenisTransaksi jenis = JenisTransaksi.personal,
    int? subscriptionId,
    int akunId = 1,
  }) => TransaksisCompanion.insert(
    tanggal: tanggal,
    bulanTagihan: Value(bulan ?? DateTime(tanggal.year, tanggal.month)),
    deskripsi: 'tes',
    jenis: jenis,
    akunId: akunId,
    totalTagihan: 100000,
    status: StatusBayar.belumDibayar,
    subscriptionId: Value(subscriptionId),
  );

  test('getByMonth hanya mengembalikan transaksi bulan tersebut', () async {
    await db.transaksiDao.insertTransaksi(trx(tanggal: DateTime(2026, 9, 30)));
    await db.transaksiDao.insertTransaksi(trx(tanggal: DateTime(2026, 10, 1)));

    final sept = await db.transaksiDao.getByMonth(DateTime(2026, 9));
    expect(sept, hasLength(1));
    expect(sept.single.ongkirFee, 0);
  });

  test('getByMonth memfilter bulan tagihan, bukan bulan tanggal', () async {
    await db.transaksiDao.insertTransaksi(
      trx(tanggal: DateTime(2026, 8, 5), bulan: DateTime(2026, 7)),
    );
    await db.transaksiDao.insertTransaksi(
      trx(tanggal: DateTime(2026, 8, 30), bulan: DateTime(2026, 9)),
    );

    expect(await db.transaksiDao.getByMonth(DateTime(2026, 7)), hasLength(1));
    expect(await db.transaksiDao.getByMonth(DateTime(2026, 8)), isEmpty);
    expect(await db.transaksiDao.getByMonth(DateTime(2026, 9)), hasLength(1));
  });

  test('hapus transaksi ikut menghapus split (cascade)', () async {
    final id = await db.transaksiDao.insertTransaksi(
      trx(tanggal: DateTime(2026, 9, 1), jenis: JenisTransaksi.groupOrder),
    );
    await db.splitDao.replaceForTransaksi(id, [
      SplitGroupOrdersCompanion.insert(
        transaksiId: id,
        nama: 'Gilang',
        status: StatusBayar.paid,
      ),
      SplitGroupOrdersCompanion.insert(
        transaksiId: id,
        nama: 'Budi',
        status: StatusBayar.belumDibayar,
      ),
    ]);
    expect(await db.splitDao.getByTransaksi(id), hasLength(2));

    await db.transaksiDao.deleteTransaksi(id);
    expect(await db.splitDao.getAll(), isEmpty);
  });

  test('hapus subscription men-set null subscriptionId transaksi', () async {
    final subId = await db.subscriptionDao.insertSubscription(
      SubscriptionsCompanion.insert(
        namaLayanan: 'Netflix',
        akunId: 1,
        siklusBilling: SiklusBilling.bulanan,
        tanggalTagihanBerikutnya: DateTime(2026, 10, 1),
        hariTagihan: 1,
        status: StatusSubscription.aktif,
      ),
    );
    final id = await db.transaksiDao.insertTransaksi(
      trx(
        tanggal: DateTime(2026, 9, 1),
        jenis: JenisTransaksi.subscription,
        subscriptionId: subId,
      ),
    );

    await db.subscriptionDao.deleteSubscription(subId);
    expect((await db.transaksiDao.getById(id))!.subscriptionId, isNull);
  });

  test('settings: default 0 dan upsert', () async {
    expect(await db.settingsDao.getValue(SettingKeys.akunTerakhir), 0);
    await db.settingsDao.setValue(SettingKeys.akunTerakhir, 1);
    await db.settingsDao.setValue(SettingKeys.akunTerakhir, 2);
    expect(await db.settingsDao.getValue(SettingKeys.akunTerakhir), 2);
  });

  group('akun', () {
    test('akun bawaan ada di database baru', () async {
      final akuns = await db.akunDao.getAll();
      expect(akuns.map((a) => a.nama), ['Kartu Kredit']);
      expect(akuns.single.id, 1);
    });

    test('usageCount menjumlah transaksi, cicilan, dan subscription', () async {
      final spay = await db.akunDao.insertAkun(
        AkunsCompanion.insert(nama: 'SPayLater'),
      );
      expect(await db.akunDao.usageCount(spay), 0);

      await db.transaksiDao.insertTransaksi(
        trx(tanggal: DateTime(2026, 9, 1), akunId: spay),
      );
      await db.cicilanDao.insertCicilan(
        CicilansCompanion.insert(
          namaCicilan: 'HP',
          akunId: spay,
          totalHargaBarang: 1000,
          tenor: 2,
          jumlahPerBulan: 500,
          tanggalMulai: DateTime(2026, 9),
        ),
      );
      await db.subscriptionDao.insertSubscription(
        SubscriptionsCompanion.insert(
          namaLayanan: 'Netflix',
          akunId: spay,
          siklusBilling: SiklusBilling.bulanan,
          tanggalTagihanBerikutnya: DateTime(2026, 10, 1),
          hariTagihan: 1,
          status: StatusSubscription.aktif,
        ),
      );
      expect(await db.akunDao.usageCount(spay), 3);
      expect(await db.akunDao.usageCount(1), 0);
    });

    test('foreign key menolak menghapus akun yang masih dipakai', () async {
      await db.transaksiDao.insertTransaksi(trx(tanggal: DateTime(2026, 9, 1)));
      await expectLater(db.akunDao.deleteAkun(1), throwsA(isA<Exception>()));
      expect(await db.akunDao.getAll(), hasLength(1));
    });
  });
}
