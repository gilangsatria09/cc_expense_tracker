import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../domain/entities/cicilan.dart';
import '../bloc/cicilan_list_cubit.dart';
import '../widgets/cicilan_card.dart';
import 'cicilan_form_page.dart';

class CicilanListPage extends StatelessWidget {
  const CicilanListPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<CicilanListCubit>()..start(),
    child: const _CicilanListView(),
  );
}

class _CicilanListView extends StatelessWidget {
  const _CicilanListView();

  void _openForm(BuildContext context, [Cicilan? initial]) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => CicilanFormPage(initial: initial),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Cicilan'),
      actions: [
        IconButton(
          tooltip: 'Cicilan baru',
          icon: const Icon(Icons.add),
          onPressed: () => _openForm(context),
        ),
      ],
    ),
    body: BlocConsumer<CicilanListCubit, CicilanListState>(
      listenWhen: (a, b) => a.message != b.message && b.message != null,
      listener: (context, state) => ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(state.message!))),
      builder: (context, state) {
        switch (state.status) {
          case CicilanListStatus.loading:
            return const Center(child: CircularProgressIndicator());
          case CicilanListStatus.failure:
            return const Center(child: Text('Gagal memuat cicilan'));
          case CicilanListStatus.success:
            if (state.cicilans.isEmpty) {
              return const Center(child: Text('Belum ada cicilan'));
            }
            final cubit = context.read<CicilanListCubit>();
            final now = cubit.now;
            final lunas = state.lunas;
            return ListView(
              padding: const EdgeInsets.only(bottom: 96),
              children: [
                for (final c in state.aktif)
                  CicilanCard(
                    cicilan: c,
                    akunNama: state.namaAkun[c.akunId],
                    now: now,
                    onTap: () => _openForm(context, c),
                    onPay: () => cubit.pay(c.id),
                  ),
                if (lunas.isNotEmpty)
                  ExpansionTile(
                    title: Text('Lunas (${lunas.length})'),
                    children: [
                      for (final c in lunas)
                        CicilanCard(
                          cicilan: c,
                          akunNama: state.namaAkun[c.akunId],
                          now: now,
                          onTap: () => _openForm(context, c),
                          onPay: () {},
                        ),
                    ],
                  ),
              ],
            );
        }
      },
    ),
  );
}
