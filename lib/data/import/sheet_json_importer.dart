import '../../core/error/domain_exception.dart';
import '../../domain/entities/import_summary.dart';
import '../../domain/services/data_importer.dart';
import '../database/app_database.dart';
import '../models/mappers.dart';
import 'import_parser.dart';

class SheetJsonImporter implements DataImporter {
  SheetJsonImporter(this._db);

  final AppDatabase _db;

  @override
  Future<bool> hasData() async {
    final counts = await Future.wait([
      _db.transaksiDao.getAll().then((r) => r.length),
      _db.cicilanDao.getAll().then((r) => r.length),
      _db.subscriptionDao.getAll().then((r) => r.length),
    ]);
    return counts.any((c) => c > 0);
  }

  @override
  Future<ImportSummary> importJson(
    String json, {
    bool replaceExisting = false,
  }) async {
    final bundle = parseImportJson(json);
    if (!replaceExisting && await hasData()) {
      throw const DomainException(
        'Database sudah berisi data. Import ditolak supaya tidak dobel',
      );
    }

    var splitCount = 0;
    await _db.transaction(() async {
      await _db.delete(_db.transaksis).go();
      await _db.delete(_db.cicilans).go();
      await _db.delete(_db.subscriptions).go();
      await _db.delete(_db.akuns).go();

      final akunIds = <int>[
        for (final a in bundle.akuns)
          await _db.akunDao.insertAkun(a.toCompanion()),
      ];

      final subscriptionIds = <int>[];
      for (final s in bundle.subscriptions) {
        subscriptionIds.add(
          await _db.subscriptionDao.insertSubscription(
            s.copyWith(akunId: akunIds[s.akunId]).toCompanion(),
          ),
        );
      }
      for (final c in bundle.cicilans) {
        await _db.cicilanDao.insertCicilan(
          c.copyWith(akunId: akunIds[c.akunId]).toCompanion(),
        );
      }
      for (final (i, t) in bundle.transaksis.indexed) {
        final link = bundle.transaksiSubscription[i];
        final id = await _db.transaksiDao.insertTransaksi(
          t
              .copyWith(
                akunId: akunIds[t.akunId],
                subscriptionId: () =>
                    link == null ? null : subscriptionIds[link],
              )
              .toCompanion(),
        );
        if (t.splits.isNotEmpty) {
          await _db.splitDao.replaceForTransaksi(id, [
            for (final s in t.splits) s.toCompanion(id),
          ]);
          splitCount += t.splits.length;
        }
      }
    });

    return ImportSummary(
      transaksi: bundle.transaksis.length,
      split: splitCount,
      cicilan: bundle.cicilans.length,
      subscription: bundle.subscriptions.length,
      akun: bundle.akuns.length,
    );
  }
}
