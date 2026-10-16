import 'package:drift/drift.dart';

import '../../../domain/entities/enums.dart';
import 'akuns.dart';
import 'subscriptions.dart';

@DataClassName('TransaksiRow')
class Transaksis extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get tanggal => dateTime()();

  DateTimeColumn get bulanTagihan => dateTime().nullable()();
  TextColumn get deskripsi => text()();
  IntColumn get jenis => intEnum<JenisTransaksi>()();

  IntColumn get akunId => integer().references(Akuns, #id)();
  IntColumn get totalTagihan => integer()();
  TextColumn get merchant => text().nullable()();
  IntColumn get ongkirFee => integer().withDefault(const Constant(0))();
  IntColumn get status => intEnum<StatusBayar>()();
  TextColumn get catatan => text().nullable()();
  IntColumn get subscriptionId => integer().nullable().references(
    Subscriptions,
    #id,
    onDelete: KeyAction.setNull,
  )();
  IntColumn get sumberEkstraksi => intEnum<SumberEkstraksi>().nullable()();
}
