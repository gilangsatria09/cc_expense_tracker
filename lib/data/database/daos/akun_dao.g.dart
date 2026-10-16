// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'akun_dao.dart';

// ignore_for_file: type=lint
mixin _$AkunDaoMixin on DatabaseAccessor<AppDatabase> {
  $AkunsTable get akuns => attachedDatabase.akuns;
  $SubscriptionsTable get subscriptions => attachedDatabase.subscriptions;
  $TransaksisTable get transaksis => attachedDatabase.transaksis;
  $CicilansTable get cicilans => attachedDatabase.cicilans;
  AkunDaoManager get managers => AkunDaoManager(this);
}

class AkunDaoManager {
  final _$AkunDaoMixin _db;
  AkunDaoManager(this._db);
  $$AkunsTableTableManager get akuns =>
      $$AkunsTableTableManager(_db.attachedDatabase, _db.akuns);
  $$SubscriptionsTableTableManager get subscriptions =>
      $$SubscriptionsTableTableManager(_db.attachedDatabase, _db.subscriptions);
  $$TransaksisTableTableManager get transaksis =>
      $$TransaksisTableTableManager(_db.attachedDatabase, _db.transaksis);
  $$CicilansTableTableManager get cicilans =>
      $$CicilansTableTableManager(_db.attachedDatabase, _db.cicilans);
}
