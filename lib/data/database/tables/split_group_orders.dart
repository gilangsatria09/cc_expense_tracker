import 'package:drift/drift.dart';

import '../../../domain/entities/enums.dart';
import 'transaksis.dart';

@DataClassName('SplitGroupOrderRow')
class SplitGroupOrders extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get transaksiId =>
      integer().references(Transaksis, #id, onDelete: KeyAction.cascade)();
  TextColumn get nama => text()();
  IntColumn get hargaManual => integer().nullable()();
  IntColumn get status => intEnum<StatusBayar>()();
  TextColumn get catatan => text().nullable()();
}
