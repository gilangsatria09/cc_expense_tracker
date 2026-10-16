import 'package:cc_expense_tracker/data/database/app_database.dart';
import 'package:cc_expense_tracker/data/repositories/akun_repository_impl.dart';
import 'package:cc_expense_tracker/domain/entities/akun.dart';

const akunBawaanId = 1;

Future<void> setCutoff(AppDatabase db, int cutoff) async {
  final repo = AkunRepositoryImpl(db);
  final akun = (await repo.getAll()).first;
  await repo.save(akun.copyWith(tanggalCutoff: cutoff));
}

Future<int> tambahAkun(
  AppDatabase db, {
  String nama = 'SPayLater',
  int limit = 0,
  int saldoAwal = 0,
  int cutoff = 0,
}) => AkunRepositoryImpl(db).save(
  Akun(
    nama: nama,
    limitKredit: limit,
    saldoAwal: saldoAwal,
    tanggalCutoff: cutoff,
  ),
);
