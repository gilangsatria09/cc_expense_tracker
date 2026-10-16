import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/cicilans.dart';

part 'cicilan_dao.g.dart';

@DriftAccessor(tables: [Cicilans])
class CicilanDao extends DatabaseAccessor<AppDatabase> with _$CicilanDaoMixin {
  CicilanDao(super.db);

  Stream<List<CicilanRow>> watchAll() => (select(
    cicilans,
  )..orderBy([(c) => OrderingTerm.asc(c.tanggalMulai)])).watch();

  Future<List<CicilanRow>> getAll() => select(cicilans).get();

  Future<CicilanRow?> getById(int id) =>
      (select(cicilans)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<int> insertCicilan(CicilansCompanion entry) =>
      into(cicilans).insert(entry);

  Future<bool> updateCicilan(CicilanRow row) => update(cicilans).replace(row);

  Future<int> deleteCicilan(int id) =>
      (delete(cicilans)..where((c) => c.id.equals(id))).go();
}
