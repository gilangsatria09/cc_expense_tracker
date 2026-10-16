import 'package:drift/drift.dart';

@DataClassName('AkunRow')
class Akuns extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nama => text()();

  IntColumn get limitKredit => integer().withDefault(const Constant(0))();

  IntColumn get saldoAwal => integer().withDefault(const Constant(0))();

  IntColumn get tanggalCutoff => integer().withDefault(const Constant(0))();

  IntColumn get tanggalJatuhTempo => integer().withDefault(const Constant(0))();
}
