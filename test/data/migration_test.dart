import 'dart:io';

import 'package:cc_expense_tracker/data/database/app_database.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

int unix(DateTime d) => d.millisecondsSinceEpoch ~/ 1000;

sqlite.Database rawDb({required int version}) {
  var ddl = File('test/data/schema_v2.sql').readAsStringSync();
  if (version == 1) {
    ddl = ddl.replaceFirst('"bulan_tagihan" INTEGER NULL, ', '');
  }
  final raw = sqlite.sqlite3.openInMemory();
  raw.execute(ddl);
  raw.execute('PRAGMA user_version = $version');
  return raw;
}

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  test('v2 → v3: data lama masuk ke akun pertama, split & tautan utuh', () async {
    final raw = rawDb(version: 2);
    raw.execute("INSERT INTO app_settings VALUES ('limitCC', 10000000)");
    raw.execute(
      "INSERT INTO app_settings VALUES ('saldoOutstandingSebelumTracker', 3870954)",
    );
    raw.execute("INSERT INTO app_settings VALUES ('tanggalCutoffTagihan', 4)");
    raw.execute("INSERT INTO app_settings VALUES ('kunci_lain', 7)");

    const insertSub =
        'INSERT INTO subscriptions (id, nama_layanan, harga_tetap, siklus_billing, '
        'tanggal_tagihan_berikutnya, hari_tagihan, status) VALUES (?, ?, ?, 0, ?, ?, 0)';
    raw.execute(insertSub, [
      5,
      'Claude',
      349000,
      unix(DateTime(2026, 10, 3)),
      3,
    ]);
    raw.execute(insertSub, [9, 'Hevy', null, unix(DateTime(2026, 10, 25)), 25]);
    raw.execute(
      'INSERT INTO cicilans (id, nama_cicilan, total_harga_barang, tenor, cicilan_ke, '
      'jumlah_per_bulan, tanggal_mulai) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [3, 'Kursi', 877387, 6, 2, 146231, unix(DateTime(2026, 7))],
    );
    const insertTrx =
        'INSERT INTO transaksis (id, tanggal, bulan_tagihan, deskripsi, jenis, sumber_bayar, '
        'total_tagihan, ongkir_fee, status, subscription_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)';
    raw.execute(insertTrx, [
      11,
      unix(DateTime(2026, 9, 1)),
      unix(DateTime(2026, 8)),
      'Makan tim',
      1,
      0,
      90000,
      5000,
      1,
      null,
    ]);
    raw.execute(insertTrx, [
      12,
      unix(DateTime(2026, 8, 5)),
      unix(DateTime(2026, 7)),
      'Pembayaran',
      3,
      1,
      3470206,
      0,
      0,
      null,
    ]);
    raw.execute(insertTrx, [
      13,
      unix(DateTime(2026, 9, 3)),
      unix(DateTime(2026, 8)),
      'Claude',
      2,
      0,
      349000,
      0,
      2,
      5,
    ]);
    const insertSplit =
        'INSERT INTO split_group_orders (id, transaksi_id, nama, harga_manual, status) VALUES (?, ?, ?, ?, ?)';
    raw.execute(insertSplit, [1, 11, 'Gilang', 30000, 1]);
    raw.execute(insertSplit, [2, 11, 'Budi', null, 0]);

    final db = AppDatabase(NativeDatabase.opened(raw));
    addTearDown(db.close);

    final akuns = await db.akunDao.getAll();
    expect(akuns, hasLength(1));
    final akun = akuns.single;
    expect(akun.nama, 'Kartu Kredit');
    expect(akun.limitKredit, 10000000);
    expect(akun.saldoAwal, 3870954);
    expect(akun.tanggalCutoff, 4);

    final trx = await db.transaksiDao.getAll();
    expect(trx.map((t) => t.id), unorderedEquals([11, 12, 13]));
    expect(trx.map((t) => t.akunId).toSet(), {akun.id});
    expect(trx.firstWhere((t) => t.id == 12).totalTagihan, 3470206);
    expect(trx.firstWhere((t) => t.id == 11).ongkirFee, 5000);
    expect((await db.cicilanDao.getAll()).single.akunId, akun.id);
    final subs = await db.subscriptionDao.getAll();
    expect(subs.map((s) => s.akunId).toSet(), {akun.id});

    final splits = await db.splitDao.getAll();
    expect(splits.map((s) => s.nama), unorderedEquals(['Gilang', 'Budi']));
    expect(splits.first.transaksiId, 11);

    expect(trx.firstWhere((t) => t.id == 13).subscriptionId, 5);

    final cols = (await db.customSelect('PRAGMA table_info(transaksis)').get())
        .map((r) => r.read<String>('name'))
        .toList();
    expect(cols, isNot(contains('sumber_bayar')));
    expect(cols, contains('akun_id'));
    final keys = (await db.customSelect('SELECT key FROM app_settings').get())
        .map((r) => r.read<String>('key'))
        .toList();
    expect(keys, ['kunci_lain']);

    expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
    expect(
      (await db.customSelect('PRAGMA foreign_keys').getSingle()).read<int>(
        'foreign_keys',
      ),
      1,
    );
    await db.transaksiDao.deleteTransaksi(11);
    expect(await db.splitDao.getAll(), isEmpty);
  });

  test(
    'v2 → v3: tanpa pengaturan lama, akun pertama berisi nilai kosong',
    () async {
      final db = AppDatabase(NativeDatabase.opened(rawDb(version: 2)));
      addTearDown(db.close);
      final akun = (await db.akunDao.getAll()).single;
      expect([akun.limitKredit, akun.saldoAwal, akun.tanggalCutoff], [0, 0, 0]);
    },
  );

  test(
    'v1 → v3: bulan tagihan terisi dari bulan tanggal, lalu masuk akun',
    () async {
      final raw = rawDb(version: 1);
      for (final d in [DateTime(2026, 8, 5), DateTime(2026, 9, 30)]) {
        raw.execute(
          'INSERT INTO transaksis (tanggal, deskripsi, jenis, sumber_bayar, total_tagihan, status) '
          "VALUES (?, 'lama', 0, 0, 1000, 2)",
          [unix(d)],
        );
      }
      final db = AppDatabase(NativeDatabase.opened(raw));
      addTearDown(db.close);

      final rows = await db.transaksiDao.getAll()
        ..sort((a, b) => a.tanggal.compareTo(b.tanggal));
      expect(rows.map((r) => r.bulanTagihan), [
        DateTime(2026, 8),
        DateTime(2026, 9),
      ]);
      expect(rows.map((r) => r.akunId).toSet(), {
        (await db.akunDao.getAll()).single.id,
      });
      expect(await db.transaksiDao.getByMonth(DateTime(2026, 9)), hasLength(1));
    },
  );

  test('instalasi baru: satu akun bawaan "Kartu Kredit"', () async {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);
    final akuns = await db.akunDao.getAll();
    expect(akuns.map((a) => a.nama), [AppDatabase.namaAkunBawaan]);
  });

  test('v3 → v4: kolom jatuh tempo ditambah (0), akun & data utuh', () async {
    final raw = sqlite.sqlite3.openInMemory();
    raw.execute(File('test/data/schema_v3.sql').readAsStringSync());
    raw.execute('PRAGMA user_version = 3');
    raw.execute(
      'INSERT INTO akuns (id, nama, limit_kredit, saldo_awal, tanggal_cutoff) VALUES (?, ?, ?, ?, ?)',
      [1, 'Kartu Kredit', 10000000, 3870954, 4],
    );
    raw.execute(
      'INSERT INTO akuns (id, nama, limit_kredit, saldo_awal, tanggal_cutoff) VALUES (?, ?, ?, ?, ?)',
      [2, 'SPayLater', 3000000, 0, 10],
    );
    raw.execute(
      'INSERT INTO transaksis (id, tanggal, bulan_tagihan, deskripsi, jenis, akun_id, total_tagihan, ongkir_fee, status) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        7,
        unix(DateTime(2026, 9, 8)),
        unix(DateTime(2026, 8)),
        'Belanja',
        0,
        2,
        150000,
        0,
        2,
      ],
    );

    final db = AppDatabase(NativeDatabase.opened(raw));
    addTearDown(db.close);

    final akuns = await db.akunDao.getAll();
    expect(akuns.map((a) => a.nama), ['Kartu Kredit', 'SPayLater']);
    expect(akuns.map((a) => a.tanggalJatuhTempo), [
      0,
      0,
    ]);
    expect(akuns.last.limitKredit, 3000000);
    expect(akuns.last.tanggalCutoff, 10);

    final trx = await db.transaksiDao.getAll();
    expect(trx.single.akunId, 2);
    expect(trx.single.totalTagihan, 150000);

    await db.akunDao.updateAkun(akuns.last.copyWith(tanggalJatuhTempo: 25));
    expect((await db.akunDao.getById(2))!.tanggalJatuhTempo, 25);
    expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
  });

  test('v2 → v4 sekaligus: rantai migrasi lengkap', () async {
    final raw = rawDb(version: 2);
    raw.execute(
      'INSERT INTO transaksis (id, tanggal, bulan_tagihan, deskripsi, jenis, sumber_bayar, total_tagihan, status) '
      'VALUES (1, ?, ?, ?, 0, 0, 1000, 2)',
      [unix(DateTime(2026, 9, 1)), unix(DateTime(2026, 8)), 'lama'],
    );
    final db = AppDatabase(NativeDatabase.opened(raw));
    addTearDown(db.close);
    final akun = (await db.akunDao.getAll()).single;
    expect(akun.tanggalJatuhTempo, 0);
    expect((await db.transaksiDao.getAll()).single.akunId, akun.id);
  });
}
