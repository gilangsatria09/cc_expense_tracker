import 'package:cc_expense_tracker/core/di/injection.dart';
import 'package:cc_expense_tracker/core/theme/app_theme.dart';
import 'package:cc_expense_tracker/data/database/app_database.dart';
import 'package:cc_expense_tracker/domain/entities/enums.dart';
import 'package:cc_expense_tracker/domain/entities/subscription.dart';
import 'package:cc_expense_tracker/domain/repositories/subscription_repository.dart';
import 'package:cc_expense_tracker/presentation/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  late AppDatabase db;

  setUpAll(() => initializeDateFormatting('id_ID'));

  setUp(() async {
    db = AppDatabase.inMemory();
    await configureDependencies(database: db);
  });

  tearDown(() async {
    await getIt.reset();
    await db.close();
  });

  Future<void> settle(WidgetTester tester) =>
      tester.pumpAndSettle(const Duration(milliseconds: 100));

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 50));
  }

  Future<void> pumpShell(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const AppShell()),
    );
    await settle(tester);
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.tap(find.text(text).last);
    await settle(tester);
  }

  Future<void> enterInto(WidgetTester tester, String label, String text) async {
    await tester.enterText(find.widgetWithText(TextField, label), text);
    await tester.pump();
  }

  testWidgets('Cicilan: buat → tampil → Sudah Bayar → tombol disabled', (
    tester,
  ) async {
    await pumpShell(tester);
    await tapText(tester, 'Cicilan');
    expect(find.text('Belum ada cicilan'), findsOneWidget);

    await tester.tap(find.byTooltip('Cicilan baru'));
    await settle(tester);
    await enterInto(tester, 'Nama cicilan', 'iPhone');
    await enterInto(tester, 'Total harga barang', '1200000');
    await enterInto(tester, 'Tenor (bulan)', '12');
    await tapText(tester, 'Simpan');

    expect(find.text('iPhone'), findsOneWidget);
    expect(find.textContaining('0 dari 12 cicilan terbayar'), findsOneWidget);
    expect(find.textContaining('100.000/bulan'), findsOneWidget);

    await tapText(tester, 'Sudah Bayar Bulan Ini');
    expect(find.textContaining('1 dari 12 cicilan terbayar'), findsOneWidget);
    final disabled = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Sudah dibayar bulan ini'),
    );
    expect(disabled.onPressed, isNull);
    await unmount(tester);
  });

  testWidgets('Subscription: buat via tab, tampil dengan badge Auto/Manual', (
    tester,
  ) async {
    await pumpShell(tester);
    await tapText(tester, 'Subscription');
    expect(find.text('Belum ada subscription'), findsOneWidget);

    await tester.tap(find.byTooltip('Subscription baru'));
    await settle(tester);
    await enterInto(tester, 'Nama layanan', 'Netflix');
    await enterInto(tester, 'Harga tetap', '54000');
    await tapText(tester, 'Simpan');

    expect(find.text('Netflix'), findsOneWidget);
    expect(find.text('Auto'), findsOneWidget);
    expect(find.textContaining('54.000'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets(
    'Transaksi Subscription: buat subscription dari form lalu simpan',
    (tester) async {
      await pumpShell(tester);
      await tester.tap(find.byTooltip('Tambah transaksi'));
      await settle(tester);

      await enterInto(tester, 'Deskripsi', 'Netflix September');
      await enterInto(tester, 'Total tagihan', '54000');
      await tapText(tester, 'Personal');
      await tapText(tester, 'Subscription');

      await tapText(tester, 'Buat subscription baru');
      expect(find.text('Subscription Baru'), findsOneWidget);
      await enterInto(tester, 'Nama layanan', 'Netflix');
      await tapText(tester, 'Simpan');

      expect(find.text('Tambah Transaksi'), findsOneWidget);
      expect(find.text('Netflix'), findsOneWidget);

      await tapText(tester, 'Simpan');
      expect(find.text('Netflix September'), findsOneWidget);

      final subs = await tester.runAsync(
        () => getIt<SubscriptionRepository>().getAll(),
      );
      expect(subs!.single.namaLayanan, 'Netflix');
      await unmount(tester);
    },
  );

  testWidgets('Subscription detail: riwayat transaksi tampil', (tester) async {
    final sub = Subscription(
      namaLayanan: 'Spotify',
      akunId: 1,
      hargaTetap: 55000,
      siklusBilling: SiklusBilling.bulanan,
      tanggalTagihanBerikutnya: DateTime(2030, 1, 1),
    );
    await tester.runAsync(() => getIt<SubscriptionRepository>().save(sub));
    await pumpShell(tester);
    await tapText(tester, 'Subscription');
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump(const Duration(milliseconds: 50));

    await tapText(tester, 'Spotify');
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Riwayat transaksi'), findsOneWidget);
    expect(find.text('Belum ada transaksi'), findsOneWidget);
    await unmount(tester);
  });
}
