import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'enums.dart';

class SplitGroupOrder extends Equatable {
  const SplitGroupOrder({
    this.id = 0,
    required this.nama,
    this.hargaManual,
    this.status = StatusBayar.belumDibayar,
    this.catatan,
  });

  final int id;
  final String nama;
  final int? hargaManual;
  final StatusBayar status;
  final String? catatan;

  SplitGroupOrder copyWith({
    int? id,
    String? nama,
    ValueGetter<int?>? hargaManual,
    StatusBayar? status,
    ValueGetter<String?>? catatan,
  }) => SplitGroupOrder(
    id: id ?? this.id,
    nama: nama ?? this.nama,
    hargaManual: hargaManual != null ? hargaManual() : this.hargaManual,
    status: status ?? this.status,
    catatan: catatan != null ? catatan() : this.catatan,
  );

  @override
  List<Object?> get props => [id, nama, hargaManual, status, catatan];
}
