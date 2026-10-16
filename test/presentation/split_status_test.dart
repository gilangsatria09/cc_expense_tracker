import 'package:cc_expense_tracker/core/di/injection.dart';
import 'package:cc_expense_tracker/core/theme/app_theme.dart';
import 'package:cc_expense_tracker/data/database/app_database.dart';
import 'package:cc_expense_tracker/domain/entities/akun.dart';
import 'package:cc_expense_tracker/domain/entities/enums.dart';
import 'package:cc_expense_tracker/domain/entities/split_group_order.dart';
import 'package:cc_expense_tracker/domain/entities/transaksi.dart';
import 'package:cc_expense_tracker/domain/repositories/transaksi_repository.dart';
import 'package:cc_expense_tracker/domain/usecases/dashboard_calculator.dart';
import 'package:cc_expense_tracker/domain/usecases/save_transaksi.dart';
import 'package:cc_expense_tracker/presentation/app_shell.dart';
import 'package:cc_expense_tracker/presentation/transaksi/bloc/transaksi_form_cubit.dart';
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

  Transaksi groupOrder(DateTime tanggal) => Transaksi(
    tanggal: tanggal,
    deskripsi: 'Makan tim',
    jenis: JenisTransaksi.groupOrder,
    akunId: 1,
    totalTagihan: 90000,
    status: StatusBayar.paidTemp,
    splits: const [
      SplitGroupOrder(nama: 'Gilang'),
      SplitGroupOrder(nama: 'Budi'),
      SplitGroupOrder(nama: 'Ani'),
    ],
  );

  test('setSplitStatus hanya mengubah peserta yang dipilih', () {
    final cubit = TransaksiFormCubit(
      getIt<SaveTransaksi>(),
      getIt<TransaksiRepository>(),
      getIt(),
      getIt(),
      initial: groupOrder(DateTime(2026, 9, 1)),
    );
    addTearDown(cubit.close);

    cubit.setSplitStatus(1, StatusBayar.paid);
    expect(cubit.state.draft.splits.map((s) => s.status), [
      StatusBayar.belumDibayar,
      StatusBayar.paid,
      StatusBayar.belumDibayar,
    ]);

    final before = cubit.state;
    cubit.setSplitStatus(9, StatusBayar.paid);
    cubit.setSplitStatus(-1, StatusBayar.paid);
    expect(cubit.state, before);
  });

  testWidgets(
    'tandai teman Paid → tersimpan → piutang Dashboard ikut berubah',
    (tester) async {
      tester.view.physicalSize = const Size(800, 2600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final now = DateTime.now();
      final tanggal = DateTime(now.year, now.month, now.day);
      final repo = getIt<TransaksiRepository>();
      final id = (await tester.runAsync(() => repo.save(groupOrder(tanggal))))!;

      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const AppShell()),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump(const Duration(milliseconds: 50));

      await tester.tap(find.text('Makan tim'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));

      expect(find.byTooltip('Ubah status Gilang'), findsNothing);
      expect(find.byTooltip('Ubah status Budi'), findsOneWidget);
      expect(find.text('Belum Dibayar'), findsNWidgets(2));

      await tester.tap(find.byTooltip('Ubah status Budi'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Paid').last);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Simpan').last);
      await tester.tap(find.text('Simpan').last);
      await tester.pumpAndSettle(const Duration(milliseconds: 100));

      final saved = (await tester.runAsync(() => repo.getById(id)))!;
      expect(
        saved.splits.firstWhere((s) => s.nama == 'Budi').status,
        StatusBayar.paid,
      );
      expect(
        saved.splits.firstWhere((s) => s.nama == 'Ani').status,
        StatusBayar.belumDibayar,
      );
      expect(saved.splits, hasLength(3));

      final summary = DashboardCalculator.calculate(
        transaksis: [saved],
        cicilans: const [],
        akuns: const [Akun(id: 1, nama: 'Kartu Kredit')],
        month: tanggal,
      );
      expect(summary.piutangPaid, 30000);
      expect(summary.piutangBelumDibayar, 30000);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    },
  );
}
