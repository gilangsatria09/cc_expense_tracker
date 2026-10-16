import 'package:drift/drift.dart';

import '../../../domain/entities/enums.dart';
import 'akuns.dart';

@DataClassName('SubscriptionRow')
class Subscriptions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get namaLayanan => text()();

  IntColumn get akunId => integer().references(Akuns, #id)();

  IntColumn get hargaTetap => integer().nullable()();
  IntColumn get siklusBilling => intEnum<SiklusBilling>()();
  DateTimeColumn get tanggalTagihanBerikutnya => dateTime()();

  IntColumn get hariTagihan => integer()();
  IntColumn get status => intEnum<StatusSubscription>()();
  TextColumn get catatan => text().nullable()();
}
