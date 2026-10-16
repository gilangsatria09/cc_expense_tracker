import '../../core/utils/date_utils.dart';
import '../entities/enums.dart';
import '../entities/subscription.dart';
import '../entities/transaksi.dart';
import '../repositories/akun_repository.dart';
import '../repositories/subscription_repository.dart';

class GenerateSubscriptionBills {
  const GenerateSubscriptionBills(this._repository, this._akunRepository);

  final SubscriptionRepository _repository;
  final AkunRepository _akunRepository;

  Future<int> call(DateTime now) async {
    final today = dateOnly(now);
    final cutoffByAkun = {
      for (final a in await _akunRepository.getAll()) a.id: a.tanggalCutoff,
    };
    var created = 0;

    for (final sub in await _repository.getAll()) {
      final harga = sub.hargaTetap;
      if (sub.status != StatusSubscription.aktif ||
          harga == null ||
          harga <= 0) {
        continue;
      }

      var next = dateOnly(sub.tanggalTagihanBerikutnya);
      final bills = <Transaksi>[];
      while (!next.isAfter(today)) {
        bills.add(_billFor(sub, harga, next, cutoffByAkun[sub.akunId] ?? 0));
        next = sub.nextBillingAfter(next);
      }
      if (bills.isEmpty) continue;

      await _repository.applyGeneratedBills(
        sub.copyWith(tanggalTagihanBerikutnya: next),
        bills,
      );
      created += bills.length;
    }
    return created;
  }

  Transaksi _billFor(
    Subscription sub,
    int harga,
    DateTime tanggal,
    int cutoff,
  ) => Transaksi(
    tanggal: tanggal,
    bulanTagihan: bulanTagihanFor(tanggal, cutoff),
    deskripsi: sub.namaLayanan,
    jenis: JenisTransaksi.subscription,
    akunId: sub.akunId,
    totalTagihan: harga,
    status: StatusBayar.belumDibayar,
    subscriptionId: sub.id,
    sumberEkstraksi: SumberEkstraksi.autoSubscription,
  );
}
