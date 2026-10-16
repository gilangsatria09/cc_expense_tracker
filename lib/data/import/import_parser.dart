import 'dart:convert';

import '../../core/error/domain_exception.dart';
import '../../domain/entities/akun.dart';
import '../../domain/entities/cicilan.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/split_group_order.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/entities/transaksi.dart';

class ImportBundle {
  const ImportBundle({
    required this.akuns,
    required this.subscriptions,
    required this.cicilans,
    required this.transaksis,
    required this.transaksiSubscription,
  });

  final List<Akun> akuns;
  final List<Subscription> subscriptions;
  final List<Cicilan> cicilans;
  final List<Transaksi> transaksis;

  final Map<int, int> transaksiSubscription;
}

const supportedImportVersions = {1, 2};

const _namaAkunImplisit = 'Kartu Kredit';

ImportBundle parseImportJson(String source) {
  final Object? decoded;
  try {
    decoded = jsonDecode(source);
  } on FormatException {
    throw const DomainException('File bukan JSON yang valid');
  }
  if (decoded is! Map<String, dynamic>) {
    throw const DomainException('Format file tidak dikenal');
  }
  final version = decoded['version'];
  if (!supportedImportVersions.contains(version)) {
    throw DomainException(
      'Versi format $version tidak didukung '
      '(didukung: ${supportedImportVersions.join(', ')})',
    );
  }

  final akuns = <Akun>[];
  final akunIndexById = <int, int>{};
  if (version == 1) {
    final settings = _map(decoded['settings'], 'settings') ?? const {};
    akuns.add(
      Akun(
        nama: _namaAkunImplisit,
        limitKredit: _optInt(settings, 'limitCC', 'settings') ?? 0,
        saldoAwal:
            _optInt(settings, 'saldoOutstandingSebelumTracker', 'settings') ??
            0,
        tanggalCutoff:
            _optInt(settings, 'tanggalCutoffTagihan', 'settings') ?? 0,
      ),
    );
  } else {
    for (final (i, m) in _list(decoded['akuns'], 'akuns').indexed) {
      final where = 'Akun ke-${i + 1}';
      final id = _int(m, 'id', where);
      if (akunIndexById.containsKey(id)) {
        throw DomainException('$where: "id" $id kembar di file');
      }
      final cutoff = _optInt(m, 'tanggalCutoff', where) ?? 0;
      if (cutoff < 0 || cutoff > 31) {
        throw DomainException('$where: tanggalCutoff harus 0–31');
      }
      final jatuhTempo = _optInt(m, 'tanggalJatuhTempo', where) ?? 0;
      if (jatuhTempo < 0 || jatuhTempo > 31) {
        throw DomainException('$where: tanggalJatuhTempo harus 0–31');
      }
      akunIndexById[id] = i;
      akuns.add(
        Akun(
          nama: _string(m, 'nama', where),
          limitKredit: _optInt(m, 'limitKredit', where) ?? 0,
          saldoAwal: _optInt(m, 'saldoAwal', where) ?? 0,
          tanggalCutoff: cutoff,
          tanggalJatuhTempo: jatuhTempo,
        ),
      );
    }
    if (akuns.isEmpty) {
      throw const DomainException('Daftar "akuns" kosong; butuh minimal satu');
    }
  }

  int akunIndex(Map<String, dynamic> m, String where) {
    if (version == 1) return 0;
    final id = _int(m, 'akunId', where);
    return akunIndexById[id] ??
        (throw DomainException('$where: akunId $id tidak ada di daftar akuns'));
  }

  final subscriptions = <Subscription>[
    for (final (i, m) in _list(
      decoded['subscriptions'],
      'subscriptions',
    ).indexed)
      _subscription(
        m,
        'Subscription ke-${i + 1}',
        akunIndex(m, 'Subscription ke-${i + 1}'),
      ),
  ];

  final indexById = <int, int>{};
  final indicesByName = <String, List<int>>{};
  for (final (i, m) in _list(
    decoded['subscriptions'],
    'subscriptions',
  ).indexed) {
    final where = 'Subscription ke-${i + 1}';
    final id = _optInt(m, 'id', where);
    if (id != null && indexById.containsKey(id)) {
      throw DomainException('$where: "id" $id kembar di file');
    }
    if (id != null) indexById[id] = i;
    (indicesByName[subscriptions[i].namaLayanan] ??= []).add(i);
  }

  final transaksis = <Transaksi>[];
  final links = <int, int>{};
  for (final (i, m) in _list(decoded['transaksis'], 'transaksis').indexed) {
    final where = 'Transaksi ke-${i + 1}';
    transaksis.add(_transaksi(m, where, akunIndex(m, where)));

    final linkId = _optInt(m, 'subscriptionId', where);
    final linkName = _optString(m, 'subscription', where);
    if (linkId != null) {
      final index = indexById[linkId];
      if (index == null) {
        throw DomainException(
          '$where: subscriptionId $linkId tidak ada di daftar',
        );
      }
      links[i] = index;
    } else if (linkName != null) {
      final matches = indicesByName[linkName] ?? const [];
      if (matches.isEmpty) {
        throw DomainException(
          '$where: subscription "$linkName" tidak ada di daftar',
        );
      }
      if (matches.length > 1) {
        throw DomainException(
          '$where: nama subscription "$linkName" kembar; gunakan subscriptionId',
        );
      }
      links[i] = matches.single;
    }
  }

  return ImportBundle(
    akuns: akuns,
    subscriptions: subscriptions,
    cicilans: [
      for (final (i, m) in _list(decoded['cicilans'], 'cicilans').indexed)
        _cicilan(m, 'Cicilan ke-${i + 1}', akunIndex(m, 'Cicilan ke-${i + 1}')),
    ],
    transaksis: transaksis,
    transaksiSubscription: links,
  );
}

Transaksi _transaksi(Map<String, dynamic> raw, String where, int akunIndex) {
  final m = raw['jenis'] == 'pembayaranCC'
      ? {...raw, 'jenis': 'pembayaran'}
      : raw;
  final total = _int(m, 'totalTagihan', where);
  if (total < 0) throw DomainException('$where: totalTagihan negatif');
  final tanggal = _date(m, 'tanggal', where);
  return Transaksi(
    tanggal: tanggal,
    bulanTagihan: _month(m, 'bulanTagihan', where),
    deskripsi: _string(m, 'deskripsi', where),
    jenis: _enum(JenisTransaksi.values, m, 'jenis', where),
    akunId: akunIndex,
    totalTagihan: total,
    merchant: _optString(m, 'merchant', where),
    ongkirFee: _optInt(m, 'ongkirFee', where) ?? 0,
    status: _enum(StatusBayar.values, m, 'status', where),
    catatan: _optString(m, 'catatan', where),
    sumberEkstraksi: _optEnum(
      SumberEkstraksi.values,
      m,
      'sumberEkstraksi',
      where,
    ),
    splits: [
      for (final (i, s) in _list(m['splits'], '$where.splits').indexed)
        SplitGroupOrder(
          nama: _string(s, 'nama', '$where, split ke-${i + 1}'),
          hargaManual: _optInt(s, 'hargaManual', '$where, split ke-${i + 1}'),
          status: _enum(
            StatusBayar.values,
            s,
            'status',
            '$where, split ke-${i + 1}',
          ),
          catatan: _optString(s, 'catatan', '$where, split ke-${i + 1}'),
        ),
    ],
  );
}

Cicilan _cicilan(Map<String, dynamic> m, String where, int akunIndex) {
  final tenor = _int(m, 'tenor', where);
  final ke = _optInt(m, 'cicilanKe', where) ?? 0;
  if (tenor <= 0) throw DomainException('$where: tenor harus lebih dari 0');
  if (ke < 0 || ke > tenor) {
    throw DomainException('$where: cicilanKe di luar 0..tenor');
  }
  return Cicilan(
    namaCicilan: _string(m, 'namaCicilan', where),
    akunId: akunIndex,
    totalHargaBarang: _int(m, 'totalHargaBarang', where),
    tenor: tenor,
    cicilanKe: ke,
    jumlahPerBulan: _int(m, 'jumlahPerBulan', where),
    tanggalMulai: _date(m, 'tanggalMulai', where),
    tanggalBayarTerakhir: m['tanggalBayarTerakhir'] == null
        ? null
        : _date(m, 'tanggalBayarTerakhir', where),
    catatan: _optString(m, 'catatan', where),
  );
}

Subscription _subscription(
  Map<String, dynamic> m,
  String where,
  int akunIndex,
) => Subscription(
  namaLayanan: _string(m, 'namaLayanan', where),
  akunId: akunIndex,
  hargaTetap: _optInt(m, 'hargaTetap', where),
  siklusBilling: _enum(SiklusBilling.values, m, 'siklusBilling', where),
  tanggalTagihanBerikutnya: _date(m, 'tanggalTagihanBerikutnya', where),
  hariTagihan: _optInt(m, 'hariTagihan', where),
  status: _enum(StatusSubscription.values, m, 'status', where),
  catatan: _optString(m, 'catatan', where),
);

Map<String, dynamic>? _map(Object? v, String where) {
  if (v == null) return null;
  if (v is Map<String, dynamic>) return v;
  throw DomainException('$where: harus berupa objek');
}

List<Map<String, dynamic>> _list(Object? v, String where) {
  if (v == null) return const [];
  if (v is! List) throw DomainException('$where: harus berupa daftar');
  return [
    for (final (i, item) in v.indexed)
      item is Map<String, dynamic>
          ? item
          : throw DomainException('$where ke-${i + 1}: harus berupa objek'),
  ];
}

String _string(Map<String, dynamic> m, String key, String where) {
  final v = m[key];
  if (v is String && v.trim().isNotEmpty) return v.trim();
  throw DomainException('$where: "$key" wajib berupa teks tidak kosong');
}

String? _optString(Map<String, dynamic> m, String key, String where) {
  final v = m[key];
  if (v == null) return null;
  if (v is String) return v.trim().isEmpty ? null : v.trim();
  throw DomainException('$where: "$key" harus berupa teks');
}

int _int(Map<String, dynamic> m, String key, String where) =>
    _optInt(m, key, where) ??
    (throw DomainException('$where: "$key" wajib diisi'));

int? _optInt(Map<String, dynamic> m, String key, String where) {
  final v = m[key];
  if (v == null) return null;
  if (v is int) return v;
  if (v is double && v == v.roundToDouble()) return v.toInt();
  throw DomainException('$where: "$key" harus berupa bilangan bulat');
}

DateTime _date(Map<String, dynamic> m, String key, String where) {
  final v = m[key];
  final parsed = v is String ? DateTime.tryParse(v) : null;
  if (parsed == null) {
    throw DomainException('$where: "$key" harus berformat YYYY-MM-DD');
  }
  return DateTime(parsed.year, parsed.month, parsed.day);
}

DateTime? _month(Map<String, dynamic> m, String key, String where) {
  final v = m[key];
  if (v == null) return null;
  final match = v is String ? RegExp(r'^(\d{4})-(\d{2})$').firstMatch(v) : null;
  final month = match == null ? null : int.parse(match.group(2)!);
  if (match == null || month! < 1 || month > 12) {
    throw DomainException('$where: "$key" harus berformat YYYY-MM');
  }
  return DateTime(int.parse(match.group(1)!), month);
}

T _enum<T extends Enum>(
  List<T> values,
  Map<String, dynamic> m,
  String key,
  String where,
) =>
    _optEnum(values, m, key, where) ??
    (throw DomainException('$where: "$key" wajib diisi'));

T? _optEnum<T extends Enum>(
  List<T> values,
  Map<String, dynamic> m,
  String key,
  String where,
) {
  final v = m[key];
  if (v == null) return null;
  for (final e in values) {
    if (e.name == v) return e;
  }
  throw DomainException(
    '$where: "$key" berisi "$v"; nilai yang valid: '
    '${values.map((e) => e.name).join(', ')}',
  );
}
