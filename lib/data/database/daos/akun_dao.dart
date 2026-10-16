import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/akuns.dart';
import '../tables/cicilans.dart';
import '../tables/subscriptions.dart';
import '../tables/transaksis.dart';

part 'akun_dao.g.dart';

@DriftAccessor(tables: [Akuns, Transaksis, Cicilans, Subscriptions])
class AkunDao extends DatabaseAccessor<AppDatabase> with _$AkunDaoMixin {
  AkunDao(super.db);

  Stream<List<AkunRow>> watchAll() =>
      (select(akuns)..orderBy([(a) => OrderingTerm.asc(a.id)])).watch();

  Future<List<AkunRow>> getAll() =>
      (select(akuns)..orderBy([(a) => OrderingTerm.asc(a.id)])).get();

  Future<AkunRow?> getById(int id) =>
      (select(akuns)..where((a) => a.id.equals(id))).getSingleOrNull();

  Future<int> insertAkun(AkunsCompanion entry) => into(akuns).insert(entry);

  Future<bool> updateAkun(AkunRow row) => update(akuns).replace(row);

  Future<int> deleteAkun(int id) =>
      (delete(akuns)..where((a) => a.id.equals(id))).go();

  Future<int> usageCount(int id) async {
    Future<int> count(TableInfo table, GeneratedColumn<int> column) async {
      final total = countAll();
      final query = selectOnly(table)
        ..addColumns([total])
        ..where(column.equals(id));
      return (await query.getSingle()).read(total)!;
    }

    return await count(transaksis, transaksis.akunId) +
        await count(cicilans, cicilans.akunId) +
        await count(subscriptions, subscriptions.akunId);
  }
}
