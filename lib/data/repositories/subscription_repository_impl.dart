import '../../domain/entities/subscription.dart';
import '../../domain/entities/transaksi.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../database/app_database.dart';
import '../models/mappers.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  SubscriptionRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Subscription>> watchAll() => _db.subscriptionDao.watchAll().map(
    (rows) => rows.map((r) => r.toEntity()).toList(),
  );

  @override
  Future<List<Subscription>> getAll() async =>
      (await _db.subscriptionDao.getAll()).map((r) => r.toEntity()).toList();

  @override
  Future<Subscription?> getById(int id) async =>
      (await _db.subscriptionDao.getById(id))?.toEntity();

  @override
  Future<int> save(Subscription subscription) async {
    if (subscription.id == 0) {
      return _db.subscriptionDao.insertSubscription(subscription.toCompanion());
    }
    await _db.subscriptionDao.updateSubscription(subscription.toRow());
    return subscription.id;
  }

  @override
  Future<void> delete(int id) async {
    await _db.subscriptionDao.deleteSubscription(id);
  }

  @override
  Future<void> applyGeneratedBills(
    Subscription subscription,
    List<Transaksi> bills,
  ) => _db.transaction(() async {
    for (final bill in bills) {
      await _db.transaksiDao.insertTransaksi(bill.toCompanion());
    }
    await _db.subscriptionDao.updateSubscription(subscription.toRow());
  });
}
