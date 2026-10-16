import 'dart:typed_data';

import 'package:cc_expense_tracker/core/di/injection.dart';
import 'package:cc_expense_tracker/core/theme/app_theme.dart';
import 'package:cc_expense_tracker/data/database/app_database.dart';
import 'package:cc_expense_tracker/domain/entities/extracted_split.dart';
import 'package:cc_expense_tracker/domain/services/split_extractor.dart';
import 'package:cc_expense_tracker/presentation/app_shell.dart';
import 'package:cc_expense_tracker/presentation/split_bill/pages/split_bill_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

class _FakeExtractor implements SplitExtractor {
  @override
  Future<List<ExtractedSplit>> extract({
    required Uint8List imageBytes,
    required String mimeType,
  }) async => const [
    ExtractedSplit(nama: 'Gilang', subtotal: 30000),
    ExtractedSplit(nama: 'Budi', subtotal: 35000),
  ];
}

void main() {
  late AppDatabase db;

  setUpAll(() => initializeDateFormatting('id_ID'));

  setUp(() async {
    db = AppDatabase.inMemory();
    await configureDependencies(database: db);
    getIt
      ..unregister<SplitExtractor>()
      ..registerSingleton<SplitExtractor>(_FakeExtractor());
  });

  tearDown(() async {
    await getIt.reset();
    await db.close();
  });

  Future<void> settle(WidgetTester tester) async {
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 50));
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    final finder = find.text(text).last;
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await settle(tester);
  }

  Future<void> enterInto(WidgetTester tester, String label, String text) async {
    final finder = find.widgetWithText(TextField, label);
    await tester.ensureVisible(finder);
    await tester.enterText(finder, text);
    await tester.pump();
  }

  testWidgets('form GroupOrder → split rata → simpan → tampil di list', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const AppShell()),
    );
    await settle(tester);

    await tester.tap(find.byTooltip('Tambah transaksi'));
    await settle(tester);

    await tapText(tester, 'Personal');
    await tapText(tester, 'Group Order');
    await tapText(tester, 'Split ke teman');
    expect(find.text('Isi total order dulu sebelum split'), findsOneWidget);
    expect(find.text('Split ke Teman'), findsNothing);

    await enterInto(tester, 'Deskripsi', 'Makan bareng');
    await enterInto(tester, 'Total order', '90000');
    await tapText(tester, 'Split ke teman');
    expect(find.text('Split ke Teman'), findsOneWidget);
    expect(find.text('Total order Rp 90.000'), findsOneWidget);

    await enterInto(tester, 'Tambah peserta', 'Budi');
    await tester.tap(find.byTooltip('Tambah peserta'));
    await settle(tester);
    expect(find.text('2 orang · rata Rp 45.000'), findsOneWidget);

    await tapText(tester, 'Simpan split');
    expect(find.text('Ubah split (2 orang)'), findsOneWidget);
    expect(find.text('Budi'), findsOneWidget);

    await tapText(tester, 'Simpan');
    expect(find.text('Makan bareng'), findsOneWidget);
    expect(find.text('Bagianmu Rp 45.000 · Teman Rp 45.000'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets(
    'halaman split: ekstraksi AI mengisi daftar + peringatan selisih',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: SplitBillPage(
            totalTagihan: 100000,
            ongkirFee: 0,
            pickImage: (_) async =>
                PickedImage(bytes: Uint8List(1), mimeType: 'image/png'),
          ),
        ),
      );
      await settle(tester);

      await tapText(tester, 'Foto / AI');
      await tapText(tester, 'Galeri');

      expect(find.widgetWithText(TextFormField, 'Budi'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '35000'), findsOneWidget);
      expect(
        find.text('Total split kurang Rp 35.000 dari total order'),
        findsOneWidget,
      );
      await unmount(tester);
    },
  );
}
