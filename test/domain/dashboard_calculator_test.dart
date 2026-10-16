import 'package:cc_expense_tracker/domain/entities/akun.dart';
import 'package:cc_expense_tracker/domain/entities/cicilan.dart';
import 'package:cc_expense_tracker/domain/entities/dashboard_summary.dart';
import 'package:cc_expense_tracker/domain/entities/enums.dart';
import 'package:cc_expense_tracker/domain/entities/split_group_order.dart';
import 'package:cc_expense_tracker/domain/entities/transaksi.dart';
import 'package:cc_expense_tracker/domain/usecases/dashboard_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

final sep = DateTime(2026, 9);

const cc = Akun(id: 1, nama: 'Kartu Kredit');
const spay = Akun(id: 2, nama: 'SPayLater');

Transaksi trx(
  JenisTransaksi jenis,
  int total, {
  StatusBayar status = StatusBayar.belumDibayar,
  int akunId = 1,
  DateTime? tanggal,
  List<SplitGroupOrder> splits = const [],
}) => Transaksi(
  tanggal: tanggal ?? DateTime(2026, 9, 10),
  deskripsi: 'x',
  jenis: jenis,
  akunId: akunId,
  totalTagihan: total,
  status: status,
  splits: splits,
);

Cicilan cicilan({
  int total = 600000,
  int tenor = 6,
  int perBulan = 100000,
  int akunId = 1,
  DateTime? mulai,
}) => Cicilan(
  namaCicilan: 'c',
  akunId: akunId,
  totalHargaBarang: total,
  tenor: tenor,
  jumlahPerBulan: perBulan,
  tanggalMulai: mulai ?? DateTime(2026, 7),
);

DashboardSummary hitung({
  List<Transaksi> transaksis = const [],
  List<Cicilan> cicilans = const [],
  List<Akun> akuns = const [cc],
  int? akunId,
}) => DashboardCalculator.calculate(
  transaksis: transaksis,
  cicilans: cicilans,
  akuns: akuns,
  month: sep,
  akunId: akunId,
);

void main() {
  group('Section 0: limit per akun (all-time, tidak terfilter bulan)', () {
    test('outstanding = saldo awal + transaksi + cicilan − pembayaran', () {
      final s = hitung(
        akuns: const [
          Akun(
            id: 1,
            nama: 'Kartu Kredit',
            limitKredit: 1000000,
            saldoAwal: 40000,
          ),
        ],
        transaksis: [
          trx(JenisTransaksi.personal, 100000, tanggal: DateTime(2026, 1, 5)),
          trx(
            JenisTransaksi.groupOrder,
            200000,
          ),
          trx(JenisTransaksi.pembayaran, 80000),
        ],
        cicilans: [cicilan(total: 600000)],
      );
      final limit = s.akunLimits.single;
      expect(limit.totalTransaksiBaru, 300000);
      expect(limit.totalHargaCicilan, 600000);
      expect(limit.totalPembayaran, 80000);
      expect(limit.outstanding, 40000 + 300000 + 600000 - 80000);
      expect(limit.sisaLimit, 1000000 - 860000);
      expect(limit.persentaseLimitTerpakai, closeTo(0.86, 1e-9));
    });

    test('limit 0: persentase 0, bukan pembagian dengan nol', () {
      final s = hitung(transaksis: [trx(JenisTransaksi.personal, 1000)]);
      expect(s.akunLimits.single.persentaseLimitTerpakai, 0);
    });

    test(
      'tiap akun punya posisi limit sendiri; total gabungan menjumlahkannya',
      () {
        final s = hitung(
          akuns: const [
            Akun(
              id: 1,
              nama: 'Kartu Kredit',
              limitKredit: 10000000,
              saldoAwal: 500000,
            ),
            Akun(id: 2, nama: 'SPayLater', limitKredit: 3000000),
          ],
          transaksis: [
            trx(JenisTransaksi.personal, 1000000, akunId: 1),
            trx(JenisTransaksi.personal, 700000, akunId: 2),
            trx(JenisTransaksi.pembayaran, 200000, akunId: 2),
          ],
          cicilans: [
            cicilan(total: 1200000, akunId: 1),
            cicilan(total: 300000, akunId: 2),
          ],
        );
        final byName = {for (final l in s.akunLimits) l.akun.nama: l};
        expect(byName['Kartu Kredit']!.outstanding, 500000 + 1000000 + 1200000);
        expect(byName['SPayLater']!.outstanding, 700000 + 300000 - 200000);
        expect(byName['SPayLater']!.sisaLimit, 3000000 - 800000);
        expect(s.totalOutstanding, 2700000 + 800000);
        expect(s.totalSisaLimit, (10000000 - 2700000) + (3000000 - 800000));
        expect(s.totalLimit, 13000000);
      },
    );

    test('pembayaran hanya mengurangi akun yang dibayar', () {
      final s = hitung(
        akuns: const [cc, spay],
        transaksis: [
          trx(JenisTransaksi.personal, 500000, akunId: 1),
          trx(JenisTransaksi.personal, 500000, akunId: 2),
          trx(JenisTransaksi.pembayaran, 500000, akunId: 1),
        ],
      );
      final byName = {for (final l in s.akunLimits) l.akun.nama: l};
      expect(byName['Kartu Kredit']!.outstanding, 0);
      expect(byName['SPayLater']!.outstanding, 500000);
    });
  });

  group('filter akun', () {
    final data = (
      akuns: const [cc, spay],
      transaksis: [
        trx(JenisTransaksi.personal, 100000, akunId: 1),
        trx(JenisTransaksi.personal, 30000, akunId: 2),
        trx(JenisTransaksi.subscription, 55000, akunId: 2),
      ],
      cicilans: [
        cicilan(perBulan: 100000, akunId: 1),
        cicilan(perBulan: 40000, akunId: 2),
      ],
    );

    test('gabungan: semua akun dijumlahkan', () {
      final s = hitung(
        akuns: data.akuns,
        transaksis: data.transaksis,
        cicilans: data.cicilans,
      );
      expect(s.akunLimits, hasLength(2));
      expect(s.tagihanBulanIni, 185000);
      expect(s.cicilanBulanIni, 140000);
    });

    test('satu akun: limit dan bagian bulanan hanya untuk akun itu', () {
      final s = hitung(
        akuns: data.akuns,
        transaksis: data.transaksis,
        cicilans: data.cicilans,
        akunId: 2,
      );
      expect(s.akunLimits.map((l) => l.akun.nama), ['SPayLater']);
      expect(s.tagihanBulanIni, 85000);
      expect(s.cicilanBulanIni, 40000);
      expect(s.subscription, 55000);
      expect(s.personal, 30000);
    });
  });

  group('Section 1: perlu dibayar bulan ini', () {
    test('hanya bagian saya, Belum Dibayar, bukan Pembayaran', () {
      final s = hitung(
        transaksis: [
          trx(JenisTransaksi.personal, 100000),
          trx(JenisTransaksi.personal, 999, status: StatusBayar.paid),
          trx(JenisTransaksi.personal, 888, status: StatusBayar.paidTemp),
          trx(JenisTransaksi.pembayaran, 5000),
          trx(JenisTransaksi.personal, 555, tanggal: DateTime(2026, 8, 31)),
          trx(
            JenisTransaksi.groupOrder,
            300000,
            splits: const [
              SplitGroupOrder(nama: 'Gilang', hargaManual: 120000),
              SplitGroupOrder(nama: 'Budi', hargaManual: 180000),
            ],
          ),
        ],
      );
      expect(s.tagihanBulanIni, 100000 + 120000);
      expect(s.dibayarSementara, 888);
    });

    test(
      'cicilan bulan ini mengikuti jadwal: mulai ≤ bulan < mulai + tenor',
      () {
        final s = hitung(
          cicilans: [
            cicilan(
              perBulan: 100,
              mulai: DateTime(2026, 7),
              tenor: 6,
            ),
            cicilan(
              perBulan: 20,
              mulai: DateTime(2026, 9),
              tenor: 1,
            ),
            cicilan(perBulan: 3, mulai: DateTime(2026, 10)),
            cicilan(perBulan: 4, mulai: DateTime(2026, 1), tenor: 6),
          ],
        );
        expect(s.cicilanBulanIni, 120);
        expect(s.totalPerluDibayar, 120);
      },
    );

    test('bulan tagihan, bukan tanggal, yang menentukan bulan', () {
      final s = DashboardCalculator.calculate(
        transaksis: [
          Transaksi(
            tanggal: DateTime(2026, 8, 30),
            bulanTagihan: DateTime(2026, 9),
            deskripsi: 'x',
            jenis: JenisTransaksi.personal,
            akunId: 1,
            totalTagihan: 77000,
          ),
        ],
        cicilans: const [],
        akuns: const [cc],
        month: sep,
      );
      expect(s.tagihanBulanIni, 77000);
    });
  });

  group('Section 3: breakdown per jenis', () {
    test(
      'Personal tidak menghitung Paid; jenis lain menghitung semua status',
      () {
        final s = hitung(
          transaksis: [
            trx(JenisTransaksi.personal, 100),
            trx(JenisTransaksi.personal, 10, status: StatusBayar.paidTemp),
            trx(JenisTransaksi.personal, 1000, status: StatusBayar.paid),
            trx(JenisTransaksi.groupOrder, 200, status: StatusBayar.paid),
            trx(JenisTransaksi.subscription, 300, status: StatusBayar.paid),
            trx(JenisTransaksi.pembayaran, 400),
            trx(JenisTransaksi.lainnya, 500, status: StatusBayar.paid),
          ],
        );
        expect(s.personal, 110);
        expect(s.groupOrder, 200);
        expect(s.subscription, 300);
        expect(s.pembayaran, 400);
        expect(s.lainnya, 500);
      },
    );
  });

  group('Section 4 & 5: beban sendiri, piutang, perkiraan', () {
    final splits = [
      const SplitGroupOrder(
        nama: 'Gilang',
        hargaManual: 40000,
        status: StatusBayar.paidTemp,
      ),
      const SplitGroupOrder(
        nama: 'Budi',
        hargaManual: 30000,
        status: StatusBayar.paid,
      ),
      const SplitGroupOrder(
        nama: 'Ani',
        hargaManual: 20000,
        status: StatusBayar.paidTemp,
      ),
      const SplitGroupOrder(nama: 'Citra', hargaManual: 10000),
    ];

    test('piutang dipecah per status split, tanpa baris Gilang', () {
      final s = hitung(
        transaksis: [
          trx(
            JenisTransaksi.groupOrder,
            100000,
            status: StatusBayar.paidTemp,
            splits: splits,
          ),
        ],
      );
      expect(s.piutangTotal, 60000);
      expect(s.piutangPaid, 30000);
      expect(s.piutangPaidTemp, 20000);
      expect(s.piutangBelumDibayar, 10000);
      expect(s.bebanSendiri, 40000);
    });

    test('perkiraan = perlu dibayar + dibayar sementara − piutang Paid '
        '(dibayar sementara memakai TOTAL penuh, meniru sheet)', () {
      final s = hitung(
        transaksis: [
          trx(
            JenisTransaksi.groupOrder,
            100000,
            status: StatusBayar.paidTemp,
            splits: splits,
          ),
          trx(JenisTransaksi.personal, 25000),
        ],
        cicilans: [cicilan(perBulan: 50000)],
      );
      expect(s.tagihanBulanIni, 25000);
      expect(s.cicilanBulanIni, 50000);
      expect(s.dibayarSementara, 100000);
      expect(s.piutangPaid, 30000);
      expect(s.perkiraanBulanDepan, 25000 + 50000 + 100000 - 30000);
    });

    test('beban sendiri: Paid tidak dihitung, Pembayaran tidak dihitung', () {
      final s = hitung(
        transaksis: [
          trx(JenisTransaksi.personal, 100),
          trx(JenisTransaksi.personal, 10, status: StatusBayar.paidTemp),
          trx(JenisTransaksi.personal, 1000, status: StatusBayar.paid),
          trx(JenisTransaksi.pembayaran, 9999),
        ],
      );
      expect(s.bebanSendiri, 110);
    });
  });

  test('Cicilan.jatuhTempoDi: batas awal dan akhir jadwal', () {
    final c = cicilan(mulai: DateTime(2026, 11), tenor: 3);
    expect(c.jatuhTempoDi(DateTime(2026, 10)), isFalse);
    expect(c.jatuhTempoDi(DateTime(2026, 11)), isTrue);
    expect(c.jatuhTempoDi(DateTime(2027, 1)), isTrue);
    expect(c.jatuhTempoDi(DateTime(2027, 2)), isFalse);
  });
}
