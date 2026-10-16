import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/utils/date_utils.dart';
import '../../domain/entities/enums.dart';
import 'daos/akun_dao.dart';
import 'daos/cicilan_dao.dart';
import 'daos/settings_dao.dart';
import 'daos/split_dao.dart';
import 'daos/subscription_dao.dart';
import 'daos/transaksi_dao.dart';
import 'tables/akuns.dart';
import 'tables/app_settings.dart';
import 'tables/cicilans.dart';
import 'tables/split_group_orders.dart';
import 'tables/subscriptions.dart';
import 'tables/transaksis.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Akuns,
    Transaksis,
    SplitGroupOrders,
    Cicilans,
    Subscriptions,
    AppSettings,
  ],
  daos: [
    AkunDao,
    TransaksiDao,
    SplitDao,
    CicilanDao,
    SubscriptionDao,
    SettingsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  AppDatabase.inMemory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 4;

  static const namaAkunBawaan = 'Kartu Kredit';

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await into(akuns).insert(AkunsCompanion.insert(nama: namaAkunBawaan));
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(transaksis, transaksis.bulanTagihan);
        final rows = await customSelect(
          'SELECT id, tanggal FROM transaksis',
        ).get();
        for (final row in rows) {
          await customUpdate(
            'UPDATE transaksis SET bulan_tagihan = ? WHERE id = ?',
            variables: [
              Variable<DateTime>(
                monthOf(
                  DateTime.fromMillisecondsSinceEpoch(
                    row.read<int>('tanggal') * 1000,
                  ),
                ),
              ),
              Variable<int>(row.read<int>('id')),
            ],
          );
        }
      }
      if (from < 3) {
        await m.createTable(akuns);

        Future<int> legacy(String key) async {
          final rows = await customSelect(
            'SELECT value FROM app_settings WHERE key = ?',
            variables: [Variable<String>(key)],
          ).get();
          return rows.isEmpty ? 0 : rows.first.read<int>('value');
        }

        final akunId = await into(akuns).insert(
          AkunsCompanion.insert(
            nama: namaAkunBawaan,
            limitKredit: Value(await legacy('limitCC')),
            saldoAwal: Value(await legacy('saldoOutstandingSebelumTracker')),
            tanggalCutoff: Value(await legacy('tanggalCutoffTagihan')),
          ),
        );

        final ke = Constant<int>(akunId);
        await m.alterTable(
          TableMigration(
            subscriptions,
            newColumns: [subscriptions.akunId],
            columnTransformer: {subscriptions.akunId: ke},
          ),
        );
        await m.alterTable(
          TableMigration(
            cicilans,
            newColumns: [cicilans.akunId],
            columnTransformer: {cicilans.akunId: ke},
          ),
        );
        await m.alterTable(
          TableMigration(
            transaksis,
            newColumns: [transaksis.akunId],
            columnTransformer: {transaksis.akunId: ke},
          ),
        );

        await customStatement(
          "DELETE FROM app_settings WHERE key IN "
          "('limitCC', 'saldoOutstandingSebelumTracker', 'tanggalCutoffTagihan')",
        );
      }
      if (from >= 3 && from < 4) {
        await m.addColumn(akuns, akuns.tanggalJatuhTempo);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

QueryExecutor openAppConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'cc_expense_tracker.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
