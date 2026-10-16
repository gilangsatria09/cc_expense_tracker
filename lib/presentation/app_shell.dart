import 'package:flutter/material.dart';

import 'cicilan/pages/cicilan_list_page.dart';
import 'dashboard/pages/dashboard_page.dart';
import 'subscription/pages/subscription_list_page.dart';
import 'transaksi/pages/transaksi_form_page.dart';
import 'transaksi/pages/transaksi_list_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _tabs = [
    (icon: Icons.receipt_long_outlined, label: 'Transaksi'),
    (icon: Icons.credit_score_outlined, label: 'Cicilan'),
    (icon: Icons.autorenew, label: 'Subscription'),
    (icon: Icons.dashboard_outlined, label: 'Dashboard'),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(
      index: _index,
      children: const [
        TransaksiListPage(),
        CicilanListPage(),
        SubscriptionListPage(),
        DashboardPage(),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      tooltip: 'Tambah transaksi',
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const TransaksiFormPage()),
      ),
      child: const Icon(Icons.add),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    bottomNavigationBar: BottomAppBar(
      shape: const CircularNotchedRectangle(),
      child: Row(
        children: [
          _item(0),
          _item(1),
          const SizedBox(width: 64),
          _item(2),
          _item(3),
        ],
      ),
    ),
  );

  Widget _item(int i) {
    final tab = _tabs[i];
    final selected = _index == i;
    final color = selected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _index = i),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(tab.icon, color: color),
              Text(
                tab.label,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: color),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
