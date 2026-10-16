import 'package:cc_expense_tracker/core/utils/date_utils.dart';
import 'package:cc_expense_tracker/domain/entities/cicilan.dart';
import 'package:cc_expense_tracker/domain/entities/enums.dart';
import 'package:cc_expense_tracker/domain/entities/split_group_order.dart';
import 'package:cc_expense_tracker/domain/entities/transaksi.dart';
import 'package:flutter_test/flutter_test.dart';

Transaksi groupTrx(int total, List<SplitGroupOrder> splits) => Transaksi(
  tanggal: DateTime(2026, 9, 1),
  deskripsi: 'Makan',
  jenis: JenisTransaksi.groupOrder,
  akunId: 1,
  totalTagihan: total,
  splits: splits,
);

void main() {
  group('Transaksi computed', () {
    test('non-GroupOrder: bagianSaya = total, ditagihKeTeman = 0', () {
      final t = Transaksi(
        tanggal: DateTime(2026, 9, 1),
        deskripsi: 'Kopi',
        jenis: JenisTransaksi.personal,
        akunId: 1,
        totalTagihan: 50000,
      );
      expect(t.bagianSaya, 50000);
      expect(t.ditagihKeTeman, 0);
    });

    test('split rata: total / jumlahOrang', () {
      final t = groupTrx(90000, const [
        SplitGroupOrder(nama: 'Gilang'),
        SplitGroupOrder(nama: 'Budi'),
        SplitGroupOrder(nama: 'Ani'),
      ]);
      expect(t.bagianRata, 30000);
      expect(t.bagianSaya, 30000);
      expect(t.ditagihKeTeman, 60000);
    });

    test('hargaManual menimpa bagianRata', () {
      final t = groupTrx(100000, const [
        SplitGroupOrder(nama: 'Gilang', hargaManual: 70000),
        SplitGroupOrder(nama: 'Budi', hargaManual: 30000),
      ]);
      expect(t.bagianSaya, 70000);
      expect(t.ditagihKeTeman, 30000);
    });

    test('GroupOrder belum di-split: semua bagian saya', () {
      expect(groupTrx(80000, const []).bagianSaya, 80000);
    });

    test('ter-split tanpa baris Gilang: bagianSaya 0', () {
      final t = groupTrx(80000, const [SplitGroupOrder(nama: 'Budi')]);
      expect(t.bagianSaya, 0);
      expect(t.ditagihKeTeman, 80000);
    });
  });

  group('Cicilan computed', () {
    final base = Cicilan(
      namaCicilan: 'HP',
      akunId: 1,
      totalHargaBarang: 1200000,
      tenor: 12,
      cicilanKe: 3,
      jumlahPerBulan: 100000,
      tanggalMulai: DateTime(2026, 6, 1),
    );

    test('sisa, sudah dibayar, lunas', () {
      expect(base.totalSudahDibayar, 300000);
      expect(base.sisaCicilan, 900000);
      expect(base.lunas, isFalse);
      expect(base.copyWith(cicilanKe: 12).lunas, isTrue);
    });

    test('bisaBayar: false kalau sudah bayar bulan ini atau lunas', () {
      final now = DateTime(2026, 9, 25);
      expect(base.bisaBayar(now), isTrue);
      final paid = base.copyWith(
        tanggalBayarTerakhir: () => DateTime(2026, 9, 2),
      );
      expect(paid.bisaBayar(now), isFalse);
      expect(paid.bisaBayar(DateTime(2026, 10, 1)), isTrue);
      expect(base.copyWith(cicilanKe: 12).bisaBayar(now), isFalse);
    });
  });

  test('addMonths clamp akhir bulan & lintas tahun', () {
    expect(addMonths(DateTime(2026, 1, 31), 1), DateTime(2026, 2, 28));
    expect(addMonths(DateTime(2028, 1, 31), 1), DateTime(2028, 2, 29));
    expect(addMonths(DateTime(2026, 12, 15), 1), DateTime(2027, 1, 15));
    expect(addMonths(DateTime(2026, 3, 10), 12), DateTime(2027, 3, 10));
    expect(addMonths(DateTime(2026, 2, 28), 1, day: 31), DateTime(2026, 3, 31));
  });
}
