import 'dart:convert';

import 'package:cc_expense_tracker/core/error/domain_exception.dart';
import 'package:cc_expense_tracker/data/database/app_database.dart';
import 'package:cc_expense_tracker/data/import/import_parser.dart';
import 'package:cc_expense_tracker/data/import/json_backup_exporter.dart';
import 'package:cc_expense_tracker/data/import/sheet_json_importer.dart';
import 'package:cc_expense_tracker/data/repositories/cicilan_repository_impl.dart';
import 'package:cc_expense_tracker/data/repositories/akun_repository_impl.dart';
import 'package:cc_expense_tracker/data/repositories/subscription_repository_impl.dart';
import 'package:cc_expense_tracker/data/repositories/transaksi_repository_impl.dart';
import 'package:cc_expense_tracker/domain/entities/akun.dart';
import 'package:cc_expense_tracker/domain/entities/cicilan.dart';
import 'package:cc_expense_tracker/domain/entities/enums.dart';
import 'package:cc_expense_tracker/domain/entities/split_group_order.dart';
import 'package:cc_expense_tracker/domain/entities/subscription.dart';
import 'package:cc_expense_tracker/domain/entities/transaksi.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';

class Repos {
  Repos(this.db)
    : transaksi = TransaksiRepositoryImpl(db),
      cicilan = CicilanRepositoryImpl(db),
      subscription = SubscriptionRepositoryImpl(db),
      akun = AkunRepositoryImpl(db);

  final AppDatabase db;
  final TransaksiRepositoryImpl transaksi;
  final CicilanRepositoryImpl cicilan;
  final SubscriptionRepositoryImpl subscription;
  final AkunRepositoryImpl akun;

  JsonBackupExporter exporter([DateTime? now]) => JsonBackupExporter(
    transaksi,
    cicilan,
    subscription,
    akun,
    now: () => now ?? DateTime(2026, 9, 26, 21, 30),
  );
}

Future<Map<String, Object?>> snapshot(Repos r) async {
  final subs = await r.subscription.getAll();
  String subKey(int? id) {
    if (id == null) return '-';
    final s = subs.firstWhere((s) => s.id == id);
    return '${s.namaLayanan}|${s.hargaTetap}';
  }

  final akuns = await r.akun.getAll();
  String akunKey(int id) => akuns.firstWhere((a) => a.id == id).nama;

  final trx = await r.transaksi.getAll();
  trx.sort((a, b) {
    final c = a.tanggal.compareTo(b.tanggal);
    return c != 0 ? c : a.deskripsi.compareTo(b.deskripsi);
  });
  final cic = await r.cicilan.watchAll().first;
  return {
    'akuns': [
      for (final a in akuns)
        [
          a.nama,
          a.limitKredit,
          a.saldoAwal,
          a.tanggalCutoff,
          a.tanggalJatuhTempo,
        ],
    ]..sort((a, b) => a.toString().compareTo(b.toString())),
    'subs': [
      for (final s in subs)
        [
          s.namaLayanan,
          akunKey(s.akunId),
          s.hargaTetap,
          s.siklusBilling,
          s.tanggalTagihanBerikutnya,
          s.hariTagihan,
          s.status,
          s.catatan,
        ],
    ]..sort((a, b) => a.toString().compareTo(b.toString())),
    'cic': [
      for (final c in cic)
        [
          c.namaCicilan,
          akunKey(c.akunId),
          c.totalHargaBarang,
          c.tenor,
          c.cicilanKe,
          c.jumlahPerBulan,
          c.tanggalMulai,
          c.tanggalBayarTerakhir == null
              ? null
              : DateTime(
                  c.tanggalBayarTerakhir!.year,
                  c.tanggalBayarTerakhir!.month,
                  c.tanggalBayarTerakhir!.day,
                ),
          c.catatan,
        ],
    ],
    'trx': [
      for (final t in trx)
        [
          t.tanggal,
          t.effectiveBulan,
          t.deskripsi,
          t.jenis,
          akunKey(t.akunId),
          t.totalTagihan,
          t.merchant,
          t.ongkirFee,
          t.status,
          t.catatan,
          subKey(t.subscriptionId),
          t.sumberEkstraksi,
          [
            for (final s in t.splits)
              [s.nama, s.hargaManual, s.status, s.catatan],
          ],
        ],
    ],
  };
}

Future<void> seed(Repos r) async {
  final kk = (await r.akun.getAll()).first;
  await r.akun.save(
    kk.copyWith(
      limitKredit: 10000000,
      saldoAwal: 3870954,
      tanggalCutoff: 4,
      tanggalJatuhTempo: 1,
    ),
  );
  final spay = await r.akun.save(
    const Akun(
      nama: 'SPayLater',
      limitKredit: 3000000,
      saldoAwal: 100000,
      tanggalCutoff: 10,
      tanggalJatuhTempo: 25,
    ),
  );

  final apple59 = await r.subscription.save(
    Subscription(
      namaLayanan: 'Apple',
      akunId: 1,
      hargaTetap: 59000,
      siklusBilling: SiklusBilling.bulanan,
      tanggalTagihanBerikutnya: DateTime(2026, 10, 29),
      hariTagihan: 31,
      catatan: 'iCloud',
    ),
  );
  final apple19 = await r.subscription.save(
    Subscription(
      namaLayanan: 'Apple',
      akunId: spay,
      hargaTetap: 19000,
      siklusBilling: SiklusBilling.tahunan,
      tanggalTagihanBerikutnya: DateTime(2027, 2, 28),
      status: StatusSubscription.dibatalkan,
    ),
  );
  await r.subscription.save(
    Subscription(
      namaLayanan: 'Getcontact',
      akunId: 1,
      siklusBilling: SiklusBilling.bulanan,
      tanggalTagihanBerikutnya: DateTime(2026, 10, 19),
    ),
  );

  await r.cicilan.save(
    Cicilan(
      namaCicilan: 'Kursi',
      akunId: 1,
      totalHargaBarang: 877387,
      tenor: 6,
      cicilanKe: 2,
      jumlahPerBulan: 146231,
      tanggalMulai: DateTime(2026, 7),
      tanggalBayarTerakhir: DateTime(2026, 8, 20, 14, 5),
      catatan: 'cek bank',
    ),
  );
  await r.cicilan.save(
    Cicilan(
      namaCicilan: 'HP',
      akunId: spay,
      totalHargaBarang: 100000,
      tenor: 2,
      jumlahPerBulan: 50000,
      tanggalMulai: DateTime(2026, 9),
    ),
  );

  Transaksi trx(
    String deskripsi,
    DateTime tanggal, {
    JenisTransaksi jenis = JenisTransaksi.personal,
    int akun = 1,
    int total = 10000,
    StatusBayar status = StatusBayar.belumDibayar,
    DateTime? bulan,
    int? subId,
    List<SplitGroupOrder> splits = const [],
    String? merchant,
    int ongkir = 0,
    String? catatan,
    SumberEkstraksi? ekstraksi,
  }) => Transaksi(
    tanggal: tanggal,
    bulanTagihan: bulan,
    deskripsi: deskripsi,
    jenis: jenis,
    akunId: akun,
    totalTagihan: total,
    status: status,
    subscriptionId: subId,
    splits: splits,
    merchant: merchant,
    ongkirFee: ongkir,
    catatan: catatan,
    sumberEkstraksi: ekstraksi,
  );

  await r.transaksi.save(
    trx(
      'Kopi "spesial" — café',
      DateTime(2026, 9, 3),
      catatan: 'baris 1\nbaris 2',
      ekstraksi: SumberEkstraksi.manual,
    ),
  );
  await r.transaksi.save(
    trx(
      'Pembayaran',
      DateTime(2026, 8, 5),
      jenis: JenisTransaksi.pembayaran,
      akun: spay,
      total: 3470206,
      status: StatusBayar.paid,
      bulan: DateTime(2026, 7),
    ),
  );
  await r.transaksi.save(
    trx(
      'Apple 59',
      DateTime(2026, 9, 29),
      jenis: JenisTransaksi.subscription,
      total: 59000,
      subId: apple59,
    ),
  );
  await r.transaksi.save(
    trx(
      'Apple 19',
      DateTime(2026, 9, 28),
      jenis: JenisTransaksi.subscription,
      akun: spay,
      total: 19000,
      subId: apple19,
    ),
  );
  await r.transaksi.save(
    trx(
      'Makan tim',
      DateTime(2026, 9, 1),
      jenis: JenisTransaksi.groupOrder,
      total: 90000,
      status: StatusBayar.paidTemp,
      merchant: 'Warung',
      ongkir: 5000,
      ekstraksi: SumberEkstraksi.aiChatGroup,
      splits: const [
        SplitGroupOrder(
          nama: 'Gilang',
          hargaManual: 30000,
          status: StatusBayar.paidTemp,
        ),
        SplitGroupOrder(
          nama: 'Daniel',
          status: StatusBayar.paid,
          catatan: 'lunas',
        ),
        SplitGroupOrder(nama: 'Daniel', hargaManual: 20000),
      ],
    ),
  );
}

void main() {
  late Repos a;
  late Repos b;

  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  setUp(() {
    a = Repos(AppDatabase.inMemory());
    b = Repos(AppDatabase.inMemory());
  });
  tearDown(() async {
    await a.db.close();
    await b.db.close();
  });

  test('backup → restore ke database kosong: semua data identik', () async {
    await seed(a);
    final json = await a.exporter().exportJson();

    final summary = await SheetJsonImporter(b.db).importJson(json);

    expect(summary.transaksi, 5);
    expect(summary.split, 3);
    expect(summary.cicilan, 2);
    expect(summary.subscription, 3);
    expect(summary.akun, 2);
    expect(await snapshot(b), await snapshot(a));
  });

  test(
    'nama subscription kembar: tiap transaksi tetap tertaut ke yang benar',
    () async {
      await seed(a);
      await SheetJsonImporter(b.db).importJson(await a.exporter().exportJson());

      final subs = await b.subscription.getAll();
      final all = await b.transaksi.getAll();
      String linked(String deskripsi) {
        final t = all.firstWhere((t) => t.deskripsi == deskripsi);
        return subs
            .firstWhere((s) => s.id == t.subscriptionId)
            .siklusBilling
            .name;
      }

      expect(linked('Apple 59'), 'bulanan');
      expect(linked('Apple 19'), 'tahunan');
    },
  );

  test('restore mengganti data yang ada (replaceExisting)', () async {
    await seed(a);
    await seed(b);
    await b.transaksi.save(
      Transaksi(
        tanggal: DateTime(2026, 9, 9),
        deskripsi: 'sisa lama',
        jenis: JenisTransaksi.personal,
        akunId: 1,
        totalTagihan: 1,
      ),
    );

    await SheetJsonImporter(
      b.db,
    ).importJson(await a.exporter().exportJson(), replaceExisting: true);
    expect(await snapshot(b), await snapshot(a));
  });

  test(
    'ekspor: struktur, versi, format tanggal & bulan, waktu ekspor',
    () async {
      await seed(a);
      final map =
          jsonDecode(
                await a.exporter(DateTime(2026, 9, 26, 21, 30)).exportJson(),
              )
              as Map<String, dynamic>;

      expect(map['version'], 2);
      expect(map['app'], 'cc_expense_tracker');
      expect(
        map['exportedAt'],
        DateTime(2026, 9, 26, 21, 30).toIso8601String(),
      );
      expect(map.containsKey('settings'), isFalse);
      final akuns = (map['akuns'] as List).cast<Map<String, dynamic>>();
      expect(akuns.map((a) => a['nama']), ['Kartu Kredit', 'SPayLater']);
      final spay = akuns.last;
      expect(spay['limitKredit'], 3000000);
      expect(spay['saldoAwal'], 100000);
      expect(spay['tanggalCutoff'], 10);
      expect(spay['tanggalJatuhTempo'], 25);
      final akunIds = akuns.map((a) => a['id']).toSet();
      for (final key in ['subscriptions', 'cicilans', 'transaksis']) {
        for (final row in (map[key] as List).cast<Map<String, dynamic>>()) {
          expect(akunIds, contains(row['akunId']), reason: key);
        }
      }

      final trx = (map['transaksis'] as List).cast<Map<String, dynamic>>();
      final pembayaran = trx.firstWhere((t) => t['deskripsi'] == 'Pembayaran');
      expect(pembayaran['tanggal'], '2026-08-05');
      expect(pembayaran['bulanTagihan'], '2026-07');
      expect(pembayaran['jenis'], 'pembayaran');
      final dates = trx.map((t) => t['tanggal'] as String).toList();
      expect(dates, [...dates]..sort());

      final cicilan = (map['cicilans'] as List).first as Map<String, dynamic>;
      expect(cicilan['tanggalBayarTerakhir'], '2026-08-20');
    },
  );

  test('database kosong tetap menghasilkan file yang bisa direstore', () async {
    final json = await a.exporter().exportJson();
    final summary = await SheetJsonImporter(b.db).importJson(json);
    expect(
      [summary.transaksi, summary.split, summary.cicilan, summary.subscription],
      [0, 0, 0, 0],
    );
  });

  group('parser: tautan subscription lewat id', () {
    Map<String, dynamic> base() => {
      'version': 1,
      'subscriptions': [
        {
          'id': 10,
          'namaLayanan': 'Apple',
          'siklusBilling': 'bulanan',
          'status': 'aktif',
          'tanggalTagihanBerikutnya': '2026-10-01',
        },
        {
          'id': 11,
          'namaLayanan': 'Apple',
          'siklusBilling': 'tahunan',
          'status': 'aktif',
          'tanggalTagihanBerikutnya': '2027-01-01',
        },
      ],
      'transaksis': [
        {
          'tanggal': '2026-09-01',
          'deskripsi': 'x',
          'jenis': 'subscription',
          'sumberBayar': 'cc',
          'totalTagihan': 1,
          'status': 'paid',
          'subscriptionId': 11,
        },
      ],
    };

    Matcher error(String contains_) => throwsA(
      isA<DomainException>().having(
        (e) => e.message,
        'message',
        contains(contains_),
      ),
    );

    test('nama kembar boleh selama tautan lewat id', () {
      final b = parseImportJson(jsonEncode(base()));
      expect(b.subscriptions, hasLength(2));
      expect(b.transaksiSubscription, {0: 1});
    });

    test('tautan lewat nama pada nama kembar ditolak', () {
      final m = base();
      final t = (m['transaksis'] as List).first as Map<String, dynamic>;
      t.remove('subscriptionId');
      t['subscription'] = 'Apple';
      expect(() => parseImportJson(jsonEncode(m)), error('kembar'));
    });

    test('subscriptionId yang tidak ada / id kembar ditolak', () {
      final m = base();
      ((m['transaksis'] as List).first
              as Map<String, dynamic>)['subscriptionId'] =
          99;
      expect(() => parseImportJson(jsonEncode(m)), error('subscriptionId 99'));

      final dup = base();
      ((dup['subscriptions'] as List)[1] as Map<String, dynamic>)['id'] = 10;
      expect(() => parseImportJson(jsonEncode(dup)), error('"id" 10 kembar'));
    });
  });

  group('parser v2: akun', () {
    Map<String, dynamic> base() => {
      'version': 2,
      'akuns': [
        {
          'id': 7,
          'nama': 'Kartu Kredit',
          'limitKredit': 10000000,
          'tanggalCutoff': 4,
        },
        {
          'id': 9,
          'nama': 'SPayLater',
          'limitKredit': 3000000,
          'saldoAwal': 100000,
          'tanggalCutoff': 10,
        },
      ],
      'cicilans': [
        {
          'namaCicilan': 'Kulkas',
          'akunId': 9,
          'totalHargaBarang': 600000,
          'tenor': 6,
          'jumlahPerBulan': 100000,
          'tanggalMulai': '2026-09-01',
        },
      ],
      'transaksis': [
        {
          'tanggal': '2026-09-01',
          'deskripsi': 'x',
          'jenis': 'personal',
          'akunId': 9,
          'totalTagihan': 1,
          'status': 'paid',
        },
      ],
    };

    Matcher error(String contains_) => throwsA(
      isA<DomainException>().having(
        (e) => e.message,
        'message',
        contains(contains_),
      ),
    );

    test('akun & rujukan diterjemahkan ke indeks di daftar akun', () {
      final b = parseImportJson(jsonEncode(base()));
      expect(b.akuns.map((a) => a.nama), ['Kartu Kredit', 'SPayLater']);
      expect(b.akuns[1].limitKredit, 3000000);
      expect(b.akuns[1].saldoAwal, 100000);
      expect(b.akuns[1].tanggalCutoff, 10);
      expect(b.transaksis.single.akunId, 1);
      expect(b.cicilans.single.akunId, 1);
    });

    test(
      'akunId yang tidak ada, akun kosong, id kembar, cutoff di luar 0–31',
      () {
        final unknown = base();
        ((unknown['transaksis'] as List).first
                as Map<String, dynamic>)['akunId'] =
            99;
        expect(() => parseImportJson(jsonEncode(unknown)), error('akunId 99'));

        final missing = base();
        ((missing['transaksis'] as List).first as Map<String, dynamic>).remove(
          'akunId',
        );
        expect(() => parseImportJson(jsonEncode(missing)), error('akunId'));

        final empty = base()..['akuns'] = [];
        expect(() => parseImportJson(jsonEncode(empty)), error('minimal satu'));

        final dup = base();
        ((dup['akuns'] as List)[1] as Map<String, dynamic>)['id'] = 7;
        expect(() => parseImportJson(jsonEncode(dup)), error('"id" 7 kembar'));

        final cutoff = base();
        ((cutoff['akuns'] as List)[0]
                as Map<String, dynamic>)['tanggalCutoff'] =
            32;
        expect(() => parseImportJson(jsonEncode(cutoff)), error('0–31'));
      },
    );

    test(
      'import: data mendarat di akun yang benar walau id akun tidak berurutan',
      () async {
        await SheetJsonImporter(b.db).importJson(jsonEncode(base()));
        final akuns = await b.akun.getAll();
        final spay = akuns.firstWhere((a) => a.nama == 'SPayLater');
        expect((await b.transaksi.getAll()).single.akunId, spay.id);
        expect((await b.cicilan.watchAll().first).single.akunId, spay.id);
        expect(akuns.map((a) => a.nama), ['Kartu Kredit', 'SPayLater']);
      },
    );
  });
}
