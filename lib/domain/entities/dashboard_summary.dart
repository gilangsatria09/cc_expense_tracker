import 'package:equatable/equatable.dart';

import 'akun.dart';

class AkunLimit extends Equatable {
  const AkunLimit({
    required this.akun,
    required this.totalTransaksiBaru,
    required this.totalHargaCicilan,
    required this.totalPembayaran,
  });

  final Akun akun;

  final int totalTransaksiBaru;

  final int totalHargaCicilan;
  final int totalPembayaran;

  int get outstanding =>
      akun.saldoAwal + totalTransaksiBaru + totalHargaCicilan - totalPembayaran;

  int get sisaLimit => akun.limitKredit - outstanding;

  double get persentaseLimitTerpakai =>
      akun.limitKredit <= 0 ? 0 : outstanding / akun.limitKredit;

  @override
  List<Object?> get props => [
    akun,
    totalTransaksiBaru,
    totalHargaCicilan,
    totalPembayaran,
  ];
}

class DashboardSummary extends Equatable {
  const DashboardSummary({
    required this.akunLimits,
    required this.tagihanBulanIni,
    required this.cicilanBulanIni,
    required this.dibayarSementara,
    required this.personal,
    required this.groupOrder,
    required this.subscription,
    required this.pembayaran,
    required this.lainnya,
    required this.bebanSendiri,
    required this.piutangTotal,
    required this.piutangPaid,
    required this.piutangPaidTemp,
    required this.piutangBelumDibayar,
  });

  final List<AkunLimit> akunLimits;

  final int tagihanBulanIni;
  final int cicilanBulanIni;

  final int dibayarSementara;

  final int personal;
  final int groupOrder;
  final int subscription;
  final int pembayaran;
  final int lainnya;

  final int bebanSendiri;
  final int piutangTotal;
  final int piutangPaid;
  final int piutangPaidTemp;
  final int piutangBelumDibayar;

  int get totalOutstanding =>
      akunLimits.fold(0, (sum, a) => sum + a.outstanding);

  int get totalSisaLimit => akunLimits.fold(0, (sum, a) => sum + a.sisaLimit);

  int get totalLimit =>
      akunLimits.fold(0, (sum, a) => sum + a.akun.limitKredit);

  int get totalPerluDibayar => tagihanBulanIni + cicilanBulanIni;

  int get perkiraanBulanDepan =>
      totalPerluDibayar + dibayarSementara - piutangPaid;

  @override
  List<Object?> get props => [
    akunLimits,
    tagihanBulanIni,
    cicilanBulanIni,
    dibayarSementara,
    personal,
    groupOrder,
    subscription,
    pembayaran,
    lainnya,
    bebanSendiri,
    piutangTotal,
    piutangPaid,
    piutangPaidTemp,
    piutangBelumDibayar,
  ];
}
