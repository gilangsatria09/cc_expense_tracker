// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cicilan_dao.dart';

// ignore_for_file: type=lint
mixin _$CicilanDaoMixin on DatabaseAccessor<AppDatabase> {
  $AkunsTable get akuns => attachedDatabase.akuns;
  $CicilansTable get cicilans => attachedDatabase.cicilans;
  CicilanDaoManager get managers => CicilanDaoManager(this);
}

class CicilanDaoManager {
  final _$CicilanDaoMixin _db;
  CicilanDaoManager(this._db);
  $$AkunsTableTableManager get akuns =>
      $$AkunsTableTableManager(_db.attachedDatabase, _db.akuns);
  $$CicilansTableTableManager get cicilans =>
      $$CicilansTableTableManager(_db.attachedDatabase, _db.cicilans);
}
