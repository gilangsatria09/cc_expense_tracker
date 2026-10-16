import '../../core/error/domain_exception.dart';
import '../entities/akun.dart';
import '../repositories/akun_repository.dart';

class SaveAkun {
  const SaveAkun(this._repository);

  final AkunRepository _repository;

  Future<int> call(Akun akun) async {
    final nama = akun.nama.trim();
    if (nama.isEmpty) throw const DomainException('Nama akun wajib diisi');
    if (akun.limitKredit < 0) {
      throw const DomainException('Limit tidak boleh negatif');
    }
    if (akun.saldoAwal < 0) {
      throw const DomainException('Saldo awal tidak boleh negatif');
    }
    if (akun.tanggalCutoff < 0 || akun.tanggalCutoff > 31) {
      throw const DomainException(
        'Tanggal tutup buku harus 1–31 (0 = ikut bulan kalender)',
      );
    }
    if (akun.tanggalJatuhTempo < 0 || akun.tanggalJatuhTempo > 31) {
      throw const DomainException(
        'Tanggal jatuh tempo harus 1–31 (0 = tanpa pengingat)',
      );
    }
    final lain = (await _repository.getAll()).where((a) => a.id != akun.id);
    if (lain.any((a) => a.nama.trim().toLowerCase() == nama.toLowerCase())) {
      throw DomainException('Akun "$nama" sudah ada');
    }
    return _repository.save(akun.copyWith(nama: nama));
  }
}

class DeleteAkun {
  const DeleteAkun(this._repository);

  final AkunRepository _repository;

  Future<void> call(int id) async {
    if ((await _repository.getAll()).length <= 1) {
      throw const DomainException('Minimal harus ada satu akun');
    }
    final pakai = await _repository.usageCount(id);
    if (pakai > 0) {
      throw DomainException(
        'Akun masih dipakai $pakai data (transaksi, cicilan, atau '
        'subscription), tidak bisa dihapus',
      );
    }
    await _repository.delete(id);
  }
}
