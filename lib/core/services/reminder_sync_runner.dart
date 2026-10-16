import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import '../../domain/repositories/akun_repository.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../../domain/usecases/sync_reminders.dart';

class ReminderSyncRunner {
  ReminderSyncRunner(
    this._subscriptions,
    this._akuns,
    this._sync, {
    Duration debounce = const Duration(milliseconds: 500),
  }) : _debounce = debounce;

  final SubscriptionRepository _subscriptions;
  final AkunRepository _akuns;
  final SyncReminders _sync;
  final Duration _debounce;
  StreamSubscription<void>? _subscription;

  void start() {
    _subscription?.cancel();
    _subscription =
        Rx.combineLatest2<Object, Object, void>(
              _subscriptions.watchAll(),
              _akuns.watchAll(),
              (subscriptions, akuns) {},
            )
            .debounceTime(
              _debounce,
            )
            .asyncMap((_) async {
              try {
                await _sync();
              } catch (e, st) {
                debugPrint('Sinkron pengingat gagal: $e\n$st');
              }
            })
            .listen((_) {});
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
