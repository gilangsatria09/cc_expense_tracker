import '../../core/error/domain_exception.dart';
import '../entities/subscription.dart';
import '../repositories/subscription_repository.dart';

class SaveSubscription {
  const SaveSubscription(this._repository);

  final SubscriptionRepository _repository;

  Future<int> call(Subscription subscription) {
    if (subscription.namaLayanan.trim().isEmpty) {
      throw const DomainException('Nama layanan wajib diisi');
    }
    if (subscription.akunId <= 0) {
      throw const DomainException('Pilih akun terlebih dahulu');
    }
    final harga = subscription.hargaTetap;
    if (harga != null && harga <= 0) {
      throw const DomainException(
        'Harga tetap harus lebih dari 0 (kosongkan kalau harga berubah-ubah)',
      );
    }
    return _repository.save(
      subscription.copyWith(namaLayanan: subscription.namaLayanan.trim()),
    );
  }
}
