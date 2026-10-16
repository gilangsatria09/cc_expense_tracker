import 'dart:convert';
import 'dart:typed_data';

import 'package:cc_expense_tracker/core/di/injection.dart';
import 'package:cc_expense_tracker/core/error/domain_exception.dart';
import 'package:cc_expense_tracker/core/theme/app_theme.dart';
import 'package:cc_expense_tracker/data/database/app_database.dart';
import 'package:cc_expense_tracker/domain/services/backup_file_saver.dart';
import 'package:cc_expense_tracker/domain/services/data_exporter.dart';
import 'package:cc_expense_tracker/presentation/import_data/bloc/backup_cubit.dart';
import 'package:cc_expense_tracker/presentation/import_data/pages/import_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeExporter implements DataExporter {
  Object result = '{"version":1}';

  @override
  Future<String> exportJson() async {
    final r = result;
    if (r is DomainException) throw r;
    return r as String;
  }
}

class FakeSaver implements BackupFileSaver {
  bool saves = true;
  Object? error;
  final saved = <({String fileName, Uint8List bytes})>[];

  @override
  Future<bool> save({
    required String fileName,
    required Uint8List bytes,
  }) async {
    if (error != null) throw error!;
    saved.add((fileName: fileName, bytes: bytes));
    return saves;
  }
}

void main() {
  late FakeExporter exporter;
  late FakeSaver saver;

  setUp(() {
    exporter = FakeExporter();
    saver = FakeSaver();
  });

  group('BackupCubit', () {
    BackupCubit newCubit() {
      final c = BackupCubit(
        exporter,
        saver,
        now: () => DateTime(2026, 9, 6, 8, 5),
      );
      addTearDown(c.close);
      return c;
    }

    test(
      'nama file memuat tanggal & jam; isi file = JSON dari exporter',
      () async {
        exporter.result = '{"version":1,"x":"é"}';
        final c = newCubit();
        await c.backup();

        expect(c.state.status, BackupStatus.success);
        expect(c.state.fileName, 'cc_expense_backup_2026-09-06_0805.json');
        expect(saver.saved.single.fileName, c.state.fileName);
        expect(utf8.decode(saver.saved.single.bytes), '{"version":1,"x":"é"}');
      },
    );

    test('dibatalkan user: kembali idle tanpa pesan sukses', () async {
      saver.saves = false;
      final c = newCubit();
      await c.backup();
      expect(c.state.status, BackupStatus.idle);
      expect(c.state.fileName, isNull);
    });

    test('kegagalan exporter / penyimpan jadi pesan gagal', () async {
      exporter.result = const DomainException('Data tidak terbaca');
      final c = newCubit();
      await c.backup();
      expect(c.state.status, BackupStatus.failure);
      expect(c.state.message, 'Data tidak terbaca');

      exporter.result = '{}';
      saver.error = StateError('disk penuh');
      await c.backup();
      expect(c.state.status, BackupStatus.failure);
      expect(c.state.message, contains('disk penuh'));
    });
  });

  group('halaman Backup & Import', () {
    late AppDatabase db;

    setUp(() async {
      db = AppDatabase.inMemory();
      await configureDependencies(database: db);
      getIt
        ..unregister<DataExporter>()
        ..registerSingleton<DataExporter>(exporter)
        ..unregister<BackupFileSaver>()
        ..registerSingleton<BackupFileSaver>(saver);
    });
    tearDown(() async {
      await getIt.reset();
      await db.close();
    });

    Future<void> pumpPage(WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const ImportPage()),
      );
      await tester.pump();
    }

    testWidgets('Simpan backup menampilkan nama file yang tersimpan', (
      tester,
    ) async {
      await pumpPage(tester);
      expect(find.text('Backup & Import'), findsOneWidget);

      await tester.tap(find.text('Simpan backup'));
      await tester.pumpAndSettle();

      expect(saver.saved, hasLength(1));
      expect(
        find.textContaining('Backup tersimpan: cc_expense_backup_'),
        findsOneWidget,
      );
    });

    testWidgets('dibatalkan: tidak ada pesan sukses', (tester) async {
      saver.saves = false;
      await pumpPage(tester);
      await tester.tap(find.text('Simpan backup'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Backup tersimpan'), findsNothing);
    });

    testWidgets('gagal: pesan kesalahan tampil', (tester) async {
      exporter.result = const DomainException('Data tidak terbaca');
      await pumpPage(tester);
      await tester.tap(find.text('Simpan backup'));
      await tester.pumpAndSettle();
      expect(find.text('Data tidak terbaca'), findsOneWidget);
    });
  });
}
