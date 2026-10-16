import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../bloc/subscription_list_cubit.dart';
import '../widgets/subscription_card.dart';
import 'subscription_detail_page.dart';
import 'subscription_form_page.dart';

class SubscriptionListPage extends StatelessWidget {
  const SubscriptionListPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<SubscriptionListCubit>()..start(),
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Subscription'),
        actions: [
          Builder(
            builder: (context) => IconButton(
              tooltip: 'Subscription baru',
              icon: const Icon(Icons.add),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SubscriptionFormPage(),
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<SubscriptionListCubit, SubscriptionListState>(
        builder: (context, state) => switch (state.status) {
          SubscriptionListStatus.loading => const Center(
            child: CircularProgressIndicator(),
          ),
          SubscriptionListStatus.failure => const Center(
            child: Text('Gagal memuat subscription'),
          ),
          SubscriptionListStatus.success =>
            state.subscriptions.isEmpty
                ? const Center(child: Text('Belum ada subscription'))
                : ListView(
                    padding: const EdgeInsets.only(bottom: 96),
                    children: [
                      for (final s in state.subscriptions)
                        SubscriptionCard(
                          subscription: s,
                          akunNama: state.namaAkun[s.akunId],
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  SubscriptionDetailPage(subscriptionId: s.id),
                            ),
                          ),
                        ),
                    ],
                  ),
        },
      ),
    ),
  );
}
