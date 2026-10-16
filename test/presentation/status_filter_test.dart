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

import '../support/akun_helpers.dart';

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

  Future<void> seed(WidgetTester tester, Map<String, StatusBayar> data) =>
      tester.runAsync(() async {
        final now = DateTime.now();
        for (final e in data.entries) {
          await getIt<TransaksiRepository>().save(
            Transaksi(
              tanggal: DateTime(now.year, now.month, now.day),
              deskripsi: e.key,
              jenis: JenisTransaksi.personal,
              akunId: akunBawaanId,
              totalTagihan: 10000,
              status: e.value,
            ),
          );
        }
      });

  Future<void> pumpShell(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const AppShell()),
    );
    await settle(tester);
    await wait(tester);
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('chip status memuat jumlah; tap menyaring daftar', (
    tester,
  ) async {
    await seed(tester, {
      'Kopi': StatusBayar.paidTemp,
      'Makan': StatusBayar.paidTemp,
      'Bensin': StatusBayar.belumDibayar,
      'Pulsa': StatusBayar.paid,
    });
    await pumpShell(tester);

    expect(find.widgetWithText(ChoiceChip, 'Semua status'), findsOneWidget);
    expect(
      find.widgetWithText(ChoiceChip, 'Belum Dibayar (1)'),
      findsOneWidget,
    );
    expect(find.widgetWithText(ChoiceChip, 'Paid Temp (2)'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Paid (1)'), findsOneWidget);
    for (final n in ['Kopi', 'Makan', 'Bensin', 'Pulsa']) {
      expect(find.text(n), findsOneWidget);
    }

    await tester.tap(find.widgetWithText(ChoiceChip, 'Paid Temp (2)'));
    await settle(tester);
    expect(find.text('Kopi'), findsOneWidget);
    expect(find.text('Makan'), findsOneWidget);
    expect(find.text('Bensin'), findsNothing);
    expect(find.text('Pulsa'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Semua status'));
    await settle(tester);
    expect(find.text('Bensin'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('tidak ada yang cocok: pesan khusus dan "Hapus filter"', (
    tester,
  ) async {
    await seed(tester, {'Kopi': StatusBayar.paidTemp});
    await pumpShell(tester);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Paid (0)'));
    await settle(tester);
    expect(
      find.text('Tidak ada transaksi yang cocok dengan filter'),
      findsOneWidget,
    );
    expect(find.text('Belum ada transaksi bulan ini'), findsNothing);
    expect(find.text('Kopi'), findsNothing);

    await tester.tap(find.text('Hapus filter'));
    await settle(tester);
    expect(find.text('Kopi'), findsOneWidget);
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Semua status'))
          .selected,
      isTrue,
    );
    await unmount(tester);
  });

  testWidgets('bulan tanpa transaksi: pesan kosong biasa, bukan pesan filter', (
    tester,
  ) async {
    await pumpShell(tester);
    expect(find.text('Belum ada transaksi bulan ini'), findsOneWidget);
    expect(
      find.text('Tidak ada transaksi yang cocok dengan filter'),
      findsNothing,
    );
    await unmount(tester);
  });

  testWidgets(
    'filter Paid Temp → pilih semua → jadikan Paid: daftar terfilter kosong',
    (tester) async {
      await seed(tester, {
        'Kopi': StatusBayar.paidTemp,
        'Makan': StatusBayar.paidTemp,
        'Pulsa': StatusBayar.paid,
      });
      await pumpShell(tester);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Paid Temp (2)'));
      await settle(tester);
      await tester.longPress(find.text('Kopi'));
      await settle(tester);
      await tester.tap(find.byTooltip('Pilih semua'));
      await settle(tester);
      expect(
        find.text('2 dipilih'),
        findsOneWidget,
      );

      await tester.tap(find.byTooltip('Ubah status'));
      await settle(tester);
      await tester.tap(find.text('Paid').last);
      await settle(tester);
      await wait(tester);
      await settle(tester);

      expect(find.text('2 transaksi diubah ke Paid'), findsOneWidget);
      expect(
        find.text('Tidak ada transaksi yang cocok dengan filter'),
        findsOneWidget,
      );
      expect(find.widgetWithText(ChoiceChip, 'Paid Temp (0)'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Paid (3)'), findsOneWidget);

      final all = await tester.runAsync(
        () => getIt<TransaksiRepository>().getAll(),
      );
      expect(all!.map((t) => t.status).toSet(), {StatusBayar.paid});
      await unmount(tester);
    },
  );
}
