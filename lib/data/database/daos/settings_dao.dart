import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/app_settings.dart';

part 'settings_dao.g.dart';

class SettingKeys {
  static const akunTerakhir = 'akunTerakhir';
}

@DriftAccessor(tables: [AppSettings])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Future<int> getValue(String key, {int defaultValue = 0}) async {
    final row = await (select(
      appSettings,
    )..where((s) => s.key.equals(key))).getSingleOrNull();
    return row?.value ?? defaultValue;
  }

  Stream<int> watchValue(String key, {int defaultValue = 0}) =>
      (select(appSettings)..where((s) => s.key.equals(key)))
          .watchSingleOrNull()
          .map((row) => row?.value ?? defaultValue);

  Future<void> setValue(String key, int value) => into(
    appSettings,
  ).insertOnConflictUpdate(AppSettingsCompanion.insert(key: key, value: value));
}
