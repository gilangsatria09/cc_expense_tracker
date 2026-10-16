import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/error/domain_exception.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/split_group_order.dart';
import '../../../domain/repositories/transaksi_repository.dart';
import '../../../domain/services/split_extractor.dart';
import '../../../domain/usecases/split_calculator.dart';

enum SplitMode { rata, ai }

class SplitRowDraft extends Equatable {
  const SplitRowDraft({
    required this.id,
    required this.nama,
    this.amount,
    this.status = StatusBayar.belumDibayar,
  });

  final int id;
  final String nama;
  final int? amount;
  final StatusBayar status;

  SplitRowDraft copyWith({String? nama, ValueGetter<int?>? amount}) =>
      SplitRowDraft(
        id: id,
        nama: nama ?? this.nama,
        amount: amount != null ? amount() : this.amount,
        status: status,
      );

  @override
  List<Object?> get props => [id, nama, amount, status];
}

class SplitResult {
  const SplitResult({required this.splits, required this.sumberEkstraksi});

  final List<SplitGroupOrder> splits;
  final SumberEkstraksi sumberEkstraksi;
}

class SplitBillState extends Equatable {
  const SplitBillState({
    required this.totalTagihan,
    required this.ongkirFee,
    required this.rows,
    this.mode = SplitMode.rata,
    this.sumberAi = SumberEkstraksi.aiStruk,
    this.aiUsed,
    this.knownNames = const [],
    this.extracting = false,
    this.error,
  });

  final int totalTagihan;
  final int ongkirFee;
  final List<SplitRowDraft> rows;
  final SplitMode mode;

  final SumberEkstraksi sumberAi;

  final SumberEkstraksi? aiUsed;
  final List<String> knownNames;
  final bool extracting;
  final String? error;

  int get jumlahOrang => rows.length;

  List<String> get suggestions {
    final used = rows.map((r) => r.nama.trim().toLowerCase()).toSet();
    return knownNames
        .where((n) => !used.contains(n.trim().toLowerCase()))
        .toList();
  }

  int get bagianRata =>
      jumlahOrang == 0 ? totalTagihan : totalTagihan ~/ jumlahOrang;

  List<int> get effectiveAmounts => [
    for (final r in rows) r.amount ?? bagianRata,
  ];

  int get selisih => rows.every((r) => r.amount == null)
      ? 0
      : SplitCalculator.selisih(
          totalTagihan: totalTagihan,
          amounts: effectiveAmounts,
        );

  bool get hasSelf => rows.any((r) => r.nama.trim() == namaSaya);

  SplitBillState copyWith({
    List<SplitRowDraft>? rows,
    SplitMode? mode,
    SumberEkstraksi? sumberAi,
    SumberEkstraksi? aiUsed,
    List<String>? knownNames,
    bool? extracting,
    ValueGetter<String?>? error,
  }) => SplitBillState(
    totalTagihan: totalTagihan,
    ongkirFee: ongkirFee,
    rows: rows ?? this.rows,
    mode: mode ?? this.mode,
    sumberAi: sumberAi ?? this.sumberAi,
    aiUsed: aiUsed ?? this.aiUsed,
    knownNames: knownNames ?? this.knownNames,
    extracting: extracting ?? this.extracting,
    error: error != null ? error() : this.error,
  );

  @override
  List<Object?> get props => [
    totalTagihan,
    ongkirFee,
    rows,
    mode,
    sumberAi,
    aiUsed,
    knownNames,
    extracting,
    error,
  ];
}

class SplitBillCubit extends Cubit<SplitBillState> {
  SplitBillCubit(
    this._extractor,
    this._transaksiRepository, {
    required int totalTagihan,
    required int ongkirFee,
    List<SplitGroupOrder> initial = const [],
  }) : super(
         SplitBillState(
           totalTagihan: totalTagihan,
           ongkirFee: ongkirFee,
           rows: [
             if (initial.isEmpty)
               const SplitRowDraft(id: 0, nama: namaSaya)
             else
               for (var i = 0; i < initial.length; i++)
                 SplitRowDraft(
                   id: i,
                   nama: initial[i].nama,
                   amount: initial[i].hargaManual,
                   status: initial[i].status,
                 ),
           ],
         ),
       ) {
    _nextId = state.rows.length;
  }

  final SplitExtractor _extractor;
  final TransaksiRepository _transaksiRepository;
  late int _nextId;

  Future<void> loadKnownNames() async {
    final names = await _transaksiRepository.getKnownParticipantNames();
    if (!isClosed) emit(state.copyWith(knownNames: names));
  }

  void setMode(SplitMode mode) => emit(state.copyWith(mode: mode));

  void setSumberAi(SumberEkstraksi v) => emit(state.copyWith(sumberAi: v));

  void addName(String raw) {
    final nama = raw.trim();
    if (nama.isEmpty) return;
    if (_hasName(nama)) {
      emit(state.copyWith(error: () => '"$nama" sudah ada di daftar'));
      return;
    }
    final known = state.knownNames.any(
      (n) => n.toLowerCase() == nama.toLowerCase(),
    );
    emit(
      state.copyWith(
        rows: [
          ...state.rows,
          SplitRowDraft(id: _nextId++, nama: nama),
        ],
        knownNames: known ? null : [nama, ...state.knownNames],
        error: () => null,
      ),
    );
  }

  void removeRow(int id) => emit(
    state.copyWith(
      rows: state.rows.where((r) => r.id != id).toList(),
      error: () => null,
    ),
  );

  void rename(int id, String nama) =>
      _updateRow(id, (r) => r.copyWith(nama: nama));

  void setAmount(int id, int? amount) =>
      _updateRow(id, (r) => r.copyWith(amount: () => amount));

  Future<void> extract(Uint8List bytes, String mimeType) async {
    emit(state.copyWith(extracting: true, error: () => null));
    try {
      final items = await _extractor.extract(
        imageBytes: bytes,
        mimeType: mimeType,
      );
      if (isClosed) return;
      if (items.isEmpty) {
        emit(
          state.copyWith(
            extracting: false,
            error: () => 'Tidak ada pesanan yang terbaca dari gambar',
          ),
        );
        return;
      }
      final amounts = SplitCalculator.foldOngkir(
        items.map((e) => e.subtotal).toList(),
        state.ongkirFee,
      );
      emit(
        state.copyWith(
          extracting: false,
          aiUsed: state.sumberAi,
          rows: [
            for (var i = 0; i < items.length; i++)
              SplitRowDraft(
                id: _nextId++,
                nama: items[i].nama,
                amount: amounts[i],
              ),
          ],
        ),
      );
    } on DomainException catch (e) {
      if (!isClosed) {
        emit(state.copyWith(extracting: false, error: () => e.message));
      }
    }
  }

  SplitResult? confirm() {
    final rows = state.rows;
    if (rows.isEmpty) return _fail('Tambahkan minimal satu peserta');
    if (rows.any((r) => r.nama.trim().isEmpty)) {
      return _fail('Nama peserta tidak boleh kosong');
    }
    final names = rows.map((r) => r.nama.trim().toLowerCase()).toList();
    if (names.toSet().length != names.length) {
      return _fail('Nama peserta tidak boleh sama');
    }
    return SplitResult(
      splits: [
        for (final r in rows)
          SplitGroupOrder(
            nama: r.nama.trim(),
            hargaManual: r.amount,
            status: r.status,
          ),
      ],
      sumberEkstraksi: state.aiUsed ?? SumberEkstraksi.manual,
    );
  }

  SplitResult? _fail(String message) {
    emit(state.copyWith(error: () => message));
    return null;
  }

  bool _hasName(String nama) =>
      state.rows.any((r) => r.nama.trim().toLowerCase() == nama.toLowerCase());

  void _updateRow(int id, SplitRowDraft Function(SplitRowDraft) change) => emit(
    state.copyWith(
      rows: [for (final r in state.rows) r.id == id ? change(r) : r],
      error: () => null,
    ),
  );
}
