import 'package:cc_expense_tracker/core/di/injection.dart';
import 'package:cc_expense_tracker/core/theme/app_theme.dart';
import 'package:cc_expense_tracker/data/database/app_database.dart';
import 'package:cc_expense_tracker/domain/entities/enums.dart';
import 'package:cc_expense_tracker/domain/entities/transaksi.dart';
import 'package:cc_expense_tracker/domain/repositories/transaksi_repository.dart';
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

  Future<void> wait(WidgetTester tester) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }

  Future<Map<String, StatusBayar>> statuses(WidgetTester tester) async {
    final all = await tester.runAsync(
      () => getIt<TransaksiRepository>().getAll(),
    );
    return {for (final t in all!) t.deskripsi: t.status};
  }

  testWidgets('tekan-tahan → pilih beberapa → ubah status → urungkan', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    await tester.runAsync(() async {
      final repo = getIt<TransaksiRepository>();
      for (final (nama, status) in [
        ('Kopi', StatusBayar.paidTemp),
        ('Makan', StatusBayar.paidTemp),
        ('Bensin', StatusBayar.belumDibayar),
      ]) {
        await repo.save(
          Transaksi(
            tanggal: today,
            deskripsi: nama,
            jenis: JenisTransaksi.personal,
            akunId: 1,
            totalTagihan: 10000,
            status: status,
          ),
        );
      }
    });

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const AppShell()),
    );
    await settle(tester);
    await wait(tester);

    expect(find.text('1 dipilih'), findsNothing);

    await tester.longPress(find.text('Kopi'));
    await settle(tester);
    expect(find.text('1 dipilih'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);

    await tester.tap(find.text('Makan'));
    await settle(tester);
    expect(find.text('2 dipilih'), findsOneWidget);
    expect(find.text('Edit Transaksi'), findsNothing);

    await tester.tap(find.byTooltip('Ubah status'));
    await settle(tester);
    await tester.tap(find.text('Paid').last);
    await settle(tester);
    await wait(tester);

    expect(find.text('2 dipilih'), findsNothing);
    expect(find.text('2 transaksi diubah ke Paid'), findsOneWidget);
    expect(await statuses(tester), {
      'Kopi': StatusBayar.paid,
      'Makan': StatusBayar.paid,
      'Bensin': StatusBayar.belumDibayar,
    });

    await tester.tap(find.text('Urungkan'));
    await settle(tester);
    await wait(tester);
    expect(await statuses(tester), {
      'Kopi': StatusBayar.paidTemp,
      'Makan': StatusBayar.paidTemp,
      'Bensin': StatusBayar.belumDibayar,
    });

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('back menutup mode pilih; lepas semua pilihan juga menutupnya', (
    tester,
  ) async {
    final now = DateTime.now();
    await tester.runAsync(
      () => getIt<TransaksiRepository>().save(
        Transaksi(
          tanggal: DateTime(now.year, now.month, now.day),
          deskripsi: 'Kopi',
          jenis: JenisTransaksi.personal,
          akunId: 1,
          totalTagihan: 10000,
        ),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const AppShell()),
    );
    await settle(tester);
    await wait(tester);

    await tester.longPress(find.text('Kopi'));
    await settle(tester);
    expect(find.text('1 dipilih'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await settle(tester);
    expect(find.text('1 dipilih'), findsNothing);
    expect(find.text('Kopi'), findsOneWidget);

    await tester.longPress(find.text('Kopi'));
    await settle(tester);
    await tester.tap(find.text('Kopi'));
    await settle(tester);
    expect(find.text('1 dipilih'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 50));
  });
}
