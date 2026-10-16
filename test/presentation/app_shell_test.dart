import 'package:cc_expense_tracker/core/di/injection.dart';
import 'package:cc_expense_tracker/core/theme/app_theme.dart';
import 'package:cc_expense_tracker/data/database/app_database.dart';
import 'package:cc_expense_tracker/domain/entities/enums.dart';
import 'package:cc_expense_tracker/domain/entities/transaksi.dart';
import 'package:cc_expense_tracker/domain/repositories/transaksi_repository.dart';
import 'package:cc_expense_tracker/presentation/app_shell.dart';
import 'package:cc_expense_tracker/core/utils/formatters.dart';
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

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const AppShell()),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('shell menampilkan tab, FAB, dan empty state', (tester) async {
    await pumpApp(tester);

    for (final label in ['Transaksi', 'Cicilan', 'Subscription', 'Dashboard']) {
      expect(find.text(label), findsWidgets);
    }
    expect(find.byTooltip('Tambah transaksi'), findsOneWidget);
    expect(find.text('Belum ada transaksi bulan ini'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('FAB membuka form; field GroupOrder muncul sesuai jenis', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpApp(tester);

    await tester.tap(find.byTooltip('Tambah transaksi'));
    await tester.pumpAndSettle();
    expect(find.text('Tambah Transaksi'), findsOneWidget);
    expect(find.text('Merchant'), findsNothing);

    await tester.tap(find.text('Personal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Group Order').last);
    await tester.pumpAndSettle();
    expect(find.text('Merchant'), findsOneWidget);
    expect(find.text('Split ke teman'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('transaksi tersimpan tampil di list', (tester) async {
    final now = DateTime.now();
    await tester.runAsync(
      () => getIt<TransaksiRepository>().save(
        Transaksi(
          tanggal: DateTime(now.year, now.month, now.day),
          deskripsi: 'Makan siang',
          jenis: JenisTransaksi.personal,
          akunId: 1,
          totalTagihan: 45000,
        ),
      ),
    );
    await pumpApp(tester);
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Makan siang'), findsOneWidget);
    expect(find.textContaining('45.000'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('transaksi yang masuk tagihan bulan lain diberi penanda', (
    tester,
  ) async {
    final now = DateTime.now();
    final tanggal = DateTime(now.year, now.month, 0);
    await tester.runAsync(
      () => getIt<TransaksiRepository>().save(
        Transaksi(
          tanggal: tanggal,
          bulanTagihan: DateTime(now.year, now.month),
          deskripsi: 'Paylater',
          jenis: JenisTransaksi.personal,
          akunId: 1,
          totalTagihan: 30000,
        ),
      ),
    );
    await pumpApp(tester);
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Paylater'), findsOneWidget);
    expect(
      find.text(
        'Masuk tagihan ${formatMonthYear(DateTime(now.year, now.month))}',
      ),
      findsOneWidget,
    );
    await unmount(tester);
  });
}
