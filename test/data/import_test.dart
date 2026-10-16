import 'dart:convert';

import 'package:cc_expense_tracker/core/error/domain_exception.dart';
import 'package:cc_expense_tracker/data/database/app_database.dart';
import 'package:cc_expense_tracker/data/import/import_parser.dart';
import 'package:cc_expense_tracker/data/import/sheet_json_importer.dart';
import 'package:cc_expense_tracker/data/repositories/cicilan_repository_impl.dart';
import 'package:cc_expense_tracker/data/repositories/akun_repository_impl.dart';
import 'package:cc_expense_tracker/data/repositories/subscription_repository_impl.dart';
import 'package:cc_expense_tracker/data/repositories/transaksi_repository_impl.dart';
import 'package:cc_expense_tracker/domain/entities/enums.dart';
import 'package:cc_expense_tracker/domain/entities/subscription.dart';
import 'package:cc_expense_tracker/domain/entities/transaksi.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> sample() => {
  'version': 1,
  'settings': {
    'limitCC': 10000000,
    'saldoOutstandingSebelumTracker': 3870954,
    'tanggalCutoffTagihan': 4,
  },
  'subscriptions': [
    {
      'namaLayanan': 'Claude',
      'hargaTetap': null,
      'siklusBilling': 'bulanan',
      'status': 'aktif',
      'tanggalTagihanBerikutnya': '2026-10-03',
      'catatan': null,
    },
  ],
  'cicilans': [
    {
      'namaCicilan': 'Kursi',
      'totalHargaBarang': 877387,
      'tenor': 6,
      'cicilanKe': 1,
      'jumlahPerBulan': 146231,
      'tanggalMulai': '2026-07-01',
      'tanggalBayarTerakhir': '2026-07-01',
      'catatan': 'cek bank',
    },
  ],
  'transaksis': [
    {
      'tanggal': '2026-08-05',
      'bulanTagihan': '2026-07',
      'deskripsi': 'Pembayaran CC',
      'jenis': 'pembayaranCC',
      'sumberBayar': 'saldo',
      'totalTagihan': 3470206,
      'status': 'paid',
    },
    {
      'tanggal': '2026-08-03',
      'bulanTagihan': '2026-08',
      'deskripsi': 'Claude subscription',
      'jenis': 'subscription',
      'sumberBayar': 'cc',
      'totalTagihan': 349000,
      'status': 'paidTemp',
      'subscription': 'Claude',
      'sumberEkstraksi': 'manual',
    },
    {
      'tanggal': '2026-08-10',
      'bulanTagihan': '2026-08',
      'deskripsi': 'Espresso',
      'jenis': 'groupOrder',
      'sumberBayar': 'cc',
      'totalTagihan': 57341,
      'merchant': 'Espresso',
      'status': 'paidTemp',
      'splits': [
        {'nama': 'Gilang', 'hargaManual': 28673, 'status': 'paidTemp'},
        {'nama': 'Daniel', 'hargaManual': 28668, 'status': 'paidTemp'},
        {'nama': 'Daniel', 'hargaManual': null, 'status': 'belumDibayar'},
      ],
    },
  ],
};

String jsonOf(Map<String, dynamic> m) => jsonEncode(m);

void main() {
  Matcher domainError(String contains_) => throwsA(
    isA<DomainException>().having(
      (e) => e.message,
      'message',
      contains(contains_),
    ),
  );

  group('parseImportJson', () {
    test('parse lengkap: enum, tanggal, bulan tagihan, split, tautan', () {
      final b = parseImportJson(jsonOf(sample()));

      final akun = b.akuns.single;
      expect(akun.nama, 'Kartu Kredit');
      expect(akun.limitKredit, 10000000);
      expect(akun.saldoAwal, 3870954);
      expect(akun.tanggalCutoff, 4);
      expect(b.transaksis.map((t) => t.akunId).toSet(), {0});
      expect(b.cicilans.single.akunId, 0);
      expect(b.subscriptions.single.akunId, 0);
      expect(b.subscriptions.single.namaLayanan, 'Claude');
      expect(b.subscriptions.single.hargaTetap, isNull);
      expect(b.subscriptions.single.hariTagihan, 3);
      expect(b.cicilans.single.cicilanKe, 1);
      expect(b.cicilans.single.tanggalBayarTerakhir, DateTime(2026, 7));

      final pembayaran = b.transaksis[0];
      expect(pembayaran.jenis, JenisTransaksi.pembayaran);
      expect(pembayaran.tanggal, DateTime(2026, 8, 5));
      expect(pembayaran.bulanTagihan, DateTime(2026, 7));
      expect(b.transaksis[2].splits, hasLength(3));
      expect(b.transaksiSubscription, {
        1: 0,
      });
    });

    test(
      'settings & daftar boleh tidak ada; akun implisit berisi nilai kosong',
      () {
        final b = parseImportJson(jsonOf({'version': 1}));
        expect(b.akuns.single.limitKredit, 0);
        expect(b.akuns.single.tanggalCutoff, 0);
        expect(b.transaksis, isEmpty);
      },
    );

    test(
      'v1: field lama sumberBayar diabaikan; jenis "pembayaranCC" dikenali',
      () {
        final m = sample();
        final t = (m['transaksis'] as List)[0] as Map<String, dynamic>;
        t['jenis'] = 'pembayaranCC';
        t['sumberBayar'] = 'saldo';
        final parsed = parseImportJson(jsonOf(m)).transaksis[0];
        expect(parsed.jenis, JenisTransaksi.pembayaran);
      },
    );

    test('bukan JSON / bukan objek / versi salah', () {
      expect(() => parseImportJson('bukan json'), domainError('bukan JSON'));
      expect(() => parseImportJson('[]'), domainError('Format file'));
      expect(
        () => parseImportJson(jsonOf({'version': 3})),
        domainError('Versi format 3'),
      );
    });

    test('kesalahan menyebut baris & nilai yang valid', () {
      final bad = sample();
      (bad['transaksis'] as List)[1]['jenis'] = 'gajian';
      expect(
        () => parseImportJson(jsonOf(bad)),
        domainError('Transaksi ke-2: "jenis" berisi "gajian"'),
      );

      final noTotal = sample();
      (noTotal['transaksis'] as List)[0].remove('totalTagihan');
      expect(
        () => parseImportJson(jsonOf(noTotal)),
        domainError('Transaksi ke-1: "totalTagihan" wajib diisi'),
      );

      final badSplit = sample();
      ((badSplit['transaksis'] as List)[2]['splits'] as List)[1]['status'] =
          'x';
      expect(
        () => parseImportJson(jsonOf(badSplit)),
        domainError('split ke-2'),
      );
    });

    test('format tanggal & bulan, total negatif, cicilanKe di luar tenor', () {
      final a = sample();
      (a['transaksis'] as List)[0]['tanggal'] = '5 Agustus';
      expect(() => parseImportJson(jsonOf(a)), domainError('YYYY-MM-DD'));

      final b = sample();
      (b['transaksis'] as List)[0]['bulanTagihan'] = '2026-13';
      expect(() => parseImportJson(jsonOf(b)), domainError('YYYY-MM'));

      final c = sample();
      (c['transaksis'] as List)[0]['totalTagihan'] = -1;
      expect(() => parseImportJson(jsonOf(c)), domainError('negatif'));

      final d = sample();
      (d['cicilans'] as List)[0]['cicilanKe'] = 7;
      expect(() => parseImportJson(jsonOf(d)), domainError('cicilanKe'));
    });

    test(
      'tautan ke subscription yang tidak ada / nama subscription kembar',
      () {
        final a = sample();
        (a['transaksis'] as List)[1]['subscription'] = 'Netflix';
        expect(
          () => parseImportJson(jsonOf(a)),
          domainError('"Netflix" tidak ada'),
        );

        final b = sample();
        (b['subscriptions'] as List).add((b['subscriptions'] as List).first);
        expect(() => parseImportJson(jsonOf(b)), domainError('kembar'));
      },
    );
  });

  group('SheetJsonImporter', () {
    late AppDatabase db;
    late SheetJsonImporter importer;

    setUp(() {
      db = AppDatabase.inMemory();
      importer = SheetJsonImporter(db);
    });
    tearDown(() => db.close());

    test(
      'impor ke database kosong: semua data, tautan, bulan tagihan, settings',
      () async {
        expect(await importer.hasData(), isFalse);
        final summary = await importer.importJson(jsonOf(sample()));

        expect(summary.transaksi, 3);
        expect(summary.split, 3);
        expect(summary.cicilan, 1);
        expect(summary.subscription, 1);
        expect(await importer.hasData(), isTrue);

        final trx = TransaksiRepositoryImpl(db);
        final all = await trx.getAll();
        final pembayaran = all.firstWhere(
          (t) => t.jenis == JenisTransaksi.pembayaran,
        );
        expect(pembayaran.tanggal, DateTime(2026, 8, 5));
        expect(pembayaran.bulanTagihan, DateTime(2026, 7));

        expect(
          await db.transaksiDao.getByMonth(DateTime(2026, 7)),
          hasLength(1),
        );

        final subs = await SubscriptionRepositoryImpl(db).getAll();
        final claude = all.firstWhere(
          (t) => t.jenis == JenisTransaksi.subscription,
        );
        expect(claude.subscriptionId, subs.single.id);

        final group = all.firstWhere((t) => t.isGroupOrder);
        expect(group.splits.map((s) => s.nama), ['Gilang', 'Daniel', 'Daniel']);
        expect(group.bagianSaya, 28673);

        final cicilan = (await CicilanRepositoryImpl(
          db,
        ).watchAll().first).single;
        expect(cicilan.cicilanKe, 1);

        final akuns = await AkunRepositoryImpl(db).getAll();
        expect(akuns, hasLength(1));
        expect(akuns.single.limitKredit, 10000000);
        expect(akuns.single.saldoAwal, 3870954);
        expect(akuns.single.tanggalCutoff, 4);
        expect(all.map((t) => t.akunId).toSet(), {akuns.single.id});
        expect(cicilan.akunId, akuns.single.id);
        expect(subs.single.akunId, akuns.single.id);
      },
    );

    test('file salah: tidak ada satu pun data yang masuk (atomik)', () async {
      final bad = sample();
      (bad['transaksis'] as List)[2]['jenis'] = 'salah';
      await expectLater(
        importer.importJson(jsonOf(bad)),
        throwsA(isA<DomainException>()),
      );
      expect(await importer.hasData(), isFalse);
      final akuns = await AkunRepositoryImpl(db).getAll();
      expect(akuns.single.nama, 'Kartu Kredit');
      expect(akuns.single.limitKredit, 0);
    });

    test(
      'database berisi ditolak; replaceExisting mengganti semuanya',
      () async {
        await importer.importJson(jsonOf(sample()));
        await expectLater(
          importer.importJson(jsonOf(sample())),
          throwsA(
            isA<DomainException>().having(
              (e) => e.message,
              'message',
              contains('sudah berisi data'),
            ),
          ),
        );
        expect(await TransaksiRepositoryImpl(db).getAll(), hasLength(3));

        await SubscriptionRepositoryImpl(db).save(
          Subscription(
            namaLayanan: 'Lama',
            akunId: (await AkunRepositoryImpl(db).getAll()).first.id,
            siklusBilling: SiklusBilling.bulanan,
            tanggalTagihanBerikutnya: DateTime(2026, 10, 1),
          ),
        );
        final summary = await importer.importJson(
          jsonOf(sample()),
          replaceExisting: true,
        );
        expect(summary.transaksi, 3);
        expect(await TransaksiRepositoryImpl(db).getAll(), hasLength(3));
        final subs = await SubscriptionRepositoryImpl(db).getAll();
        expect(subs.map((s) => s.namaLayanan), ['Claude']);
        expect(await db.splitDao.getAll(), hasLength(3));
      },
    );

    test(
      'replaceExisting dengan file salah tidak menghapus data lama',
      () async {
        await importer.importJson(jsonOf(sample()));
        final bad = sample();
        (bad['cicilans'] as List)[0]['tenor'] = 0;
        await expectLater(
          importer.importJson(jsonOf(bad), replaceExisting: true),
          throwsA(isA<DomainException>()),
        );
        expect(await TransaksiRepositoryImpl(db).getAll(), hasLength(3));
      },
    );
  });

  test('Transaksi hasil impor: subscriptionId null bila tidak ditautkan', () {
    final b = parseImportJson(jsonOf(sample()));
    final Transaksi t = b.transaksis[0];
    expect(t.subscriptionId, isNull);
  });
}
