import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/domain_exception.dart';
import '../../../domain/services/backup_file_saver.dart';
import '../../../domain/services/data_exporter.dart';

enum BackupStatus { idle, working, success, failure }

class BackupState extends Equatable {
  const BackupState({
    this.status = BackupStatus.idle,
    this.fileName,
    this.message,
  });

  final BackupStatus status;

  final String? fileName;
  final String? message;

  @override
  List<Object?> get props => [status, fileName, message];
}

class BackupCubit extends Cubit<BackupState> {
  BackupCubit(this._exporter, this._saver, {DateTime Function()? now})
    : _now = now ?? DateTime.now,
      super(const BackupState());

  final DataExporter _exporter;
  final BackupFileSaver _saver;
  final DateTime Function() _now;

  @visibleForTesting
  static String fileNameFor(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return 'cc_expense_backup_${t.year}-${two(t.month)}-${two(t.day)}'
        '_${two(t.hour)}${two(t.minute)}.json';
  }

  Future<void> backup() async {
    if (state.status == BackupStatus.working) return;
    emit(const BackupState(status: BackupStatus.working));
    try {
      final json = await _exporter.exportJson();
      final name = fileNameFor(_now());
      final saved = await _saver.save(
        fileName: name,
        bytes: Uint8List.fromList(utf8.encode(json)),
      );
      emit(
        saved
            ? BackupState(status: BackupStatus.success, fileName: name)
            : const BackupState(),
      );
    } on DomainException catch (e) {
      emit(BackupState(status: BackupStatus.failure, message: e.message));
    } catch (e) {
      emit(
        BackupState(
          status: BackupStatus.failure,
          message: 'Backup gagal disimpan: $e',
        ),
      );
    }
  }
}
