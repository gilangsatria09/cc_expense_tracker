import 'package:cc_expense_tracker/data/database/app_database.dart';
import 'package:cc_expense_tracker/data/repositories/akun_repository_impl.dart';
import 'package:cc_expense_tracker/data/repositories/cicilan_repository_impl.dart';
import 'package:cc_expense_tracker/data/repositories/subscription_repository_impl.dart';
import 'package:cc_expense_tracker/data/repositories/transaksi_repository_impl.dart';
import 'package:cc_expense_tracker/domain/entities/cicilan.dart';
import 'package:cc_expense_tracker/domain/entities/enums.dart';
import 'package:cc_expense_tracker/domain/entities/subscription.dart';
import 'package:cc_expense_tracker/domain/entities/transaksi.dart';
import 'package:cc_expense_tracker/domain/usecases/pay_cicilan.dart';
import 'package:cc_expense_tracker/domain/usecases/save_cicilan.dart';
import 'package:cc_expense_tracker/domain/usecases/save_subscription.dart';
import 'package:cc_expense_tracker/presentation/cicilan/bloc/cicilan_form_cubit.dart';
import 'package:cc_expense_tracker/presentation/cicilan/bloc/cicilan_list_cubit.dart';
import 'package:cc_expense_tracker/presentation/subscription/bloc/subscription_detail_cubit.dart';
import 'package:cc_expense_tracker/presentation/subscription/bloc/subscription_form_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/akun_helpers.dart';

void main() {
  late AppDatabase db;
  late CicilanRepositoryImpl cicilanRepo;
  late SubscriptionRepositoryImpl subRepo;
  late TransaksiRepositoryImpl trxRepo;

  setUp(() {
    db = AppDatabase.inMemory();
    cicilanRepo = CicilanRepositoryImpl(db);
    subRepo = SubscriptionRepositoryImpl(db);
    trxRepo = TransaksiRepositoryImpl(db);
  });
  tearDown(() => db.close());

  group('CicilanListCubit', () {
    test(
      'memisahkan aktif & lunas, pay menaikkan cicilan, pay kedua → pesan',
      () async {
        await cicilanRepo.save(
          Cicilan(
            namaCicilan: 'Aktif',
            akunId: 1,
            totalHargaBarang: 300000,
            tenor: 3,
            jumlahPerBulan: 100000,
            tanggalMulai: DateTime(2026, 7, 1),
          ),
        );
        await cicilanRepo.save(
          Cicilan(
            namaCicilan: 'Lunas',
            akunId: 1,
            totalHargaBarang: 100000,
            tenor: 1,
            cicilanKe: 1,
            jumlahPerBulan: 100000,
            tanggalMulai: DateTime(2026, 1, 1),
          ),
        );

        final cubit = CicilanListCubit(
          cicilanRepo,
          PayCicilan(cicilanRepo),
          AkunRepositoryImpl(db),
          now: () => DateTime(2026, 9, 25),
        )..start();
        addTearDown(cubit.close);

        var s = await cubit.stream.firstWhere(
          (s) => s.status == CicilanListStatus.success,
        );
        expect(s.aktif.map((c) => c.namaCicilan), ['Aktif']);
        expect(s.lunas.map((c) => c.namaCicilan), ['Lunas']);

        final aktifId = s.aktif.single.id;
        await cubit.pay(aktifId);
        s = await cubit.stream.firstWhere(
          (s) => s.aktif.any((c) => c.cicilanKe == 1),
        );

        final messages = <String?>[];
        final sub = cubit.stream.listen((s) => messages.add(s.message));
        await cubit.pay(aktifId);
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();
        expect(messages, contains('Cicilan bulan ini sudah dibayar'));
        expect(cubit.state.message, isNull);
      },
    );
  });

  group('CicilanFormCubit', () {
    CicilanFormCubit newCubit() => CicilanFormCubit(
      SaveCicilan(cicilanRepo),
      cicilanRepo,
      AkunRepositoryImpl(db),
      now: DateTime(2026, 9, 25, 10),
    );

    test('saran per bulan dibulatkan ke atas & dipakai kalau kosong', () async {
      final c = newCubit();
      addTearDown(c.close);
      c
        ..setNama('Laptop')
        ..setTotal(100000)
        ..setTenor(3);
      await c.load();
      expect(c.state.suggestedPerBulan, 33334);

      await c.submit();
      expect(c.state.done, isTrue);
      final saved = (await cicilanRepo.watchAll().first).single;
      expect(saved.jumlahPerBulan, 33334);
      expect(saved.tanggalMulai, DateTime(2026, 9, 25));
      expect(saved.cicilanKe, 0);
    });

    test('error validasi tampil, tidak tersimpan', () async {
      final c = newCubit();
      addTearDown(c.close);
      await c.submit();
      expect(c.state.error, 'Nama cicilan wajib diisi');
      expect(c.state.done, isFalse);
    });
  });

  group('SubscriptionFormCubit', () {
    SubscriptionFormCubit newCubit({Subscription? initial}) =>
        SubscriptionFormCubit(
          SaveSubscription(subRepo),
          subRepo,
          AkunRepositoryImpl(db),
          initial: initial,
          now: DateTime(2026, 9, 25),
        );

    test('ganti tanggal memperbarui hari jangkar', () {
      final c = newCubit();
      addTearDown(c.close);
      c.setTanggal(DateTime(2026, 1, 31, 15));
      expect(c.state.draft.tanggalTagihanBerikutnya, DateTime(2026, 1, 31));
      expect(c.state.draft.hariTagihan, 31);
    });

    test('harga kosong/0 = variable; simpan mengembalikan id', () async {
      final c = newCubit();
      addTearDown(c.close);
      c
        ..setNama('Spotify')
        ..setHarga(0);
      expect(c.state.draft.autoGenerate, isFalse);
      c.setHarga(55000);
      expect(c.state.draft.autoGenerate, isTrue);

      await c.load();
      await c.submit();
      final id = c.state.result!.savedId!;
      expect((await subRepo.getById(id))!.hargaTetap, 55000);
    });

    test('hapus: hasil deleted, transaksi tetap ada tanpa tautan', () async {
      final id = await subRepo.save(
        Subscription(
          namaLayanan: 'Netflix',
          akunId: 1,
          hargaTetap: 54000,
          siklusBilling: SiklusBilling.bulanan,
          tanggalTagihanBerikutnya: DateTime(2026, 10, 1),
        ),
      );
      final trxId = await trxRepo.save(
        Transaksi(
          tanggal: DateTime(2026, 9, 1),
          deskripsi: 'Netflix',
          jenis: JenisTransaksi.subscription,
          akunId: 1,
          totalTagihan: 54000,
          subscriptionId: id,
        ),
      );

      final c = newCubit(initial: (await subRepo.getById(id))!);
      addTearDown(c.close);
      await c.delete();

      expect(c.state.result!.deleted, isTrue);
      expect(await subRepo.getById(id), isNull);
      expect((await trxRepo.getById(trxId))!.subscriptionId, isNull);
    });
  });

  test('SubscriptionDetailCubit: riwayat & total tercatat per bulan', () async {
    final id = await subRepo.save(
      Subscription(
        namaLayanan: 'Netflix',
        akunId: 1,
        hargaTetap: 54000,
        siklusBilling: SiklusBilling.bulanan,
        tanggalTagihanBerikutnya: DateTime(2026, 10, 1),
      ),
    );
    Future<void> bill(DateTime d, int total, {int? subId}) => trxRepo.save(
      Transaksi(
        tanggal: d,
        deskripsi: 'x',
        jenis: JenisTransaksi.subscription,
        akunId: 1,
        totalTagihan: total,
        subscriptionId: subId,
      ),
    );
    await bill(DateTime(2026, 8, 1), 54000, subId: id);
    await bill(DateTime(2026, 9, 1), 54000, subId: id);
    await bill(DateTime(2026, 9, 15), 10000, subId: id);
    await bill(DateTime(2026, 9, 2), 99999);

    final cubit = SubscriptionDetailCubit(subRepo, trxRepo, id);
    addTearDown(cubit.close);
    await cubit.load();

    expect(cubit.state.subscription!.namaLayanan, 'Netflix');
    expect(cubit.state.transaksis, hasLength(3));
    expect(cubit.state.transaksis.first.tanggal, DateTime(2026, 9, 15));
    expect(cubit.state.totalTercatat(DateTime(2026, 9)), 64000);
    expect(cubit.state.totalTercatat(DateTime(2026, 7)), 0);
  });

  group('akun pada form cicilan & subscription', () {
    test(
      'cicilan: akun dimuat dan dipilih; tersimpan pada akun tersebut',
      () async {
        final spay = await tambahAkun(db, limit: 5000000, cutoff: 10);
        final c = CicilanFormCubit(
          SaveCicilan(cicilanRepo),
          cicilanRepo,
          AkunRepositoryImpl(db),
          now: DateTime(2026, 9, 25),
        );
        addTearDown(c.close);
        expect(c.state.draft.akunId, 0);

        await c.load();
        expect(c.state.akuns.map((a) => a.nama), ['Kartu Kredit', 'SPayLater']);
        expect(c.state.draft.akunId, akunBawaanId);

        c
          ..setAkun(spay)
          ..setNama('Kulkas')
          ..setTotal(600000)
          ..setTenor(6);
        await c.submit();
        expect(c.state.done, isTrue);
        expect((await cicilanRepo.watchAll().first).single.akunId, spay);
      },
    );

    test('cicilan tanpa akun ditolak', () async {
      final c = CicilanFormCubit(
        SaveCicilan(cicilanRepo),
        cicilanRepo,
        AkunRepositoryImpl(db),
        now: DateTime(2026, 9, 25),
      );
      addTearDown(c.close);
      c
        ..setNama('Kulkas')
        ..setTotal(600000)
        ..setTenor(6);
      await c.submit();
      expect(c.state.error, 'Pilih akun terlebih dahulu');
      expect(c.state.done, isFalse);
    });

    test('subscription: tersimpan pada akun yang dipilih', () async {
      final spay = await tambahAkun(db);
      final c = SubscriptionFormCubit(
        SaveSubscription(subRepo),
        subRepo,
        AkunRepositoryImpl(db),
        now: DateTime(2026, 9, 25),
      );
      addTearDown(c.close);
      await c.load();
      c
        ..setAkun(spay)
        ..setNama('Shopee VIP')
        ..setHarga(20000);
      await c.submit();
      expect((await subRepo.getById(c.state.result!.savedId!))!.akunId, spay);
    });

    test(
      'daftar cicilan: nama akun hanya muncul kalau ada lebih dari satu',
      () async {
        final cubit = CicilanListCubit(
          cicilanRepo,
          PayCicilan(cicilanRepo),
          AkunRepositoryImpl(db),
        )..start();
        addTearDown(cubit.close);
        var s = await cubit.stream.firstWhere(
          (s) => s.status == CicilanListStatus.success,
        );
        expect(s.namaAkun, isEmpty);

        final spay = await tambahAkun(db);
        s = await cubit.stream.firstWhere((s) => s.akuns.length == 2);
        expect(s.namaAkun[spay], 'SPayLater');
      },
    );
  });
}
