import '../../core/error/domain_exception.dart';
import '../../core/utils/date_utils.dart';
import '../entities/enums.dart';
import '../entities/transaksi.dart';
import '../repositories/akun_repository.dart';
import '../repositories/transaksi_repository.dart';

class SaveTransaksi {
  const SaveTransaksi(this._repository, this._akunRepository);

  final TransaksiRepository _repository;
  final AkunRepository _akunRepository;

  Future<int> call(Transaksi transaksi) {
    if (transaksi.totalTagihan <= 0) {
      throw const DomainException('Total tagihan harus lebih dari 0');
    }
    if (transaksi.akunId <= 0) {
      throw const DomainException('Pilih akun terlebih dahulu');
    }
    if (transaksi.jenis == JenisTransaksi.subscription &&
        transaksi.subscriptionId == null) {
      throw const DomainException('Pilih subscription terlebih dahulu');
    }

    var normalized = transaksi;
    if (transaksi.jenis != JenisTransaksi.subscription) {
      normalized = normalized.copyWith(subscriptionId: () => null);
    }
    if (transaksi.jenis != JenisTransaksi.groupOrder) {
      normalized = normalized.copyWith(
        merchant: () => null,
        ongkirFee: 0,
        splits: const [],
      );
    }
    return _save(normalized);
  }

  Future<int> _save(Transaksi transaksi) async {
    final akun = await _akunRepository.getById(transaksi.akunId);
    if (akun == null) throw const DomainException('Akun tidak ditemukan');

    final resolved = transaksi.bulanTagihan != null
        ? transaksi
        : transaksi.copyWith(
            bulanTagihan: () =>
                bulanTagihanFor(transaksi.tanggal, akun.tanggalCutoff),
          );
    final id = await _repository.save(resolved);
    await _akunRepository.setLastUsedId(akun.id);
    return id;
  }
}
