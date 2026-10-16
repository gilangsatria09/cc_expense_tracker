import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../../core/error/domain_exception.dart';
import '../../../domain/entities/akun.dart';
import '../../../domain/entities/cicilan.dart';
import '../../../domain/repositories/akun_repository.dart';
import '../../../domain/repositories/cicilan_repository.dart';
import '../../../domain/usecases/pay_cicilan.dart';

enum CicilanListStatus { loading, success, failure }

class CicilanListState extends Equatable {
  const CicilanListState({
    this.status = CicilanListStatus.loading,
    this.cicilans = const [],
    this.akuns = const [],
    this.message,
  });

  final CicilanListStatus status;
  final List<Cicilan> cicilans;
  final List<Akun> akuns;

  Map<int, String> get namaAkun =>
      akuns.length > 1 ? {for (final a in akuns) a.id: a.nama} : const {};

  final String? message;

  List<Cicilan> get aktif => cicilans.where((c) => !c.lunas).toList();
  List<Cicilan> get lunas => cicilans.where((c) => c.lunas).toList();

  CicilanListState copyWith({
    CicilanListStatus? status,
    List<Cicilan>? cicilans,
    List<Akun>? akuns,
    ValueGetter<String?>? message,
  }) => CicilanListState(
    status: status ?? this.status,
    cicilans: cicilans ?? this.cicilans,
    akuns: akuns ?? this.akuns,
    message: message != null ? message() : this.message,
  );

  @override
  List<Object?> get props => [status, cicilans, akuns, message];
}

class CicilanListCubit extends Cubit<CicilanListState> {
  CicilanListCubit(
    this._repository,
    this._payCicilan,
    this._akunRepository, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now,
       super(const CicilanListState());

  final CicilanRepository _repository;
  final PayCicilan _payCicilan;
  final AkunRepository _akunRepository;
  final DateTime Function() _now;
  StreamSubscription<({List<Cicilan> list, List<Akun> akuns})>? _subscription;

  DateTime get now => _now();

  void start() {
    _subscription?.cancel();
    _subscription =
        Rx.combineLatest2(
          _repository.watchAll(),
          _akunRepository.watchAll(),
          (list, akuns) => (list: list, akuns: akuns),
        ).listen(
          (data) => emit(
            state.copyWith(
              status: CicilanListStatus.success,
              cicilans: data.list,
              akuns: data.akuns,
            ),
          ),
          onError: (Object error, StackTrace stackTrace) =>
              emit(state.copyWith(status: CicilanListStatus.failure)),
        );
  }

  Future<void> pay(int id) async {
    try {
      await _payCicilan(id, now: _now());
    } on DomainException catch (e) {
      emit(state.copyWith(message: () => e.message));
      emit(state.copyWith(message: () => null));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
