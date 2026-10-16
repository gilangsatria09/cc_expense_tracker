import '../entities/akun.dart';

abstract interface class AkunRepository {
  Stream<List<Akun>> watchAll();
  Future<List<Akun>> getAll();
  Future<Akun?> getById(int id);

  Future<int> save(Akun akun);

  Future<int> usageCount(int id);

  Future<void> delete(int id);

  Future<int?> getLastUsedId();
  Future<void> setLastUsedId(int id);
}
