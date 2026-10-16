import 'package:cc_expense_tracker/core/di/injection.dart';
import 'package:cc_expense_tracker/core/theme/app_theme.dart';
import 'package:cc_expense_tracker/data/database/app_database.dart';
import 'package:cc_expense_tracker/domain/entities/enums.dart';
import 'package:cc_expense_tracker/domain/entities/transaksi.dart';
import 'package:cc_expense_tracker/domain/repositories/akun_repository.dart';
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

  Transaksi trx(String deskripsi, int akunId) {
    final now = DateTime.now();
    return Transaksi(
      tanggal: DateTime(now.year, now.month, now.day),
      deskripsi: deskripsi,
      jenis: JenisTransaksi.personal,
      akunId: akunId,
      totalTagihan: 25000,
    );
  }

  Future<void> pumpShell(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const AppShell()),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 50));
  }

  Future<void> settle(WidgetTester tester) =>
      tester.pumpAndSettle(const Duration(milliseconds: 100));

  testWidgets('satu akun: tanpa chip filter dan tanpa nama akun di transaksi', (
    tester,
  ) async {
    await tester.runAsync(
      () => getIt<TransaksiRepository>().save(trx('Kopi', akunBawaanId)),
    );
    await pumpShell(tester);

    expect(find.text('Kopi'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Kartu Kredit'), findsNothing);
    expect(find.widgetWithText(ChoiceChip, 'Semua'), findsNothing);
    expect(find.widgetWithText(ChoiceChip, 'Semua status'), findsOneWidget);
    expect(find.text('Kartu Kredit'), findsNothing);
    await unmount(tester);
  });

  testWidgets(
    'dua akun: chip filter, nama akun di tiap transaksi, tap menyaring',
    (tester) async {
      final spay = (await tester.runAsync(() => tambahAkun(db)))!;
      await tester.runAsync(() async {
        final repo = getIt<TransaksiRepository>();
        await repo.save(trx('Kopi CC', akunBawaanId));
        await repo.save(trx('Belanja Shopee', spay));
      });
      await pumpShell(tester);

      expect(find.widgetWithText(ChoiceChip, 'Semua'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Kartu Kredit'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'SPayLater'), findsOneWidget);
      expect(find.text('Kopi CC'), findsOneWidget);
      expect(find.text('Belanja Shopee'), findsOneWidget);
      expect(find.text('Kartu Kredit'), findsNWidgets(2));
      expect(find.text('SPayLater'), findsNWidgets(2));

      await tester.tap(find.widgetWithText(ChoiceChip, 'SPayLater'));
      await settle(tester);
      expect(find.text('Belanja Shopee'), findsOneWidget);
      expect(find.text('Kopi CC'), findsNothing);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Semua'));
      await settle(tester);
      expect(find.text('Kopi CC'), findsOneWidget);
      await unmount(tester);
    },
  );

  testWidgets(
    'form: akun terakhir dipakai jadi bawaan; ganti akun mengubah tanggal tutup buku',
    (tester) async {
      final spay = (await tester.runAsync(() async {
        final id = await tambahAkun(db, cutoff: 10);
        await getIt<AkunRepository>().setLastUsedId(id);
        return id;
      }))!;
      await pumpShell(tester);

      await tester.tap(find.byTooltip('Tambah transaksi'));
      await settle(tester);
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await settle(tester);

      expect(
        find.widgetWithText(DropdownButtonFormField<int>, 'SPayLater'),
        findsOneWidget,
      );
      expect(find.text('Otomatis (statement tutup tgl 10)'), findsOneWidget);

      await tester.tap(
        find.widgetWithText(DropdownButtonFormField<int>, 'SPayLater'),
      );
      await settle(tester);
      await tester.tap(find.text('Kartu Kredit').last);
      await settle(tester);
      expect(find.text('Otomatis (bulan kalender)'), findsOneWidget);

      await tester.tap(
        find.widgetWithText(DropdownButtonFormField<int>, 'Kartu Kredit'),
      );
      await settle(tester);
      await tester.tap(find.text('SPayLater').last);
      await settle(tester);
      await tester.enterText(
        find.widgetWithText(TextField, 'Deskripsi'),
        'Beli sepatu',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Total tagihan'),
        '150000',
      );
      await tester.tap(find.text('Simpan'));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await settle(tester);

      final saved = (await tester.runAsync(
        () => getIt<TransaksiRepository>().getAll(),
      ))!;
      expect(saved.single.akunId, spay);
      expect(saved.single.deskripsi, 'Beli sepatu');
      await unmount(tester);
    },
  );
}
