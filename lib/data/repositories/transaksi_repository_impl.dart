import 'package:rxdart/rxdart.dart';

import '../../domain/entities/enums.dart';
import '../../domain/entities/transaksi.dart';
import '../../domain/repositories/transaksi_repository.dart';
import '../database/app_database.dart';
import '../models/mappers.dart';

class TransaksiRepositoryImpl implements TransaksiRepository {
  TransaksiRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Transaksi>> watchByMonth(DateTime month) => Rx.combineLatest2(
    _db.transaksiDao.watchByMonth(month),
    _db.splitDao.watchAll(),
    _assemble,
  );

  @override
  Stream<List<Transaksi>> watchAll() => Rx.combineLatest2(
    _db.transaksiDao.watchAll(),
    _db.splitDao.watchAll(),
    _assemble,
  );

  @override
  Future<List<Transaksi>> getAll() async =>
      _assemble(await _db.transaksiDao.getAll(), await _db.splitDao.getAll());

  @override
  Future<Transaksi?> getById(int id) async {
    final row = await _db.transaksiDao.getById(id);
    if (row == null) return null;
    return row.toEntity(await _db.splitDao.getByTransaksi(id));
  }

  @override
  Future<List<Transaksi>> getBySubscription(int subscriptionId) async =>
      _assemble(
        await _db.transaksiDao.getBySubscription(subscriptionId),
        await _db.splitDao.getAll(),
      );

  @override
  Future<int> save(Transaksi transaksi) => _db.transaction(() async {
    final int id;
    if (transaksi.id == 0) {
      id = await _db.transaksiDao.insertTransaksi(transaksi.toCompanion());
    } else {
      await _db.transaksiDao.updateTransaksi(transaksi.toRow());
      id = transaksi.id;
    }
    await _db.splitDao.replaceForTransaksi(
      id,
      transaksi.splits.map((s) => s.toCompanion(id)).toList(),
    );
    return id;
  });

  @override
  Future<void> delete(int id) async {
    await _db.transaksiDao.deleteTransaksi(id);
  }

  @override
  Future<void> updateStatuses(Map<int, StatusBayar> statuses) =>
      _db.transaksiDao.updateStatuses(statuses);

  @override
  Future<List<String>> getKnownParticipantNames() =>
      _db.splitDao.getDistinctNames();

  List<Transaksi> _assemble(
    List<TransaksiRow> rows,
    List<SplitGroupOrderRow> splits,
  ) {
    final byTransaksi = <int, List<SplitGroupOrderRow>>{};
    for (final s in splits) {
      (byTransaksi[s.transaksiId] ??= []).add(s);
    }
    return rows.map((r) => r.toEntity(byTransaksi[r.id] ?? const [])).toList();
  }
}
