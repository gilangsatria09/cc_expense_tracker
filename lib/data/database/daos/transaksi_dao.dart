import 'package:drift/drift.dart';

import '../../../domain/entities/enums.dart';
import '../app_database.dart';
import '../tables/subscriptions.dart';
import '../tables/transaksis.dart';
import '../tables/split_group_orders.dart';

part 'transaksi_dao.g.dart';

@DriftAccessor(tables: [Transaksis, SplitGroupOrders, Subscriptions])
class TransaksiDao extends DatabaseAccessor<AppDatabase>
    with _$TransaksiDaoMixin {
  TransaksiDao(super.db);

  Stream<List<TransaksiRow>> watchByMonth(DateTime month) {
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);
    return (select(transaksis)
          ..where((t) => t.bulanTagihan.isBiggerOrEqualValue(start))
          ..where((t) => t.bulanTagihan.isSmallerThanValue(end))
          ..orderBy([
            (t) => OrderingTerm.desc(t.tanggal),
            (t) => OrderingTerm.desc(t.id),
          ]))
        .watch();
  }

  Future<List<TransaksiRow>> getByMonth(DateTime month) =>
      watchByMonth(month).first;

  Stream<List<TransaksiRow>> watchAll() => select(transaksis).watch();

  Future<List<TransaksiRow>> getAll() => select(transaksis).get();

  Future<TransaksiRow?> getById(int id) =>
      (select(transaksis)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<TransaksiRow>> getBySubscription(int subscriptionId) =>
      (select(transaksis)
            ..where((t) => t.subscriptionId.equals(subscriptionId))
            ..orderBy([(t) => OrderingTerm.desc(t.tanggal)]))
          .get();

  Future<int> insertTransaksi(TransaksisCompanion entry) =>
      into(transaksis).insert(entry);

  Future<void> updateStatuses(Map<int, StatusBayar> statuses) =>
      transaction(() async {
        for (final entry in statuses.entries) {
          await (update(transaksis)..where((t) => t.id.equals(entry.key)))
              .write(TransaksisCompanion(status: Value(entry.value)));
        }
      });

  Future<bool> updateTransaksi(TransaksiRow row) =>
      update(transaksis).replace(row);

  Future<int> deleteTransaksi(int id) =>
      (delete(transaksis)..where((t) => t.id.equals(id))).go();
}
