import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/domain_exception.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/entities/akun.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/split_group_order.dart';
import '../../../domain/entities/subscription.dart';
import '../../../domain/entities/transaksi.dart';
import '../../../domain/repositories/akun_repository.dart';
import '../../../domain/repositories/subscription_repository.dart';
import '../../../domain/repositories/transaksi_repository.dart';
import '../../../domain/usecases/save_transaksi.dart';

class TransaksiFormState extends Equatable {
  const TransaksiFormState({
    required this.draft,
    required this.isEdit,
    this.subscriptions = const [],
    this.akuns = const [],
    this.submitting = false,
    this.error,
    this.done = false,
  });

  final Transaksi draft;
  final bool isEdit;

  final List<Subscription> subscriptions;

  final List<Akun> akuns;
  final bool submitting;
  final String? error;
  final bool done;

  Akun? get akun {
    for (final a in akuns) {
      if (a.id == draft.akunId) return a;
    }
    return null;
  }

  int get cutoff => akun?.tanggalCutoff ?? 0;

  DateTime get bulanOtomatis => bulanTagihanFor(draft.tanggal, cutoff);

  DateTime get bulanTagihan => draft.bulanTagihan ?? bulanOtomatis;

  bool get bulanManual =>
      draft.bulanTagihan != null && draft.bulanTagihan != bulanOtomatis;

  TransaksiFormState copyWith({
    Transaksi? draft,
    List<Subscription>? subscriptions,
    List<Akun>? akuns,
    bool? submitting,
    ValueGetter<String?>? error,
    bool? done,
  }) => TransaksiFormState(
    draft: draft ?? this.draft,
    isEdit: isEdit,
    subscriptions: subscriptions ?? this.subscriptions,
    akuns: akuns ?? this.akuns,
    submitting: submitting ?? this.submitting,
    error: error != null ? error() : this.error,
    done: done ?? this.done,
  );

  @override
  List<Object?> get props => [
    draft,
    isEdit,
    subscriptions,
    akuns,
    submitting,
    error,
    done,
  ];
}

class TransaksiFormCubit extends Cubit<TransaksiFormState> {
  TransaksiFormCubit(
    this._saveTransaksi,
    this._transaksiRepository,
    this._subscriptionRepository,
    this._akunRepository, {
    Transaksi? initial,
    DateTime? now,
  }) : super(
         TransaksiFormState(
           draft:
               initial ??
               Transaksi(
                 tanggal: dateOnly(now ?? DateTime.now()),
                 deskripsi: '',
                 jenis: JenisTransaksi.personal,
                 akunId: 0,
                 totalTagihan: 0,
                 sumberEkstraksi: SumberEkstraksi.manual,
               ),
           isEdit: initial != null,
         ),
       );

  final SaveTransaksi _saveTransaksi;
  final TransaksiRepository _transaksiRepository;
  final SubscriptionRepository _subscriptionRepository;
  final AkunRepository _akunRepository;

  Future<void> load() async {
    final linkedId = state.draft.subscriptionId;
    final subscriptions = await _subscriptionRepository.getAll();
    final akuns = await _akunRepository.getAll();
    final lastUsed = await _akunRepository.getLastUsedId();
    if (isClosed) return;

    var akunId = state.draft.akunId;
    if (akunId == 0 && akuns.isNotEmpty) {
      akunId = akuns.any((a) => a.id == lastUsed) ? lastUsed! : akuns.first.id;
    }
    emit(
      state.copyWith(
        draft: state.draft.copyWith(akunId: akunId),
        akuns: akuns,
        subscriptions: subscriptions
            .where(
              (s) => s.status == StatusSubscription.aktif || s.id == linkedId,
            )
            .toList(),
      ),
    );
  }

  void setAkun(int id) {
    final keepManual = state.bulanManual;
    final manualValue = state.draft.bulanTagihan;
    _update(
      (d) => d.copyWith(
        akunId: id,
        bulanTagihan: () => keepManual ? manualValue : null,
      ),
    );
  }

  void setTanggal(DateTime v) {
    final keepManual = state.bulanManual;
    final manualValue = state.draft.bulanTagihan;
    _update(
      (d) => d.copyWith(
        tanggal: dateOnly(v),
        bulanTagihan: () => keepManual ? manualValue : null,
      ),
    );
  }

  void setBulanTagihan(DateTime month) {
    final chosen = monthOf(month);
    _update(
      (d) => d.copyWith(
        bulanTagihan: () => chosen == state.bulanOtomatis ? null : chosen,
      ),
    );
  }

  void resetBulanTagihan() =>
      _update((d) => d.copyWith(bulanTagihan: () => null));
  void setDeskripsi(String v) => _update((d) => d.copyWith(deskripsi: v));
  void setTotal(int v) => _update((d) => d.copyWith(totalTagihan: v));
  void setStatus(StatusBayar v) => _update((d) => d.copyWith(status: v));
  void setCatatan(String v) =>
      _update((d) => d.copyWith(catatan: () => v.trim().isEmpty ? null : v));
  void setMerchant(String v) =>
      _update((d) => d.copyWith(merchant: () => v.trim().isEmpty ? null : v));
  void setOngkir(int v) => _update((d) => d.copyWith(ongkirFee: v));

  void setSplitStatus(int index, StatusBayar status) {
    final splits = state.draft.splits;
    if (index < 0 || index >= splits.length) return;
    _update(
      (d) => d.copyWith(
        splits: [
          for (var i = 0; i < splits.length; i++)
            i == index ? splits[i].copyWith(status: status) : splits[i],
        ],
      ),
    );
  }

  void setSplits(
    List<SplitGroupOrder> splits,
    SumberEkstraksi sumberEkstraksi,
  ) => _update(
    (d) => d.copyWith(splits: splits, sumberEkstraksi: () => sumberEkstraksi),
  );

  void setSubscription(int? id) =>
      _update((d) => d.copyWith(subscriptionId: () => id));

  void setJenis(JenisTransaksi v) => _update((d) => d.copyWith(jenis: v));

  Future<void> submit() async {
    if (state.submitting) return;
    if (state.draft.deskripsi.trim().isEmpty) {
      emit(state.copyWith(error: () => 'Deskripsi wajib diisi'));
      return;
    }
    emit(state.copyWith(submitting: true, error: () => null));
    try {
      await _saveTransaksi(
        state.draft.copyWith(deskripsi: state.draft.deskripsi.trim()),
      );
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
    await _transaksiRepository.delete(state.draft.id);
    if (!isClosed) emit(state.copyWith(submitting: false, done: true));
  }

  void _update(Transaksi Function(Transaksi) change) =>
      emit(state.copyWith(draft: change(state.draft), error: () => null));
}
