import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/domain_exception.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/entities/akun.dart';
import '../../../domain/entities/cicilan.dart';
import '../../../domain/repositories/akun_repository.dart';
import '../../../domain/repositories/cicilan_repository.dart';
import '../../../domain/usecases/save_cicilan.dart';

class CicilanFormState extends Equatable {
  const CicilanFormState({
    required this.draft,
    required this.isEdit,
    this.akuns = const [],
    this.submitting = false,
    this.error,
    this.done = false,
  });

  final Cicilan draft;
  final bool isEdit;
  final List<Akun> akuns;
  final bool submitting;
  final String? error;
  final bool done;

  int get suggestedPerBulan => draft.tenor > 0 && draft.totalHargaBarang > 0
      ? (draft.totalHargaBarang + draft.tenor - 1) ~/ draft.tenor
      : 0;

  CicilanFormState copyWith({
    Cicilan? draft,
    List<Akun>? akuns,
    bool? submitting,
    ValueGetter<String?>? error,
    bool? done,
  }) => CicilanFormState(
    draft: draft ?? this.draft,
    isEdit: isEdit,
    akuns: akuns ?? this.akuns,
    submitting: submitting ?? this.submitting,
    error: error != null ? error() : this.error,
    done: done ?? this.done,
  );

  @override
  List<Object?> get props => [draft, isEdit, akuns, submitting, error, done];
}

class CicilanFormCubit extends Cubit<CicilanFormState> {
  CicilanFormCubit(
    this._saveCicilan,
    this._repository,
    this._akunRepository, {
    Cicilan? initial,
    DateTime? now,
  }) : super(
         CicilanFormState(
           draft:
               initial ??
               Cicilan(
                 namaCicilan: '',
                 akunId: 0,
                 totalHargaBarang: 0,
                 tenor: 0,
                 jumlahPerBulan: 0,
                 tanggalMulai: dateOnly(now ?? DateTime.now()),
               ),
           isEdit: initial != null,
         ),
       );

  final SaveCicilan _saveCicilan;
  final CicilanRepository _repository;
  final AkunRepository _akunRepository;

  Future<void> load() async {
    final akuns = await _akunRepository.getAll();
    final lastUsed = await _akunRepository.getLastUsedId();
    if (isClosed) return;
    var akunId = state.draft.akunId;
    if (akunId == 0 && akuns.isNotEmpty) {
      akunId = akuns.any((a) => a.id == lastUsed) ? lastUsed! : akuns.first.id;
    }
    emit(
      state.copyWith(
        akuns: akuns,
        draft: state.draft.copyWith(akunId: akunId),
      ),
    );
  }

  void setAkun(int id) => _update((d) => d.copyWith(akunId: id));

  void setNama(String v) => _update((d) => d.copyWith(namaCicilan: v));
  void setTotal(int v) => _update((d) => d.copyWith(totalHargaBarang: v));
  void setTenor(int v) => _update((d) => d.copyWith(tenor: v));
  void setJumlahPerBulan(int v) =>
      _update((d) => d.copyWith(jumlahPerBulan: v));
  void setTanggalMulai(DateTime v) =>
      _update((d) => d.copyWith(tanggalMulai: dateOnly(v)));
  void setCatatan(String v) =>
      _update((d) => d.copyWith(catatan: () => v.trim().isEmpty ? null : v));

  Future<void> submit() async {
    if (state.submitting) return;
    var draft = state.draft;
    if (draft.jumlahPerBulan == 0) {
      draft = draft.copyWith(jumlahPerBulan: state.suggestedPerBulan);
    }
    emit(state.copyWith(submitting: true, error: () => null));
    try {
      await _saveCicilan(draft);
      if (!isClosed) emit(state.copyWith(submitting: false, done: true));
    } on DomainException catch (e) {
      if (!isClosed) {
        emit(state.copyWith(submitting: false, error: () => e.message));
      }
    }
  }

  Future<void> delete() async {
    if (!state.isEdit || state.submitting) return;
    emit(state.copyWith(submitting: true));
    await _repository.delete(state.draft.id);
    if (!isClosed) emit(state.copyWith(submitting: false, done: true));
  }

  void _update(Cicilan Function(Cicilan) change) =>
      emit(state.copyWith(draft: change(state.draft), error: () => null));
}
