import 'package:drift/drift.dart';

@DataClassName('AppSettingRow')
class AppSettings extends Table {
  TextColumn get key => text()();
  IntColumn get value => integer()();

  @override
  Set<Column> get primaryKey => {key};
}
