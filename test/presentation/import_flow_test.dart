import 'package:cc_expense_tracker/core/di/injection.dart';
import 'package:cc_expense_tracker/core/error/domain_exception.dart';
import 'package:cc_expense_tracker/core/theme/app_theme.dart';
import 'package:cc_expense_tracker/data/database/app_database.dart';
import 'package:cc_expense_tracker/data/import/sheet_json_importer.dart';
import 'package:cc_expense_tracker/data/repositories/akun_repository_impl.dart';
import 'package:cc_expense_tracker/data/repositories/subscription_repository_impl.dart';
import 'package:cc_expense_tracker/data/repositories/transaksi_repository_impl.dart';
import 'package:cc_expense_tracker/domain/entities/enums.dart';
import 'package:cc_expense_tracker/domain/entities/import_summary.dart';
import 'package:cc_expense_tracker/domain/services/data_importer.dart';
import 'package:cc_expense_tracker/domain/services/json_file_picker.dart';
import 'package:cc_expense_tracker/domain/usecases/generate_subscription_bills.dart';
import 'package:cc_expense_tracker/presentation/import_data/bloc/import_cubit.dart';
import 'package:cc_expense_tracker/presentation/import_data/pages/import_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakePicker implements JsonFilePicker {
  FakePicker(this.result);
  Object? result;

  @override
  Future<String?> pickJson() async {
    final r = result;
    if (r is DomainException) throw r;
    return r as String?;
  }
}

class FakeImporter implements DataImporter {
  bool has = false;
  Object? error;
  final calls = <({String json, bool replace})>[];

  @override
  Future<bool> hasData() async => has;

  @override
  Future<ImportSummary> importJson(
    String json, {
    bool replaceExisting = false,
  }) async {
    calls.add((json: json, replace: replaceExisting));
    final e = error;
    if (e is DomainException) throw e;
    return const ImportSummary(
      transaksi: 137,
      split: 112,
      cicilan: 2,
      subscription: 5,
    );
  }
}

void main() {
  late FakePicker picker;
  late FakeImporter importer;

  setUp(() {
    picker = FakePicker('{"version":1}');
    importer = FakeImporter();
  });

  group('ImportCubit', () {
    late AppDatabase cubitDb;

    setUp(() => cubitDb = AppDatabase.inMemory());
    tearDown(() => cubitDb.close());

    ImportCubit newCubit() {
      final c = ImportCubit(
        picker,
        importer,
        GenerateSubscriptionBills(
          SubscriptionRepositoryImpl(cubitDb),
          AkunRepositoryImpl(cubitDb),
        ),
        now: () => DateTime(2026, 9, 26),
      );
      addTearDown(c.close);
      return c;
    }

    test('dibatalkan: kembali idle tanpa mengimpor', () async {
      picker.result = null;
      final c = newCubit();
      await c.pickAndImport();
      expect(c.state.status, ImportStatus.idle);
      expect(importer.calls, isEmpty);
    });

    test('database kosong: langsung impor tanpa mengganti', () async {
      final c = newCubit();
      await c.pickAndImport();
      expect(c.state.status, ImportStatus.success);
      expect(c.state.summary!.transaksi, 137);
      expect(importer.calls.single.replace, isFalse);
    });

    test('database berisi: minta konfirmasi; batal tidak mengimpor', () async {
      importer.has = true;
      final c = newCubit();
      await c.pickAndImport();
      expect(c.state.status, ImportStatus.needsConfirm);
      expect(importer.calls, isEmpty);

      c.cancelReplace();
      expect(c.state.status, ImportStatus.idle);
      await c.confirmReplace();
      expect(importer.calls, isEmpty);
    });

    test('database berisi: konfirmasi mengimpor dengan replace', () async {
      importer.has = true;
      final c = newCubit();
      await c.pickAndImport();
      await c.confirmReplace();
      expect(c.state.status, ImportStatus.success);
      expect(importer.calls.single.replace, isTrue);
      expect(importer.calls.single.json, '{"version":1}');
    });

    test(
      'setelah import: tagihan subscription jatuh tempo dibuat otomatis',
      () async {
        String sub(String nama, int harga, String status, String next) =>
            '''{
        "namaLayanan": "$nama", "hargaTetap": $harga, "hariTagihan": ${int.parse(next.substring(8))},
        "siklusBilling": "bulanan", "status": "$status", "tanggalTagihanBerikutnya": "$next"}''';
        final json =
            '''{"version": 1,
        "settings": {"tanggalCutoffTagihan": 4},
        "subscriptions": [
          ${sub('Hevy', 45000, 'aktif', '2026-09-25')},
          ${sub('Yellow', 59000, 'dibatalkan', '2026-09-01')},
          ${sub('Claude', 349000, 'aktif', '2026-10-03')}
        ]}''';

        final c = ImportCubit(
          FakePicker(json),
          SheetJsonImporter(cubitDb),
          GenerateSubscriptionBills(
            SubscriptionRepositoryImpl(cubitDb),
            AkunRepositoryImpl(cubitDb),
          ),
          now: () => DateTime(2026, 9, 26),
        );
        addTearDown(c.close);
        await c.pickAndImport();

        expect(c.state.status, ImportStatus.success);
        expect(c.state.generatedBills, 1);
        final bills = await TransaksiRepositoryImpl(cubitDb).getAll();
        expect(bills.single.deskripsi, 'Hevy');
        expect(bills.single.tanggal, DateTime(2026, 9, 25));
        expect(bills.single.bulanTagihan, DateTime(2026, 9));
        expect(bills.single.status, StatusBayar.belumDibayar);
      },
    );

    test('error picker & importer jadi pesan gagal', () async {
      picker.result = const DomainException('File tidak bisa dibaca');
      final c = newCubit();
      await c.pickAndImport();
      expect(c.state.status, ImportStatus.failure);
      expect(c.state.message, 'File tidak bisa dibaca');

      picker.result = '{}';
      importer.error = const DomainException('Transaksi ke-3: "jenis" salah');
      await c.pickAndImport();
      expect(c.state.message, 'Transaksi ke-3: "jenis" salah');
    });
  });

  group('ImportPage', () {
    late AppDatabase db;

    setUp(() async {
      db = AppDatabase.inMemory();
      await configureDependencies(database: db);
      getIt
        ..unregister<JsonFilePicker>()
        ..registerSingleton<JsonFilePicker>(picker)
        ..unregister<DataImporter>()
        ..registerSingleton<DataImporter>(importer);
    });
    tearDown(() async {
      await getIt.reset();
      await db.close();
    });

    Future<void> pumpPage(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const ImportPage()),
      );
      await tester.pump();
    }

    testWidgets('sukses menampilkan ringkasan jumlah data', (tester) async {
      await pumpPage(tester);
      await tester.tap(find.text('Pilih file JSON'));
      await tester.pumpAndSettle();

      expect(find.text('Import berhasil'), findsOneWidget);
      expect(find.text('137 transaksi'), findsOneWidget);
      expect(find.text('112 peserta split'), findsOneWidget);
      expect(find.textContaining('tagihan subscription dibuat'), findsNothing);
    });

    testWidgets('gagal menampilkan pesan error', (tester) async {
      importer.error = const DomainException('Transaksi ke-9: "jenis" salah');
      await pumpPage(tester);
      await tester.tap(find.text('Pilih file JSON'));
      await tester.pumpAndSettle();

      expect(find.text('Transaksi ke-9: "jenis" salah'), findsOneWidget);
      expect(find.text('Import berhasil'), findsNothing);
    });

    testWidgets('data sudah ada: dialog konfirmasi, batal → tidak mengimpor', (
      tester,
    ) async {
      importer.has = true;
      await pumpPage(tester);
      await tester.tap(find.text('Pilih file JSON'));
      await tester.pumpAndSettle();

      expect(find.text('Ganti semua data?'), findsOneWidget);
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();
      expect(importer.calls, isEmpty);
      expect(find.text('Import berhasil'), findsNothing);
    });

    testWidgets('data sudah ada: "Hapus & import" mengimpor dengan replace', (
      tester,
    ) async {
      importer.has = true;
      await pumpPage(tester);
      await tester.tap(find.text('Pilih file JSON'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hapus & import'));
      await tester.pumpAndSettle();

      expect(importer.calls.single.replace, isTrue);
      expect(find.text('Import berhasil'), findsOneWidget);
    });
  });
}
