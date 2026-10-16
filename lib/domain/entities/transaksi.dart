import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils.dart';
import 'enums.dart';
import 'split_group_order.dart';

class Transaksi extends Equatable {
  const Transaksi({
    this.id = 0,
    required this.tanggal,
    this.bulanTagihan,
    required this.deskripsi,
    required this.jenis,
    required this.akunId,
    required this.totalTagihan,
    this.merchant,
    this.ongkirFee = 0,
    this.status = StatusBayar.belumDibayar,
    this.catatan,
    this.subscriptionId,
    this.sumberEkstraksi,
    this.splits = const [],
  });

  final int id;
  final DateTime tanggal;

  final DateTime? bulanTagihan;
  final String deskripsi;
  final JenisTransaksi jenis;

  final int akunId;

  final int totalTagihan;
  final String? merchant;
  final int ongkirFee;
  final StatusBayar status;
  final String? catatan;
  final int? subscriptionId;
  final SumberEkstraksi? sumberEkstraksi;
  final List<SplitGroupOrder> splits;

  DateTime get effectiveBulan => bulanTagihan ?? monthOf(tanggal);

  bool get isGroupOrder => jenis == JenisTransaksi.groupOrder;

  int get jumlahOrang => splits.length;

  int get bagianRata =>
      jumlahOrang == 0 ? totalTagihan : totalTagihan ~/ jumlahOrang;

  int tagihanUntuk(SplitGroupOrder split) => split.hargaManual ?? bagianRata;

  int get bagianSaya {
    if (!isGroupOrder || splits.isEmpty) return totalTagihan;
    for (final split in splits) {
      if (split.nama == namaSaya) return tagihanUntuk(split);
    }
    return 0;
  }

  int get ditagihKeTeman => totalTagihan - bagianSaya;

  Transaksi copyWith({
    int? id,
    DateTime? tanggal,
    ValueGetter<DateTime?>? bulanTagihan,
    String? deskripsi,
    JenisTransaksi? jenis,
    int? akunId,
    int? totalTagihan,
    ValueGetter<String?>? merchant,
    int? ongkirFee,
    StatusBayar? status,
    ValueGetter<String?>? catatan,
    ValueGetter<int?>? subscriptionId,
    ValueGetter<SumberEkstraksi?>? sumberEkstraksi,
    List<SplitGroupOrder>? splits,
  }) => Transaksi(
    id: id ?? this.id,
    tanggal: tanggal ?? this.tanggal,
    bulanTagihan: bulanTagihan != null ? bulanTagihan() : this.bulanTagihan,
    deskripsi: deskripsi ?? this.deskripsi,
    jenis: jenis ?? this.jenis,
    akunId: akunId ?? this.akunId,
    totalTagihan: totalTagihan ?? this.totalTagihan,
    merchant: merchant != null ? merchant() : this.merchant,
    ongkirFee: ongkirFee ?? this.ongkirFee,
    status: status ?? this.status,
    catatan: catatan != null ? catatan() : this.catatan,
    subscriptionId: subscriptionId != null
        ? subscriptionId()
        : this.subscriptionId,
    sumberEkstraksi: sumberEkstraksi != null
        ? sumberEkstraksi()
        : this.sumberEkstraksi,
    splits: splits ?? this.splits,
  );

  @override
  List<Object?> get props => [
    id,
    tanggal,
    bulanTagihan,
    deskripsi,
    jenis,
    akunId,
    totalTagihan,
    merchant,
    ongkirFee,
    status,
    catatan,
    subscriptionId,
    sumberEkstraksi,
    splits,
  ];
}
