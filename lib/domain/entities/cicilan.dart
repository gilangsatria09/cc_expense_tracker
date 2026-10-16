import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../core/utils/date_utils.dart';

class Cicilan extends Equatable {
  const Cicilan({
    this.id = 0,
    required this.namaCicilan,
    required this.akunId,
    required this.totalHargaBarang,
    required this.tenor,
    this.cicilanKe = 0,
    required this.jumlahPerBulan,
    required this.tanggalMulai,
    this.tanggalBayarTerakhir,
    this.catatan,
  });

  final int id;
  final String namaCicilan;

  final int akunId;
  final int totalHargaBarang;
  final int tenor;
  final int cicilanKe;
  final int jumlahPerBulan;
  final DateTime tanggalMulai;
  final DateTime? tanggalBayarTerakhir;
  final String? catatan;

  int get totalSudahDibayar => jumlahPerBulan * cicilanKe;

  int get sisaCicilan => math.max(0, totalHargaBarang - totalSudahDibayar);
  bool get lunas => cicilanKe >= tenor;

  bool jatuhTempoDi(DateTime month) {
    final start = tanggalMulai.year * 12 + tanggalMulai.month;
    final target = month.year * 12 + month.month;
    return target >= start && target < start + tenor;
  }

  bool sudahBayarBulanIni(DateTime now) =>
      tanggalBayarTerakhir != null && isSameMonth(tanggalBayarTerakhir!, now);

  bool bisaBayar(DateTime now) => !lunas && !sudahBayarBulanIni(now);

  Cicilan copyWith({
    int? id,
    String? namaCicilan,
    int? akunId,
    int? totalHargaBarang,
    int? tenor,
    int? cicilanKe,
    int? jumlahPerBulan,
    DateTime? tanggalMulai,
    ValueGetter<DateTime?>? tanggalBayarTerakhir,
    ValueGetter<String?>? catatan,
  }) => Cicilan(
    id: id ?? this.id,
    namaCicilan: namaCicilan ?? this.namaCicilan,
    akunId: akunId ?? this.akunId,
    totalHargaBarang: totalHargaBarang ?? this.totalHargaBarang,
    tenor: tenor ?? this.tenor,
    cicilanKe: cicilanKe ?? this.cicilanKe,
    jumlahPerBulan: jumlahPerBulan ?? this.jumlahPerBulan,
    tanggalMulai: tanggalMulai ?? this.tanggalMulai,
    tanggalBayarTerakhir: tanggalBayarTerakhir != null
        ? tanggalBayarTerakhir()
        : this.tanggalBayarTerakhir,
    catatan: catatan != null ? catatan() : this.catatan,
  );

  @override
  List<Object?> get props => [
    id,
    namaCicilan,
    akunId,
    totalHargaBarang,
    tenor,
    cicilanKe,
    jumlahPerBulan,
    tanggalMulai,
    tanggalBayarTerakhir,
    catatan,
  ];
}
