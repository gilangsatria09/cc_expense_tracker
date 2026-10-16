import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils.dart';
import '../entities/akun.dart';
import '../entities/cicilan.dart';
import '../entities/dashboard_summary.dart';
import '../entities/enums.dart';
import '../entities/transaksi.dart';

class DashboardCalculator {
  const DashboardCalculator._();

  static DashboardSummary calculate({
    required List<Transaksi> transaksis,
    required List<Cicilan> cicilans,
    required List<Akun> akuns,
    required DateTime month,
    int? akunId,
  }) {
    bool dalamAkun(int id) => akunId == null || id == akunId;
    final scopeTrx = transaksis.where((t) => dalamAkun(t.akunId)).toList();
    final scopeCicilan = cicilans.where((c) => dalamAkun(c.akunId)).toList();
    final inMonth = scopeTrx
        .where((t) => isSameMonth(t.effectiveBulan, month))
        .toList();

    int sum(Iterable<Transaksi> items, int Function(Transaksi) value) =>
        items.fold(0, (total, t) => total + value(t));
    int total(Transaksi t) => t.totalTagihan;
    int bagianSaya(Transaksi t) => t.bagianSaya;

    bool bukanPembayaran(Transaksi t) => t.jenis != JenisTransaksi.pembayaran;
    bool jenis(Transaksi t, JenisTransaksi j) => t.jenis == j;

    final akunLimits = [
      for (final akun in akuns.where((a) => dalamAkun(a.id)))
        AkunLimit(
          akun: akun,
          totalTransaksiBaru: sum(
            transaksis.where((t) => t.akunId == akun.id && bukanPembayaran(t)),
            total,
          ),
          totalHargaCicilan: cicilans
              .where((c) => c.akunId == akun.id)
              .fold(0, (s, c) => s + c.totalHargaBarang),
          totalPembayaran: sum(
            transaksis.where(
              (t) => t.akunId == akun.id && jenis(t, JenisTransaksi.pembayaran),
            ),
            total,
          ),
        ),
    ];

    final tagihanBulanIni = sum(
      inMonth.where(
        (t) => bukanPembayaran(t) && t.status == StatusBayar.belumDibayar,
      ),
      bagianSaya,
    );
    final cicilanBulanIni = scopeCicilan
        .where((c) => c.jatuhTempoDi(month))
        .fold(0, (s, c) => s + c.jumlahPerBulan);

    final dibayarSementara = sum(
      inMonth.where(
        (t) => bukanPembayaran(t) && t.status == StatusBayar.paidTemp,
      ),
      total,
    );

    final personal = sum(
      inMonth.where(
        (t) =>
            jenis(t, JenisTransaksi.personal) &&
            (t.status == StatusBayar.belumDibayar ||
                t.status == StatusBayar.paidTemp),
      ),
      total,
    );
    int semua(JenisTransaksi j) =>
        sum(inMonth.where((t) => jenis(t, j)), total);

    final bebanSendiri = sum(
      inMonth.where(
        (t) =>
            bukanPembayaran(t) &&
            (t.status == StatusBayar.belumDibayar ||
                t.status == StatusBayar.paidTemp),
      ),
      bagianSaya,
    );
    final piutangTotal = sum(inMonth, (t) => t.ditagihKeTeman);

    int piutang(StatusBayar status) {
      var result = 0;
      for (final t in inMonth) {
        if (!t.isGroupOrder) continue;
        for (final s in t.splits) {
          if (s.nama != namaSaya && s.status == status) {
            result += t.tagihanUntuk(s);
          }
        }
      }
      return result;
    }

    return DashboardSummary(
      akunLimits: akunLimits,
      tagihanBulanIni: tagihanBulanIni,
      cicilanBulanIni: cicilanBulanIni,
      dibayarSementara: dibayarSementara,
      personal: personal,
      groupOrder: semua(JenisTransaksi.groupOrder),
      subscription: semua(JenisTransaksi.subscription),
      pembayaran: semua(JenisTransaksi.pembayaran),
      lainnya: semua(JenisTransaksi.lainnya),
      bebanSendiri: bebanSendiri,
      piutangTotal: piutangTotal,
      piutangPaid: piutang(StatusBayar.paid),
      piutangPaidTemp: piutang(StatusBayar.paidTemp),
      piutangBelumDibayar: piutang(StatusBayar.belumDibayar),
    );
  }
}
