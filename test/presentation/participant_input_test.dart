import 'package:cc_expense_tracker/core/di/injection.dart';
import 'package:cc_expense_tracker/core/theme/app_theme.dart';
import 'package:cc_expense_tracker/data/database/app_database.dart';
import 'package:cc_expense_tracker/domain/entities/enums.dart';
import 'package:cc_expense_tracker/domain/entities/split_group_order.dart';
import 'package:cc_expense_tracker/domain/entities/transaksi.dart';
import 'package:cc_expense_tracker/domain/repositories/transaksi_repository.dart';
import 'package:cc_expense_tracker/presentation/split_bill/pages/split_bill_page.dart';
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

  Future<void> order(DateTime d, List<String> names) =>
      getIt<TransaksiRepository>().save(
        Transaksi(
          tanggal: d,
          deskripsi: 'x',
          jenis: JenisTransaksi.groupOrder,
          akunId: 1,
          totalTagihan: 100000,
          splits: [for (final n in names) SplitGroupOrder(nama: n)],
        ),
      );

  Future<void> seed(WidgetTester tester) => tester.runAsync(() async {
    await order(DateTime(2026, 9, 1), [
      'Ani',
      'Budi',
      'Citra',
      'Dedi',
      'Eka',
      'Fani',
      'Gita',
      'Hadi',
      'Indra',
      'Joko',
      'Kiki',
      'Lala',
    ]);
    await order(DateTime(2026, 9, 2), ['Kiki', 'Lala']);
  });

  Future<void> pumpPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const SplitBillPage(totalTagihan: 100000, ongkirFee: 0),
      ),
    );
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();
  }

  Finder rowField(String nama) => find.widgetWithText(TextFormField, nama);

  testWidgets('chip dibatasi 8 (paling sering dulu) + "+4 lainnya"', (
    tester,
  ) async {
    await seed(tester);
    await pumpPage(tester);

    final chips = tester
        .widgetList<ActionChip>(find.byType(ActionChip))
        .toList();
    expect(chips, hasLength(9));
    final labels = chips.map((c) => (c.label as Text).data).toList();
    expect(labels.take(2), ['Kiki', 'Lala']);
    expect(labels.last, '+4 lainnya');
    expect(labels, isNot(contains('Joko')));
  });

  testWidgets('sedikit nama: semua jadi chip, tanpa "+N lainnya"', (
    tester,
  ) async {
    await tester.runAsync(() => order(DateTime(2026, 9, 1), ['Ani', 'Budi']));
    await pumpPage(tester);
    expect(find.byType(ActionChip), findsNWidgets(2));
    expect(find.textContaining('lainnya'), findsNothing);
  });

  testWidgets('tap chip menambah peserta dan chip-nya hilang dari saran', (
    tester,
  ) async {
    await seed(tester);
    await pumpPage(tester);

    await tester.tap(find.widgetWithText(ActionChip, 'Kiki'));
    await tester.pumpAndSettle();

    expect(rowField('Kiki'), findsOneWidget);
    expect(find.widgetWithText(ActionChip, 'Kiki'), findsNothing);
    expect(find.text('+3 lainnya'), findsOneWidget);
  });

  testWidgets('ketik sebagian nama: autocomplete menyarankan, tap menambah', (
    tester,
  ) async {
    await seed(tester);
    await pumpPage(tester);

    expect(find.text('Joko'), findsNothing);
    await tester.enterText(
      find.widgetWithText(TextField, 'Tambah peserta'),
      'jo',
    );
    await tester.pumpAndSettle();
    expect(find.text('Joko'), findsOneWidget);

    await tester.tap(find.text('Joko'));
    await tester.pumpAndSettle();

    expect(rowField('Joko'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.widgetWithText(TextField, 'Tambah peserta'))
          .controller!
          .text,
      isEmpty,
    );
  });

  testWidgets(
    'lembar "+N lainnya": cari, centang menambah, hapus centang melepas',
    (tester) async {
      await seed(tester);
      await pumpPage(tester);

      await tester.tap(find.text('+4 lainnya'));
      await tester.pumpAndSettle();
      expect(find.text('Cari nama'), findsOneWidget);
      expect(find.byType(CheckboxListTile), findsWidgets);

      await tester.enterText(
        find.widgetWithText(TextField, 'Cari nama'),
        'had',
      );
      await tester.pumpAndSettle();
      expect(find.byType(CheckboxListTile), findsOneWidget);

      await tester.tap(find.widgetWithText(CheckboxListTile, 'Hadi'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
        isTrue,
      );

      await tester.tap(find.widgetWithText(CheckboxListTile, 'Hadi'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
        isFalse,
      );

      await tester.tap(find.widgetWithText(CheckboxListTile, 'Hadi'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Selesai'));
      await tester.pumpAndSettle();
      expect(rowField('Hadi'), findsOneWidget);
    },
  );

  testWidgets(
    'lembar: nama yang belum ada bisa ditambah sebagai peserta baru',
    (tester) async {
      await seed(tester);
      await pumpPage(tester);

      await tester.tap(find.text('+4 lainnya'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Cari nama'),
        'Baru',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tambah "Baru" sebagai peserta baru'));
      await tester.pumpAndSettle();

      expect(find.text('Tambah "Baru" sebagai peserta baru'), findsNothing);
      await tester.enterText(
        find.widgetWithText(TextField, 'Cari nama'),
        'baru',
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<CheckboxListTile>(
              find.widgetWithText(CheckboxListTile, 'Baru'),
            )
            .value,
        isTrue,
      );

      await tester.tap(find.text('Selesai'));
      await tester.pumpAndSettle();
      expect(rowField('Baru'), findsOneWidget);
    },
  );
}
