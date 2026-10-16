import 'package:cc_expense_tracker/core/di/injection.dart';
import 'package:cc_expense_tracker/core/theme/app_theme.dart';
import 'package:cc_expense_tracker/data/database/app_database.dart';
import 'package:cc_expense_tracker/domain/entities/cicilan.dart';
import 'package:cc_expense_tracker/domain/entities/enums.dart';
import 'package:cc_expense_tracker/domain/entities/transaksi.dart';
import 'package:cc_expense_tracker/domain/repositories/akun_repository.dart';
import 'package:cc_expense_tracker/domain/repositories/cicilan_repository.dart';
import 'package:cc_expense_tracker/domain/repositories/transaksi_repository.dart';
import 'package:cc_expense_tracker/presentation/app_shell.dart';
import 'package:cc_expense_tracker/presentation/dashboard/bloc/dashboard_cubit.dart';
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

  Transaksi trx(DateTime tanggal, int total, {int akunId = akunBawaanId}) =>
      Transaksi(
        tanggal: tanggal,
        deskripsi: 'x',
        jenis: JenisTransaksi.personal,
        akunId: akunId,
        totalTagihan: total,
      );

  DashboardCubit newCubit() {
    final c = DashboardCubit(
      getIt<TransaksiRepository>(),
      getIt<CicilanRepository>(),
      getIt<AkunRepository>(),
      now: DateTime(2026, 9, 25),
    )..start();
    addTearDown(c.close);
    return c;
  }

  test(
    'DashboardCubit: reaktif terhadap data, akun, dan ganti bulan',
    () async {
      final cubit = newCubit();
      var s = await cubit.stream.firstWhere(
        (s) => s.status == DashboardStatus.success,
      );
      expect(s.month, DateTime(2026, 9));
      expect(s.summary!.tagihanBulanIni, 0);
      expect(s.akuns.map((a) => a.nama), ['Kartu Kredit']);

      await getIt<TransaksiRepository>().save(trx(DateTime(2026, 9, 3), 70000));
      await getIt<TransaksiRepository>().save(trx(DateTime(2026, 10, 3), 5000));
      s = await cubit.stream.firstWhere(
        (s) => s.summary!.tagihanBulanIni == 70000,
      );

      final repo = getIt<AkunRepository>();
      final akun = (await repo.getAll()).single;
      await repo.save(akun.copyWith(limitKredit: 1000000, saldoAwal: 25000));
      s = await cubit.stream.firstWhere(
        (s) => s.summary!.akunLimits.single.akun.limitKredit == 1000000,
      );
      final limit = s.summary!.akunLimits.single;
      expect(limit.outstanding, 25000 + 75000);
      expect(limit.sisaLimit, 1000000 - 100000);

      cubit.setMonth(DateTime(2026, 10, 20));
      s = await cubit.stream.firstWhere((s) => s.month == DateTime(2026, 10));
      expect(s.summary!.tagihanBulanIni, 5000);
      expect(s.summary!.akunLimits.single.totalTransaksiBaru, 75000);
    },
  );

  test(
    'DashboardCubit: filter akun, dan filter ke akun terhapus dilepas',
    () async {
      final spay = await tambahAkun(db, nama: 'SPayLater', limit: 3000000);
      final trxRepo = getIt<TransaksiRepository>();
      await trxRepo.save(trx(DateTime(2026, 9, 3), 70000));
      await trxRepo.save(trx(DateTime(2026, 9, 4), 30000, akunId: spay));

      final cubit = newCubit();
      var s = await cubit.stream.firstWhere(
        (s) => s.summary?.tagihanBulanIni == 100000,
      );
      expect(s.akunFilter, isNull);
      expect(s.summary!.akunLimits, hasLength(2));

      cubit.setAkunFilter(spay);
      s = await cubit.stream.firstWhere((s) => s.akunFilter == spay);
      expect(s.summary!.tagihanBulanIni, 30000);
      expect(s.summary!.akunLimits.single.akun.nama, 'SPayLater');
      expect(s.akuns, hasLength(2));

      cubit.setAkunFilter(null);
      s = await cubit.stream.firstWhere((s) => s.akunFilter == null);
      expect(s.summary!.tagihanBulanIni, 100000);

      final kosong = await tambahAkun(db, nama: 'Kredivo');
      cubit.setAkunFilter(kosong);
      await cubit.stream.firstWhere((s) => s.akunFilter == kosong);
      await getIt<AkunRepository>().delete(kosong);
      s = await cubit.stream.firstWhere(
        (s) => s.akuns.length == 2 && s.akunFilter == null,
      );
      expect(s.summary!.tagihanBulanIni, 100000);
    },
  );

  Future<void> openDashboard(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const AppShell()),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    await tester.tap(find.text('Dashboard').last);
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 150)),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('Dashboard: angka benar; satu akun tanpa chip filter', (
    tester,
  ) async {
    final now = DateTime.now();
    await tester.runAsync(() async {
      await getIt<TransaksiRepository>().save(
        trx(DateTime(now.year, now.month, 1), 120000),
      );
      await getIt<CicilanRepository>().save(
        Cicilan(
          namaCicilan: 'HP',
          akunId: akunBawaanId,
          totalHargaBarang: 600000,
          tenor: 6,
          jumlahPerBulan: 100000,
          tanggalMulai: DateTime(now.year, now.month),
        ),
      );
    });
    await openDashboard(tester);

    expect(find.text('0. LIMIT PER AKUN (kumulatif)'), findsOneWidget);
    expect(find.text('Kartu Kredit'), findsWidgets);
    expect(find.text('Limit belum diisi'), findsOneWidget);
    expect(find.text('Rp 120.000'), findsWidgets);
    expect(find.text('Rp 100.000'), findsWidgets);
    expect(find.text('Rp 220.000'), findsWidgets);
    expect(find.byType(ChoiceChip), findsNothing);
    await unmount(tester);
  });

  testWidgets(
    'Dashboard: dua akun → chip filter, tap menyaring, total gabungan',
    (tester) async {
      final now = DateTime.now();
      final spay = await tester.runAsync(
        () => tambahAkun(db, nama: 'SPayLater', limit: 3000000, cutoff: 10),
      );
      await tester.runAsync(() async {
        await getIt<TransaksiRepository>().save(
          trx(DateTime(now.year, now.month, 15), 120000),
        );
        await getIt<TransaksiRepository>().save(
          trx(DateTime(now.year, now.month, 15), 30000, akunId: spay!),
        );
      });
      await openDashboard(tester);

      expect(find.widgetWithText(ChoiceChip, 'Semua'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'SPayLater'), findsOneWidget);
      expect(find.textContaining('TOTAL SEMUA AKUN'), findsWidgets);
      expect(find.text('Rp 150.000'), findsWidgets);

      await tester.tap(find.widgetWithText(ChoiceChip, 'SPayLater'));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 100));

      expect(find.text('Rp 30.000'), findsWidgets);
      expect(find.text('Rp 150.000'), findsNothing);
      expect(
        find.textContaining('TOTAL SEMUA AKUN'),
        findsNothing,
      );
      await unmount(tester);
    },
  );

  testWidgets('Kelola Akun: tambah SPayLater dari Dashboard, chip muncul', (
    tester,
  ) async {
    await openDashboard(tester);
    expect(find.byType(ChoiceChip), findsNothing);

    await tester.tap(find.byTooltip('Kelola akun').first);
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.text('Kelola Akun'), findsOneWidget);
    expect(find.text('Kartu Kredit'), findsOneWidget);

    await tester.tap(find.byTooltip('Akun baru'));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    await tester.enterText(
      find.widgetWithText(TextField, 'Nama akun'),
      'SPayLater',
    );
    await tester.enterText(find.widgetWithText(TextField, 'Limit'), '3000000');
    await tester.enterText(
      find.widgetWithText(TextField, 'Tanggal tutup buku tagihan'),
      '10',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Tanggal jatuh tempo tagihan'),
      '25',
    );
    await tester.tap(find.text('Simpan'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.text('SPayLater'), findsOneWidget);
    expect(find.textContaining('Limit Rp 3.000.000'), findsOneWidget);
    expect(find.textContaining('tutup buku tgl 10'), findsOneWidget);
    expect(find.textContaining('jatuh tempo tgl 25'), findsOneWidget);

    await tester.pageBack();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.widgetWithText(ChoiceChip, 'SPayLater'), findsOneWidget);
    await unmount(tester);
  });
}
