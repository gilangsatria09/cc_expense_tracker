import '../entities/cicilan.dart';

abstract interface class CicilanRepository {
  Stream<List<Cicilan>> watchAll();
  Future<Cicilan?> getById(int id);

  Future<int> save(Cicilan cicilan);

  Future<void> delete(int id);
}
