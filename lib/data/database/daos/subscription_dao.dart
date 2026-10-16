import 'package:drift/drift.dart';

import '../../../domain/entities/enums.dart';
import '../app_database.dart';
import '../tables/subscriptions.dart';

part 'subscription_dao.g.dart';

@DriftAccessor(tables: [Subscriptions])
class SubscriptionDao extends DatabaseAccessor<AppDatabase>
    with _$SubscriptionDaoMixin {
  SubscriptionDao(super.db);

  Stream<List<SubscriptionRow>> watchAll() => (select(
    subscriptions,
  )..orderBy([(s) => OrderingTerm.asc(s.tanggalTagihanBerikutnya)])).watch();

  Future<List<SubscriptionRow>> getAll() => select(subscriptions).get();

  Future<List<SubscriptionRow>> getAktif() => (select(
    subscriptions,
  )..where((s) => s.status.equalsValue(StatusSubscription.aktif))).get();

  Future<SubscriptionRow?> getById(int id) =>
      (select(subscriptions)..where((s) => s.id.equals(id))).getSingleOrNull();

  Future<int> insertSubscription(SubscriptionsCompanion entry) =>
      into(subscriptions).insert(entry);

  Future<bool> updateSubscription(SubscriptionRow row) =>
      update(subscriptions).replace(row);

  Future<int> deleteSubscription(int id) =>
      (delete(subscriptions)..where((s) => s.id.equals(id))).go();
}
