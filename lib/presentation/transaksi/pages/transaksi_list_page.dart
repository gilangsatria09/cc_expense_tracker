import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/transaksi.dart';
import '../../common/widgets/akun_filter_chips.dart';
import '../../common/widgets/badge_chip.dart';
import '../../common/widgets/month_selector.dart';
import '../bloc/transaksi_list_bloc.dart';
import '../widgets/status_filter_chips.dart';
import '../widgets/transaksi_tile.dart';
import 'transaksi_form_page.dart';

class TransaksiListPage extends StatelessWidget {
  const TransaksiListPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        getIt<TransaksiListBloc>()..add(TransaksiMonthChanged(DateTime.now())),
    child: const _TransaksiListView(),
  );
}

class _TransaksiListView extends StatelessWidget {
  const _TransaksiListView();

  void _showNotice(BuildContext context, StatusChangeNotice notice) {
    final bloc = context.read<TransaksiListBloc>();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '${notice.count} transaksi diubah ke ${notice.status.label}',
          ),
          action: SnackBarAction(
            label: 'Urungkan',
            onPressed: () => bloc.add(TransaksiStatusUndone(notice)),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<TransaksiListBloc, TransaksiListState>(
        listenWhen: (a, b) => a.notice != b.notice && b.notice != null,
        listener: (context, state) => _showNotice(context, state.notice!),
        builder: (context, state) => PopScope(
          canPop: !state.selecting,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              context.read<TransaksiListBloc>().add(
                const TransaksiSelectionCleared(),
              );
            }
          },
          child: Scaffold(
            appBar: state.selecting
                ? _SelectionAppBar(count: state.selectedIds.length)
                : AppBar(title: const _MonthSelector()),
            body: _body(state),
          ),
        ),
      );

  Widget _body(TransaksiListState state) => Builder(
    builder: (context) => Column(
      children: [
        AkunFilterChips(
          akuns: state.akuns,
          selected: state.akunFilter,
          onSelected: (id) => context.read<TransaksiListBloc>().add(
            TransaksiAkunFilterChanged(id),
          ),
        ),
        StatusFilterChips(
          counts: state.statusCounts,
          selected: state.statusFilter,
          onSelected: (status) => context.read<TransaksiListBloc>().add(
            TransaksiStatusFilterChanged(status),
          ),
        ),
        Expanded(child: _content(state)),
      ],
    ),
  );

  Widget _content(TransaksiListState state) => Builder(
    builder: (context) => switch (state.status) {
      TransaksiListStatus.loading => const Center(
        child: CircularProgressIndicator(),
      ),
      TransaksiListStatus.failure => const Center(
        child: Text('Gagal memuat transaksi'),
      ),
      TransaksiListStatus.success =>
        state.transaksis.isEmpty
            ? _EmptyState(filtered: state.adaTransaksiBulanIni)
            : _GroupedList(
                transaksis: state.transaksis,
                selectedIds: state.selectedIds,
                namaAkun: state.akuns.length > 1 ? state.namaAkun : const {},
              ),
    },
  );
}

class _SelectionAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _SelectionAppBar({required this.count});

  final int count;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<TransaksiListBloc>();
    return AppBar(
      leading: IconButton(
        tooltip: 'Batal pilih',
        icon: const Icon(Icons.close),
        onPressed: () => bloc.add(const TransaksiSelectionCleared()),
      ),
      title: Text('$count dipilih'),
      actions: [
        IconButton(
          tooltip: 'Pilih semua',
          icon: const Icon(Icons.select_all),
          onPressed: () => bloc.add(const TransaksiSelectAllRequested()),
        ),
        PopupMenuButton<StatusBayar>(
          tooltip: 'Ubah status',
          icon: const Icon(Icons.published_with_changes),
          onSelected: (status) =>
              bloc.add(TransaksiSelectedStatusChanged(status)),
          itemBuilder: (_) => [
            for (final status in StatusBayar.values)
              PopupMenuItem(
                value: status,
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 12, color: status.color),
                    const SizedBox(width: 12),
                    Text(status.label),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _MonthSelector extends StatelessWidget {
  const _MonthSelector();

  @override
  Widget build(BuildContext context) => MonthSelector(
    month: context.select((TransaksiListBloc b) => b.state.month),
    onChanged: (month) =>
        context.read<TransaksiListBloc>().add(TransaksiMonthChanged(month)),
  );
}

class _GroupedList extends StatelessWidget {
  const _GroupedList({
    required this.transaksis,
    required this.selectedIds,
    required this.namaAkun,
  });

  final List<Transaksi> transaksis;
  final Set<int> selectedIds;
  final Map<int, String> namaAkun;

  @override
  Widget build(BuildContext context) {
    final rows = <Object>[];
    DateTime? lastDay;
    for (final t in transaksis) {
      final day = dateOnly(t.tanggal);
      if (day != lastDay) {
        rows.add(day);
        lastDay = day;
      }
      rows.add(t);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 96),
      itemCount: rows.length,
      itemBuilder: (context, i) {
        final row = rows[i];
        if (row is DateTime) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              formatDateHeader(row),
              style: Theme.of(context).textTheme.labelLarge,
            ),
          );
        }
        final t = row as Transaksi;
        final bloc = context.read<TransaksiListBloc>();
        final selecting = selectedIds.isNotEmpty;
        return TransaksiTile(
          transaksi: t,
          akunNama: namaAkun[t.akunId],
          selectionMode: selecting,
          selected: selectedIds.contains(t.id),
          onLongPress: () => bloc.add(TransaksiSelectionToggled(t.id)),
          onTap: selecting
              ? () => bloc.add(TransaksiSelectionToggled(t.id))
              : () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => TransaksiFormPage(initial: t),
                  ),
                ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filtered});

  final bool filtered;

  @override
  Widget build(BuildContext context) {
    if (!filtered) {
      return const Center(child: Text('Belum ada transaksi bulan ini'));
    }
    final bloc = context.read<TransaksiListBloc>();
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Tidak ada transaksi yang cocok dengan filter'),
          TextButton(
            onPressed: () => bloc
              ..add(const TransaksiAkunFilterChanged(null))
              ..add(const TransaksiStatusFilterChanged(null)),
            child: const Text('Hapus filter'),
          ),
        ],
      ),
    );
  }
}
