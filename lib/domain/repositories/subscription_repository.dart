import '../entities/subscription.dart';
import '../entities/transaksi.dart';

abstract interface class SubscriptionRepository {
  Stream<List<Subscription>> watchAll();
  Future<List<Subscription>> getAll();
  Future<Subscription?> getById(int id);

  Future<int> save(Subscription subscription);

  Future<void> delete(int id);

  Future<void> applyGeneratedBills(
    Subscription subscription,
    List<Transaksi> bills,
  );
}
