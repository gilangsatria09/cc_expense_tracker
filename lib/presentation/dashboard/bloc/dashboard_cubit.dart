import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../../domain/entities/akun.dart';
import '../../../domain/entities/dashboard_summary.dart';
import '../../../domain/repositories/akun_repository.dart';
import '../../../domain/repositories/cicilan_repository.dart';
import '../../../domain/repositories/transaksi_repository.dart';
import '../../../domain/usecases/dashboard_calculator.dart';

enum DashboardStatus { loading, success, failure }

class DashboardState extends Equatable {
  const DashboardState({
    required this.month,
    this.status = DashboardStatus.loading,
    this.summary,
    this.akuns = const [],
    this.akunFilter,
  });

  final DateTime month;
  final DashboardStatus status;
  final DashboardSummary? summary;

  final List<Akun> akuns;

  final int? akunFilter;

  @override
  List<Object?> get props => [month, status, summary, akuns, akunFilter];
}

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(
    this._transaksiRepository,
    this._cicilanRepository,
    this._akunRepository, {
    DateTime? now,
  }) : _month = BehaviorSubject.seeded(_monthOf(now ?? DateTime.now())),
       super(DashboardState(month: _monthOf(now ?? DateTime.now())));

  final TransaksiRepository _transaksiRepository;
  final CicilanRepository _cicilanRepository;
  final AkunRepository _akunRepository;
  final BehaviorSubject<DateTime> _month;
  final BehaviorSubject<int?> _akunFilter = BehaviorSubject.seeded(null);
  StreamSubscription<DashboardState>? _subscription;

  static DateTime _monthOf(DateTime d) => DateTime(d.year, d.month);

  void start() {
    _subscription?.cancel();
    _subscription =
        Rx.combineLatest5(
          _transaksiRepository.watchAll(),
          _cicilanRepository.watchAll(),
          _akunRepository.watchAll(),
          _month,
          _akunFilter,
          (transaksis, cicilans, akuns, month, filter) {
            final aktif = akuns.any((a) => a.id == filter) ? filter : null;
            return DashboardState(
              month: month,
              status: DashboardStatus.success,
              akuns: akuns,
              akunFilter: aktif,
              summary: DashboardCalculator.calculate(
                transaksis: transaksis,
                cicilans: cicilans,
                akuns: akuns,
                month: month,
                akunId: aktif,
              ),
            );
          },
        ).listen(
          emit,
          onError: (Object error, StackTrace stackTrace) => emit(
            DashboardState(month: state.month, status: DashboardStatus.failure),
          ),
        );
  }

  void setMonth(DateTime month) => _month.add(_monthOf(month));

  void setAkunFilter(int? akunId) => _akunFilter.add(akunId);

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await _month.close();
    await _akunFilter.close();
    return super.close();
  }
}
