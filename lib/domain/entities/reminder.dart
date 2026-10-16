import 'package:equatable/equatable.dart';

class Reminder extends Equatable {
  const Reminder({
    required this.id,
    required this.at,
    required this.title,
    required this.body,
  });

  final int id;

  final DateTime at;
  final String title;
  final String body;

  @override
  List<Object?> get props => [id, at, title, body];
}
