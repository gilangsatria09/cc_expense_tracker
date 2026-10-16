import '../../core/error/domain_exception.dart';
import '../entities/cicilan.dart';
import '../repositories/cicilan_repository.dart';

class SaveCicilan {
  const SaveCicilan(this._repository);

  final CicilanRepository _repository;

  Future<int> call(Cicilan cicilan) {
    if (cicilan.namaCicilan.trim().isEmpty) {
      throw const DomainException('Nama cicilan wajib diisi');
    }
    if (cicilan.akunId <= 0) {
      throw const DomainException('Pilih akun terlebih dahulu');
    }
    if (cicilan.totalHargaBarang <= 0) {
      throw const DomainException('Total harga barang harus lebih dari 0');
    }
    if (cicilan.tenor <= 0) {
      throw const DomainException('Tenor harus lebih dari 0');
    }
    if (cicilan.jumlahPerBulan <= 0) {
      throw const DomainException('Jumlah per bulan harus lebih dari 0');
    }
    if (cicilan.tenor < cicilan.cicilanKe) {
      throw DomainException(
        'Tenor tidak boleh kurang dari cicilan yang sudah dibayar '
        '(${cicilan.cicilanKe})',
      );
    }
    return _repository.save(
      cicilan.copyWith(namaCicilan: cicilan.namaCicilan.trim()),
    );
  }
}
