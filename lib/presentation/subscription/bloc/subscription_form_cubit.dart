import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/domain_exception.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/entities/akun.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/subscription.dart';
import '../../../domain/repositories/akun_repository.dart';
import '../../../domain/repositories/subscription_repository.dart';
import '../../../domain/usecases/save_subscription.dart';

class SubscriptionFormResult {
  const SubscriptionFormResult({this.savedId, this.deleted = false});

  final int? savedId;
  final bool deleted;
}

class SubscriptionFormState extends Equatable {
  const SubscriptionFormState({
    required this.draft,
    required this.isEdit,
    this.akuns = const [],
    this.submitting = false,
    this.error,
    this.result,
  });

  final Subscription draft;
  final bool isEdit;
  final List<Akun> akuns;
  final bool submitting;
  final String? error;

  final SubscriptionFormResult? result;

  SubscriptionFormState copyWith({
    Subscription? draft,
    List<Akun>? akuns,
    bool? submitting,
    ValueGetter<String?>? error,
    SubscriptionFormResult? result,
  }) => SubscriptionFormState(
    draft: draft ?? this.draft,
    isEdit: isEdit,
    akuns: akuns ?? this.akuns,
    submitting: submitting ?? this.submitting,
    error: error != null ? error() : this.error,
    result: result ?? this.result,
  );

  @override
  List<Object?> get props => [
    draft,
    isEdit,
    akuns,
    submitting,
    error,
    result?.savedId,
    result?.deleted,
  ];
}

class SubscriptionFormCubit extends Cubit<SubscriptionFormState> {
  SubscriptionFormCubit(
    this._saveSubscription,
    this._repository,
    this._akunRepository, {
    Subscription? initial,
    DateTime? now,
  }) : super(
         SubscriptionFormState(
           draft:
               initial ??
               Subscription(
                 namaLayanan: '',
                 akunId: 0,
                 siklusBilling: SiklusBilling.bulanan,
                 tanggalTagihanBerikutnya: dateOnly(now ?? DateTime.now()),
               ),
           isEdit: initial != null,
         ),
       );

  final SaveSubscription _saveSubscription;
  final SubscriptionRepository _repository;
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

  void setNama(String v) => _update((d) => d.copyWith(namaLayanan: v));

  void setHarga(int? v) => _update(
    (d) => d.copyWith(hargaTetap: () => (v == null || v == 0) ? null : v),
  );

  void setSiklus(SiklusBilling v) =>
      _update((d) => d.copyWith(siklusBilling: v));
  void setStatus(StatusSubscription v) => _update((d) => d.copyWith(status: v));

  void setTanggal(DateTime v) {
    final date = dateOnly(v);
    _update(
      (d) => d.copyWith(tanggalTagihanBerikutnya: date, hariTagihan: date.day),
    );
  }

  void setCatatan(String v) =>
      _update((d) => d.copyWith(catatan: () => v.trim().isEmpty ? null : v));

  Future<void> submit() async {
    if (state.submitting) return;
    emit(state.copyWith(submitting: true, error: () => null));
    try {
      final id = await _saveSubscription(state.draft);
      if (!isClosed) {
        emit(
          state.copyWith(
            submitting: false,
            result: SubscriptionFormResult(savedId: id),
          ),
        );
      }
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
    if (!isClosed) {
      emit(
        state.copyWith(
          submitting: false,
          result: const SubscriptionFormResult(deleted: true),
        ),
      );
    }
  }

  void _update(Subscription Function(Subscription) change) =>
      emit(state.copyWith(draft: change(state.draft), error: () => null));
}
