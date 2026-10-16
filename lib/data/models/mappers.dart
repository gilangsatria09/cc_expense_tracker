import 'package:drift/drift.dart';

import '../../domain/entities/akun.dart';
import '../../domain/entities/cicilan.dart';
import '../../domain/entities/split_group_order.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/entities/transaksi.dart';
import '../database/app_database.dart';

extension SplitRowMapper on SplitGroupOrderRow {
  SplitGroupOrder toEntity() => SplitGroupOrder(
    id: id,
    nama: nama,
    hargaManual: hargaManual,
    status: status,
    catatan: catatan,
  );
}

extension SplitEntityMapper on SplitGroupOrder {
  SplitGroupOrdersCompanion toCompanion(int transaksiId) =>
      SplitGroupOrdersCompanion.insert(
        transaksiId: transaksiId,
        nama: nama,
        hargaManual: Value(hargaManual),
        status: status,
        catatan: Value(catatan),
      );
}

extension TransaksiRowMapper on TransaksiRow {
  Transaksi toEntity(List<SplitGroupOrderRow> splitRows) => Transaksi(
    id: id,
    tanggal: tanggal,
    bulanTagihan: bulanTagihan,
    deskripsi: deskripsi,
    jenis: jenis,
    akunId: akunId,
    totalTagihan: totalTagihan,
    merchant: merchant,
    ongkirFee: ongkirFee,
    status: status,
    catatan: catatan,
    subscriptionId: subscriptionId,
    sumberEkstraksi: sumberEkstraksi,
    splits: splitRows.map((s) => s.toEntity()).toList(),
  );
}

extension TransaksiEntityMapper on Transaksi {
  TransaksisCompanion toCompanion() => TransaksisCompanion.insert(
    tanggal: tanggal,
    bulanTagihan: Value(effectiveBulan),
    deskripsi: deskripsi,
    jenis: jenis,
    akunId: akunId,
    totalTagihan: totalTagihan,
    merchant: Value(merchant),
    ongkirFee: Value(ongkirFee),
    status: status,
    catatan: Value(catatan),
    subscriptionId: Value(subscriptionId),
    sumberEkstraksi: Value(sumberEkstraksi),
  );

  TransaksiRow toRow() => TransaksiRow(
    id: id,
    tanggal: tanggal,
    bulanTagihan: effectiveBulan,
    deskripsi: deskripsi,
    jenis: jenis,
    akunId: akunId,
    totalTagihan: totalTagihan,
    merchant: merchant,
    ongkirFee: ongkirFee,
    status: status,
    catatan: catatan,
    subscriptionId: subscriptionId,
    sumberEkstraksi: sumberEkstraksi,
  );
}

extension CicilanRowMapper on CicilanRow {
  Cicilan toEntity() => Cicilan(
    id: id,
    namaCicilan: namaCicilan,
    akunId: akunId,
    totalHargaBarang: totalHargaBarang,
    tenor: tenor,
    cicilanKe: cicilanKe,
    jumlahPerBulan: jumlahPerBulan,
    tanggalMulai: tanggalMulai,
    tanggalBayarTerakhir: tanggalBayarTerakhir,
    catatan: catatan,
  );
}

extension CicilanEntityMapper on Cicilan {
  CicilansCompanion toCompanion() => CicilansCompanion.insert(
    namaCicilan: namaCicilan,
    akunId: akunId,
    totalHargaBarang: totalHargaBarang,
    tenor: tenor,
    cicilanKe: Value(cicilanKe),
    jumlahPerBulan: jumlahPerBulan,
    tanggalMulai: tanggalMulai,
    tanggalBayarTerakhir: Value(tanggalBayarTerakhir),
    catatan: Value(catatan),
  );

  CicilanRow toRow() => CicilanRow(
    id: id,
    namaCicilan: namaCicilan,
    akunId: akunId,
    totalHargaBarang: totalHargaBarang,
    tenor: tenor,
    cicilanKe: cicilanKe,
    jumlahPerBulan: jumlahPerBulan,
    tanggalMulai: tanggalMulai,
    tanggalBayarTerakhir: tanggalBayarTerakhir,
    catatan: catatan,
  );
}

extension SubscriptionRowMapper on SubscriptionRow {
  Subscription toEntity() => Subscription(
    id: id,
    namaLayanan: namaLayanan,
    akunId: akunId,
    hargaTetap: hargaTetap,
    siklusBilling: siklusBilling,
    tanggalTagihanBerikutnya: tanggalTagihanBerikutnya,
    hariTagihan: hariTagihan,
    status: status,
    catatan: catatan,
  );
}

extension SubscriptionEntityMapper on Subscription {
  SubscriptionsCompanion toCompanion() => SubscriptionsCompanion.insert(
    namaLayanan: namaLayanan,
    akunId: akunId,
    hargaTetap: Value(hargaTetap),
    siklusBilling: siklusBilling,
    tanggalTagihanBerikutnya: tanggalTagihanBerikutnya,
    hariTagihan: hariTagihan,
    status: status,
    catatan: Value(catatan),
  );

  SubscriptionRow toRow() => SubscriptionRow(
    id: id,
    namaLayanan: namaLayanan,
    akunId: akunId,
    hargaTetap: hargaTetap,
    siklusBilling: siklusBilling,
    tanggalTagihanBerikutnya: tanggalTagihanBerikutnya,
    hariTagihan: hariTagihan,
    status: status,
    catatan: catatan,
  );
}

extension AkunRowMapper on AkunRow {
  Akun toEntity() => Akun(
    id: id,
    nama: nama,
    limitKredit: limitKredit,
    saldoAwal: saldoAwal,
    tanggalCutoff: tanggalCutoff,
    tanggalJatuhTempo: tanggalJatuhTempo,
  );
}

extension AkunEntityMapper on Akun {
  AkunsCompanion toCompanion() => AkunsCompanion.insert(
    nama: nama,
    limitKredit: Value(limitKredit),
    saldoAwal: Value(saldoAwal),
    tanggalCutoff: Value(tanggalCutoff),
    tanggalJatuhTempo: Value(tanggalJatuhTempo),
  );

  AkunRow toRow() => AkunRow(
    id: id,
    nama: nama,
    limitKredit: limitKredit,
    saldoAwal: saldoAwal,
    tanggalCutoff: tanggalCutoff,
    tanggalJatuhTempo: tanggalJatuhTempo,
  );
}
