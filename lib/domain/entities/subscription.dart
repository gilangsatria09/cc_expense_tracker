import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../core/utils/date_utils.dart';
import 'enums.dart';

class Subscription extends Equatable {
  Subscription({
    this.id = 0,
    required this.namaLayanan,
    required this.akunId,
    this.hargaTetap,
    required this.siklusBilling,
    required this.tanggalTagihanBerikutnya,
    int? hariTagihan,
    this.status = StatusSubscription.aktif,
    this.catatan,
  }) : hariTagihan = hariTagihan ?? tanggalTagihanBerikutnya.day;

  final int id;
  final String namaLayanan;

  final int akunId;

  final int? hargaTetap;
  final SiklusBilling siklusBilling;
  final DateTime tanggalTagihanBerikutnya;

  final int hariTagihan;
  final StatusSubscription status;
  final String? catatan;

  bool get autoGenerate => hargaTetap != null;

  DateTime tagihanBerikutnya(DateTime now) {
    if (autoGenerate) return tanggalTagihanBerikutnya;
    final today = dateOnly(now);
    var due = dateOnly(tanggalTagihanBerikutnya);
    var guard = 0;
    while (due.isBefore(today) && guard++ < 1200) {
      due = nextBillingAfter(due);
    }
    return due;
  }

  DateTime nextBillingAfter(DateTime from) => addMonths(
    from,
    siklusBilling == SiklusBilling.bulanan ? 1 : 12,
    day: hariTagihan,
  );

  Subscription copyWith({
    int? id,
    String? namaLayanan,
    int? akunId,
    ValueGetter<int?>? hargaTetap,
    SiklusBilling? siklusBilling,
    DateTime? tanggalTagihanBerikutnya,
    int? hariTagihan,
    StatusSubscription? status,
    ValueGetter<String?>? catatan,
  }) => Subscription(
    id: id ?? this.id,
    namaLayanan: namaLayanan ?? this.namaLayanan,
    akunId: akunId ?? this.akunId,
    hargaTetap: hargaTetap != null ? hargaTetap() : this.hargaTetap,
    siklusBilling: siklusBilling ?? this.siklusBilling,
    tanggalTagihanBerikutnya:
        tanggalTagihanBerikutnya ?? this.tanggalTagihanBerikutnya,
    hariTagihan: hariTagihan ?? this.hariTagihan,
    status: status ?? this.status,
    catatan: catatan != null ? catatan() : this.catatan,
  );

  @override
  List<Object?> get props => [
    id,
    namaLayanan,
    akunId,
    hargaTetap,
    siklusBilling,
    tanggalTagihanBerikutnya,
    hariTagihan,
    status,
    catatan,
  ];
}
