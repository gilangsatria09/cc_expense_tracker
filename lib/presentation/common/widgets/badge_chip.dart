import 'package:flutter/material.dart';

import '../../../domain/entities/enums.dart';

class BadgeChip extends StatelessWidget {
  const BadgeChip({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

extension JenisTransaksiUi on JenisTransaksi {
  String get label => switch (this) {
    JenisTransaksi.personal => 'Personal',
    JenisTransaksi.groupOrder => 'Group Order',
    JenisTransaksi.subscription => 'Subscription',
    JenisTransaksi.pembayaran => 'Pembayaran',
    JenisTransaksi.lainnya => 'Lainnya',
  };

  Color get color => switch (this) {
    JenisTransaksi.personal => Colors.indigo,
    JenisTransaksi.groupOrder => Colors.deepOrange,
    JenisTransaksi.subscription => Colors.purple,
    JenisTransaksi.pembayaran => Colors.green,
    JenisTransaksi.lainnya => Colors.blueGrey,
  };
}

extension StatusBayarUi on StatusBayar {
  String get label => switch (this) {
    StatusBayar.paid => 'Paid',
    StatusBayar.paidTemp => 'Paid Temp',
    StatusBayar.belumDibayar => 'Belum Dibayar',
  };

  Color get color => switch (this) {
    StatusBayar.paid => Colors.green,
    StatusBayar.paidTemp => Colors.orange,
    StatusBayar.belumDibayar => Colors.red,
  };
}

extension SiklusBillingUi on SiklusBilling {
  String get label => switch (this) {
    SiklusBilling.bulanan => 'Bulanan',
    SiklusBilling.tahunan => 'Tahunan',
  };
}

extension StatusSubscriptionUi on StatusSubscription {
  String get label => switch (this) {
    StatusSubscription.aktif => 'Aktif',
    StatusSubscription.nonaktif => 'Nonaktif',
    StatusSubscription.dibatalkan => 'Dibatalkan',
  };

  Color get color => switch (this) {
    StatusSubscription.aktif => Colors.green,
    StatusSubscription.nonaktif => Colors.blueGrey,
    StatusSubscription.dibatalkan => Colors.red,
  };
}
