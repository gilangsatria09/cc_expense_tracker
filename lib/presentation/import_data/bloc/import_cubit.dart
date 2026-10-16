import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/domain_exception.dart';
import '../../../domain/entities/import_summary.dart';
import '../../../domain/services/data_importer.dart';
import '../../../domain/services/json_file_picker.dart';
import '../../../domain/usecases/generate_subscription_bills.dart';

enum ImportStatus { idle, working, needsConfirm, success, failure }

class ImportState extends Equatable {
  const ImportState({
    this.status = ImportStatus.idle,
    this.summary,
    this.generatedBills = 0,
    this.message,
  });

  final ImportStatus status;
  final ImportSummary? summary;

  final int generatedBills;
  final String? message;

  ImportState copyWith({
    ImportStatus? status,
    ValueGetter<ImportSummary?>? summary,
    int? generatedBills,
    ValueGetter<String?>? message,
  }) => ImportState(
    status: status ?? this.status,
    summary: summary != null ? summary() : this.summary,
    generatedBills: generatedBills ?? this.generatedBills,
    message: message != null ? message() : this.message,
  );

  @override
  List<Object?> get props => [status, summary, generatedBills, message];
}

class ImportCubit extends Cubit<ImportState> {
  ImportCubit(
    this._picker,
    this._importer,
    this._generateBills, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now,
       super(const ImportState());

  final JsonFilePicker _picker;
  final DataImporter _importer;
  final GenerateSubscriptionBills _generateBills;
  final DateTime Function() _now;
  String? _pendingJson;

  Future<void> pickAndImport() async {
    if (state.status == ImportStatus.working) return;
    emit(const ImportState(status: ImportStatus.working));
    try {
      final json = await _picker.pickJson();
      if (json == null) {
        emit(const ImportState());
        return;
      }
      if (await _importer.hasData()) {
        _pendingJson = json;
        emit(const ImportState(status: ImportStatus.needsConfirm));
        return;
      }
      await _run(json, replace: false);
    } on DomainException catch (e) {
      emit(ImportState(status: ImportStatus.failure, message: e.message));
    }
  }

  Future<void> confirmReplace() async {
    final json = _pendingJson;
    if (json == null || state.status != ImportStatus.needsConfirm) return;
    _pendingJson = null;
    emit(const ImportState(status: ImportStatus.working));
    await _run(json, replace: true);
  }

  void cancelReplace() {
    _pendingJson = null;
    emit(const ImportState());
  }

  Future<void> _run(String json, {required bool replace}) async {
    try {
      final summary = await _importer.importJson(
        json,
        replaceExisting: replace,
      );
      var generated = 0;
      try {
        generated = await _generateBills(_now());
      } catch (_) {
      }
      emit(
        ImportState(
          status: ImportStatus.success,
          summary: summary,
          generatedBills: generated,
        ),
      );
    } on DomainException catch (e) {
      emit(ImportState(status: ImportStatus.failure, message: e.message));
    }
  }
}
