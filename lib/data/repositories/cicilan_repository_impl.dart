import '../../domain/entities/cicilan.dart';
import '../../domain/repositories/cicilan_repository.dart';
import '../database/app_database.dart';
import '../models/mappers.dart';

class CicilanRepositoryImpl implements CicilanRepository {
  CicilanRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Cicilan>> watchAll() => _db.cicilanDao.watchAll().map(
    (rows) => rows.map((r) => r.toEntity()).toList(),
  );

  @override
  Future<Cicilan?> getById(int id) async =>
      (await _db.cicilanDao.getById(id))?.toEntity();

  @override
  Future<int> save(Cicilan cicilan) async {
    if (cicilan.id == 0) {
      return _db.cicilanDao.insertCicilan(cicilan.toCompanion());
    }
    await _db.cicilanDao.updateCicilan(cicilan.toRow());
    return cicilan.id;
  }

  @override
  Future<void> delete(int id) async {
    await _db.cicilanDao.deleteCicilan(id);
  }
}
