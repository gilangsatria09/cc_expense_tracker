import 'package:cc_expense_tracker/core/error/domain_exception.dart';
import 'package:cc_expense_tracker/data/database/app_database.dart';
import 'package:cc_expense_tracker/data/repositories/cicilan_repository_impl.dart';
import 'package:cc_expense_tracker/data/repositories/subscription_repository_impl.dart';
import 'package:cc_expense_tracker/domain/entities/cicilan.dart';
import 'package:cc_expense_tracker/domain/entities/enums.dart';
import 'package:cc_expense_tracker/domain/entities/subscription.dart';
import 'package:cc_expense_tracker/domain/usecases/save_cicilan.dart';
import 'package:cc_expense_tracker/domain/usecases/save_subscription.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.inMemory());
  tearDown(() => db.close());

  Matcher domainError(String contains_) => throwsA(
    isA<DomainException>().having(
      (e) => e.message,
      'message',
      contains(contains_),
    ),
  );

  group('SaveCicilan', () {
    Cicilan cicilan({
      String nama = 'HP',
      int total = 1200000,
      int tenor = 12,
      int ke = 0,
      int perBulan = 100000,
    }) => Cicilan(
      namaCicilan: nama,
      akunId: 1,
      totalHargaBarang: total,
      tenor: tenor,
      cicilanKe: ke,
      jumlahPerBulan: perBulan,
      tanggalMulai: DateTime(2026, 9, 1),
    );

    test('validasi tiap field', () {
      final save = SaveCicilan(CicilanRepositoryImpl(db));
      expect(() => save(cicilan(nama: '  ')), domainError('Nama'));
      expect(() => save(cicilan(total: 0)), domainError('Total harga'));
      expect(() => save(cicilan(tenor: 0)), domainError('Tenor'));
      expect(() => save(cicilan(perBulan: 0)), domainError('per bulan'));
      expect(
        () => save(cicilan(tenor: 2, ke: 3)),
        domainError('cicilan yang sudah dibayar'),
      );
    });

    test('menyimpan dengan nama ter-trim', () async {
      final repo = CicilanRepositoryImpl(db);
      final id = await SaveCicilan(repo)(cicilan(nama: '  HP Baru '));
      expect((await repo.getById(id))!.namaCicilan, 'HP Baru');
    });

    test('sisaCicilan tidak pernah negatif', () {
      expect(
        cicilan(total: 100000, tenor: 3, ke: 3, perBulan: 33334).sisaCicilan,
        0,
      );
    });
  });

  group('SaveSubscription', () {
    Subscription sub({String nama = 'Netflix', int? harga = 54000}) =>
        Subscription(
          namaLayanan: nama,
          akunId: 1,
          hargaTetap: harga,
          siklusBilling: SiklusBilling.bulanan,
          tanggalTagihanBerikutnya: DateTime(2026, 10, 31),
        );

    test('validasi nama & harga; harga null (variable) valid', () async {
      final save = SaveSubscription(SubscriptionRepositoryImpl(db));
      expect(() => save(sub(nama: ' ')), domainError('Nama'));
      expect(() => save(sub(harga: 0)), domainError('Harga'));
      expect(() => save(sub(harga: -1)), domainError('Harga'));
      expect(await save(sub(harga: null)), greaterThan(0));
    });

    test('hari jangkar ikut tersimpan', () async {
      final repo = SubscriptionRepositoryImpl(db);
      final id = await SaveSubscription(repo)(sub());
      expect((await repo.getById(id))!.hariTagihan, 31);
    });
  });
}
