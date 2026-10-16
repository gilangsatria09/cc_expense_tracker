import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../../domain/entities/akun.dart';
import '../../../domain/entities/subscription.dart';
import '../../../domain/repositories/akun_repository.dart';
import '../../../domain/repositories/subscription_repository.dart';

enum SubscriptionListStatus { loading, success, failure }

class SubscriptionListState extends Equatable {
  const SubscriptionListState({
    this.status = SubscriptionListStatus.loading,
    this.subscriptions = const [],
    this.akuns = const [],
  });

  final SubscriptionListStatus status;
  final List<Subscription> subscriptions;
  final List<Akun> akuns;

  Map<int, String> get namaAkun =>
      akuns.length > 1 ? {for (final a in akuns) a.id: a.nama} : const {};

  @override
  List<Object?> get props => [status, subscriptions, akuns];
}

class SubscriptionListCubit extends Cubit<SubscriptionListState> {
  SubscriptionListCubit(this._repository, this._akunRepository)
    : super(const SubscriptionListState());

  final SubscriptionRepository _repository;
  final AkunRepository _akunRepository;
  StreamSubscription<({List<Subscription> list, List<Akun> akuns})>?
  _subscription;

  void start() {
    _subscription?.cancel();
    _subscription =
        Rx.combineLatest2(
          _repository.watchAll(),
          _akunRepository.watchAll(),
          (list, akuns) => (list: list, akuns: akuns),
        ).listen(
          (data) => emit(
            SubscriptionListState(
              status: SubscriptionListStatus.success,
              subscriptions: data.list,
              akuns: data.akuns,
            ),
          ),
          onError: (Object error, StackTrace stackTrace) => emit(
            const SubscriptionListState(status: SubscriptionListStatus.failure),
          ),
        );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
