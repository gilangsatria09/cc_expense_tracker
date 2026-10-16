import '../../core/error/domain_exception.dart';
import '../entities/cicilan.dart';
import '../repositories/cicilan_repository.dart';

class PayCicilan {
  const PayCicilan(this._repository);

  final CicilanRepository _repository;

  Future<Cicilan> call(int cicilanId, {required DateTime now}) async {
    final cicilan = await _repository.getById(cicilanId);
    if (cicilan == null) throw const DomainException('Cicilan tidak ditemukan');
    if (cicilan.lunas) throw const DomainException('Cicilan sudah lunas');
    if (cicilan.sudahBayarBulanIni(now)) {
      throw const DomainException('Cicilan bulan ini sudah dibayar');
    }

    final updated = cicilan.copyWith(
      cicilanKe: cicilan.cicilanKe + 1,
      tanggalBayarTerakhir: () => now,
    );
    await _repository.save(updated);
    return updated;
  }
}
