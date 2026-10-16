import 'package:equatable/equatable.dart';

class ImportSummary extends Equatable {
  const ImportSummary({
    required this.transaksi,
    required this.split,
    required this.cicilan,
    required this.subscription,
    this.akun = 1,
  });

  final int transaksi;
  final int split;
  final int cicilan;
  final int subscription;
  final int akun;

  @override
  List<Object?> get props => [transaksi, split, cicilan, subscription, akun];
}
