import 'package:drift/drift.dart';

import 'akuns.dart';

@DataClassName('CicilanRow')
class Cicilans extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get namaCicilan => text()();
  IntColumn get akunId => integer().references(Akuns, #id)();
  IntColumn get totalHargaBarang => integer()();
  IntColumn get tenor => integer()();
  IntColumn get cicilanKe => integer().withDefault(const Constant(0))();
  IntColumn get jumlahPerBulan => integer()();
  DateTimeColumn get tanggalMulai => dateTime()();
  DateTimeColumn get tanggalBayarTerakhir => dateTime().nullable()();
  TextColumn get catatan => text().nullable()();
}
