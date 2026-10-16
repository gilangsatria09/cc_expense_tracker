import 'package:equatable/equatable.dart';

class Akun extends Equatable {
  const Akun({
    this.id = 0,
    required this.nama,
    this.limitKredit = 0,
    this.saldoAwal = 0,
    this.tanggalCutoff = 0,
    this.tanggalJatuhTempo = 0,
  });

  final int id;
  final String nama;

  final int limitKredit;

  final int saldoAwal;

  final int tanggalCutoff;

  final int tanggalJatuhTempo;

  Akun copyWith({
    int? id,
    String? nama,
    int? limitKredit,
    int? saldoAwal,
    int? tanggalCutoff,
    int? tanggalJatuhTempo,
  }) => Akun(
    id: id ?? this.id,
    nama: nama ?? this.nama,
    limitKredit: limitKredit ?? this.limitKredit,
    saldoAwal: saldoAwal ?? this.saldoAwal,
    tanggalCutoff: tanggalCutoff ?? this.tanggalCutoff,
    tanggalJatuhTempo: tanggalJatuhTempo ?? this.tanggalJatuhTempo,
  );

  @override
  List<Object?> get props => [
    id,
    nama,
    limitKredit,
    saldoAwal,
    tanggalCutoff,
    tanggalJatuhTempo,
  ];
}
