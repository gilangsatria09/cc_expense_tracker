import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/split_group_orders.dart';
import '../tables/transaksis.dart';

part 'split_dao.g.dart';

@DriftAccessor(tables: [SplitGroupOrders, Transaksis])
class SplitDao extends DatabaseAccessor<AppDatabase> with _$SplitDaoMixin {
  SplitDao(super.db);

  Stream<List<SplitGroupOrderRow>> watchByTransaksi(int transaksiId) =>
      (select(splitGroupOrders)
            ..where((s) => s.transaksiId.equals(transaksiId))
            ..orderBy([(s) => OrderingTerm.asc(s.id)]))
          .watch();

  Future<List<SplitGroupOrderRow>> getByTransaksi(int transaksiId) =>
      (select(splitGroupOrders)
            ..where((s) => s.transaksiId.equals(transaksiId))
            ..orderBy([(s) => OrderingTerm.asc(s.id)]))
          .get();

  Future<List<SplitGroupOrderRow>> getAll() => select(splitGroupOrders).get();

  Stream<List<SplitGroupOrderRow>> watchAll() =>
      select(splitGroupOrders).watch();

  Future<void> replaceForTransaksi(
    int transaksiId,
    List<SplitGroupOrdersCompanion> entries,
  ) => transaction(() async {
    await (delete(
      splitGroupOrders,
    )..where((s) => s.transaksiId.equals(transaksiId))).go();
    await batch((b) => b.insertAll(splitGroupOrders, entries));
  });

  Future<bool> updateSplit(SplitGroupOrderRow row) =>
      update(splitGroupOrders).replace(row);

  Future<List<String>> getDistinctNames() async {
    final pemakaian = splitGroupOrders.id.count();
    final terakhir = transaksis.tanggal.max();
    final query =
        selectOnly(splitGroupOrders).join([
            innerJoin(
              transaksis,
              transaksis.id.equalsExp(splitGroupOrders.transaksiId),
            ),
          ])
          ..addColumns([splitGroupOrders.nama, pemakaian, terakhir])
          ..groupBy([splitGroupOrders.nama])
          ..orderBy([
            OrderingTerm.desc(pemakaian),
            OrderingTerm.desc(terakhir),
            OrderingTerm.asc(splitGroupOrders.nama),
          ]);
    final rows = await query.get();
    return rows.map((r) => r.read(splitGroupOrders.nama)!).toList();
  }
}
