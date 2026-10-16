import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/split_bill_cubit.dart';

class ParticipantInput extends StatefulWidget {
  const ParticipantInput({super.key});

  static const maxChips = 8;

  @override
  State<ParticipantInput> createState() => _ParticipantInputState();
}

class _ParticipantInputState extends State<ParticipantInput> {
  TextEditingController? _field;

  void _add(String name) {
    context.read<SplitBillCubit>().addName(name);
    _field?.clear();
  }

  Future<void> _openAll() {
    final cubit = context.read<SplitBillCubit>();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) =>
          BlocProvider.value(value: cubit, child: const _AllNamesSheet()),
    );
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<SplitBillCubit, SplitBillState>(
        buildWhen: (a, b) => a.rows != b.rows || a.knownNames != b.knownNames,
        builder: (context, state) {
          final suggestions = state.suggestions;
          final chips = suggestions.take(ParticipantInput.maxChips).toList();
          final rest = suggestions.length - chips.length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Autocomplete<String>(
                      optionsBuilder: (value) {
                        final q = value.text.trim().toLowerCase();
                        if (q.isEmpty) return const Iterable<String>.empty();
                        return suggestions.where(
                          (n) => n.toLowerCase().contains(q),
                        );
                      },
                      onSelected: _add,
                      fieldViewBuilder:
                          (context, controller, focusNode, onSubmitted) {
                            _field = controller;
                            return TextField(
                              controller: controller,
                              focusNode: focusNode,
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.done,
                              decoration: const InputDecoration(
                                labelText: 'Tambah peserta',
                              ),
                              onSubmitted: _add,
                            );
                          },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Tambah peserta',
                    icon: const Icon(Icons.add),
                    onPressed: () => _add(_field?.text ?? ''),
                  ),
                ],
              ),
              if (chips.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final n in chips)
                      ActionChip(
                        label: Text(n),
                        onPressed: () =>
                            context.read<SplitBillCubit>().addName(n),
                      ),
                    if (rest > 0)
                      ActionChip(
                        avatar: const Icon(Icons.search, size: 18),
                        label: Text('+$rest lainnya'),
                        onPressed: _openAll,
                      ),
                  ],
                ),
              ],
            ],
          );
        },
      );
}

class _AllNamesSheet extends StatefulWidget {
  const _AllNamesSheet();

  @override
  State<_AllNamesSheet> createState() => _AllNamesSheetState();
}

class _AllNamesSheetState extends State<_AllNamesSheet> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SplitBillCubit>();
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.75,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _search,
                decoration: const InputDecoration(
                  labelText: 'Cari nama',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Expanded(
              child: BlocBuilder<SplitBillCubit, SplitBillState>(
                builder: (context, state) {
                  final q = _query.trim();
                  final lower = q.toLowerCase();
                  final names = state.knownNames
                      .where(
                        (n) => lower.isEmpty || n.toLowerCase().contains(lower),
                      )
                      .toList();
                  final exists =
                      state.knownNames.any((n) => n.toLowerCase() == lower) ||
                      state.rows.any(
                        (r) => r.nama.trim().toLowerCase() == lower,
                      );

                  return ListView(
                    children: [
                      if (q.isNotEmpty && !exists)
                        ListTile(
                          leading: const Icon(Icons.person_add_outlined),
                          title: Text('Tambah "$q" sebagai peserta baru'),
                          onTap: () {
                            cubit.addName(q);
                            _search.clear();
                            setState(() => _query = '');
                          },
                        ),
                      if (names.isEmpty && q.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('Belum ada nama tersimpan'),
                        ),
                      for (final n in names)
                        CheckboxListTile(
                          value: _rowFor(state, n) != null,
                          title: Text(n),
                          onChanged: (checked) {
                            final row = _rowFor(state, n);
                            if (checked == true && row == null) {
                              cubit.addName(n);
                            } else if (checked != true && row != null) {
                              cubit.removeRow(row.id);
                            }
                          },
                        ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Selesai'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SplitRowDraft? _rowFor(SplitBillState state, String name) {
    for (final r in state.rows) {
      if (r.nama.trim().toLowerCase() == name.toLowerCase()) return r;
    }
    return null;
  }
}
