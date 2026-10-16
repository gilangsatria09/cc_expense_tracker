import 'package:equatable/equatable.dart';

class ExtractedSplit extends Equatable {
  const ExtractedSplit({required this.nama, required this.subtotal});

  final String nama;
  final int subtotal;

  @override
  List<Object?> get props => [nama, subtotal];
}
