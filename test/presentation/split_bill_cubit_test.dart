import 'dart:typed_data';

import 'package:cc_expense_tracker/core/error/domain_exception.dart';
import 'package:cc_expense_tracker/data/database/app_database.dart';
import 'package:cc_expense_tracker/data/repositories/transaksi_repository_impl.dart';
import 'package:cc_expense_tracker/domain/entities/enums.dart';
import 'package:cc_expense_tracker/domain/entities/extracted_split.dart';
import 'package:cc_expense_tracker/domain/entities/split_group_order.dart';
import 'package:cc_expense_tracker/domain/entities/transaksi.dart';
import 'package:cc_expense_tracker/domain/services/split_extractor.dart';
import 'package:cc_expense_tracker/presentation/split_bill/bloc/split_bill_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeExtractor implements SplitExtractor {
  FakeExtractor(this.result);

  Object result;

  @override
  Future<List<ExtractedSplit>> extract({
    required Uint8List imageBytes,
    required String mimeType,
  }) async {
    final r = result;
    if (r is DomainException) throw r;
    return r as List<ExtractedSplit>;
  }
}

void main() {
  late AppDatabase db;
  late TransaksiRepositoryImpl repo;
  late FakeExtractor extractor;

  setUp(() {
    db = AppDatabase.inMemory();
    repo = TransaksiRepositoryImpl(db);
    extractor = FakeExtractor(const <ExtractedSplit>[]);
  });
  tearDown(() => db.close());

  SplitBillCubit newCubit({
    int total = 100000,
    int ongkir = 0,
    List<SplitGroupOrder> initial = const [],
  }) {
    final c = SplitBillCubit(
      extractor,
      repo,
      totalTagihan: total,
      ongkirFee: ongkir,
      initial: initial,
    );
    addTearDown(c.close);
    return c;
  }

  test('awal: satu baris "Gilang"', () {
    final c = newCubit();
    expect(c.state.rows.map((r) => r.nama), ['Gilang']);
    expect(c.state.hasSelf, isTrue);
  });

  test('split rata: bagianRata, tanpa selisih (sisa pembulatan diabaikan)', () {
    final c = newCubit(total: 100000)
      ..addName('Budi')
      ..addName('Ani');
    expect(c.state.jumlahOrang, 3);
    expect(c.state.bagianRata, 33333);
    expect(c.state.selisih, 0);

    final result = c.confirm()!;
    expect(result.splits.map((s) => s.hargaManual), [null, null, null]);
    expect(result.sumberEkstraksi, SumberEkstraksi.manual);
  });

  test('override manual mempengaruhi selisih; kosongkan = kembali rata', () {
    final c = newCubit(total: 100000)..addName('Budi');
    final gilang = c.state.rows[0].id;
    final budi = c.state.rows[1].id;

    c.setAmount(gilang, 30000);
    expect(c.state.effectiveAmounts, [30000, 50000]);
    expect(c.state.selisih, 20000);

    c.setAmount(budi, 70000);
    expect(c.state.selisih, 0);

    c.setAmount(gilang, null);
    c.setAmount(budi, null);
    expect(c.state.selisih, 0);
  });

  test('nama duplikat (case-insensitive) & kosong ditolak', () {
    final c = newCubit()..addName('budi');
    c.addName('  BUDI ');
    expect(c.state.rows, hasLength(2));
    expect(c.state.error, contains('sudah ada'));

    c.addName('   ');
    expect(c.state.rows, hasLength(2));

    c.addName('Ani');
    c.rename(c.state.rows.last.id, 'budi');
    expect(c.confirm(), isNull);
    expect(c.state.error, 'Nama peserta tidak boleh sama');

    c.rename(c.state.rows.last.id, '');
    expect(c.confirm(), isNull);
    expect(c.state.error, 'Nama peserta tidak boleh kosong');
  });

  test('tanpa peserta ditolak; tanpa "Gilang" hanya peringatan', () {
    final c = newCubit();
    c.removeRow(c.state.rows.single.id);
    expect(c.state.hasSelf, isFalse);
    expect(c.confirm(), isNull);
    expect(c.state.error, 'Tambahkan minimal satu peserta');

    c.addName('Budi');
    expect(c.confirm(), isNotNull);
  });

  test(
    'AI: ongkir dibagi rata & ditambahkan ke subtotal, sumber tercatat',
    () async {
      extractor.result = const [
        ExtractedSplit(nama: 'Gilang', subtotal: 30000),
        ExtractedSplit(nama: 'Budi', subtotal: 35000),
        ExtractedSplit(nama: 'Ani', subtotal: 25000),
      ];
      final c = newCubit(total: 100000, ongkir: 10000)
        ..setSumberAi(SumberEkstraksi.aiChatGroup);

      await c.extract(Uint8List(1), 'image/png');

      expect(c.state.extracting, isFalse);
      expect(c.state.rows.map((r) => r.amount), [33334, 38333, 28333]);
      expect(c.state.selisih, 0);

      final result = c.confirm()!;
      expect(result.sumberEkstraksi, SumberEkstraksi.aiChatGroup);
      expect(result.splits.map((s) => s.hargaManual), [33334, 38333, 28333]);
    },
  );

  test(
    'AI: total beda dari order memunculkan selisih (tidak memblokir simpan)',
    () async {
      extractor.result = const [
        ExtractedSplit(nama: 'Gilang', subtotal: 30000),
        ExtractedSplit(nama: 'Budi', subtotal: 35000),
      ];
      final c = newCubit(total: 100000);
      await c.extract(Uint8List(1), 'image/jpeg');

      expect(c.state.selisih, 35000);
      expect(c.confirm(), isNotNull);
    },
  );

  test('AI gagal / kosong: daftar lama dipertahankan, error tampil', () async {
    final c = newCubit()..addName('Budi');

    extractor.result = const DomainException('Kuota Gemini habis');
    await c.extract(Uint8List(1), 'image/png');
    expect(c.state.error, 'Kuota Gemini habis');
    expect(c.state.extracting, isFalse);
    expect(c.state.rows.map((r) => r.nama), ['Gilang', 'Budi']);

    extractor.result = const <ExtractedSplit>[];
    await c.extract(Uint8List(1), 'image/png');
    expect(c.state.error, contains('Tidak ada pesanan'));
    expect(c.state.rows, hasLength(2));
    expect(c.state.aiUsed, isNull);
  });

  test('edit split yang sudah ada: baris & status dipertahankan', () {
    final c = newCubit(
      initial: const [
        SplitGroupOrder(nama: 'Gilang', hargaManual: 40000),
        SplitGroupOrder(nama: 'Budi', status: StatusBayar.paid),
      ],
    );
    expect(c.state.rows.map((r) => r.nama), ['Gilang', 'Budi']);
    c.addName('Ani');
    expect(c.state.rows.last.id, isNot(c.state.rows.first.id));

    final result = c.confirm()!;
    expect(result.splits[0].hargaManual, 40000);
    expect(result.splits[1].status, StatusBayar.paid);
  });

  test(
    'nama saran urut: paling sering dipakai, lalu terbaru, lalu abjad',
    () async {
      Future<void> order(DateTime d, List<String> names) => repo.save(
        Transaksi(
          tanggal: d,
          deskripsi: 'x',
          jenis: JenisTransaksi.groupOrder,
          akunId: 1,
          totalTagihan: 1000,
          splits: [for (final n in names) SplitGroupOrder(nama: n)],
        ),
      );
      await order(DateTime(2026, 9, 1), ['Ani', 'Budi', 'Citra']);
      await order(DateTime(2026, 9, 5), ['Ani', 'Citra']);
      await order(DateTime(2026, 9, 10), ['Ani', 'Dedi']);

      final c = newCubit();
      await c.loadKnownNames();
      expect(c.state.knownNames, ['Ani', 'Citra', 'Dedi', 'Budi']);
    },
  );

  test(
    'saran tidak memuat nama yang sudah ada (tanpa beda huruf besar/kecil)',
    () async {
      await repo.save(
        Transaksi(
          tanggal: DateTime(2026, 9, 1),
          deskripsi: 'x',
          jenis: JenisTransaksi.groupOrder,
          akunId: 1,
          totalTagihan: 1000,
          splits: const [
            SplitGroupOrder(nama: 'Budi'),
            SplitGroupOrder(nama: 'Ani'),
          ],
        ),
      );
      final c = newCubit();
      await c.loadKnownNames();
      expect(c.state.suggestions, ['Ani', 'Budi']);

      c.addName(
        'BUDI',
      );
      expect(c.state.suggestions, ['Ani']);
    },
  );

  test(
    'nama baru langsung jadi saran, dan tetap ada setelah barisnya dihapus',
    () async {
      final c = newCubit();
      await c.loadKnownNames();
      expect(c.state.knownNames, isEmpty);

      c.addName('Zaki');
      expect(c.state.knownNames, ['Zaki']);
      expect(c.state.suggestions, isEmpty);

      c.removeRow(c.state.rows.last.id);
      expect(c.state.suggestions, ['Zaki']);

      c.addName('zaki');
      expect(c.state.knownNames, ['Zaki']);
    },
  );

  test('loadKnownNames mengambil nama dari transaksi sebelumnya', () async {
    await repo.save(
      Transaksi(
        tanggal: DateTime(2026, 9, 1),
        deskripsi: 'x',
        jenis: JenisTransaksi.groupOrder,
        akunId: 1,
        totalTagihan: 1000,
        splits: const [SplitGroupOrder(nama: 'Citra')],
      ),
    );
    final c = newCubit();
    await c.loadKnownNames();
    expect(c.state.knownNames, ['Citra']);
  });
}
