import 'package:flutter/material.dart';

import '../../../core/di/injection.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/akun.dart';
import '../../../domain/repositories/akun_repository.dart';
import 'akun_form_page.dart';

class AkunListPage extends StatelessWidget {
  const AkunListPage({super.key});

  void _open(BuildContext context, [Akun? akun]) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => AkunFormPage(initial: akun)));

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Kelola Akun'),
      actions: [
        IconButton(
          tooltip: 'Akun baru',
          icon: const Icon(Icons.add),
          onPressed: () => _open(context),
        ),
      ],
    ),
    body: StreamBuilder<List<Akun>>(
      stream: getIt<AkunRepository>().watchAll(),
      builder: (context, snapshot) {
        final akuns = snapshot.data;
        if (akuns == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            for (final a in akuns)
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  title: Text(a.nama),
                  subtitle: Text(
                    '${a.limitKredit > 0 ? 'Limit ${formatRupiah(a.limitKredit)}' : 'Limit belum diisi'}'
                    ' · ${a.tanggalCutoff > 0 ? 'tutup buku tgl ${a.tanggalCutoff}' : 'ikut bulan kalender'}'
                    '${a.tanggalJatuhTempo > 0 ? ' · jatuh tempo tgl ${a.tanggalJatuhTempo}' : ''}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _open(context, a),
                ),
              ),
          ],
        );
      },
    ),
  );
}
