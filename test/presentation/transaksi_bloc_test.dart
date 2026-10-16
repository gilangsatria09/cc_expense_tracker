import 'package:cc_expense_tracker/data/database/app_database.dart';
import 'package:cc_expense_tracker/data/repositories/akun_repository_impl.dart';
import 'package:cc_expense_tracker/data/repositories/subscription_repository_impl.dart';
import 'package:cc_expense_tracker/data/repositories/transaksi_repository_impl.dart';
import 'package:cc_expense_tracker/domain/entities/enums.dart';
import 'package:cc_expense_tracker/domain/entities/subscription.dart';
import 'package:cc_expense_tracker/domain/entities/transaksi.dart';
import 'package:cc_expense_tracker/domain/usecases/save_transaksi.dart';
import 'package:cc_expense_tracker/presentation/transaksi/bloc/transaksi_form_cubit.dart';
import 'package:cc_expense_tracker/presentation/transaksi/bloc/transaksi_list_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/akun_helpers.dart';

void main() {
  late AppDatabase db;
  late TransaksiRepositoryImpl repo;
  late SubscriptionRepositoryImpl subRepo;

  setUp(() {
    db = AppDatabase.inMemory();
    repo = TransaksiRepositoryImpl(db);
    subRepo = SubscriptionRepositoryImpl(db);
  });
  tearDown(() => db.close());

  Transaksi trx(DateTime tanggal, {String deskripsi = 'tes'}) => Transaksi(
    tanggal: tanggal,
    deskripsi: deskripsi,
    jenis: JenisTransaksi.personal,
    akunId: 1,
    totalTagihan: 10000,
  );

  group('TransaksiListBloc', () {
    test(
      'memuat bulan berjalan, reaktif terhadap insert, ganti bulan',
      () async {
        await repo.save(trx(DateTime(2026, 9, 5)));
        await repo.save(trx(DateTime(2026, 10, 5), deskripsi: 'oktober'));

        final bloc = TransaksiListBloc(
          repo,
          AkunRepositoryImpl(db),
          now: DateTime(2026, 9, 25),
        );
        addTearDown(bloc.close);

        bloc.add(TransaksiMonthChanged(DateTime(2026, 9, 25)));
        var s = await bloc.stream.firstWhere(
          (s) => s.status == TransaksiListStatus.success,
        );
        expect(s.month, DateTime(2026, 9));
        expect(s.transaksis, hasLength(1));

        await repo.save(trx(DateTime(2026, 9, 6)));
        s = await bloc.stream.firstWhere((s) => s.transaksis.length == 2);
        expect(s.transaksis, hasLength(2));

        bloc.add(TransaksiMonthChanged(DateTime(2026, 10)));
        s = await bloc.stream.firstWhere(
          (s) =>
              s.month == DateTime(2026, 10) &&
              s.status == TransaksiListStatus.success,
        );
        expect(s.transaksis.single.deskripsi, 'oktober');
      },
    );
  });

  group('TransaksiListBloc: pilih & ubah status massal', () {
    Future<TransaksiListBloc> loaded(
      DateTime month,
      Map<String, StatusBayar> statuses,
    ) async {
      for (final e in statuses.entries) {
        await repo.save(trx(month, deskripsi: e.key).copyWith(status: e.value));
      }
      final bloc = TransaksiListBloc(repo, AkunRepositoryImpl(db), now: month);
      addTearDown(bloc.close);
      bloc.add(TransaksiMonthChanged(month));
      await bloc.stream.firstWhere(
        (s) =>
            s.status == TransaksiListStatus.success &&
            s.transaksis.length == statuses.length,
      );
      return bloc;
    }

    List<StatusBayar> statusesInDb(List<Transaksi> all, List<String> names) => [
      for (final n in names) all.firstWhere((t) => t.deskripsi == n).status,
    ];

    test('toggle memilih/melepas; select all & clear', () async {
      final bloc = await loaded(DateTime(2026, 9), {
        'a': StatusBayar.paidTemp,
        'b': StatusBayar.paidTemp,
        'c': StatusBayar.paid,
      });
      final ids = bloc.state.transaksis.map((t) => t.id).toList();
      expect(bloc.state.selecting, isFalse);

      bloc.add(TransaksiSelectionToggled(ids[0]));
      var s = await bloc.stream.firstWhere((s) => s.selecting);
      expect(s.selectedIds, {ids[0]});

      bloc.add(TransaksiSelectionToggled(ids[1]));
      s = await bloc.stream.firstWhere((s) => s.selectedIds.length == 2);

      bloc.add(TransaksiSelectionToggled(ids[0]));
      s = await bloc.stream.firstWhere((s) => s.selectedIds.length == 1);
      expect(s.selectedIds, {ids[1]});

      bloc.add(const TransaksiSelectAllRequested());
      s = await bloc.stream.firstWhere((s) => s.selectedIds.length == 3);

      bloc.add(const TransaksiSelectionCleared());
      s = await bloc.stream.firstWhere((s) => !s.selecting);
      expect(s.selectedIds, isEmpty);
    });

    test('ganti bulan membuang pilihan', () async {
      final bloc = await loaded(DateTime(2026, 9), {'a': StatusBayar.paid});
      bloc.add(TransaksiSelectionToggled(bloc.state.transaksis.single.id));
      await bloc.stream.firstWhere((s) => s.selecting);

      bloc.add(TransaksiMonthChanged(DateTime(2026, 10)));
      final s = await bloc.stream.firstWhere(
        (s) => s.month == DateTime(2026, 10) && !s.selecting,
      );
      expect(s.selectedIds, isEmpty);
    });

    test('pilihan yang transaksinya dihapus ikut hilang', () async {
      final bloc = await loaded(DateTime(2026, 9), {
        'a': StatusBayar.paid,
        'b': StatusBayar.paid,
      });
      final ids = bloc.state.transaksis.map((t) => t.id).toList();
      bloc
        ..add(TransaksiSelectionToggled(ids[0]))
        ..add(TransaksiSelectionToggled(ids[1]));
      await bloc.stream.firstWhere((s) => s.selectedIds.length == 2);

      await repo.delete(ids[0]);
      final s = await bloc.stream.firstWhere((s) => s.transaksis.length == 1);
      expect(s.selectedIds, {ids[1]});
    });

    test(
      'ubah status: tersimpan, pilihan ditutup, notice hanya yang berubah',
      () async {
        final bloc = await loaded(DateTime(2026, 9), {
          'a': StatusBayar.paidTemp,
          'b': StatusBayar.paidTemp,
          'c': StatusBayar.paid,
          'd': StatusBayar.paidTemp,
        });
        for (final t in bloc.state.transaksis.where(
          (t) => t.deskripsi != 'd',
        )) {
          bloc.add(TransaksiSelectionToggled(t.id));
        }
        await bloc.stream.firstWhere((s) => s.selectedIds.length == 3);

        bloc.add(const TransaksiSelectedStatusChanged(StatusBayar.paid));
        final s = await bloc.stream.firstWhere((s) => s.notice != null);

        expect(s.selecting, isFalse);
        expect(s.notice!.status, StatusBayar.paid);
        expect(s.notice!.count, 2);
        expect(s.notice!.previous.values, everyElement(StatusBayar.paidTemp));
        expect(statusesInDb(await repo.getAll(), ['a', 'b', 'c', 'd']), [
          StatusBayar.paid,
          StatusBayar.paid,
          StatusBayar.paid,
          StatusBayar.paidTemp,
        ]);
      },
    );

    test('urungkan mengembalikan status lama', () async {
      final bloc = await loaded(DateTime(2026, 9), {
        'a': StatusBayar.paidTemp,
        'b': StatusBayar.belumDibayar,
      });
      bloc.add(const TransaksiSelectAllRequested());
      await bloc.stream.firstWhere((s) => s.selectedIds.length == 2);
      bloc.add(const TransaksiSelectedStatusChanged(StatusBayar.paid));
      final notice = (await bloc.stream.firstWhere(
        (s) => s.notice != null,
      )).notice!;

      bloc.add(TransaksiStatusUndone(notice));
      await bloc.stream.firstWhere(
        (s) => s.transaksis.any((t) => t.status == StatusBayar.belumDibayar),
      );
      expect(statusesInDb(await repo.getAll(), ['a', 'b']), [
        StatusBayar.paidTemp,
        StatusBayar.belumDibayar,
      ]);
    });

    test(
      'semua sudah berstatus itu: tidak menulis, tidak ada notice',
      () async {
        final bloc = await loaded(DateTime(2026, 9), {'a': StatusBayar.paid});
        bloc.add(const TransaksiSelectAllRequested());
        await bloc.stream.firstWhere((s) => s.selecting);
        bloc.add(const TransaksiSelectedStatusChanged(StatusBayar.paid));
        final s = await bloc.stream.firstWhere((s) => !s.selecting);
        expect(s.notice, isNull);
      },
    );
  });

  group('TransaksiListBloc: filter status', () {
    Future<TransaksiListBloc> loaded(
      DateTime month,
      List<(String, StatusBayar, int)> data,
    ) async {
      for (final (nama, status, akun) in data) {
        await repo.save(
          trx(month, deskripsi: nama).copyWith(status: status, akunId: akun),
        );
      }
      final bloc = TransaksiListBloc(repo, AkunRepositoryImpl(db), now: month);
      addTearDown(bloc.close);
      bloc.add(TransaksiMonthChanged(month));
      await bloc.stream.firstWhere(
        (s) =>
            s.status == TransaksiListStatus.success &&
            s.transaksis.length == data.length,
      );
      return bloc;
    }

    final sep = DateTime(2026, 9);

    test('menyaring per status; jumlah per status tetap utuh', () async {
      final bloc = await loaded(sep, [
        ('a', StatusBayar.paidTemp, 1),
        ('b', StatusBayar.paidTemp, 1),
        ('c', StatusBayar.paid, 1),
        ('d', StatusBayar.belumDibayar, 1),
      ]);
      expect(bloc.state.statusFilter, isNull);
      expect(bloc.state.statusCounts, {
        StatusBayar.belumDibayar: 1,
        StatusBayar.paidTemp: 2,
        StatusBayar.paid: 1,
      });

      bloc.add(const TransaksiStatusFilterChanged(StatusBayar.paidTemp));
      var s = await bloc.stream.firstWhere((s) => s.statusFilter != null);
      expect(s.transaksis.map((t) => t.deskripsi).toSet(), {'a', 'b'});
      expect(s.statusCounts[StatusBayar.paid], 1);
      expect(s.adaTransaksiBulanIni, isTrue);

      bloc.add(const TransaksiStatusFilterChanged(null));
      s = await bloc.stream.firstWhere((s) => s.statusFilter == null);
      expect(s.transaksis, hasLength(4));
    });

    test(
      'digabung dengan filter akun (keduanya berlaku); jumlah mengikuti akun',
      () async {
        final spay = await tambahAkun(db);
        final bloc = await loaded(sep, [
          ('cc-temp', StatusBayar.paidTemp, 1),
          ('cc-paid', StatusBayar.paid, 1),
          ('sp-temp', StatusBayar.paidTemp, spay),
          ('sp-temp2', StatusBayar.paidTemp, spay),
        ]);

        bloc.add(const TransaksiStatusFilterChanged(StatusBayar.paidTemp));
        await bloc.stream.firstWhere((s) => s.statusFilter != null);
        bloc.add(TransaksiAkunFilterChanged(spay));
        final s = await bloc.stream.firstWhere((s) => s.akunFilter == spay);

        expect(s.transaksis.map((t) => t.deskripsi).toSet(), {
          'sp-temp',
          'sp-temp2',
        });
        expect(s.statusCounts[StatusBayar.paidTemp], 2);
        expect(s.statusCounts[StatusBayar.paid], 0);
      },
    );

    test('filter bertahan saat ganti bulan; pilihan dibuang', () async {
      final bloc = await loaded(sep, [
        ('a', StatusBayar.paidTemp, 1),
        ('b', StatusBayar.paid, 1),
      ]);
      await repo.save(
        trx(
          DateTime(2026, 10),
          deskripsi: 'okt',
        ).copyWith(status: StatusBayar.paidTemp),
      );
      bloc.add(const TransaksiStatusFilterChanged(StatusBayar.paidTemp));
      await bloc.stream.firstWhere((s) => s.statusFilter != null);
      bloc.add(TransaksiSelectionToggled(bloc.state.transaksis.single.id));
      await bloc.stream.firstWhere((s) => s.selecting);

      bloc.add(TransaksiMonthChanged(DateTime(2026, 10)));
      final s = await bloc.stream.firstWhere(
        (s) =>
            s.month == DateTime(2026, 10) &&
            s.status == TransaksiListStatus.success,
      );
      expect(s.statusFilter, StatusBayar.paidTemp);
      expect(s.transaksis.map((t) => t.deskripsi), ['okt']);
      expect(s.selecting, isFalse);
    });

    test('mengganti filter membuang pilihan', () async {
      final bloc = await loaded(sep, [
        ('a', StatusBayar.paidTemp, 1),
        ('b', StatusBayar.paid, 1),
      ]);
      bloc.add(const TransaksiSelectAllRequested());
      await bloc.stream.firstWhere((s) => s.selecting);
      bloc.add(const TransaksiStatusFilterChanged(StatusBayar.paid));
      final s = await bloc.stream.firstWhere((s) => s.statusFilter != null);
      expect(s.selecting, isFalse);
    });

    test(
      'alur: filter Paid Temp → pilih semua → jadikan Paid → daftar kosong terfilter',
      () async {
        final bloc = await loaded(sep, [
          ('a', StatusBayar.paidTemp, 1),
          ('b', StatusBayar.paidTemp, 1),
          ('c', StatusBayar.paid, 1),
        ]);
        bloc.add(const TransaksiStatusFilterChanged(StatusBayar.paidTemp));
        await bloc.stream.firstWhere((s) => s.statusFilter != null);
        bloc.add(const TransaksiSelectAllRequested());
        await bloc.stream.firstWhere((s) => s.selectedIds.length == 2);

        bloc.add(const TransaksiSelectedStatusChanged(StatusBayar.paid));
        final s = await bloc.stream.firstWhere(
          (s) => s.notice != null && s.transaksis.isEmpty,
        );
        expect(s.notice!.count, 2);
        expect(s.statusFilter, StatusBayar.paidTemp);
        expect(
          s.adaTransaksiBulanIni,
          isTrue,
        );
        expect(s.statusCounts, {
          StatusBayar.belumDibayar: 0,
          StatusBayar.paidTemp: 0,
          StatusBayar.paid: 3,
        });
        expect(s.selecting, isFalse);
      },
    );

    test('bulan tanpa transaksi: adaTransaksiBulanIni false', () async {
      final bloc = TransaksiListBloc(repo, AkunRepositoryImpl(db), now: sep);
      addTearDown(bloc.close);
      bloc.add(TransaksiMonthChanged(sep));
      final s = await bloc.stream.firstWhere(
        (s) => s.status == TransaksiListStatus.success,
      );
      expect(s.adaTransaksiBulanIni, isFalse);
      expect(s.statusCounts.values, everyElement(0));
    });
  });

  group('TransaksiFormCubit', () {
    TransaksiFormCubit newCubit({Transaksi? initial}) => TransaksiFormCubit(
      SaveTransaksi(repo, AkunRepositoryImpl(db)),
      repo,
      subRepo,
      AkunRepositoryImpl(db),
      initial: initial,
      now: DateTime(2026, 9, 25, 14),
    );

    test('draft baru: default tanggal hari ini, jenis Personal, CC', () {
      final c = newCubit();
      addTearDown(c.close);
      expect(c.state.isEdit, isFalse);
      expect(c.state.draft.tanggal, DateTime(2026, 9, 25));
      expect(c.state.draft.sumberEkstraksi, SumberEkstraksi.manual);
    });

    test('deskripsi kosong / total 0 ditolak dengan pesan error', () async {
      final c = newCubit();
      addTearDown(c.close);

      await c.submit();
      expect(c.state.error, 'Deskripsi wajib diisi');

      c.setDeskripsi('Kopi');
      await c.submit();
      expect(c.state.error, 'Total tagihan harus lebih dari 0');
      expect(c.state.done, isFalse);
      expect(await repo.getAll(), isEmpty);
    });

    test(
      'bulan tagihan: otomatis dari cutoff, override manual, reset',
      () async {
        await setCutoff(db, 4);
        final c = newCubit();
        addTearDown(c.close);
        await c.load();
        expect(c.state.cutoff, 4);

        c.setTanggal(DateTime(2026, 9, 2));
        expect(c.state.bulanTagihan, DateTime(2026, 8));
        expect(c.state.bulanManual, isFalse);

        c.setTanggal(DateTime(2026, 9, 10));
        c.setBulanTagihan(DateTime(2026, 8));
        expect(c.state.bulanTagihan, DateTime(2026, 8));
        expect(c.state.bulanManual, isTrue);

        c.setTanggal(DateTime(2026, 9, 12));
        expect(c.state.bulanTagihan, DateTime(2026, 8));
        expect(c.state.bulanManual, isTrue);

        c.resetBulanTagihan();
        expect(c.state.bulanTagihan, DateTime(2026, 9));
        expect(c.state.bulanManual, isFalse);

        c.setBulanTagihan(DateTime(2026, 9, 20));
        expect(c.state.draft.bulanTagihan, isNull);
      },
    );

    test(
      'simpan: bulan otomatis & manual tersimpan sebagai bulan tagihan',
      () async {
        await setCutoff(db, 4);
        final c = newCubit();
        addTearDown(c.close);
        await c.load();
        c
          ..setDeskripsi('Pembayaran')
          ..setTotal(500000)
          ..setJenis(JenisTransaksi.pembayaran)
          ..setTanggal(DateTime(2026, 8, 5))
          ..setBulanTagihan(DateTime(2026, 7));
        await c.submit();

        final saved = (await repo.getAll()).single;
        expect(saved.tanggal, DateTime(2026, 8, 5));
        expect(saved.bulanTagihan, DateTime(2026, 7));
      },
    );

    test(
      'akun awal: yang terakhir dipakai, kalau tidak ada akun pertama',
      () async {
        final spay = await tambahAkun(db, cutoff: 10);

        final baru = newCubit();
        addTearDown(baru.close);
        expect(baru.state.draft.akunId, 0);
        await baru.load();
        expect(baru.state.draft.akunId, akunBawaanId);
        expect(baru.state.akuns, hasLength(2));

        await AkunRepositoryImpl(db).setLastUsedId(spay);
        final lagi = newCubit();
        addTearDown(lagi.close);
        await lagi.load();
        expect(lagi.state.draft.akunId, spay);

        await AkunRepositoryImpl(db).setLastUsedId(999);
        final hapus = newCubit();
        addTearDown(hapus.close);
        await hapus.load();
        expect(hapus.state.draft.akunId, akunBawaanId);
      },
    );

    test(
      'ganti akun: bulan tagihan mengikuti tanggal tutup buku akun baru',
      () async {
        await setCutoff(db, 4);
        final spay = await tambahAkun(db, cutoff: 10);
        final c = newCubit();
        addTearDown(c.close);
        await c.load();

        c.setTanggal(DateTime(2026, 9, 8));
        expect(c.state.cutoff, 4);
        expect(c.state.bulanTagihan, DateTime(2026, 9));

        c.setAkun(spay);
        expect(c.state.cutoff, 10);
        expect(c.state.bulanTagihan, DateTime(2026, 8));
        expect(c.state.bulanManual, isFalse);
      },
    );

    test('ganti akun tidak menimpa bulan tagihan yang diubah manual', () async {
      final spay = await tambahAkun(db, cutoff: 10);
      final c = newCubit();
      addTearDown(c.close);
      await c.load();

      c.setTanggal(DateTime(2026, 9, 8));
      c.setBulanTagihan(DateTime(2026, 11));
      c.setAkun(spay);
      expect(c.state.bulanTagihan, DateTime(2026, 11));
      expect(c.state.bulanManual, isTrue);
    });

    test('simpan sukses lalu edit & hapus', () async {
      final c = newCubit();
      addTearDown(c.close);
      await c.load();
      c
        ..setDeskripsi('  Kopi  ')
        ..setTotal(25000);
      await c.submit();
      expect(c.state.done, isTrue);

      final saved = (await repo.getAll()).single;
      expect(saved.deskripsi, 'Kopi');

      final edit = newCubit(initial: saved);
      addTearDown(edit.close);
      expect(edit.state.isEdit, isTrue);
      await edit.delete();
      expect(edit.state.done, isTrue);
      expect(await repo.getAll(), isEmpty);
    });

    test('load(): hanya subscription aktif + yang sedang tertaut', () async {
      Subscription sub(String nama, StatusSubscription status) => Subscription(
        namaLayanan: nama,
        akunId: 1,
        siklusBilling: SiklusBilling.bulanan,
        tanggalTagihanBerikutnya: DateTime(2026, 10, 1),
        status: status,
      );
      await subRepo.save(sub('Aktif', StatusSubscription.aktif));
      final oldId = await subRepo.save(
        sub('Lama', StatusSubscription.nonaktif),
      );
      await subRepo.save(sub('Batal', StatusSubscription.dibatalkan));

      final fresh = newCubit();
      addTearDown(fresh.close);
      await fresh.load();
      expect(fresh.state.subscriptions.map((s) => s.namaLayanan), ['Aktif']);

      final linked = newCubit(
        initial: trx(
          DateTime(2026, 9, 1),
        ).copyWith(subscriptionId: () => oldId),
      );
      addTearDown(linked.close);
      await linked.load();
      expect(
        linked.state.subscriptions.map((s) => s.namaLayanan),
        unorderedEquals(['Aktif', 'Lama']),
      );
    });
  });
}
