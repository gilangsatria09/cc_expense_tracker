import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../../domain/entities/akun.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/transaksi.dart';
import '../../../domain/repositories/akun_repository.dart';
import '../../../domain/repositories/transaksi_repository.dart';

sealed class TransaksiListEvent {
  const TransaksiListEvent();
}

class TransaksiMonthChanged extends TransaksiListEvent {
  const TransaksiMonthChanged(this.month);

  final DateTime month;
}

class TransaksiSelectionToggled extends TransaksiListEvent {
  const TransaksiSelectionToggled(this.id);

  final int id;
}

class TransaksiAkunFilterChanged extends TransaksiListEvent {
  const TransaksiAkunFilterChanged(this.akunId);

  final int? akunId;
}

class TransaksiStatusFilterChanged extends TransaksiListEvent {
  const TransaksiStatusFilterChanged(this.status);

  final StatusBayar? status;
}

class TransaksiSelectAllRequested extends TransaksiListEvent {
  const TransaksiSelectAllRequested();
}

class TransaksiSelectionCleared extends TransaksiListEvent {
  const TransaksiSelectionCleared();
}

class TransaksiSelectedStatusChanged extends TransaksiListEvent {
  const TransaksiSelectedStatusChanged(this.status);

  final StatusBayar status;
}

class TransaksiStatusUndone extends TransaksiListEvent {
  const TransaksiStatusUndone(this.notice);

  final StatusChangeNotice notice;
}

class StatusChangeNotice {
  const StatusChangeNotice({required this.status, required this.previous});

  final StatusBayar status;

  final Map<int, StatusBayar> previous;

  int get count => previous.length;
}

enum TransaksiListStatus { loading, success, failure }

class TransaksiListState extends Equatable {
  const TransaksiListState({
    required this.month,
    this.status = TransaksiListStatus.loading,
    this.transaksis = const [],
    this.akuns = const [],
    this.akunFilter,
    this.statusFilter,
    this.statusCounts = const {},
    this.adaTransaksiBulanIni = false,
    this.selectedIds = const {},
    this.notice,
  });

  final DateTime month;
  final TransaksiListStatus status;

  final List<Transaksi> transaksis;
  final List<Akun> akuns;

  final int? akunFilter;

  final StatusBayar? statusFilter;

  final Map<StatusBayar, int> statusCounts;

  final bool adaTransaksiBulanIni;

  Map<int, String> get namaAkun => {for (final a in akuns) a.id: a.nama};

  final Set<int> selectedIds;

  final StatusChangeNotice? notice;

  bool get selecting => selectedIds.isNotEmpty;

  TransaksiListState copyWith({
    DateTime? month,
    TransaksiListStatus? status,
    List<Transaksi>? transaksis,
    List<Akun>? akuns,
    ValueGetter<int?>? akunFilter,
    ValueGetter<StatusBayar?>? statusFilter,
    Map<StatusBayar, int>? statusCounts,
    bool? adaTransaksiBulanIni,
    Set<int>? selectedIds,
    StatusChangeNotice? notice,
  }) => TransaksiListState(
    month: month ?? this.month,
    status: status ?? this.status,
    transaksis: transaksis ?? this.transaksis,
    akuns: akuns ?? this.akuns,
    akunFilter: akunFilter != null ? akunFilter() : this.akunFilter,
    statusFilter: statusFilter != null ? statusFilter() : this.statusFilter,
    statusCounts: statusCounts ?? this.statusCounts,
    adaTransaksiBulanIni: adaTransaksiBulanIni ?? this.adaTransaksiBulanIni,
    selectedIds: selectedIds ?? this.selectedIds,
    notice: notice ?? this.notice,
  );

  @override
  List<Object?> get props => [
    month,
    status,
    transaksis,
    akuns,
    akunFilter,
    statusFilter,
    statusCounts,
    adaTransaksiBulanIni,
    selectedIds,
    notice,
  ];
}

class TransaksiListBloc extends Bloc<TransaksiListEvent, TransaksiListState> {
  TransaksiListBloc(this._repository, this._akunRepository, {DateTime? now})
    : super(TransaksiListState(month: _monthOf(now ?? DateTime.now()))) {
    on<TransaksiMonthChanged>(_onMonthChanged, transformer: restartable());
    on<TransaksiAkunFilterChanged>(_onAkunFilterChanged);
    on<TransaksiStatusFilterChanged>(_onStatusFilterChanged);
    on<TransaksiSelectionToggled>(_onToggled);
    on<TransaksiSelectAllRequested>(
      (event, emit) => emit(
        state.copyWith(selectedIds: state.transaksis.map((t) => t.id).toSet()),
      ),
    );
    on<TransaksiSelectionCleared>(
      (event, emit) => emit(state.copyWith(selectedIds: const {})),
    );
    on<TransaksiSelectedStatusChanged>(_onStatusChanged);
    on<TransaksiStatusUndone>(_onUndone);
  }

  final TransaksiRepository _repository;
  final AkunRepository _akunRepository;

  List<Transaksi> _monthAll = const [];

  static DateTime _monthOf(DateTime d) => DateTime(d.year, d.month);

  Future<void> _onMonthChanged(
    TransaksiMonthChanged event,
    Emitter<TransaksiListState> emit,
  ) async {
    final month = _monthOf(event.month);
    emit(
      state.copyWith(
        month: month,
        status: TransaksiListStatus.loading,
        transaksis: const [],
        selectedIds: const {},
      ),
    );
    await emit.forEach<({List<Transaksi> list, List<Akun> akuns})>(
      Rx.combineLatest2(
        _repository.watchByMonth(month),
        _akunRepository.watchAll(),
        (list, akuns) => (list: list, akuns: akuns),
      ),
      onData: (data) {
        _monthAll = data.list;
        final filter = data.akuns.any((a) => a.id == state.akunFilter)
            ? state.akunFilter
            : null;
        final visible = _visible(data.list, filter, state.statusFilter);
        return state.copyWith(
          status: TransaksiListStatus.success,
          transaksis: visible,
          akuns: data.akuns,
          akunFilter: () => filter,
          statusCounts: _counts(data.list, filter),
          adaTransaksiBulanIni: data.list.isNotEmpty,
          selectedIds: state.selectedIds.intersection(
            visible.map((t) => t.id).toSet(),
          ),
        );
      },
      onError: (error, stackTrace) =>
          state.copyWith(status: TransaksiListStatus.failure),
    );
  }

  static List<Transaksi> _visible(
    List<Transaksi> all,
    int? akunId,
    StatusBayar? status,
  ) => all
      .where(
        (t) =>
            (akunId == null || t.akunId == akunId) &&
            (status == null || t.status == status),
      )
      .toList();

  static Map<StatusBayar, int> _counts(List<Transaksi> all, int? akunId) {
    final counts = {for (final s in StatusBayar.values) s: 0};
    for (final t in all) {
      if (akunId == null || t.akunId == akunId) {
        counts[t.status] = counts[t.status]! + 1;
      }
    }
    return counts;
  }

  void _onAkunFilterChanged(
    TransaksiAkunFilterChanged event,
    Emitter<TransaksiListState> emit,
  ) => emit(
    state.copyWith(
      akunFilter: () => event.akunId,
      transaksis: _visible(_monthAll, event.akunId, state.statusFilter),
      statusCounts: _counts(_monthAll, event.akunId),
      selectedIds: const {},
    ),
  );

  void _onStatusFilterChanged(
    TransaksiStatusFilterChanged event,
    Emitter<TransaksiListState> emit,
  ) => emit(
    state.copyWith(
      statusFilter: () => event.status,
      transaksis: _visible(_monthAll, state.akunFilter, event.status),
      selectedIds: const {},
    ),
  );

  void _onToggled(
    TransaksiSelectionToggled event,
    Emitter<TransaksiListState> emit,
  ) {
    final next = {...state.selectedIds};
    if (!next.remove(event.id)) next.add(event.id);
    emit(state.copyWith(selectedIds: next));
  }

  Future<void> _onStatusChanged(
    TransaksiSelectedStatusChanged event,
    Emitter<TransaksiListState> emit,
  ) async {
    final previous = <int, StatusBayar>{
      for (final t in state.transaksis)
        if (state.selectedIds.contains(t.id) && t.status != event.status)
          t.id: t.status,
    };
    if (previous.isEmpty) {
      emit(state.copyWith(selectedIds: const {}));
      return;
    }
    await _repository.updateStatuses({
      for (final id in previous.keys) id: event.status,
    });
    emit(
      state.copyWith(
        selectedIds: const {},
        notice: StatusChangeNotice(status: event.status, previous: previous),
      ),
    );
  }

  Future<void> _onUndone(
    TransaksiStatusUndone event,
    Emitter<TransaksiListState> emit,
  ) => _repository.updateStatuses(event.notice.previous);
}
