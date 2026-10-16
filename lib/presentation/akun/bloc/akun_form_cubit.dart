import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/domain_exception.dart';
import '../../../domain/entities/akun.dart';
import '../../../domain/usecases/save_akun.dart';

class AkunFormState extends Equatable {
  const AkunFormState({
    required this.draft,
    required this.isEdit,
    this.submitting = false,
    this.error,
    this.done = false,
  });

  final Akun draft;
  final bool isEdit;
  final bool submitting;
  final String? error;
  final bool done;

  AkunFormState copyWith({
    Akun? draft,
    bool? submitting,
    ValueGetter<String?>? error,
    bool? done,
  }) => AkunFormState(
    draft: draft ?? this.draft,
    isEdit: isEdit,
    submitting: submitting ?? this.submitting,
    error: error != null ? error() : this.error,
    done: done ?? this.done,
  );

  @override
  List<Object?> get props => [draft, isEdit, submitting, error, done];
}

class AkunFormCubit extends Cubit<AkunFormState> {
  AkunFormCubit(this._saveAkun, this._deleteAkun, {Akun? initial})
    : super(
        AkunFormState(
          draft: initial ?? const Akun(nama: ''),
          isEdit: initial != null,
        ),
      );

  final SaveAkun _saveAkun;
  final DeleteAkun _deleteAkun;

  void setNama(String v) => _update((d) => d.copyWith(nama: v));
  void setLimit(int v) => _update((d) => d.copyWith(limitKredit: v));
  void setSaldoAwal(int v) => _update((d) => d.copyWith(saldoAwal: v));
  void setTanggalCutoff(int v) => _update((d) => d.copyWith(tanggalCutoff: v));
  void setTanggalJatuhTempo(int v) =>
      _update((d) => d.copyWith(tanggalJatuhTempo: v));

  Future<void> submit() async {
    if (state.submitting) return;
    emit(state.copyWith(submitting: true, error: () => null));
    try {
      await _saveAkun(state.draft);
      if (!isClosed) emit(state.copyWith(submitting: false, done: true));
    } on DomainException catch (e) {
      if (!isClosed) {
        emit(state.copyWith(submitting: false, error: () => e.message));
      }
    }
  }

  Future<void> delete() async {
    if (!state.isEdit || state.submitting) return;
    emit(state.copyWith(submitting: true, error: () => null));
    try {
      await _deleteAkun(state.draft.id);
      if (!isClosed) emit(state.copyWith(submitting: false, done: true));
    } on DomainException catch (e) {
      if (!isClosed) {
        emit(state.copyWith(submitting: false, error: () => e.message));
      }
    }
  }

  void _update(Akun Function(Akun) change) =>
      emit(state.copyWith(draft: change(state.draft), error: () => null));
}
