import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/date_utils.dart';
import '../../../domain/entities/subscription.dart';
import '../../../domain/entities/transaksi.dart';
import '../../../domain/repositories/subscription_repository.dart';
import '../../../domain/repositories/transaksi_repository.dart';

class SubscriptionDetailState extends Equatable {
  const SubscriptionDetailState({
    this.loading = true,
    this.subscription,
    this.transaksis = const [],
  });

  final bool loading;
  final Subscription? subscription;

  final List<Transaksi> transaksis;

  int totalTercatat(DateTime month) => transaksis
      .where((t) => isSameMonth(t.effectiveBulan, month))
      .fold(0, (sum, t) => sum + t.totalTagihan);

  @override
  List<Object?> get props => [loading, subscription, transaksis];
}

class SubscriptionDetailCubit extends Cubit<SubscriptionDetailState> {
  SubscriptionDetailCubit(
    this._subscriptionRepository,
    this._transaksiRepository,
    this._id,
  ) : super(const SubscriptionDetailState());

  final SubscriptionRepository _subscriptionRepository;
  final TransaksiRepository _transaksiRepository;
  final int _id;

  Future<void> load() async {
    final subscription = await _subscriptionRepository.getById(_id);
    final transaksis = await _transaksiRepository.getBySubscription(_id);
    if (isClosed) return;
    emit(
      SubscriptionDetailState(
        loading: false,
        subscription: subscription,
        transaksis: transaksis,
      ),
    );
  }
}
