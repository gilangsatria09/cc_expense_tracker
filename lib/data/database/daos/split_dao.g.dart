// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'split_dao.dart';

// ignore_for_file: type=lint
mixin _$SplitDaoMixin on DatabaseAccessor<AppDatabase> {
  $AkunsTable get akuns => attachedDatabase.akuns;
  $SubscriptionsTable get subscriptions => attachedDatabase.subscriptions;
  $TransaksisTable get transaksis => attachedDatabase.transaksis;
  $SplitGroupOrdersTable get splitGroupOrders =>
      attachedDatabase.splitGroupOrders;
  SplitDaoManager get managers => SplitDaoManager(this);
}

class SplitDaoManager {
  final _$SplitDaoMixin _db;
  SplitDaoManager(this._db);
  $$AkunsTableTableManager get akuns =>
      $$AkunsTableTableManager(_db.attachedDatabase, _db.akuns);
  $$SubscriptionsTableTableManager get subscriptions =>
      $$SubscriptionsTableTableManager(_db.attachedDatabase, _db.subscriptions);
  $$TransaksisTableTableManager get transaksis =>
      $$TransaksisTableTableManager(_db.attachedDatabase, _db.transaksis);
  $$SplitGroupOrdersTableTableManager get splitGroupOrders =>
      $$SplitGroupOrdersTableTableManager(
        _db.attachedDatabase,
        _db.splitGroupOrders,
      );
}
