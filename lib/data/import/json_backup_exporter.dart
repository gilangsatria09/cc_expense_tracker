import 'dart:convert';

import '../../domain/repositories/akun_repository.dart';
import '../../domain/repositories/cicilan_repository.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../../domain/repositories/transaksi_repository.dart';
import '../../domain/services/data_exporter.dart';

class JsonBackupExporter implements DataExporter {
  JsonBackupExporter(
    this._transaksi,
    this._cicilan,
    this._subscription,
    this._akun, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final TransaksiRepository _transaksi;
  final CicilanRepository _cicilan;
  final SubscriptionRepository _subscription;
  final AkunRepository _akun;
  final DateTime Function() _now;

  @override
  Future<String> exportJson() async {
    final akuns = await _akun.getAll();
    final subscriptions = await _subscription.getAll();
    final cicilans = await _cicilan.watchAll().first;
    final transaksis = await _transaksi.getAll()
      ..sort((a, b) {
        final byDate = a.tanggal.compareTo(b.tanggal);
        return byDate != 0 ? byDate : a.id.compareTo(b.id);
      });

    final data = <String, dynamic>{
      'version': 2,
      'app': 'cc_expense_tracker',
      'exportedAt': _now().toIso8601String(),
      'akuns': [
        for (final a in akuns)
          {
            'id': a.id,
            'nama': a.nama,
            'limitKredit': a.limitKredit,
            'saldoAwal': a.saldoAwal,
            'tanggalCutoff': a.tanggalCutoff,
            'tanggalJatuhTempo': a.tanggalJatuhTempo,
          },
      ],
      'subscriptions': [
        for (final s in subscriptions)
          {
            'id': s.id,
            'akunId': s.akunId,
            'namaLayanan': s.namaLayanan,
            'hargaTetap': s.hargaTetap,
            'siklusBilling': s.siklusBilling.name,
            'tanggalTagihanBerikutnya': _date(s.tanggalTagihanBerikutnya),
            'hariTagihan': s.hariTagihan,
            'status': s.status.name,
            'catatan': s.catatan,
          },
      ],
      'cicilans': [
        for (final c in cicilans)
          {
            'namaCicilan': c.namaCicilan,
            'akunId': c.akunId,
            'totalHargaBarang': c.totalHargaBarang,
            'tenor': c.tenor,
            'cicilanKe': c.cicilanKe,
            'jumlahPerBulan': c.jumlahPerBulan,
            'tanggalMulai': _date(c.tanggalMulai),
            'tanggalBayarTerakhir': c.tanggalBayarTerakhir == null
                ? null
                : _date(c.tanggalBayarTerakhir!),
            'catatan': c.catatan,
          },
      ],
      'transaksis': [
        for (final t in transaksis)
          {
            'tanggal': _date(t.tanggal),
            'bulanTagihan': _month(t.effectiveBulan),
            'deskripsi': t.deskripsi,
            'jenis': t.jenis.name,
            'akunId': t.akunId,
            'totalTagihan': t.totalTagihan,
            'merchant': t.merchant,
            'ongkirFee': t.ongkirFee,
            'status': t.status.name,
            'catatan': t.catatan,
            'subscriptionId': t.subscriptionId,
            'sumberEkstraksi': t.sumberEkstraksi?.name,
            'splits': [
              for (final s in t.splits)
                {
                  'nama': s.nama,
                  'hargaManual': s.hargaManual,
                  'status': s.status.name,
                  'catatan': s.catatan,
                },
            ],
          },
      ],
    };
    return const JsonEncoder.withIndent(' ').convert(data);
  }

  static String _two(int n) => n.toString().padLeft(2, '0');

  static String _month(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${_two(d.month)}';

  static String _date(DateTime d) => '${_month(d)}-${_two(d.day)}';
}
