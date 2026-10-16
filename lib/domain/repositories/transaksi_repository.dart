import '../entities/enums.dart';
import '../entities/transaksi.dart';

abstract interface class TransaksiRepository {
  Stream<List<Transaksi>> watchByMonth(DateTime month);
  Stream<List<Transaksi>> watchAll();
  Future<List<Transaksi>> getAll();
  Future<Transaksi?> getById(int id);
  Future<List<Transaksi>> getBySubscription(int subscriptionId);

  Future<int> save(Transaksi transaksi);

  Future<void> delete(int id);

  Future<void> updateStatuses(Map<int, StatusBayar> statuses);

  Future<List<String>> getKnownParticipantNames();
}
