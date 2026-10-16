import '../../core/error/domain_exception.dart';
import '../../domain/entities/akun.dart';
import '../../domain/repositories/akun_repository.dart';
import '../database/app_database.dart';
import '../database/daos/settings_dao.dart';
import '../models/mappers.dart';

class AkunRepositoryImpl implements AkunRepository {
  AkunRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Akun>> watchAll() => _db.akunDao.watchAll().map(
    (rows) => rows.map((r) => r.toEntity()).toList(),
  );

  @override
  Future<List<Akun>> getAll() async =>
      (await _db.akunDao.getAll()).map((r) => r.toEntity()).toList();

  @override
  Future<Akun?> getById(int id) async =>
      (await _db.akunDao.getById(id))?.toEntity();

  @override
  Future<int> save(Akun akun) async {
    if (akun.id == 0) return _db.akunDao.insertAkun(akun.toCompanion());
    await _db.akunDao.updateAkun(akun.toRow());
    return akun.id;
  }

  @override
  Future<int> usageCount(int id) => _db.akunDao.usageCount(id);

  @override
  Future<void> delete(int id) async {
    if (await usageCount(id) > 0) {
      throw const DomainException(
        'Akun masih dipakai data, tidak bisa dihapus',
      );
    }
    await _db.akunDao.deleteAkun(id);
  }

  @override
  Future<int?> getLastUsedId() async {
    final id = await _db.settingsDao.getValue(SettingKeys.akunTerakhir);
    return id == 0 ? null : id;
  }

  @override
  Future<void> setLastUsedId(int id) =>
      _db.settingsDao.setValue(SettingKeys.akunTerakhir, id);
}
