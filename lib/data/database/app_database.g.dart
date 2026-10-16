// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AkunsTable extends Akuns with TableInfo<$AkunsTable, AkunRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AkunsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _namaMeta = const VerificationMeta('nama');
  @override
  late final GeneratedColumn<String> nama = GeneratedColumn<String>(
    'nama',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _limitKreditMeta = const VerificationMeta(
    'limitKredit',
  );
  @override
  late final GeneratedColumn<int> limitKredit = GeneratedColumn<int>(
    'limit_kredit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _saldoAwalMeta = const VerificationMeta(
    'saldoAwal',
  );
  @override
  late final GeneratedColumn<int> saldoAwal = GeneratedColumn<int>(
    'saldo_awal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _tanggalCutoffMeta = const VerificationMeta(
    'tanggalCutoff',
  );
  @override
  late final GeneratedColumn<int> tanggalCutoff = GeneratedColumn<int>(
    'tanggal_cutoff',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _tanggalJatuhTempoMeta = const VerificationMeta(
    'tanggalJatuhTempo',
  );
  @override
  late final GeneratedColumn<int> tanggalJatuhTempo = GeneratedColumn<int>(
    'tanggal_jatuh_tempo',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nama,
    limitKredit,
    saldoAwal,
    tanggalCutoff,
    tanggalJatuhTempo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'akuns';
  @override
  VerificationContext validateIntegrity(
    Insertable<AkunRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nama')) {
      context.handle(
        _namaMeta,
        nama.isAcceptableOrUnknown(data['nama']!, _namaMeta),
      );
    } else if (isInserting) {
      context.missing(_namaMeta);
    }
    if (data.containsKey('limit_kredit')) {
      context.handle(
        _limitKreditMeta,
        limitKredit.isAcceptableOrUnknown(
          data['limit_kredit']!,
          _limitKreditMeta,
        ),
      );
    }
    if (data.containsKey('saldo_awal')) {
      context.handle(
        _saldoAwalMeta,
        saldoAwal.isAcceptableOrUnknown(data['saldo_awal']!, _saldoAwalMeta),
      );
    }
    if (data.containsKey('tanggal_cutoff')) {
      context.handle(
        _tanggalCutoffMeta,
        tanggalCutoff.isAcceptableOrUnknown(
          data['tanggal_cutoff']!,
          _tanggalCutoffMeta,
        ),
      );
    }
    if (data.containsKey('tanggal_jatuh_tempo')) {
      context.handle(
        _tanggalJatuhTempoMeta,
        tanggalJatuhTempo.isAcceptableOrUnknown(
          data['tanggal_jatuh_tempo']!,
          _tanggalJatuhTempoMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AkunRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AkunRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nama: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nama'],
      )!,
      limitKredit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}limit_kredit'],
      )!,
      saldoAwal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}saldo_awal'],
      )!,
      tanggalCutoff: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tanggal_cutoff'],
      )!,
      tanggalJatuhTempo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tanggal_jatuh_tempo'],
      )!,
    );
  }

  @override
  $AkunsTable createAlias(String alias) {
    return $AkunsTable(attachedDatabase, alias);
  }
}

class AkunRow extends DataClass implements Insertable<AkunRow> {
  final int id;
  final String nama;

  /// Limit kredit (Rp); 0 = belum diisi.
  final int limitKredit;

  /// Saldo outstanding sebelum tracker dipakai (Rp).
  final int saldoAwal;

  /// Tanggal statement akun ini tutup buku (1–31); 0 = ikut bulan kalender.
  final int tanggalCutoff;

  /// Tanggal tagihan harus dibayar tiap bulan (1–31); 0 = tanpa pengingat.
  final int tanggalJatuhTempo;
  const AkunRow({
    required this.id,
    required this.nama,
    required this.limitKredit,
    required this.saldoAwal,
    required this.tanggalCutoff,
    required this.tanggalJatuhTempo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nama'] = Variable<String>(nama);
    map['limit_kredit'] = Variable<int>(limitKredit);
    map['saldo_awal'] = Variable<int>(saldoAwal);
    map['tanggal_cutoff'] = Variable<int>(tanggalCutoff);
    map['tanggal_jatuh_tempo'] = Variable<int>(tanggalJatuhTempo);
    return map;
  }

  AkunsCompanion toCompanion(bool nullToAbsent) {
    return AkunsCompanion(
      id: Value(id),
      nama: Value(nama),
      limitKredit: Value(limitKredit),
      saldoAwal: Value(saldoAwal),
      tanggalCutoff: Value(tanggalCutoff),
      tanggalJatuhTempo: Value(tanggalJatuhTempo),
    );
  }

  factory AkunRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AkunRow(
      id: serializer.fromJson<int>(json['id']),
      nama: serializer.fromJson<String>(json['nama']),
      limitKredit: serializer.fromJson<int>(json['limitKredit']),
      saldoAwal: serializer.fromJson<int>(json['saldoAwal']),
      tanggalCutoff: serializer.fromJson<int>(json['tanggalCutoff']),
      tanggalJatuhTempo: serializer.fromJson<int>(json['tanggalJatuhTempo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nama': serializer.toJson<String>(nama),
      'limitKredit': serializer.toJson<int>(limitKredit),
      'saldoAwal': serializer.toJson<int>(saldoAwal),
      'tanggalCutoff': serializer.toJson<int>(tanggalCutoff),
      'tanggalJatuhTempo': serializer.toJson<int>(tanggalJatuhTempo),
    };
  }

  AkunRow copyWith({
    int? id,
    String? nama,
    int? limitKredit,
    int? saldoAwal,
    int? tanggalCutoff,
    int? tanggalJatuhTempo,
  }) => AkunRow(
    id: id ?? this.id,
    nama: nama ?? this.nama,
    limitKredit: limitKredit ?? this.limitKredit,
    saldoAwal: saldoAwal ?? this.saldoAwal,
    tanggalCutoff: tanggalCutoff ?? this.tanggalCutoff,
    tanggalJatuhTempo: tanggalJatuhTempo ?? this.tanggalJatuhTempo,
  );
  AkunRow copyWithCompanion(AkunsCompanion data) {
    return AkunRow(
      id: data.id.present ? data.id.value : this.id,
      nama: data.nama.present ? data.nama.value : this.nama,
      limitKredit: data.limitKredit.present
          ? data.limitKredit.value
          : this.limitKredit,
      saldoAwal: data.saldoAwal.present ? data.saldoAwal.value : this.saldoAwal,
      tanggalCutoff: data.tanggalCutoff.present
          ? data.tanggalCutoff.value
          : this.tanggalCutoff,
      tanggalJatuhTempo: data.tanggalJatuhTempo.present
          ? data.tanggalJatuhTempo.value
          : this.tanggalJatuhTempo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AkunRow(')
          ..write('id: $id, ')
          ..write('nama: $nama, ')
          ..write('limitKredit: $limitKredit, ')
          ..write('saldoAwal: $saldoAwal, ')
          ..write('tanggalCutoff: $tanggalCutoff, ')
          ..write('tanggalJatuhTempo: $tanggalJatuhTempo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nama,
    limitKredit,
    saldoAwal,
    tanggalCutoff,
    tanggalJatuhTempo,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AkunRow &&
          other.id == this.id &&
          other.nama == this.nama &&
          other.limitKredit == this.limitKredit &&
          other.saldoAwal == this.saldoAwal &&
          other.tanggalCutoff == this.tanggalCutoff &&
          other.tanggalJatuhTempo == this.tanggalJatuhTempo);
}

class AkunsCompanion extends UpdateCompanion<AkunRow> {
  final Value<int> id;
  final Value<String> nama;
  final Value<int> limitKredit;
  final Value<int> saldoAwal;
  final Value<int> tanggalCutoff;
  final Value<int> tanggalJatuhTempo;
  const AkunsCompanion({
    this.id = const Value.absent(),
    this.nama = const Value.absent(),
    this.limitKredit = const Value.absent(),
    this.saldoAwal = const Value.absent(),
    this.tanggalCutoff = const Value.absent(),
    this.tanggalJatuhTempo = const Value.absent(),
  });
  AkunsCompanion.insert({
    this.id = const Value.absent(),
    required String nama,
    this.limitKredit = const Value.absent(),
    this.saldoAwal = const Value.absent(),
    this.tanggalCutoff = const Value.absent(),
    this.tanggalJatuhTempo = const Value.absent(),
  }) : nama = Value(nama);
  static Insertable<AkunRow> custom({
    Expression<int>? id,
    Expression<String>? nama,
    Expression<int>? limitKredit,
    Expression<int>? saldoAwal,
    Expression<int>? tanggalCutoff,
    Expression<int>? tanggalJatuhTempo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nama != null) 'nama': nama,
      if (limitKredit != null) 'limit_kredit': limitKredit,
      if (saldoAwal != null) 'saldo_awal': saldoAwal,
      if (tanggalCutoff != null) 'tanggal_cutoff': tanggalCutoff,
      if (tanggalJatuhTempo != null) 'tanggal_jatuh_tempo': tanggalJatuhTempo,
    });
  }

  AkunsCompanion copyWith({
    Value<int>? id,
    Value<String>? nama,
    Value<int>? limitKredit,
    Value<int>? saldoAwal,
    Value<int>? tanggalCutoff,
    Value<int>? tanggalJatuhTempo,
  }) {
    return AkunsCompanion(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      limitKredit: limitKredit ?? this.limitKredit,
      saldoAwal: saldoAwal ?? this.saldoAwal,
      tanggalCutoff: tanggalCutoff ?? this.tanggalCutoff,
      tanggalJatuhTempo: tanggalJatuhTempo ?? this.tanggalJatuhTempo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nama.present) {
      map['nama'] = Variable<String>(nama.value);
    }
    if (limitKredit.present) {
      map['limit_kredit'] = Variable<int>(limitKredit.value);
    }
    if (saldoAwal.present) {
      map['saldo_awal'] = Variable<int>(saldoAwal.value);
    }
    if (tanggalCutoff.present) {
      map['tanggal_cutoff'] = Variable<int>(tanggalCutoff.value);
    }
    if (tanggalJatuhTempo.present) {
      map['tanggal_jatuh_tempo'] = Variable<int>(tanggalJatuhTempo.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AkunsCompanion(')
          ..write('id: $id, ')
          ..write('nama: $nama, ')
          ..write('limitKredit: $limitKredit, ')
          ..write('saldoAwal: $saldoAwal, ')
          ..write('tanggalCutoff: $tanggalCutoff, ')
          ..write('tanggalJatuhTempo: $tanggalJatuhTempo')
          ..write(')'))
        .toString();
  }
}

class $SubscriptionsTable extends Subscriptions
    with TableInfo<$SubscriptionsTable, SubscriptionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubscriptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _namaLayananMeta = const VerificationMeta(
    'namaLayanan',
  );
  @override
  late final GeneratedColumn<String> namaLayanan = GeneratedColumn<String>(
    'nama_layanan',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _akunIdMeta = const VerificationMeta('akunId');
  @override
  late final GeneratedColumn<int> akunId = GeneratedColumn<int>(
    'akun_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES akuns (id)',
    ),
  );
  static const VerificationMeta _hargaTetapMeta = const VerificationMeta(
    'hargaTetap',
  );
  @override
  late final GeneratedColumn<int> hargaTetap = GeneratedColumn<int>(
    'harga_tetap',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SiklusBilling, int>
  siklusBilling = GeneratedColumn<int>(
    'siklus_billing',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  ).withConverter<SiklusBilling>($SubscriptionsTable.$convertersiklusBilling);
  static const VerificationMeta _tanggalTagihanBerikutnyaMeta =
      const VerificationMeta('tanggalTagihanBerikutnya');
  @override
  late final GeneratedColumn<DateTime> tanggalTagihanBerikutnya =
      GeneratedColumn<DateTime>(
        'tanggal_tagihan_berikutnya',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _hariTagihanMeta = const VerificationMeta(
    'hariTagihan',
  );
  @override
  late final GeneratedColumn<int> hariTagihan = GeneratedColumn<int>(
    'hari_tagihan',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<StatusSubscription, int> status =
      GeneratedColumn<int>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<StatusSubscription>($SubscriptionsTable.$converterstatus);
  static const VerificationMeta _catatanMeta = const VerificationMeta(
    'catatan',
  );
  @override
  late final GeneratedColumn<String> catatan = GeneratedColumn<String>(
    'catatan',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    namaLayanan,
    akunId,
    hargaTetap,
    siklusBilling,
    tanggalTagihanBerikutnya,
    hariTagihan,
    status,
    catatan,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subscriptions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SubscriptionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nama_layanan')) {
      context.handle(
        _namaLayananMeta,
        namaLayanan.isAcceptableOrUnknown(
          data['nama_layanan']!,
          _namaLayananMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_namaLayananMeta);
    }
    if (data.containsKey('akun_id')) {
      context.handle(
        _akunIdMeta,
        akunId.isAcceptableOrUnknown(data['akun_id']!, _akunIdMeta),
      );
    } else if (isInserting) {
      context.missing(_akunIdMeta);
    }
    if (data.containsKey('harga_tetap')) {
      context.handle(
        _hargaTetapMeta,
        hargaTetap.isAcceptableOrUnknown(data['harga_tetap']!, _hargaTetapMeta),
      );
    }
    if (data.containsKey('tanggal_tagihan_berikutnya')) {
      context.handle(
        _tanggalTagihanBerikutnyaMeta,
        tanggalTagihanBerikutnya.isAcceptableOrUnknown(
          data['tanggal_tagihan_berikutnya']!,
          _tanggalTagihanBerikutnyaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tanggalTagihanBerikutnyaMeta);
    }
    if (data.containsKey('hari_tagihan')) {
      context.handle(
        _hariTagihanMeta,
        hariTagihan.isAcceptableOrUnknown(
          data['hari_tagihan']!,
          _hariTagihanMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_hariTagihanMeta);
    }
    if (data.containsKey('catatan')) {
      context.handle(
        _catatanMeta,
        catatan.isAcceptableOrUnknown(data['catatan']!, _catatanMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SubscriptionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubscriptionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      namaLayanan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nama_layanan'],
      )!,
      akunId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}akun_id'],
      )!,
      hargaTetap: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}harga_tetap'],
      ),
      siklusBilling: $SubscriptionsTable.$convertersiklusBilling.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}siklus_billing'],
        )!,
      ),
      tanggalTagihanBerikutnya: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}tanggal_tagihan_berikutnya'],
      )!,
      hariTagihan: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hari_tagihan'],
      )!,
      status: $SubscriptionsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}status'],
        )!,
      ),
      catatan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catatan'],
      ),
    );
  }

  @override
  $SubscriptionsTable createAlias(String alias) {
    return $SubscriptionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SiklusBilling, int, int> $convertersiklusBilling =
      const EnumIndexConverter<SiklusBilling>(SiklusBilling.values);
  static JsonTypeConverter2<StatusSubscription, int, int> $converterstatus =
      const EnumIndexConverter<StatusSubscription>(StatusSubscription.values);
}

class SubscriptionRow extends DataClass implements Insertable<SubscriptionRow> {
  final int id;
  final String namaLayanan;

  /// Akun yang ditagih saat tagihan dibuat otomatis.
  final int akunId;

  /// Null = harga variable, tidak di-auto-generate.
  final int? hargaTetap;
  final SiklusBilling siklusBilling;
  final DateTime tanggalTagihanBerikutnya;

  /// Hari jangkar (1–31) untuk menghitung tanggal tagihan berikutnya.
  final int hariTagihan;
  final StatusSubscription status;
  final String? catatan;
  const SubscriptionRow({
    required this.id,
    required this.namaLayanan,
    required this.akunId,
    this.hargaTetap,
    required this.siklusBilling,
    required this.tanggalTagihanBerikutnya,
    required this.hariTagihan,
    required this.status,
    this.catatan,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nama_layanan'] = Variable<String>(namaLayanan);
    map['akun_id'] = Variable<int>(akunId);
    if (!nullToAbsent || hargaTetap != null) {
      map['harga_tetap'] = Variable<int>(hargaTetap);
    }
    {
      map['siklus_billing'] = Variable<int>(
        $SubscriptionsTable.$convertersiklusBilling.toSql(siklusBilling),
      );
    }
    map['tanggal_tagihan_berikutnya'] = Variable<DateTime>(
      tanggalTagihanBerikutnya,
    );
    map['hari_tagihan'] = Variable<int>(hariTagihan);
    {
      map['status'] = Variable<int>(
        $SubscriptionsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || catatan != null) {
      map['catatan'] = Variable<String>(catatan);
    }
    return map;
  }

  SubscriptionsCompanion toCompanion(bool nullToAbsent) {
    return SubscriptionsCompanion(
      id: Value(id),
      namaLayanan: Value(namaLayanan),
      akunId: Value(akunId),
      hargaTetap: hargaTetap == null && nullToAbsent
          ? const Value.absent()
          : Value(hargaTetap),
      siklusBilling: Value(siklusBilling),
      tanggalTagihanBerikutnya: Value(tanggalTagihanBerikutnya),
      hariTagihan: Value(hariTagihan),
      status: Value(status),
      catatan: catatan == null && nullToAbsent
          ? const Value.absent()
          : Value(catatan),
    );
  }

  factory SubscriptionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubscriptionRow(
      id: serializer.fromJson<int>(json['id']),
      namaLayanan: serializer.fromJson<String>(json['namaLayanan']),
      akunId: serializer.fromJson<int>(json['akunId']),
      hargaTetap: serializer.fromJson<int?>(json['hargaTetap']),
      siklusBilling: $SubscriptionsTable.$convertersiklusBilling.fromJson(
        serializer.fromJson<int>(json['siklusBilling']),
      ),
      tanggalTagihanBerikutnya: serializer.fromJson<DateTime>(
        json['tanggalTagihanBerikutnya'],
      ),
      hariTagihan: serializer.fromJson<int>(json['hariTagihan']),
      status: $SubscriptionsTable.$converterstatus.fromJson(
        serializer.fromJson<int>(json['status']),
      ),
      catatan: serializer.fromJson<String?>(json['catatan']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'namaLayanan': serializer.toJson<String>(namaLayanan),
      'akunId': serializer.toJson<int>(akunId),
      'hargaTetap': serializer.toJson<int?>(hargaTetap),
      'siklusBilling': serializer.toJson<int>(
        $SubscriptionsTable.$convertersiklusBilling.toJson(siklusBilling),
      ),
      'tanggalTagihanBerikutnya': serializer.toJson<DateTime>(
        tanggalTagihanBerikutnya,
      ),
      'hariTagihan': serializer.toJson<int>(hariTagihan),
      'status': serializer.toJson<int>(
        $SubscriptionsTable.$converterstatus.toJson(status),
      ),
      'catatan': serializer.toJson<String?>(catatan),
    };
  }

  SubscriptionRow copyWith({
    int? id,
    String? namaLayanan,
    int? akunId,
    Value<int?> hargaTetap = const Value.absent(),
    SiklusBilling? siklusBilling,
    DateTime? tanggalTagihanBerikutnya,
    int? hariTagihan,
    StatusSubscription? status,
    Value<String?> catatan = const Value.absent(),
  }) => SubscriptionRow(
    id: id ?? this.id,
    namaLayanan: namaLayanan ?? this.namaLayanan,
    akunId: akunId ?? this.akunId,
    hargaTetap: hargaTetap.present ? hargaTetap.value : this.hargaTetap,
    siklusBilling: siklusBilling ?? this.siklusBilling,
    tanggalTagihanBerikutnya:
        tanggalTagihanBerikutnya ?? this.tanggalTagihanBerikutnya,
    hariTagihan: hariTagihan ?? this.hariTagihan,
    status: status ?? this.status,
    catatan: catatan.present ? catatan.value : this.catatan,
  );
  SubscriptionRow copyWithCompanion(SubscriptionsCompanion data) {
    return SubscriptionRow(
      id: data.id.present ? data.id.value : this.id,
      namaLayanan: data.namaLayanan.present
          ? data.namaLayanan.value
          : this.namaLayanan,
      akunId: data.akunId.present ? data.akunId.value : this.akunId,
      hargaTetap: data.hargaTetap.present
          ? data.hargaTetap.value
          : this.hargaTetap,
      siklusBilling: data.siklusBilling.present
          ? data.siklusBilling.value
          : this.siklusBilling,
      tanggalTagihanBerikutnya: data.tanggalTagihanBerikutnya.present
          ? data.tanggalTagihanBerikutnya.value
          : this.tanggalTagihanBerikutnya,
      hariTagihan: data.hariTagihan.present
          ? data.hariTagihan.value
          : this.hariTagihan,
      status: data.status.present ? data.status.value : this.status,
      catatan: data.catatan.present ? data.catatan.value : this.catatan,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubscriptionRow(')
          ..write('id: $id, ')
          ..write('namaLayanan: $namaLayanan, ')
          ..write('akunId: $akunId, ')
          ..write('hargaTetap: $hargaTetap, ')
          ..write('siklusBilling: $siklusBilling, ')
          ..write('tanggalTagihanBerikutnya: $tanggalTagihanBerikutnya, ')
          ..write('hariTagihan: $hariTagihan, ')
          ..write('status: $status, ')
          ..write('catatan: $catatan')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    namaLayanan,
    akunId,
    hargaTetap,
    siklusBilling,
    tanggalTagihanBerikutnya,
    hariTagihan,
    status,
    catatan,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubscriptionRow &&
          other.id == this.id &&
          other.namaLayanan == this.namaLayanan &&
          other.akunId == this.akunId &&
          other.hargaTetap == this.hargaTetap &&
          other.siklusBilling == this.siklusBilling &&
          other.tanggalTagihanBerikutnya == this.tanggalTagihanBerikutnya &&
          other.hariTagihan == this.hariTagihan &&
          other.status == this.status &&
          other.catatan == this.catatan);
}

class SubscriptionsCompanion extends UpdateCompanion<SubscriptionRow> {
  final Value<int> id;
  final Value<String> namaLayanan;
  final Value<int> akunId;
  final Value<int?> hargaTetap;
  final Value<SiklusBilling> siklusBilling;
  final Value<DateTime> tanggalTagihanBerikutnya;
  final Value<int> hariTagihan;
  final Value<StatusSubscription> status;
  final Value<String?> catatan;
  const SubscriptionsCompanion({
    this.id = const Value.absent(),
    this.namaLayanan = const Value.absent(),
    this.akunId = const Value.absent(),
    this.hargaTetap = const Value.absent(),
    this.siklusBilling = const Value.absent(),
    this.tanggalTagihanBerikutnya = const Value.absent(),
    this.hariTagihan = const Value.absent(),
    this.status = const Value.absent(),
    this.catatan = const Value.absent(),
  });
  SubscriptionsCompanion.insert({
    this.id = const Value.absent(),
    required String namaLayanan,
    required int akunId,
    this.hargaTetap = const Value.absent(),
    required SiklusBilling siklusBilling,
    required DateTime tanggalTagihanBerikutnya,
    required int hariTagihan,
    required StatusSubscription status,
    this.catatan = const Value.absent(),
  }) : namaLayanan = Value(namaLayanan),
       akunId = Value(akunId),
       siklusBilling = Value(siklusBilling),
       tanggalTagihanBerikutnya = Value(tanggalTagihanBerikutnya),
       hariTagihan = Value(hariTagihan),
       status = Value(status);
  static Insertable<SubscriptionRow> custom({
    Expression<int>? id,
    Expression<String>? namaLayanan,
    Expression<int>? akunId,
    Expression<int>? hargaTetap,
    Expression<int>? siklusBilling,
    Expression<DateTime>? tanggalTagihanBerikutnya,
    Expression<int>? hariTagihan,
    Expression<int>? status,
    Expression<String>? catatan,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (namaLayanan != null) 'nama_layanan': namaLayanan,
      if (akunId != null) 'akun_id': akunId,
      if (hargaTetap != null) 'harga_tetap': hargaTetap,
      if (siklusBilling != null) 'siklus_billing': siklusBilling,
      if (tanggalTagihanBerikutnya != null)
        'tanggal_tagihan_berikutnya': tanggalTagihanBerikutnya,
      if (hariTagihan != null) 'hari_tagihan': hariTagihan,
      if (status != null) 'status': status,
      if (catatan != null) 'catatan': catatan,
    });
  }

  SubscriptionsCompanion copyWith({
    Value<int>? id,
    Value<String>? namaLayanan,
    Value<int>? akunId,
    Value<int?>? hargaTetap,
    Value<SiklusBilling>? siklusBilling,
    Value<DateTime>? tanggalTagihanBerikutnya,
    Value<int>? hariTagihan,
    Value<StatusSubscription>? status,
    Value<String?>? catatan,
  }) {
    return SubscriptionsCompanion(
      id: id ?? this.id,
      namaLayanan: namaLayanan ?? this.namaLayanan,
      akunId: akunId ?? this.akunId,
      hargaTetap: hargaTetap ?? this.hargaTetap,
      siklusBilling: siklusBilling ?? this.siklusBilling,
      tanggalTagihanBerikutnya:
          tanggalTagihanBerikutnya ?? this.tanggalTagihanBerikutnya,
      hariTagihan: hariTagihan ?? this.hariTagihan,
      status: status ?? this.status,
      catatan: catatan ?? this.catatan,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (namaLayanan.present) {
      map['nama_layanan'] = Variable<String>(namaLayanan.value);
    }
    if (akunId.present) {
      map['akun_id'] = Variable<int>(akunId.value);
    }
    if (hargaTetap.present) {
      map['harga_tetap'] = Variable<int>(hargaTetap.value);
    }
    if (siklusBilling.present) {
      map['siklus_billing'] = Variable<int>(
        $SubscriptionsTable.$convertersiklusBilling.toSql(siklusBilling.value),
      );
    }
    if (tanggalTagihanBerikutnya.present) {
      map['tanggal_tagihan_berikutnya'] = Variable<DateTime>(
        tanggalTagihanBerikutnya.value,
      );
    }
    if (hariTagihan.present) {
      map['hari_tagihan'] = Variable<int>(hariTagihan.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(
        $SubscriptionsTable.$converterstatus.toSql(status.value),
      );
    }
    if (catatan.present) {
      map['catatan'] = Variable<String>(catatan.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubscriptionsCompanion(')
          ..write('id: $id, ')
          ..write('namaLayanan: $namaLayanan, ')
          ..write('akunId: $akunId, ')
          ..write('hargaTetap: $hargaTetap, ')
          ..write('siklusBilling: $siklusBilling, ')
          ..write('tanggalTagihanBerikutnya: $tanggalTagihanBerikutnya, ')
          ..write('hariTagihan: $hariTagihan, ')
          ..write('status: $status, ')
          ..write('catatan: $catatan')
          ..write(')'))
        .toString();
  }
}

class $TransaksisTable extends Transaksis
    with TableInfo<$TransaksisTable, TransaksiRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransaksisTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _tanggalMeta = const VerificationMeta(
    'tanggal',
  );
  @override
  late final GeneratedColumn<DateTime> tanggal = GeneratedColumn<DateTime>(
    'tanggal',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bulanTagihanMeta = const VerificationMeta(
    'bulanTagihan',
  );
  @override
  late final GeneratedColumn<DateTime> bulanTagihan = GeneratedColumn<DateTime>(
    'bulan_tagihan',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deskripsiMeta = const VerificationMeta(
    'deskripsi',
  );
  @override
  late final GeneratedColumn<String> deskripsi = GeneratedColumn<String>(
    'deskripsi',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<JenisTransaksi, int> jenis =
      GeneratedColumn<int>(
        'jenis',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<JenisTransaksi>($TransaksisTable.$converterjenis);
  static const VerificationMeta _akunIdMeta = const VerificationMeta('akunId');
  @override
  late final GeneratedColumn<int> akunId = GeneratedColumn<int>(
    'akun_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES akuns (id)',
    ),
  );
  static const VerificationMeta _totalTagihanMeta = const VerificationMeta(
    'totalTagihan',
  );
  @override
  late final GeneratedColumn<int> totalTagihan = GeneratedColumn<int>(
    'total_tagihan',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _merchantMeta = const VerificationMeta(
    'merchant',
  );
  @override
  late final GeneratedColumn<String> merchant = GeneratedColumn<String>(
    'merchant',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ongkirFeeMeta = const VerificationMeta(
    'ongkirFee',
  );
  @override
  late final GeneratedColumn<int> ongkirFee = GeneratedColumn<int>(
    'ongkir_fee',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<StatusBayar, int> status =
      GeneratedColumn<int>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<StatusBayar>($TransaksisTable.$converterstatus);
  static const VerificationMeta _catatanMeta = const VerificationMeta(
    'catatan',
  );
  @override
  late final GeneratedColumn<String> catatan = GeneratedColumn<String>(
    'catatan',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subscriptionIdMeta = const VerificationMeta(
    'subscriptionId',
  );
  @override
  late final GeneratedColumn<int> subscriptionId = GeneratedColumn<int>(
    'subscription_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES subscriptions (id) ON DELETE SET NULL',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<SumberEkstraksi?, int>
  sumberEkstraksi =
      GeneratedColumn<int>(
        'sumber_ekstraksi',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<SumberEkstraksi?>(
        $TransaksisTable.$convertersumberEkstraksin,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tanggal,
    bulanTagihan,
    deskripsi,
    jenis,
    akunId,
    totalTagihan,
    merchant,
    ongkirFee,
    status,
    catatan,
    subscriptionId,
    sumberEkstraksi,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaksis';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransaksiRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tanggal')) {
      context.handle(
        _tanggalMeta,
        tanggal.isAcceptableOrUnknown(data['tanggal']!, _tanggalMeta),
      );
    } else if (isInserting) {
      context.missing(_tanggalMeta);
    }
    if (data.containsKey('bulan_tagihan')) {
      context.handle(
        _bulanTagihanMeta,
        bulanTagihan.isAcceptableOrUnknown(
          data['bulan_tagihan']!,
          _bulanTagihanMeta,
        ),
      );
    }
    if (data.containsKey('deskripsi')) {
      context.handle(
        _deskripsiMeta,
        deskripsi.isAcceptableOrUnknown(data['deskripsi']!, _deskripsiMeta),
      );
    } else if (isInserting) {
      context.missing(_deskripsiMeta);
    }
    if (data.containsKey('akun_id')) {
      context.handle(
        _akunIdMeta,
        akunId.isAcceptableOrUnknown(data['akun_id']!, _akunIdMeta),
      );
    } else if (isInserting) {
      context.missing(_akunIdMeta);
    }
    if (data.containsKey('total_tagihan')) {
      context.handle(
        _totalTagihanMeta,
        totalTagihan.isAcceptableOrUnknown(
          data['total_tagihan']!,
          _totalTagihanMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalTagihanMeta);
    }
    if (data.containsKey('merchant')) {
      context.handle(
        _merchantMeta,
        merchant.isAcceptableOrUnknown(data['merchant']!, _merchantMeta),
      );
    }
    if (data.containsKey('ongkir_fee')) {
      context.handle(
        _ongkirFeeMeta,
        ongkirFee.isAcceptableOrUnknown(data['ongkir_fee']!, _ongkirFeeMeta),
      );
    }
    if (data.containsKey('catatan')) {
      context.handle(
        _catatanMeta,
        catatan.isAcceptableOrUnknown(data['catatan']!, _catatanMeta),
      );
    }
    if (data.containsKey('subscription_id')) {
      context.handle(
        _subscriptionIdMeta,
        subscriptionId.isAcceptableOrUnknown(
          data['subscription_id']!,
          _subscriptionIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransaksiRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransaksiRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tanggal: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}tanggal'],
      )!,
      bulanTagihan: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}bulan_tagihan'],
      ),
      deskripsi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deskripsi'],
      )!,
      jenis: $TransaksisTable.$converterjenis.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}jenis'],
        )!,
      ),
      akunId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}akun_id'],
      )!,
      totalTagihan: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_tagihan'],
      )!,
      merchant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}merchant'],
      ),
      ongkirFee: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ongkir_fee'],
      )!,
      status: $TransaksisTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}status'],
        )!,
      ),
      catatan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catatan'],
      ),
      subscriptionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}subscription_id'],
      ),
      sumberEkstraksi: $TransaksisTable.$convertersumberEkstraksin.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sumber_ekstraksi'],
        ),
      ),
    );
  }

  @override
  $TransaksisTable createAlias(String alias) {
    return $TransaksisTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<JenisTransaksi, int, int> $converterjenis =
      const EnumIndexConverter<JenisTransaksi>(JenisTransaksi.values);
  static JsonTypeConverter2<StatusBayar, int, int> $converterstatus =
      const EnumIndexConverter<StatusBayar>(StatusBayar.values);
  static JsonTypeConverter2<SumberEkstraksi, int, int>
  $convertersumberEkstraksi = const EnumIndexConverter<SumberEkstraksi>(
    SumberEkstraksi.values,
  );
  static JsonTypeConverter2<SumberEkstraksi?, int?, int?>
  $convertersumberEkstraksin = JsonTypeConverter2.asNullable(
    $convertersumberEkstraksi,
  );
}

class TransaksiRow extends DataClass implements Insertable<TransaksiRow> {
  final int id;
  final DateTime tanggal;

  /// Bulan tagihan akun (tanggal 1). Nullable hanya karena kolom ini ditambah
  /// di skema v2; baris baru selalu terisi.
  final DateTime? bulanTagihan;
  final String deskripsi;
  final JenisTransaksi jenis;

  /// Akun kredit yang ditagih (atau yang dibayar, untuk jenis Pembayaran).
  final int akunId;
  final int totalTagihan;
  final String? merchant;
  final int ongkirFee;
  final StatusBayar status;
  final String? catatan;
  final int? subscriptionId;
  final SumberEkstraksi? sumberEkstraksi;
  const TransaksiRow({
    required this.id,
    required this.tanggal,
    this.bulanTagihan,
    required this.deskripsi,
    required this.jenis,
    required this.akunId,
    required this.totalTagihan,
    this.merchant,
    required this.ongkirFee,
    required this.status,
    this.catatan,
    this.subscriptionId,
    this.sumberEkstraksi,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['tanggal'] = Variable<DateTime>(tanggal);
    if (!nullToAbsent || bulanTagihan != null) {
      map['bulan_tagihan'] = Variable<DateTime>(bulanTagihan);
    }
    map['deskripsi'] = Variable<String>(deskripsi);
    {
      map['jenis'] = Variable<int>(
        $TransaksisTable.$converterjenis.toSql(jenis),
      );
    }
    map['akun_id'] = Variable<int>(akunId);
    map['total_tagihan'] = Variable<int>(totalTagihan);
    if (!nullToAbsent || merchant != null) {
      map['merchant'] = Variable<String>(merchant);
    }
    map['ongkir_fee'] = Variable<int>(ongkirFee);
    {
      map['status'] = Variable<int>(
        $TransaksisTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || catatan != null) {
      map['catatan'] = Variable<String>(catatan);
    }
    if (!nullToAbsent || subscriptionId != null) {
      map['subscription_id'] = Variable<int>(subscriptionId);
    }
    if (!nullToAbsent || sumberEkstraksi != null) {
      map['sumber_ekstraksi'] = Variable<int>(
        $TransaksisTable.$convertersumberEkstraksin.toSql(sumberEkstraksi),
      );
    }
    return map;
  }

  TransaksisCompanion toCompanion(bool nullToAbsent) {
    return TransaksisCompanion(
      id: Value(id),
      tanggal: Value(tanggal),
      bulanTagihan: bulanTagihan == null && nullToAbsent
          ? const Value.absent()
          : Value(bulanTagihan),
      deskripsi: Value(deskripsi),
      jenis: Value(jenis),
      akunId: Value(akunId),
      totalTagihan: Value(totalTagihan),
      merchant: merchant == null && nullToAbsent
          ? const Value.absent()
          : Value(merchant),
      ongkirFee: Value(ongkirFee),
      status: Value(status),
      catatan: catatan == null && nullToAbsent
          ? const Value.absent()
          : Value(catatan),
      subscriptionId: subscriptionId == null && nullToAbsent
          ? const Value.absent()
          : Value(subscriptionId),
      sumberEkstraksi: sumberEkstraksi == null && nullToAbsent
          ? const Value.absent()
          : Value(sumberEkstraksi),
    );
  }

  factory TransaksiRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransaksiRow(
      id: serializer.fromJson<int>(json['id']),
      tanggal: serializer.fromJson<DateTime>(json['tanggal']),
      bulanTagihan: serializer.fromJson<DateTime?>(json['bulanTagihan']),
      deskripsi: serializer.fromJson<String>(json['deskripsi']),
      jenis: $TransaksisTable.$converterjenis.fromJson(
        serializer.fromJson<int>(json['jenis']),
      ),
      akunId: serializer.fromJson<int>(json['akunId']),
      totalTagihan: serializer.fromJson<int>(json['totalTagihan']),
      merchant: serializer.fromJson<String?>(json['merchant']),
      ongkirFee: serializer.fromJson<int>(json['ongkirFee']),
      status: $TransaksisTable.$converterstatus.fromJson(
        serializer.fromJson<int>(json['status']),
      ),
      catatan: serializer.fromJson<String?>(json['catatan']),
      subscriptionId: serializer.fromJson<int?>(json['subscriptionId']),
      sumberEkstraksi: $TransaksisTable.$convertersumberEkstraksin.fromJson(
        serializer.fromJson<int?>(json['sumberEkstraksi']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tanggal': serializer.toJson<DateTime>(tanggal),
      'bulanTagihan': serializer.toJson<DateTime?>(bulanTagihan),
      'deskripsi': serializer.toJson<String>(deskripsi),
      'jenis': serializer.toJson<int>(
        $TransaksisTable.$converterjenis.toJson(jenis),
      ),
      'akunId': serializer.toJson<int>(akunId),
      'totalTagihan': serializer.toJson<int>(totalTagihan),
      'merchant': serializer.toJson<String?>(merchant),
      'ongkirFee': serializer.toJson<int>(ongkirFee),
      'status': serializer.toJson<int>(
        $TransaksisTable.$converterstatus.toJson(status),
      ),
      'catatan': serializer.toJson<String?>(catatan),
      'subscriptionId': serializer.toJson<int?>(subscriptionId),
      'sumberEkstraksi': serializer.toJson<int?>(
        $TransaksisTable.$convertersumberEkstraksin.toJson(sumberEkstraksi),
      ),
    };
  }

  TransaksiRow copyWith({
    int? id,
    DateTime? tanggal,
    Value<DateTime?> bulanTagihan = const Value.absent(),
    String? deskripsi,
    JenisTransaksi? jenis,
    int? akunId,
    int? totalTagihan,
    Value<String?> merchant = const Value.absent(),
    int? ongkirFee,
    StatusBayar? status,
    Value<String?> catatan = const Value.absent(),
    Value<int?> subscriptionId = const Value.absent(),
    Value<SumberEkstraksi?> sumberEkstraksi = const Value.absent(),
  }) => TransaksiRow(
    id: id ?? this.id,
    tanggal: tanggal ?? this.tanggal,
    bulanTagihan: bulanTagihan.present ? bulanTagihan.value : this.bulanTagihan,
    deskripsi: deskripsi ?? this.deskripsi,
    jenis: jenis ?? this.jenis,
    akunId: akunId ?? this.akunId,
    totalTagihan: totalTagihan ?? this.totalTagihan,
    merchant: merchant.present ? merchant.value : this.merchant,
    ongkirFee: ongkirFee ?? this.ongkirFee,
    status: status ?? this.status,
    catatan: catatan.present ? catatan.value : this.catatan,
    subscriptionId: subscriptionId.present
        ? subscriptionId.value
        : this.subscriptionId,
    sumberEkstraksi: sumberEkstraksi.present
        ? sumberEkstraksi.value
        : this.sumberEkstraksi,
  );
  TransaksiRow copyWithCompanion(TransaksisCompanion data) {
    return TransaksiRow(
      id: data.id.present ? data.id.value : this.id,
      tanggal: data.tanggal.present ? data.tanggal.value : this.tanggal,
      bulanTagihan: data.bulanTagihan.present
          ? data.bulanTagihan.value
          : this.bulanTagihan,
      deskripsi: data.deskripsi.present ? data.deskripsi.value : this.deskripsi,
      jenis: data.jenis.present ? data.jenis.value : this.jenis,
      akunId: data.akunId.present ? data.akunId.value : this.akunId,
      totalTagihan: data.totalTagihan.present
          ? data.totalTagihan.value
          : this.totalTagihan,
      merchant: data.merchant.present ? data.merchant.value : this.merchant,
      ongkirFee: data.ongkirFee.present ? data.ongkirFee.value : this.ongkirFee,
      status: data.status.present ? data.status.value : this.status,
      catatan: data.catatan.present ? data.catatan.value : this.catatan,
      subscriptionId: data.subscriptionId.present
          ? data.subscriptionId.value
          : this.subscriptionId,
      sumberEkstraksi: data.sumberEkstraksi.present
          ? data.sumberEkstraksi.value
          : this.sumberEkstraksi,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransaksiRow(')
          ..write('id: $id, ')
          ..write('tanggal: $tanggal, ')
          ..write('bulanTagihan: $bulanTagihan, ')
          ..write('deskripsi: $deskripsi, ')
          ..write('jenis: $jenis, ')
          ..write('akunId: $akunId, ')
          ..write('totalTagihan: $totalTagihan, ')
          ..write('merchant: $merchant, ')
          ..write('ongkirFee: $ongkirFee, ')
          ..write('status: $status, ')
          ..write('catatan: $catatan, ')
          ..write('subscriptionId: $subscriptionId, ')
          ..write('sumberEkstraksi: $sumberEkstraksi')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tanggal,
    bulanTagihan,
    deskripsi,
    jenis,
    akunId,
    totalTagihan,
    merchant,
    ongkirFee,
    status,
    catatan,
    subscriptionId,
    sumberEkstraksi,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransaksiRow &&
          other.id == this.id &&
          other.tanggal == this.tanggal &&
          other.bulanTagihan == this.bulanTagihan &&
          other.deskripsi == this.deskripsi &&
          other.jenis == this.jenis &&
          other.akunId == this.akunId &&
          other.totalTagihan == this.totalTagihan &&
          other.merchant == this.merchant &&
          other.ongkirFee == this.ongkirFee &&
          other.status == this.status &&
          other.catatan == this.catatan &&
          other.subscriptionId == this.subscriptionId &&
          other.sumberEkstraksi == this.sumberEkstraksi);
}

class TransaksisCompanion extends UpdateCompanion<TransaksiRow> {
  final Value<int> id;
  final Value<DateTime> tanggal;
  final Value<DateTime?> bulanTagihan;
  final Value<String> deskripsi;
  final Value<JenisTransaksi> jenis;
  final Value<int> akunId;
  final Value<int> totalTagihan;
  final Value<String?> merchant;
  final Value<int> ongkirFee;
  final Value<StatusBayar> status;
  final Value<String?> catatan;
  final Value<int?> subscriptionId;
  final Value<SumberEkstraksi?> sumberEkstraksi;
  const TransaksisCompanion({
    this.id = const Value.absent(),
    this.tanggal = const Value.absent(),
    this.bulanTagihan = const Value.absent(),
    this.deskripsi = const Value.absent(),
    this.jenis = const Value.absent(),
    this.akunId = const Value.absent(),
    this.totalTagihan = const Value.absent(),
    this.merchant = const Value.absent(),
    this.ongkirFee = const Value.absent(),
    this.status = const Value.absent(),
    this.catatan = const Value.absent(),
    this.subscriptionId = const Value.absent(),
    this.sumberEkstraksi = const Value.absent(),
  });
  TransaksisCompanion.insert({
    this.id = const Value.absent(),
    required DateTime tanggal,
    this.bulanTagihan = const Value.absent(),
    required String deskripsi,
    required JenisTransaksi jenis,
    required int akunId,
    required int totalTagihan,
    this.merchant = const Value.absent(),
    this.ongkirFee = const Value.absent(),
    required StatusBayar status,
    this.catatan = const Value.absent(),
    this.subscriptionId = const Value.absent(),
    this.sumberEkstraksi = const Value.absent(),
  }) : tanggal = Value(tanggal),
       deskripsi = Value(deskripsi),
       jenis = Value(jenis),
       akunId = Value(akunId),
       totalTagihan = Value(totalTagihan),
       status = Value(status);
  static Insertable<TransaksiRow> custom({
    Expression<int>? id,
    Expression<DateTime>? tanggal,
    Expression<DateTime>? bulanTagihan,
    Expression<String>? deskripsi,
    Expression<int>? jenis,
    Expression<int>? akunId,
    Expression<int>? totalTagihan,
    Expression<String>? merchant,
    Expression<int>? ongkirFee,
    Expression<int>? status,
    Expression<String>? catatan,
    Expression<int>? subscriptionId,
    Expression<int>? sumberEkstraksi,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tanggal != null) 'tanggal': tanggal,
      if (bulanTagihan != null) 'bulan_tagihan': bulanTagihan,
      if (deskripsi != null) 'deskripsi': deskripsi,
      if (jenis != null) 'jenis': jenis,
      if (akunId != null) 'akun_id': akunId,
      if (totalTagihan != null) 'total_tagihan': totalTagihan,
      if (merchant != null) 'merchant': merchant,
      if (ongkirFee != null) 'ongkir_fee': ongkirFee,
      if (status != null) 'status': status,
      if (catatan != null) 'catatan': catatan,
      if (subscriptionId != null) 'subscription_id': subscriptionId,
      if (sumberEkstraksi != null) 'sumber_ekstraksi': sumberEkstraksi,
    });
  }

  TransaksisCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? tanggal,
    Value<DateTime?>? bulanTagihan,
    Value<String>? deskripsi,
    Value<JenisTransaksi>? jenis,
    Value<int>? akunId,
    Value<int>? totalTagihan,
    Value<String?>? merchant,
    Value<int>? ongkirFee,
    Value<StatusBayar>? status,
    Value<String?>? catatan,
    Value<int?>? subscriptionId,
    Value<SumberEkstraksi?>? sumberEkstraksi,
  }) {
    return TransaksisCompanion(
      id: id ?? this.id,
      tanggal: tanggal ?? this.tanggal,
      bulanTagihan: bulanTagihan ?? this.bulanTagihan,
      deskripsi: deskripsi ?? this.deskripsi,
      jenis: jenis ?? this.jenis,
      akunId: akunId ?? this.akunId,
      totalTagihan: totalTagihan ?? this.totalTagihan,
      merchant: merchant ?? this.merchant,
      ongkirFee: ongkirFee ?? this.ongkirFee,
      status: status ?? this.status,
      catatan: catatan ?? this.catatan,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      sumberEkstraksi: sumberEkstraksi ?? this.sumberEkstraksi,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tanggal.present) {
      map['tanggal'] = Variable<DateTime>(tanggal.value);
    }
    if (bulanTagihan.present) {
      map['bulan_tagihan'] = Variable<DateTime>(bulanTagihan.value);
    }
    if (deskripsi.present) {
      map['deskripsi'] = Variable<String>(deskripsi.value);
    }
    if (jenis.present) {
      map['jenis'] = Variable<int>(
        $TransaksisTable.$converterjenis.toSql(jenis.value),
      );
    }
    if (akunId.present) {
      map['akun_id'] = Variable<int>(akunId.value);
    }
    if (totalTagihan.present) {
      map['total_tagihan'] = Variable<int>(totalTagihan.value);
    }
    if (merchant.present) {
      map['merchant'] = Variable<String>(merchant.value);
    }
    if (ongkirFee.present) {
      map['ongkir_fee'] = Variable<int>(ongkirFee.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(
        $TransaksisTable.$converterstatus.toSql(status.value),
      );
    }
    if (catatan.present) {
      map['catatan'] = Variable<String>(catatan.value);
    }
    if (subscriptionId.present) {
      map['subscription_id'] = Variable<int>(subscriptionId.value);
    }
    if (sumberEkstraksi.present) {
      map['sumber_ekstraksi'] = Variable<int>(
        $TransaksisTable.$convertersumberEkstraksin.toSql(
          sumberEkstraksi.value,
        ),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransaksisCompanion(')
          ..write('id: $id, ')
          ..write('tanggal: $tanggal, ')
          ..write('bulanTagihan: $bulanTagihan, ')
          ..write('deskripsi: $deskripsi, ')
          ..write('jenis: $jenis, ')
          ..write('akunId: $akunId, ')
          ..write('totalTagihan: $totalTagihan, ')
          ..write('merchant: $merchant, ')
          ..write('ongkirFee: $ongkirFee, ')
          ..write('status: $status, ')
          ..write('catatan: $catatan, ')
          ..write('subscriptionId: $subscriptionId, ')
          ..write('sumberEkstraksi: $sumberEkstraksi')
          ..write(')'))
        .toString();
  }
}

class $SplitGroupOrdersTable extends SplitGroupOrders
    with TableInfo<$SplitGroupOrdersTable, SplitGroupOrderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SplitGroupOrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _transaksiIdMeta = const VerificationMeta(
    'transaksiId',
  );
  @override
  late final GeneratedColumn<int> transaksiId = GeneratedColumn<int>(
    'transaksi_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES transaksis (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _namaMeta = const VerificationMeta('nama');
  @override
  late final GeneratedColumn<String> nama = GeneratedColumn<String>(
    'nama',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hargaManualMeta = const VerificationMeta(
    'hargaManual',
  );
  @override
  late final GeneratedColumn<int> hargaManual = GeneratedColumn<int>(
    'harga_manual',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<StatusBayar, int> status =
      GeneratedColumn<int>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<StatusBayar>($SplitGroupOrdersTable.$converterstatus);
  static const VerificationMeta _catatanMeta = const VerificationMeta(
    'catatan',
  );
  @override
  late final GeneratedColumn<String> catatan = GeneratedColumn<String>(
    'catatan',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    transaksiId,
    nama,
    hargaManual,
    status,
    catatan,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'split_group_orders';
  @override
  VerificationContext validateIntegrity(
    Insertable<SplitGroupOrderRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('transaksi_id')) {
      context.handle(
        _transaksiIdMeta,
        transaksiId.isAcceptableOrUnknown(
          data['transaksi_id']!,
          _transaksiIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transaksiIdMeta);
    }
    if (data.containsKey('nama')) {
      context.handle(
        _namaMeta,
        nama.isAcceptableOrUnknown(data['nama']!, _namaMeta),
      );
    } else if (isInserting) {
      context.missing(_namaMeta);
    }
    if (data.containsKey('harga_manual')) {
      context.handle(
        _hargaManualMeta,
        hargaManual.isAcceptableOrUnknown(
          data['harga_manual']!,
          _hargaManualMeta,
        ),
      );
    }
    if (data.containsKey('catatan')) {
      context.handle(
        _catatanMeta,
        catatan.isAcceptableOrUnknown(data['catatan']!, _catatanMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SplitGroupOrderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SplitGroupOrderRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      transaksiId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transaksi_id'],
      )!,
      nama: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nama'],
      )!,
      hargaManual: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}harga_manual'],
      ),
      status: $SplitGroupOrdersTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}status'],
        )!,
      ),
      catatan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catatan'],
      ),
    );
  }

  @override
  $SplitGroupOrdersTable createAlias(String alias) {
    return $SplitGroupOrdersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<StatusBayar, int, int> $converterstatus =
      const EnumIndexConverter<StatusBayar>(StatusBayar.values);
}

class SplitGroupOrderRow extends DataClass
    implements Insertable<SplitGroupOrderRow> {
  final int id;
  final int transaksiId;
  final String nama;
  final int? hargaManual;
  final StatusBayar status;
  final String? catatan;
  const SplitGroupOrderRow({
    required this.id,
    required this.transaksiId,
    required this.nama,
    this.hargaManual,
    required this.status,
    this.catatan,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['transaksi_id'] = Variable<int>(transaksiId);
    map['nama'] = Variable<String>(nama);
    if (!nullToAbsent || hargaManual != null) {
      map['harga_manual'] = Variable<int>(hargaManual);
    }
    {
      map['status'] = Variable<int>(
        $SplitGroupOrdersTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || catatan != null) {
      map['catatan'] = Variable<String>(catatan);
    }
    return map;
  }

  SplitGroupOrdersCompanion toCompanion(bool nullToAbsent) {
    return SplitGroupOrdersCompanion(
      id: Value(id),
      transaksiId: Value(transaksiId),
      nama: Value(nama),
      hargaManual: hargaManual == null && nullToAbsent
          ? const Value.absent()
          : Value(hargaManual),
      status: Value(status),
      catatan: catatan == null && nullToAbsent
          ? const Value.absent()
          : Value(catatan),
    );
  }

  factory SplitGroupOrderRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SplitGroupOrderRow(
      id: serializer.fromJson<int>(json['id']),
      transaksiId: serializer.fromJson<int>(json['transaksiId']),
      nama: serializer.fromJson<String>(json['nama']),
      hargaManual: serializer.fromJson<int?>(json['hargaManual']),
      status: $SplitGroupOrdersTable.$converterstatus.fromJson(
        serializer.fromJson<int>(json['status']),
      ),
      catatan: serializer.fromJson<String?>(json['catatan']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'transaksiId': serializer.toJson<int>(transaksiId),
      'nama': serializer.toJson<String>(nama),
      'hargaManual': serializer.toJson<int?>(hargaManual),
      'status': serializer.toJson<int>(
        $SplitGroupOrdersTable.$converterstatus.toJson(status),
      ),
      'catatan': serializer.toJson<String?>(catatan),
    };
  }

  SplitGroupOrderRow copyWith({
    int? id,
    int? transaksiId,
    String? nama,
    Value<int?> hargaManual = const Value.absent(),
    StatusBayar? status,
    Value<String?> catatan = const Value.absent(),
  }) => SplitGroupOrderRow(
    id: id ?? this.id,
    transaksiId: transaksiId ?? this.transaksiId,
    nama: nama ?? this.nama,
    hargaManual: hargaManual.present ? hargaManual.value : this.hargaManual,
    status: status ?? this.status,
    catatan: catatan.present ? catatan.value : this.catatan,
  );
  SplitGroupOrderRow copyWithCompanion(SplitGroupOrdersCompanion data) {
    return SplitGroupOrderRow(
      id: data.id.present ? data.id.value : this.id,
      transaksiId: data.transaksiId.present
          ? data.transaksiId.value
          : this.transaksiId,
      nama: data.nama.present ? data.nama.value : this.nama,
      hargaManual: data.hargaManual.present
          ? data.hargaManual.value
          : this.hargaManual,
      status: data.status.present ? data.status.value : this.status,
      catatan: data.catatan.present ? data.catatan.value : this.catatan,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SplitGroupOrderRow(')
          ..write('id: $id, ')
          ..write('transaksiId: $transaksiId, ')
          ..write('nama: $nama, ')
          ..write('hargaManual: $hargaManual, ')
          ..write('status: $status, ')
          ..write('catatan: $catatan')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, transaksiId, nama, hargaManual, status, catatan);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SplitGroupOrderRow &&
          other.id == this.id &&
          other.transaksiId == this.transaksiId &&
          other.nama == this.nama &&
          other.hargaManual == this.hargaManual &&
          other.status == this.status &&
          other.catatan == this.catatan);
}

class SplitGroupOrdersCompanion extends UpdateCompanion<SplitGroupOrderRow> {
  final Value<int> id;
  final Value<int> transaksiId;
  final Value<String> nama;
  final Value<int?> hargaManual;
  final Value<StatusBayar> status;
  final Value<String?> catatan;
  const SplitGroupOrdersCompanion({
    this.id = const Value.absent(),
    this.transaksiId = const Value.absent(),
    this.nama = const Value.absent(),
    this.hargaManual = const Value.absent(),
    this.status = const Value.absent(),
    this.catatan = const Value.absent(),
  });
  SplitGroupOrdersCompanion.insert({
    this.id = const Value.absent(),
    required int transaksiId,
    required String nama,
    this.hargaManual = const Value.absent(),
    required StatusBayar status,
    this.catatan = const Value.absent(),
  }) : transaksiId = Value(transaksiId),
       nama = Value(nama),
       status = Value(status);
  static Insertable<SplitGroupOrderRow> custom({
    Expression<int>? id,
    Expression<int>? transaksiId,
    Expression<String>? nama,
    Expression<int>? hargaManual,
    Expression<int>? status,
    Expression<String>? catatan,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transaksiId != null) 'transaksi_id': transaksiId,
      if (nama != null) 'nama': nama,
      if (hargaManual != null) 'harga_manual': hargaManual,
      if (status != null) 'status': status,
      if (catatan != null) 'catatan': catatan,
    });
  }

  SplitGroupOrdersCompanion copyWith({
    Value<int>? id,
    Value<int>? transaksiId,
    Value<String>? nama,
    Value<int?>? hargaManual,
    Value<StatusBayar>? status,
    Value<String?>? catatan,
  }) {
    return SplitGroupOrdersCompanion(
      id: id ?? this.id,
      transaksiId: transaksiId ?? this.transaksiId,
      nama: nama ?? this.nama,
      hargaManual: hargaManual ?? this.hargaManual,
      status: status ?? this.status,
      catatan: catatan ?? this.catatan,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (transaksiId.present) {
      map['transaksi_id'] = Variable<int>(transaksiId.value);
    }
    if (nama.present) {
      map['nama'] = Variable<String>(nama.value);
    }
    if (hargaManual.present) {
      map['harga_manual'] = Variable<int>(hargaManual.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(
        $SplitGroupOrdersTable.$converterstatus.toSql(status.value),
      );
    }
    if (catatan.present) {
      map['catatan'] = Variable<String>(catatan.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SplitGroupOrdersCompanion(')
          ..write('id: $id, ')
          ..write('transaksiId: $transaksiId, ')
          ..write('nama: $nama, ')
          ..write('hargaManual: $hargaManual, ')
          ..write('status: $status, ')
          ..write('catatan: $catatan')
          ..write(')'))
        .toString();
  }
}

class $CicilansTable extends Cicilans
    with TableInfo<$CicilansTable, CicilanRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CicilansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _namaCicilanMeta = const VerificationMeta(
    'namaCicilan',
  );
  @override
  late final GeneratedColumn<String> namaCicilan = GeneratedColumn<String>(
    'nama_cicilan',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _akunIdMeta = const VerificationMeta('akunId');
  @override
  late final GeneratedColumn<int> akunId = GeneratedColumn<int>(
    'akun_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES akuns (id)',
    ),
  );
  static const VerificationMeta _totalHargaBarangMeta = const VerificationMeta(
    'totalHargaBarang',
  );
  @override
  late final GeneratedColumn<int> totalHargaBarang = GeneratedColumn<int>(
    'total_harga_barang',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenorMeta = const VerificationMeta('tenor');
  @override
  late final GeneratedColumn<int> tenor = GeneratedColumn<int>(
    'tenor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cicilanKeMeta = const VerificationMeta(
    'cicilanKe',
  );
  @override
  late final GeneratedColumn<int> cicilanKe = GeneratedColumn<int>(
    'cicilan_ke',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _jumlahPerBulanMeta = const VerificationMeta(
    'jumlahPerBulan',
  );
  @override
  late final GeneratedColumn<int> jumlahPerBulan = GeneratedColumn<int>(
    'jumlah_per_bulan',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tanggalMulaiMeta = const VerificationMeta(
    'tanggalMulai',
  );
  @override
  late final GeneratedColumn<DateTime> tanggalMulai = GeneratedColumn<DateTime>(
    'tanggal_mulai',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tanggalBayarTerakhirMeta =
      const VerificationMeta('tanggalBayarTerakhir');
  @override
  late final GeneratedColumn<DateTime> tanggalBayarTerakhir =
      GeneratedColumn<DateTime>(
        'tanggal_bayar_terakhir',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _catatanMeta = const VerificationMeta(
    'catatan',
  );
  @override
  late final GeneratedColumn<String> catatan = GeneratedColumn<String>(
    'catatan',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    namaCicilan,
    akunId,
    totalHargaBarang,
    tenor,
    cicilanKe,
    jumlahPerBulan,
    tanggalMulai,
    tanggalBayarTerakhir,
    catatan,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cicilans';
  @override
  VerificationContext validateIntegrity(
    Insertable<CicilanRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nama_cicilan')) {
      context.handle(
        _namaCicilanMeta,
        namaCicilan.isAcceptableOrUnknown(
          data['nama_cicilan']!,
          _namaCicilanMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_namaCicilanMeta);
    }
    if (data.containsKey('akun_id')) {
      context.handle(
        _akunIdMeta,
        akunId.isAcceptableOrUnknown(data['akun_id']!, _akunIdMeta),
      );
    } else if (isInserting) {
      context.missing(_akunIdMeta);
    }
    if (data.containsKey('total_harga_barang')) {
      context.handle(
        _totalHargaBarangMeta,
        totalHargaBarang.isAcceptableOrUnknown(
          data['total_harga_barang']!,
          _totalHargaBarangMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalHargaBarangMeta);
    }
    if (data.containsKey('tenor')) {
      context.handle(
        _tenorMeta,
        tenor.isAcceptableOrUnknown(data['tenor']!, _tenorMeta),
      );
    } else if (isInserting) {
      context.missing(_tenorMeta);
    }
    if (data.containsKey('cicilan_ke')) {
      context.handle(
        _cicilanKeMeta,
        cicilanKe.isAcceptableOrUnknown(data['cicilan_ke']!, _cicilanKeMeta),
      );
    }
    if (data.containsKey('jumlah_per_bulan')) {
      context.handle(
        _jumlahPerBulanMeta,
        jumlahPerBulan.isAcceptableOrUnknown(
          data['jumlah_per_bulan']!,
          _jumlahPerBulanMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_jumlahPerBulanMeta);
    }
    if (data.containsKey('tanggal_mulai')) {
      context.handle(
        _tanggalMulaiMeta,
        tanggalMulai.isAcceptableOrUnknown(
          data['tanggal_mulai']!,
          _tanggalMulaiMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tanggalMulaiMeta);
    }
    if (data.containsKey('tanggal_bayar_terakhir')) {
      context.handle(
        _tanggalBayarTerakhirMeta,
        tanggalBayarTerakhir.isAcceptableOrUnknown(
          data['tanggal_bayar_terakhir']!,
          _tanggalBayarTerakhirMeta,
        ),
      );
    }
    if (data.containsKey('catatan')) {
      context.handle(
        _catatanMeta,
        catatan.isAcceptableOrUnknown(data['catatan']!, _catatanMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CicilanRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CicilanRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      namaCicilan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nama_cicilan'],
      )!,
      akunId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}akun_id'],
      )!,
      totalHargaBarang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_harga_barang'],
      )!,
      tenor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tenor'],
      )!,
      cicilanKe: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cicilan_ke'],
      )!,
      jumlahPerBulan: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}jumlah_per_bulan'],
      )!,
      tanggalMulai: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}tanggal_mulai'],
      )!,
      tanggalBayarTerakhir: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}tanggal_bayar_terakhir'],
      ),
      catatan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catatan'],
      ),
    );
  }

  @override
  $CicilansTable createAlias(String alias) {
    return $CicilansTable(attachedDatabase, alias);
  }
}

class CicilanRow extends DataClass implements Insertable<CicilanRow> {
  final int id;
  final String namaCicilan;
  final int akunId;
  final int totalHargaBarang;
  final int tenor;
  final int cicilanKe;
  final int jumlahPerBulan;
  final DateTime tanggalMulai;
  final DateTime? tanggalBayarTerakhir;
  final String? catatan;
  const CicilanRow({
    required this.id,
    required this.namaCicilan,
    required this.akunId,
    required this.totalHargaBarang,
    required this.tenor,
    required this.cicilanKe,
    required this.jumlahPerBulan,
    required this.tanggalMulai,
    this.tanggalBayarTerakhir,
    this.catatan,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nama_cicilan'] = Variable<String>(namaCicilan);
    map['akun_id'] = Variable<int>(akunId);
    map['total_harga_barang'] = Variable<int>(totalHargaBarang);
    map['tenor'] = Variable<int>(tenor);
    map['cicilan_ke'] = Variable<int>(cicilanKe);
    map['jumlah_per_bulan'] = Variable<int>(jumlahPerBulan);
    map['tanggal_mulai'] = Variable<DateTime>(tanggalMulai);
    if (!nullToAbsent || tanggalBayarTerakhir != null) {
      map['tanggal_bayar_terakhir'] = Variable<DateTime>(tanggalBayarTerakhir);
    }
    if (!nullToAbsent || catatan != null) {
      map['catatan'] = Variable<String>(catatan);
    }
    return map;
  }

  CicilansCompanion toCompanion(bool nullToAbsent) {
    return CicilansCompanion(
      id: Value(id),
      namaCicilan: Value(namaCicilan),
      akunId: Value(akunId),
      totalHargaBarang: Value(totalHargaBarang),
      tenor: Value(tenor),
      cicilanKe: Value(cicilanKe),
      jumlahPerBulan: Value(jumlahPerBulan),
      tanggalMulai: Value(tanggalMulai),
      tanggalBayarTerakhir: tanggalBayarTerakhir == null && nullToAbsent
          ? const Value.absent()
          : Value(tanggalBayarTerakhir),
      catatan: catatan == null && nullToAbsent
          ? const Value.absent()
          : Value(catatan),
    );
  }

  factory CicilanRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CicilanRow(
      id: serializer.fromJson<int>(json['id']),
      namaCicilan: serializer.fromJson<String>(json['namaCicilan']),
      akunId: serializer.fromJson<int>(json['akunId']),
      totalHargaBarang: serializer.fromJson<int>(json['totalHargaBarang']),
      tenor: serializer.fromJson<int>(json['tenor']),
      cicilanKe: serializer.fromJson<int>(json['cicilanKe']),
      jumlahPerBulan: serializer.fromJson<int>(json['jumlahPerBulan']),
      tanggalMulai: serializer.fromJson<DateTime>(json['tanggalMulai']),
      tanggalBayarTerakhir: serializer.fromJson<DateTime?>(
        json['tanggalBayarTerakhir'],
      ),
      catatan: serializer.fromJson<String?>(json['catatan']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'namaCicilan': serializer.toJson<String>(namaCicilan),
      'akunId': serializer.toJson<int>(akunId),
      'totalHargaBarang': serializer.toJson<int>(totalHargaBarang),
      'tenor': serializer.toJson<int>(tenor),
      'cicilanKe': serializer.toJson<int>(cicilanKe),
      'jumlahPerBulan': serializer.toJson<int>(jumlahPerBulan),
      'tanggalMulai': serializer.toJson<DateTime>(tanggalMulai),
      'tanggalBayarTerakhir': serializer.toJson<DateTime?>(
        tanggalBayarTerakhir,
      ),
      'catatan': serializer.toJson<String?>(catatan),
    };
  }

  CicilanRow copyWith({
    int? id,
    String? namaCicilan,
    int? akunId,
    int? totalHargaBarang,
    int? tenor,
    int? cicilanKe,
    int? jumlahPerBulan,
    DateTime? tanggalMulai,
    Value<DateTime?> tanggalBayarTerakhir = const Value.absent(),
    Value<String?> catatan = const Value.absent(),
  }) => CicilanRow(
    id: id ?? this.id,
    namaCicilan: namaCicilan ?? this.namaCicilan,
    akunId: akunId ?? this.akunId,
    totalHargaBarang: totalHargaBarang ?? this.totalHargaBarang,
    tenor: tenor ?? this.tenor,
    cicilanKe: cicilanKe ?? this.cicilanKe,
    jumlahPerBulan: jumlahPerBulan ?? this.jumlahPerBulan,
    tanggalMulai: tanggalMulai ?? this.tanggalMulai,
    tanggalBayarTerakhir: tanggalBayarTerakhir.present
        ? tanggalBayarTerakhir.value
        : this.tanggalBayarTerakhir,
    catatan: catatan.present ? catatan.value : this.catatan,
  );
  CicilanRow copyWithCompanion(CicilansCompanion data) {
    return CicilanRow(
      id: data.id.present ? data.id.value : this.id,
      namaCicilan: data.namaCicilan.present
          ? data.namaCicilan.value
          : this.namaCicilan,
      akunId: data.akunId.present ? data.akunId.value : this.akunId,
      totalHargaBarang: data.totalHargaBarang.present
          ? data.totalHargaBarang.value
          : this.totalHargaBarang,
      tenor: data.tenor.present ? data.tenor.value : this.tenor,
      cicilanKe: data.cicilanKe.present ? data.cicilanKe.value : this.cicilanKe,
      jumlahPerBulan: data.jumlahPerBulan.present
          ? data.jumlahPerBulan.value
          : this.jumlahPerBulan,
      tanggalMulai: data.tanggalMulai.present
          ? data.tanggalMulai.value
          : this.tanggalMulai,
      tanggalBayarTerakhir: data.tanggalBayarTerakhir.present
          ? data.tanggalBayarTerakhir.value
          : this.tanggalBayarTerakhir,
      catatan: data.catatan.present ? data.catatan.value : this.catatan,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CicilanRow(')
          ..write('id: $id, ')
          ..write('namaCicilan: $namaCicilan, ')
          ..write('akunId: $akunId, ')
          ..write('totalHargaBarang: $totalHargaBarang, ')
          ..write('tenor: $tenor, ')
          ..write('cicilanKe: $cicilanKe, ')
          ..write('jumlahPerBulan: $jumlahPerBulan, ')
          ..write('tanggalMulai: $tanggalMulai, ')
          ..write('tanggalBayarTerakhir: $tanggalBayarTerakhir, ')
          ..write('catatan: $catatan')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    namaCicilan,
    akunId,
    totalHargaBarang,
    tenor,
    cicilanKe,
    jumlahPerBulan,
    tanggalMulai,
    tanggalBayarTerakhir,
    catatan,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CicilanRow &&
          other.id == this.id &&
          other.namaCicilan == this.namaCicilan &&
          other.akunId == this.akunId &&
          other.totalHargaBarang == this.totalHargaBarang &&
          other.tenor == this.tenor &&
          other.cicilanKe == this.cicilanKe &&
          other.jumlahPerBulan == this.jumlahPerBulan &&
          other.tanggalMulai == this.tanggalMulai &&
          other.tanggalBayarTerakhir == this.tanggalBayarTerakhir &&
          other.catatan == this.catatan);
}

class CicilansCompanion extends UpdateCompanion<CicilanRow> {
  final Value<int> id;
  final Value<String> namaCicilan;
  final Value<int> akunId;
  final Value<int> totalHargaBarang;
  final Value<int> tenor;
  final Value<int> cicilanKe;
  final Value<int> jumlahPerBulan;
  final Value<DateTime> tanggalMulai;
  final Value<DateTime?> tanggalBayarTerakhir;
  final Value<String?> catatan;
  const CicilansCompanion({
    this.id = const Value.absent(),
    this.namaCicilan = const Value.absent(),
    this.akunId = const Value.absent(),
    this.totalHargaBarang = const Value.absent(),
    this.tenor = const Value.absent(),
    this.cicilanKe = const Value.absent(),
    this.jumlahPerBulan = const Value.absent(),
    this.tanggalMulai = const Value.absent(),
    this.tanggalBayarTerakhir = const Value.absent(),
    this.catatan = const Value.absent(),
  });
  CicilansCompanion.insert({
    this.id = const Value.absent(),
    required String namaCicilan,
    required int akunId,
    required int totalHargaBarang,
    required int tenor,
    this.cicilanKe = const Value.absent(),
    required int jumlahPerBulan,
    required DateTime tanggalMulai,
    this.tanggalBayarTerakhir = const Value.absent(),
    this.catatan = const Value.absent(),
  }) : namaCicilan = Value(namaCicilan),
       akunId = Value(akunId),
       totalHargaBarang = Value(totalHargaBarang),
       tenor = Value(tenor),
       jumlahPerBulan = Value(jumlahPerBulan),
       tanggalMulai = Value(tanggalMulai);
  static Insertable<CicilanRow> custom({
    Expression<int>? id,
    Expression<String>? namaCicilan,
    Expression<int>? akunId,
    Expression<int>? totalHargaBarang,
    Expression<int>? tenor,
    Expression<int>? cicilanKe,
    Expression<int>? jumlahPerBulan,
    Expression<DateTime>? tanggalMulai,
    Expression<DateTime>? tanggalBayarTerakhir,
    Expression<String>? catatan,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (namaCicilan != null) 'nama_cicilan': namaCicilan,
      if (akunId != null) 'akun_id': akunId,
      if (totalHargaBarang != null) 'total_harga_barang': totalHargaBarang,
      if (tenor != null) 'tenor': tenor,
      if (cicilanKe != null) 'cicilan_ke': cicilanKe,
      if (jumlahPerBulan != null) 'jumlah_per_bulan': jumlahPerBulan,
      if (tanggalMulai != null) 'tanggal_mulai': tanggalMulai,
      if (tanggalBayarTerakhir != null)
        'tanggal_bayar_terakhir': tanggalBayarTerakhir,
      if (catatan != null) 'catatan': catatan,
    });
  }

  CicilansCompanion copyWith({
    Value<int>? id,
    Value<String>? namaCicilan,
    Value<int>? akunId,
    Value<int>? totalHargaBarang,
    Value<int>? tenor,
    Value<int>? cicilanKe,
    Value<int>? jumlahPerBulan,
    Value<DateTime>? tanggalMulai,
    Value<DateTime?>? tanggalBayarTerakhir,
    Value<String?>? catatan,
  }) {
    return CicilansCompanion(
      id: id ?? this.id,
      namaCicilan: namaCicilan ?? this.namaCicilan,
      akunId: akunId ?? this.akunId,
      totalHargaBarang: totalHargaBarang ?? this.totalHargaBarang,
      tenor: tenor ?? this.tenor,
      cicilanKe: cicilanKe ?? this.cicilanKe,
      jumlahPerBulan: jumlahPerBulan ?? this.jumlahPerBulan,
      tanggalMulai: tanggalMulai ?? this.tanggalMulai,
      tanggalBayarTerakhir: tanggalBayarTerakhir ?? this.tanggalBayarTerakhir,
      catatan: catatan ?? this.catatan,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (namaCicilan.present) {
      map['nama_cicilan'] = Variable<String>(namaCicilan.value);
    }
    if (akunId.present) {
      map['akun_id'] = Variable<int>(akunId.value);
    }
    if (totalHargaBarang.present) {
      map['total_harga_barang'] = Variable<int>(totalHargaBarang.value);
    }
    if (tenor.present) {
      map['tenor'] = Variable<int>(tenor.value);
    }
    if (cicilanKe.present) {
      map['cicilan_ke'] = Variable<int>(cicilanKe.value);
    }
    if (jumlahPerBulan.present) {
      map['jumlah_per_bulan'] = Variable<int>(jumlahPerBulan.value);
    }
    if (tanggalMulai.present) {
      map['tanggal_mulai'] = Variable<DateTime>(tanggalMulai.value);
    }
    if (tanggalBayarTerakhir.present) {
      map['tanggal_bayar_terakhir'] = Variable<DateTime>(
        tanggalBayarTerakhir.value,
      );
    }
    if (catatan.present) {
      map['catatan'] = Variable<String>(catatan.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CicilansCompanion(')
          ..write('id: $id, ')
          ..write('namaCicilan: $namaCicilan, ')
          ..write('akunId: $akunId, ')
          ..write('totalHargaBarang: $totalHargaBarang, ')
          ..write('tenor: $tenor, ')
          ..write('cicilanKe: $cicilanKe, ')
          ..write('jumlahPerBulan: $jumlahPerBulan, ')
          ..write('tanggalMulai: $tanggalMulai, ')
          ..write('tanggalBayarTerakhir: $tanggalBayarTerakhir, ')
          ..write('catatan: $catatan')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<int> value = GeneratedColumn<int>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSettingRow extends DataClass implements Insertable<AppSettingRow> {
  final String key;
  final int value;
  const AppSettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<int>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<int>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<int>(value),
    };
  }

  AppSettingRow copyWith({String? key, int? value}) =>
      AppSettingRow(key: key ?? this.key, value: value ?? this.value);
  AppSettingRow copyWithCompanion(AppSettingsCompanion data) {
    return AppSettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSettingRow> {
  final Value<String> key;
  final Value<int> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required int value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSettingRow> custom({
    Expression<String>? key,
    Expression<int>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<int>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<int>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AkunsTable akuns = $AkunsTable(this);
  late final $SubscriptionsTable subscriptions = $SubscriptionsTable(this);
  late final $TransaksisTable transaksis = $TransaksisTable(this);
  late final $SplitGroupOrdersTable splitGroupOrders = $SplitGroupOrdersTable(
    this,
  );
  late final $CicilansTable cicilans = $CicilansTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final AkunDao akunDao = AkunDao(this as AppDatabase);
  late final TransaksiDao transaksiDao = TransaksiDao(this as AppDatabase);
  late final SplitDao splitDao = SplitDao(this as AppDatabase);
  late final CicilanDao cicilanDao = CicilanDao(this as AppDatabase);
  late final SubscriptionDao subscriptionDao = SubscriptionDao(
    this as AppDatabase,
  );
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    akuns,
    subscriptions,
    transaksis,
    splitGroupOrders,
    cicilans,
    appSettings,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'subscriptions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('transaksis', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'transaksis',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('split_group_orders', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$AkunsTableCreateCompanionBuilder =
    AkunsCompanion Function({
      Value<int> id,
      required String nama,
      Value<int> limitKredit,
      Value<int> saldoAwal,
      Value<int> tanggalCutoff,
      Value<int> tanggalJatuhTempo,
    });
typedef $$AkunsTableUpdateCompanionBuilder =
    AkunsCompanion Function({
      Value<int> id,
      Value<String> nama,
      Value<int> limitKredit,
      Value<int> saldoAwal,
      Value<int> tanggalCutoff,
      Value<int> tanggalJatuhTempo,
    });

final class $$AkunsTableReferences
    extends BaseReferences<_$AppDatabase, $AkunsTable, AkunRow> {
  $$AkunsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SubscriptionsTable, List<SubscriptionRow>>
  _subscriptionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.subscriptions,
    aliasName: 'akuns__id__subscriptions__akun_id',
  );

  $$SubscriptionsTableProcessedTableManager get subscriptionsRefs {
    final manager = $$SubscriptionsTableTableManager(
      $_db,
      $_db.subscriptions,
    ).filter((f) => f.akunId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_subscriptionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TransaksisTable, List<TransaksiRow>>
  _transaksisRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transaksis,
    aliasName: 'akuns__id__transaksis__akun_id',
  );

  $$TransaksisTableProcessedTableManager get transaksisRefs {
    final manager = $$TransaksisTableTableManager(
      $_db,
      $_db.transaksis,
    ).filter((f) => f.akunId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_transaksisRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CicilansTable, List<CicilanRow>>
  _cicilansRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cicilans,
    aliasName: 'akuns__id__cicilans__akun_id',
  );

  $$CicilansTableProcessedTableManager get cicilansRefs {
    final manager = $$CicilansTableTableManager(
      $_db,
      $_db.cicilans,
    ).filter((f) => f.akunId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_cicilansRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AkunsTableFilterComposer extends Composer<_$AppDatabase, $AkunsTable> {
  $$AkunsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get limitKredit => $composableBuilder(
    column: $table.limitKredit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get saldoAwal => $composableBuilder(
    column: $table.saldoAwal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tanggalCutoff => $composableBuilder(
    column: $table.tanggalCutoff,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tanggalJatuhTempo => $composableBuilder(
    column: $table.tanggalJatuhTempo,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> subscriptionsRefs(
    Expression<bool> Function($$SubscriptionsTableFilterComposer f) f,
  ) {
    final $$SubscriptionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.subscriptions,
      getReferencedColumn: (t) => t.akunId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubscriptionsTableFilterComposer(
            $db: $db,
            $table: $db.subscriptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> transaksisRefs(
    Expression<bool> Function($$TransaksisTableFilterComposer f) f,
  ) {
    final $$TransaksisTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transaksis,
      getReferencedColumn: (t) => t.akunId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransaksisTableFilterComposer(
            $db: $db,
            $table: $db.transaksis,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> cicilansRefs(
    Expression<bool> Function($$CicilansTableFilterComposer f) f,
  ) {
    final $$CicilansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cicilans,
      getReferencedColumn: (t) => t.akunId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CicilansTableFilterComposer(
            $db: $db,
            $table: $db.cicilans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AkunsTableOrderingComposer
    extends Composer<_$AppDatabase, $AkunsTable> {
  $$AkunsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get limitKredit => $composableBuilder(
    column: $table.limitKredit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get saldoAwal => $composableBuilder(
    column: $table.saldoAwal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tanggalCutoff => $composableBuilder(
    column: $table.tanggalCutoff,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tanggalJatuhTempo => $composableBuilder(
    column: $table.tanggalJatuhTempo,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AkunsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AkunsTable> {
  $$AkunsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nama =>
      $composableBuilder(column: $table.nama, builder: (column) => column);

  GeneratedColumn<int> get limitKredit => $composableBuilder(
    column: $table.limitKredit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get saldoAwal =>
      $composableBuilder(column: $table.saldoAwal, builder: (column) => column);

  GeneratedColumn<int> get tanggalCutoff => $composableBuilder(
    column: $table.tanggalCutoff,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tanggalJatuhTempo => $composableBuilder(
    column: $table.tanggalJatuhTempo,
    builder: (column) => column,
  );

  Expression<T> subscriptionsRefs<T extends Object>(
    Expression<T> Function($$SubscriptionsTableAnnotationComposer a) f,
  ) {
    final $$SubscriptionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.subscriptions,
      getReferencedColumn: (t) => t.akunId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubscriptionsTableAnnotationComposer(
            $db: $db,
            $table: $db.subscriptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> transaksisRefs<T extends Object>(
    Expression<T> Function($$TransaksisTableAnnotationComposer a) f,
  ) {
    final $$TransaksisTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transaksis,
      getReferencedColumn: (t) => t.akunId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransaksisTableAnnotationComposer(
            $db: $db,
            $table: $db.transaksis,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> cicilansRefs<T extends Object>(
    Expression<T> Function($$CicilansTableAnnotationComposer a) f,
  ) {
    final $$CicilansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cicilans,
      getReferencedColumn: (t) => t.akunId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CicilansTableAnnotationComposer(
            $db: $db,
            $table: $db.cicilans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AkunsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AkunsTable,
          AkunRow,
          $$AkunsTableFilterComposer,
          $$AkunsTableOrderingComposer,
          $$AkunsTableAnnotationComposer,
          $$AkunsTableCreateCompanionBuilder,
          $$AkunsTableUpdateCompanionBuilder,
          (AkunRow, $$AkunsTableReferences),
          AkunRow,
          PrefetchHooks Function({
            bool subscriptionsRefs,
            bool transaksisRefs,
            bool cicilansRefs,
          })
        > {
  $$AkunsTableTableManager(_$AppDatabase db, $AkunsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AkunsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AkunsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AkunsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nama = const Value.absent(),
                Value<int> limitKredit = const Value.absent(),
                Value<int> saldoAwal = const Value.absent(),
                Value<int> tanggalCutoff = const Value.absent(),
                Value<int> tanggalJatuhTempo = const Value.absent(),
              }) => AkunsCompanion(
                id: id,
                nama: nama,
                limitKredit: limitKredit,
                saldoAwal: saldoAwal,
                tanggalCutoff: tanggalCutoff,
                tanggalJatuhTempo: tanggalJatuhTempo,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nama,
                Value<int> limitKredit = const Value.absent(),
                Value<int> saldoAwal = const Value.absent(),
                Value<int> tanggalCutoff = const Value.absent(),
                Value<int> tanggalJatuhTempo = const Value.absent(),
              }) => AkunsCompanion.insert(
                id: id,
                nama: nama,
                limitKredit: limitKredit,
                saldoAwal: saldoAwal,
                tanggalCutoff: tanggalCutoff,
                tanggalJatuhTempo: tanggalJatuhTempo,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$AkunsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                subscriptionsRefs = false,
                transaksisRefs = false,
                cicilansRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (subscriptionsRefs) db.subscriptions,
                    if (transaksisRefs) db.transaksis,
                    if (cicilansRefs) db.cicilans,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (subscriptionsRefs)
                        await $_getPrefetchedData<
                          AkunRow,
                          $AkunsTable,
                          SubscriptionRow
                        >(
                          currentTable: table,
                          referencedTable: $$AkunsTableReferences
                              ._subscriptionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AkunsTableReferences(
                                db,
                                table,
                                p0,
                              ).subscriptionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.akunId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (transaksisRefs)
                        await $_getPrefetchedData<
                          AkunRow,
                          $AkunsTable,
                          TransaksiRow
                        >(
                          currentTable: table,
                          referencedTable: $$AkunsTableReferences
                              ._transaksisRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AkunsTableReferences(
                                db,
                                table,
                                p0,
                              ).transaksisRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.akunId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (cicilansRefs)
                        await $_getPrefetchedData<
                          AkunRow,
                          $AkunsTable,
                          CicilanRow
                        >(
                          currentTable: table,
                          referencedTable: $$AkunsTableReferences
                              ._cicilansRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AkunsTableReferences(
                                db,
                                table,
                                p0,
                              ).cicilansRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.akunId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AkunsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AkunsTable,
      AkunRow,
      $$AkunsTableFilterComposer,
      $$AkunsTableOrderingComposer,
      $$AkunsTableAnnotationComposer,
      $$AkunsTableCreateCompanionBuilder,
      $$AkunsTableUpdateCompanionBuilder,
      (AkunRow, $$AkunsTableReferences),
      AkunRow,
      PrefetchHooks Function({
        bool subscriptionsRefs,
        bool transaksisRefs,
        bool cicilansRefs,
      })
    >;
typedef $$SubscriptionsTableCreateCompanionBuilder =
    SubscriptionsCompanion Function({
      Value<int> id,
      required String namaLayanan,
      required int akunId,
      Value<int?> hargaTetap,
      required SiklusBilling siklusBilling,
      required DateTime tanggalTagihanBerikutnya,
      required int hariTagihan,
      required StatusSubscription status,
      Value<String?> catatan,
    });
typedef $$SubscriptionsTableUpdateCompanionBuilder =
    SubscriptionsCompanion Function({
      Value<int> id,
      Value<String> namaLayanan,
      Value<int> akunId,
      Value<int?> hargaTetap,
      Value<SiklusBilling> siklusBilling,
      Value<DateTime> tanggalTagihanBerikutnya,
      Value<int> hariTagihan,
      Value<StatusSubscription> status,
      Value<String?> catatan,
    });

final class $$SubscriptionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $SubscriptionsTable, SubscriptionRow> {
  $$SubscriptionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AkunsTable _akunIdTable(_$AppDatabase db) =>
      db.akuns.createAlias('subscriptions__akun_id__akuns__id');

  $$AkunsTableProcessedTableManager get akunId {
    final $_column = $_itemColumn<int>('akun_id')!;

    final manager = $$AkunsTableTableManager(
      $_db,
      $_db.akuns,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_akunIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TransaksisTable, List<TransaksiRow>>
  _transaksisRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transaksis,
    aliasName: 'subscriptions__id__transaksis__subscription_id',
  );

  $$TransaksisTableProcessedTableManager get transaksisRefs {
    final manager = $$TransaksisTableTableManager(
      $_db,
      $_db.transaksis,
    ).filter((f) => f.subscriptionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_transaksisRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SubscriptionsTableFilterComposer
    extends Composer<_$AppDatabase, $SubscriptionsTable> {
  $$SubscriptionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get namaLayanan => $composableBuilder(
    column: $table.namaLayanan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hargaTetap => $composableBuilder(
    column: $table.hargaTetap,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SiklusBilling, SiklusBilling, int>
  get siklusBilling => $composableBuilder(
    column: $table.siklusBilling,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get tanggalTagihanBerikutnya => $composableBuilder(
    column: $table.tanggalTagihanBerikutnya,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hariTagihan => $composableBuilder(
    column: $table.hariTagihan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<StatusSubscription, StatusSubscription, int>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get catatan => $composableBuilder(
    column: $table.catatan,
    builder: (column) => ColumnFilters(column),
  );

  $$AkunsTableFilterComposer get akunId {
    final $$AkunsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.akunId,
      referencedTable: $db.akuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AkunsTableFilterComposer(
            $db: $db,
            $table: $db.akuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> transaksisRefs(
    Expression<bool> Function($$TransaksisTableFilterComposer f) f,
  ) {
    final $$TransaksisTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transaksis,
      getReferencedColumn: (t) => t.subscriptionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransaksisTableFilterComposer(
            $db: $db,
            $table: $db.transaksis,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SubscriptionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubscriptionsTable> {
  $$SubscriptionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get namaLayanan => $composableBuilder(
    column: $table.namaLayanan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hargaTetap => $composableBuilder(
    column: $table.hargaTetap,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get siklusBilling => $composableBuilder(
    column: $table.siklusBilling,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get tanggalTagihanBerikutnya => $composableBuilder(
    column: $table.tanggalTagihanBerikutnya,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hariTagihan => $composableBuilder(
    column: $table.hariTagihan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catatan => $composableBuilder(
    column: $table.catatan,
    builder: (column) => ColumnOrderings(column),
  );

  $$AkunsTableOrderingComposer get akunId {
    final $$AkunsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.akunId,
      referencedTable: $db.akuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AkunsTableOrderingComposer(
            $db: $db,
            $table: $db.akuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SubscriptionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubscriptionsTable> {
  $$SubscriptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get namaLayanan => $composableBuilder(
    column: $table.namaLayanan,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hargaTetap => $composableBuilder(
    column: $table.hargaTetap,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SiklusBilling, int> get siklusBilling =>
      $composableBuilder(
        column: $table.siklusBilling,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get tanggalTagihanBerikutnya => $composableBuilder(
    column: $table.tanggalTagihanBerikutnya,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hariTagihan => $composableBuilder(
    column: $table.hariTagihan,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<StatusSubscription, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get catatan =>
      $composableBuilder(column: $table.catatan, builder: (column) => column);

  $$AkunsTableAnnotationComposer get akunId {
    final $$AkunsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.akunId,
      referencedTable: $db.akuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AkunsTableAnnotationComposer(
            $db: $db,
            $table: $db.akuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> transaksisRefs<T extends Object>(
    Expression<T> Function($$TransaksisTableAnnotationComposer a) f,
  ) {
    final $$TransaksisTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transaksis,
      getReferencedColumn: (t) => t.subscriptionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransaksisTableAnnotationComposer(
            $db: $db,
            $table: $db.transaksis,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SubscriptionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubscriptionsTable,
          SubscriptionRow,
          $$SubscriptionsTableFilterComposer,
          $$SubscriptionsTableOrderingComposer,
          $$SubscriptionsTableAnnotationComposer,
          $$SubscriptionsTableCreateCompanionBuilder,
          $$SubscriptionsTableUpdateCompanionBuilder,
          (SubscriptionRow, $$SubscriptionsTableReferences),
          SubscriptionRow,
          PrefetchHooks Function({bool akunId, bool transaksisRefs})
        > {
  $$SubscriptionsTableTableManager(_$AppDatabase db, $SubscriptionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubscriptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubscriptionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubscriptionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> namaLayanan = const Value.absent(),
                Value<int> akunId = const Value.absent(),
                Value<int?> hargaTetap = const Value.absent(),
                Value<SiklusBilling> siklusBilling = const Value.absent(),
                Value<DateTime> tanggalTagihanBerikutnya = const Value.absent(),
                Value<int> hariTagihan = const Value.absent(),
                Value<StatusSubscription> status = const Value.absent(),
                Value<String?> catatan = const Value.absent(),
              }) => SubscriptionsCompanion(
                id: id,
                namaLayanan: namaLayanan,
                akunId: akunId,
                hargaTetap: hargaTetap,
                siklusBilling: siklusBilling,
                tanggalTagihanBerikutnya: tanggalTagihanBerikutnya,
                hariTagihan: hariTagihan,
                status: status,
                catatan: catatan,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String namaLayanan,
                required int akunId,
                Value<int?> hargaTetap = const Value.absent(),
                required SiklusBilling siklusBilling,
                required DateTime tanggalTagihanBerikutnya,
                required int hariTagihan,
                required StatusSubscription status,
                Value<String?> catatan = const Value.absent(),
              }) => SubscriptionsCompanion.insert(
                id: id,
                namaLayanan: namaLayanan,
                akunId: akunId,
                hargaTetap: hargaTetap,
                siklusBilling: siklusBilling,
                tanggalTagihanBerikutnya: tanggalTagihanBerikutnya,
                hariTagihan: hariTagihan,
                status: status,
                catatan: catatan,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SubscriptionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({akunId = false, transaksisRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (transaksisRefs) db.transaksis],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (akunId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.akunId,
                                referencedTable: $$SubscriptionsTableReferences
                                    ._akunIdTable(db),
                                referencedColumn: $$SubscriptionsTableReferences
                                    ._akunIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (transaksisRefs)
                    await $_getPrefetchedData<
                      SubscriptionRow,
                      $SubscriptionsTable,
                      TransaksiRow
                    >(
                      currentTable: table,
                      referencedTable: $$SubscriptionsTableReferences
                          ._transaksisRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SubscriptionsTableReferences(
                            db,
                            table,
                            p0,
                          ).transaksisRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.subscriptionId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SubscriptionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubscriptionsTable,
      SubscriptionRow,
      $$SubscriptionsTableFilterComposer,
      $$SubscriptionsTableOrderingComposer,
      $$SubscriptionsTableAnnotationComposer,
      $$SubscriptionsTableCreateCompanionBuilder,
      $$SubscriptionsTableUpdateCompanionBuilder,
      (SubscriptionRow, $$SubscriptionsTableReferences),
      SubscriptionRow,
      PrefetchHooks Function({bool akunId, bool transaksisRefs})
    >;
typedef $$TransaksisTableCreateCompanionBuilder =
    TransaksisCompanion Function({
      Value<int> id,
      required DateTime tanggal,
      Value<DateTime?> bulanTagihan,
      required String deskripsi,
      required JenisTransaksi jenis,
      required int akunId,
      required int totalTagihan,
      Value<String?> merchant,
      Value<int> ongkirFee,
      required StatusBayar status,
      Value<String?> catatan,
      Value<int?> subscriptionId,
      Value<SumberEkstraksi?> sumberEkstraksi,
    });
typedef $$TransaksisTableUpdateCompanionBuilder =
    TransaksisCompanion Function({
      Value<int> id,
      Value<DateTime> tanggal,
      Value<DateTime?> bulanTagihan,
      Value<String> deskripsi,
      Value<JenisTransaksi> jenis,
      Value<int> akunId,
      Value<int> totalTagihan,
      Value<String?> merchant,
      Value<int> ongkirFee,
      Value<StatusBayar> status,
      Value<String?> catatan,
      Value<int?> subscriptionId,
      Value<SumberEkstraksi?> sumberEkstraksi,
    });

final class $$TransaksisTableReferences
    extends BaseReferences<_$AppDatabase, $TransaksisTable, TransaksiRow> {
  $$TransaksisTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AkunsTable _akunIdTable(_$AppDatabase db) =>
      db.akuns.createAlias('transaksis__akun_id__akuns__id');

  $$AkunsTableProcessedTableManager get akunId {
    final $_column = $_itemColumn<int>('akun_id')!;

    final manager = $$AkunsTableTableManager(
      $_db,
      $_db.akuns,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_akunIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SubscriptionsTable _subscriptionIdTable(_$AppDatabase db) => db
      .subscriptions
      .createAlias('transaksis__subscription_id__subscriptions__id');

  $$SubscriptionsTableProcessedTableManager? get subscriptionId {
    final $_column = $_itemColumn<int>('subscription_id');
    if ($_column == null) return null;
    final manager = $$SubscriptionsTableTableManager(
      $_db,
      $_db.subscriptions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subscriptionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SplitGroupOrdersTable, List<SplitGroupOrderRow>>
  _splitGroupOrdersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.splitGroupOrders,
    aliasName: 'transaksis__id__split_group_orders__transaksi_id',
  );

  $$SplitGroupOrdersTableProcessedTableManager get splitGroupOrdersRefs {
    final manager = $$SplitGroupOrdersTableTableManager(
      $_db,
      $_db.splitGroupOrders,
    ).filter((f) => f.transaksiId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _splitGroupOrdersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TransaksisTableFilterComposer
    extends Composer<_$AppDatabase, $TransaksisTable> {
  $$TransaksisTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get tanggal => $composableBuilder(
    column: $table.tanggal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get bulanTagihan => $composableBuilder(
    column: $table.bulanTagihan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deskripsi => $composableBuilder(
    column: $table.deskripsi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<JenisTransaksi, JenisTransaksi, int>
  get jenis => $composableBuilder(
    column: $table.jenis,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get totalTagihan => $composableBuilder(
    column: $table.totalTagihan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ongkirFee => $composableBuilder(
    column: $table.ongkirFee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<StatusBayar, StatusBayar, int> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get catatan => $composableBuilder(
    column: $table.catatan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SumberEkstraksi?, SumberEkstraksi, int>
  get sumberEkstraksi => $composableBuilder(
    column: $table.sumberEkstraksi,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$AkunsTableFilterComposer get akunId {
    final $$AkunsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.akunId,
      referencedTable: $db.akuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AkunsTableFilterComposer(
            $db: $db,
            $table: $db.akuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SubscriptionsTableFilterComposer get subscriptionId {
    final $$SubscriptionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subscriptionId,
      referencedTable: $db.subscriptions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubscriptionsTableFilterComposer(
            $db: $db,
            $table: $db.subscriptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> splitGroupOrdersRefs(
    Expression<bool> Function($$SplitGroupOrdersTableFilterComposer f) f,
  ) {
    final $$SplitGroupOrdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.splitGroupOrders,
      getReferencedColumn: (t) => t.transaksiId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SplitGroupOrdersTableFilterComposer(
            $db: $db,
            $table: $db.splitGroupOrders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TransaksisTableOrderingComposer
    extends Composer<_$AppDatabase, $TransaksisTable> {
  $$TransaksisTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get tanggal => $composableBuilder(
    column: $table.tanggal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get bulanTagihan => $composableBuilder(
    column: $table.bulanTagihan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deskripsi => $composableBuilder(
    column: $table.deskripsi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get jenis => $composableBuilder(
    column: $table.jenis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalTagihan => $composableBuilder(
    column: $table.totalTagihan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ongkirFee => $composableBuilder(
    column: $table.ongkirFee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catatan => $composableBuilder(
    column: $table.catatan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sumberEkstraksi => $composableBuilder(
    column: $table.sumberEkstraksi,
    builder: (column) => ColumnOrderings(column),
  );

  $$AkunsTableOrderingComposer get akunId {
    final $$AkunsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.akunId,
      referencedTable: $db.akuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AkunsTableOrderingComposer(
            $db: $db,
            $table: $db.akuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SubscriptionsTableOrderingComposer get subscriptionId {
    final $$SubscriptionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subscriptionId,
      referencedTable: $db.subscriptions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubscriptionsTableOrderingComposer(
            $db: $db,
            $table: $db.subscriptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransaksisTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransaksisTable> {
  $$TransaksisTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get tanggal =>
      $composableBuilder(column: $table.tanggal, builder: (column) => column);

  GeneratedColumn<DateTime> get bulanTagihan => $composableBuilder(
    column: $table.bulanTagihan,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deskripsi =>
      $composableBuilder(column: $table.deskripsi, builder: (column) => column);

  GeneratedColumnWithTypeConverter<JenisTransaksi, int> get jenis =>
      $composableBuilder(column: $table.jenis, builder: (column) => column);

  GeneratedColumn<int> get totalTagihan => $composableBuilder(
    column: $table.totalTagihan,
    builder: (column) => column,
  );

  GeneratedColumn<String> get merchant =>
      $composableBuilder(column: $table.merchant, builder: (column) => column);

  GeneratedColumn<int> get ongkirFee =>
      $composableBuilder(column: $table.ongkirFee, builder: (column) => column);

  GeneratedColumnWithTypeConverter<StatusBayar, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get catatan =>
      $composableBuilder(column: $table.catatan, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SumberEkstraksi?, int> get sumberEkstraksi =>
      $composableBuilder(
        column: $table.sumberEkstraksi,
        builder: (column) => column,
      );

  $$AkunsTableAnnotationComposer get akunId {
    final $$AkunsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.akunId,
      referencedTable: $db.akuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AkunsTableAnnotationComposer(
            $db: $db,
            $table: $db.akuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SubscriptionsTableAnnotationComposer get subscriptionId {
    final $$SubscriptionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subscriptionId,
      referencedTable: $db.subscriptions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubscriptionsTableAnnotationComposer(
            $db: $db,
            $table: $db.subscriptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> splitGroupOrdersRefs<T extends Object>(
    Expression<T> Function($$SplitGroupOrdersTableAnnotationComposer a) f,
  ) {
    final $$SplitGroupOrdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.splitGroupOrders,
      getReferencedColumn: (t) => t.transaksiId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SplitGroupOrdersTableAnnotationComposer(
            $db: $db,
            $table: $db.splitGroupOrders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TransaksisTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransaksisTable,
          TransaksiRow,
          $$TransaksisTableFilterComposer,
          $$TransaksisTableOrderingComposer,
          $$TransaksisTableAnnotationComposer,
          $$TransaksisTableCreateCompanionBuilder,
          $$TransaksisTableUpdateCompanionBuilder,
          (TransaksiRow, $$TransaksisTableReferences),
          TransaksiRow,
          PrefetchHooks Function({
            bool akunId,
            bool subscriptionId,
            bool splitGroupOrdersRefs,
          })
        > {
  $$TransaksisTableTableManager(_$AppDatabase db, $TransaksisTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransaksisTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransaksisTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransaksisTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> tanggal = const Value.absent(),
                Value<DateTime?> bulanTagihan = const Value.absent(),
                Value<String> deskripsi = const Value.absent(),
                Value<JenisTransaksi> jenis = const Value.absent(),
                Value<int> akunId = const Value.absent(),
                Value<int> totalTagihan = const Value.absent(),
                Value<String?> merchant = const Value.absent(),
                Value<int> ongkirFee = const Value.absent(),
                Value<StatusBayar> status = const Value.absent(),
                Value<String?> catatan = const Value.absent(),
                Value<int?> subscriptionId = const Value.absent(),
                Value<SumberEkstraksi?> sumberEkstraksi = const Value.absent(),
              }) => TransaksisCompanion(
                id: id,
                tanggal: tanggal,
                bulanTagihan: bulanTagihan,
                deskripsi: deskripsi,
                jenis: jenis,
                akunId: akunId,
                totalTagihan: totalTagihan,
                merchant: merchant,
                ongkirFee: ongkirFee,
                status: status,
                catatan: catatan,
                subscriptionId: subscriptionId,
                sumberEkstraksi: sumberEkstraksi,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime tanggal,
                Value<DateTime?> bulanTagihan = const Value.absent(),
                required String deskripsi,
                required JenisTransaksi jenis,
                required int akunId,
                required int totalTagihan,
                Value<String?> merchant = const Value.absent(),
                Value<int> ongkirFee = const Value.absent(),
                required StatusBayar status,
                Value<String?> catatan = const Value.absent(),
                Value<int?> subscriptionId = const Value.absent(),
                Value<SumberEkstraksi?> sumberEkstraksi = const Value.absent(),
              }) => TransaksisCompanion.insert(
                id: id,
                tanggal: tanggal,
                bulanTagihan: bulanTagihan,
                deskripsi: deskripsi,
                jenis: jenis,
                akunId: akunId,
                totalTagihan: totalTagihan,
                merchant: merchant,
                ongkirFee: ongkirFee,
                status: status,
                catatan: catatan,
                subscriptionId: subscriptionId,
                sumberEkstraksi: sumberEkstraksi,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransaksisTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                akunId = false,
                subscriptionId = false,
                splitGroupOrdersRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (splitGroupOrdersRefs) db.splitGroupOrders,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (akunId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.akunId,
                                    referencedTable: $$TransaksisTableReferences
                                        ._akunIdTable(db),
                                    referencedColumn:
                                        $$TransaksisTableReferences
                                            ._akunIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (subscriptionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.subscriptionId,
                                    referencedTable: $$TransaksisTableReferences
                                        ._subscriptionIdTable(db),
                                    referencedColumn:
                                        $$TransaksisTableReferences
                                            ._subscriptionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (splitGroupOrdersRefs)
                        await $_getPrefetchedData<
                          TransaksiRow,
                          $TransaksisTable,
                          SplitGroupOrderRow
                        >(
                          currentTable: table,
                          referencedTable: $$TransaksisTableReferences
                              ._splitGroupOrdersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TransaksisTableReferences(
                                db,
                                table,
                                p0,
                              ).splitGroupOrdersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.transaksiId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TransaksisTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransaksisTable,
      TransaksiRow,
      $$TransaksisTableFilterComposer,
      $$TransaksisTableOrderingComposer,
      $$TransaksisTableAnnotationComposer,
      $$TransaksisTableCreateCompanionBuilder,
      $$TransaksisTableUpdateCompanionBuilder,
      (TransaksiRow, $$TransaksisTableReferences),
      TransaksiRow,
      PrefetchHooks Function({
        bool akunId,
        bool subscriptionId,
        bool splitGroupOrdersRefs,
      })
    >;
typedef $$SplitGroupOrdersTableCreateCompanionBuilder =
    SplitGroupOrdersCompanion Function({
      Value<int> id,
      required int transaksiId,
      required String nama,
      Value<int?> hargaManual,
      required StatusBayar status,
      Value<String?> catatan,
    });
typedef $$SplitGroupOrdersTableUpdateCompanionBuilder =
    SplitGroupOrdersCompanion Function({
      Value<int> id,
      Value<int> transaksiId,
      Value<String> nama,
      Value<int?> hargaManual,
      Value<StatusBayar> status,
      Value<String?> catatan,
    });

final class $$SplitGroupOrdersTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SplitGroupOrdersTable,
          SplitGroupOrderRow
        > {
  $$SplitGroupOrdersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TransaksisTable _transaksiIdTable(_$AppDatabase db) => db.transaksis
      .createAlias('split_group_orders__transaksi_id__transaksis__id');

  $$TransaksisTableProcessedTableManager get transaksiId {
    final $_column = $_itemColumn<int>('transaksi_id')!;

    final manager = $$TransaksisTableTableManager(
      $_db,
      $_db.transaksis,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transaksiIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SplitGroupOrdersTableFilterComposer
    extends Composer<_$AppDatabase, $SplitGroupOrdersTable> {
  $$SplitGroupOrdersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hargaManual => $composableBuilder(
    column: $table.hargaManual,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<StatusBayar, StatusBayar, int> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get catatan => $composableBuilder(
    column: $table.catatan,
    builder: (column) => ColumnFilters(column),
  );

  $$TransaksisTableFilterComposer get transaksiId {
    final $$TransaksisTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transaksiId,
      referencedTable: $db.transaksis,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransaksisTableFilterComposer(
            $db: $db,
            $table: $db.transaksis,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SplitGroupOrdersTableOrderingComposer
    extends Composer<_$AppDatabase, $SplitGroupOrdersTable> {
  $$SplitGroupOrdersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hargaManual => $composableBuilder(
    column: $table.hargaManual,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catatan => $composableBuilder(
    column: $table.catatan,
    builder: (column) => ColumnOrderings(column),
  );

  $$TransaksisTableOrderingComposer get transaksiId {
    final $$TransaksisTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transaksiId,
      referencedTable: $db.transaksis,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransaksisTableOrderingComposer(
            $db: $db,
            $table: $db.transaksis,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SplitGroupOrdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $SplitGroupOrdersTable> {
  $$SplitGroupOrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nama =>
      $composableBuilder(column: $table.nama, builder: (column) => column);

  GeneratedColumn<int> get hargaManual => $composableBuilder(
    column: $table.hargaManual,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<StatusBayar, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get catatan =>
      $composableBuilder(column: $table.catatan, builder: (column) => column);

  $$TransaksisTableAnnotationComposer get transaksiId {
    final $$TransaksisTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transaksiId,
      referencedTable: $db.transaksis,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransaksisTableAnnotationComposer(
            $db: $db,
            $table: $db.transaksis,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SplitGroupOrdersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SplitGroupOrdersTable,
          SplitGroupOrderRow,
          $$SplitGroupOrdersTableFilterComposer,
          $$SplitGroupOrdersTableOrderingComposer,
          $$SplitGroupOrdersTableAnnotationComposer,
          $$SplitGroupOrdersTableCreateCompanionBuilder,
          $$SplitGroupOrdersTableUpdateCompanionBuilder,
          (SplitGroupOrderRow, $$SplitGroupOrdersTableReferences),
          SplitGroupOrderRow,
          PrefetchHooks Function({bool transaksiId})
        > {
  $$SplitGroupOrdersTableTableManager(
    _$AppDatabase db,
    $SplitGroupOrdersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SplitGroupOrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SplitGroupOrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SplitGroupOrdersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> transaksiId = const Value.absent(),
                Value<String> nama = const Value.absent(),
                Value<int?> hargaManual = const Value.absent(),
                Value<StatusBayar> status = const Value.absent(),
                Value<String?> catatan = const Value.absent(),
              }) => SplitGroupOrdersCompanion(
                id: id,
                transaksiId: transaksiId,
                nama: nama,
                hargaManual: hargaManual,
                status: status,
                catatan: catatan,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int transaksiId,
                required String nama,
                Value<int?> hargaManual = const Value.absent(),
                required StatusBayar status,
                Value<String?> catatan = const Value.absent(),
              }) => SplitGroupOrdersCompanion.insert(
                id: id,
                transaksiId: transaksiId,
                nama: nama,
                hargaManual: hargaManual,
                status: status,
                catatan: catatan,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SplitGroupOrdersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({transaksiId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (transaksiId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.transaksiId,
                                referencedTable:
                                    $$SplitGroupOrdersTableReferences
                                        ._transaksiIdTable(db),
                                referencedColumn:
                                    $$SplitGroupOrdersTableReferences
                                        ._transaksiIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SplitGroupOrdersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SplitGroupOrdersTable,
      SplitGroupOrderRow,
      $$SplitGroupOrdersTableFilterComposer,
      $$SplitGroupOrdersTableOrderingComposer,
      $$SplitGroupOrdersTableAnnotationComposer,
      $$SplitGroupOrdersTableCreateCompanionBuilder,
      $$SplitGroupOrdersTableUpdateCompanionBuilder,
      (SplitGroupOrderRow, $$SplitGroupOrdersTableReferences),
      SplitGroupOrderRow,
      PrefetchHooks Function({bool transaksiId})
    >;
typedef $$CicilansTableCreateCompanionBuilder =
    CicilansCompanion Function({
      Value<int> id,
      required String namaCicilan,
      required int akunId,
      required int totalHargaBarang,
      required int tenor,
      Value<int> cicilanKe,
      required int jumlahPerBulan,
      required DateTime tanggalMulai,
      Value<DateTime?> tanggalBayarTerakhir,
      Value<String?> catatan,
    });
typedef $$CicilansTableUpdateCompanionBuilder =
    CicilansCompanion Function({
      Value<int> id,
      Value<String> namaCicilan,
      Value<int> akunId,
      Value<int> totalHargaBarang,
      Value<int> tenor,
      Value<int> cicilanKe,
      Value<int> jumlahPerBulan,
      Value<DateTime> tanggalMulai,
      Value<DateTime?> tanggalBayarTerakhir,
      Value<String?> catatan,
    });

final class $$CicilansTableReferences
    extends BaseReferences<_$AppDatabase, $CicilansTable, CicilanRow> {
  $$CicilansTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AkunsTable _akunIdTable(_$AppDatabase db) =>
      db.akuns.createAlias('cicilans__akun_id__akuns__id');

  $$AkunsTableProcessedTableManager get akunId {
    final $_column = $_itemColumn<int>('akun_id')!;

    final manager = $$AkunsTableTableManager(
      $_db,
      $_db.akuns,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_akunIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CicilansTableFilterComposer
    extends Composer<_$AppDatabase, $CicilansTable> {
  $$CicilansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get namaCicilan => $composableBuilder(
    column: $table.namaCicilan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalHargaBarang => $composableBuilder(
    column: $table.totalHargaBarang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tenor => $composableBuilder(
    column: $table.tenor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cicilanKe => $composableBuilder(
    column: $table.cicilanKe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get jumlahPerBulan => $composableBuilder(
    column: $table.jumlahPerBulan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get tanggalMulai => $composableBuilder(
    column: $table.tanggalMulai,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get tanggalBayarTerakhir => $composableBuilder(
    column: $table.tanggalBayarTerakhir,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catatan => $composableBuilder(
    column: $table.catatan,
    builder: (column) => ColumnFilters(column),
  );

  $$AkunsTableFilterComposer get akunId {
    final $$AkunsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.akunId,
      referencedTable: $db.akuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AkunsTableFilterComposer(
            $db: $db,
            $table: $db.akuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CicilansTableOrderingComposer
    extends Composer<_$AppDatabase, $CicilansTable> {
  $$CicilansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get namaCicilan => $composableBuilder(
    column: $table.namaCicilan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalHargaBarang => $composableBuilder(
    column: $table.totalHargaBarang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tenor => $composableBuilder(
    column: $table.tenor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cicilanKe => $composableBuilder(
    column: $table.cicilanKe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get jumlahPerBulan => $composableBuilder(
    column: $table.jumlahPerBulan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get tanggalMulai => $composableBuilder(
    column: $table.tanggalMulai,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get tanggalBayarTerakhir => $composableBuilder(
    column: $table.tanggalBayarTerakhir,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catatan => $composableBuilder(
    column: $table.catatan,
    builder: (column) => ColumnOrderings(column),
  );

  $$AkunsTableOrderingComposer get akunId {
    final $$AkunsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.akunId,
      referencedTable: $db.akuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AkunsTableOrderingComposer(
            $db: $db,
            $table: $db.akuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CicilansTableAnnotationComposer
    extends Composer<_$AppDatabase, $CicilansTable> {
  $$CicilansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get namaCicilan => $composableBuilder(
    column: $table.namaCicilan,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalHargaBarang => $composableBuilder(
    column: $table.totalHargaBarang,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tenor =>
      $composableBuilder(column: $table.tenor, builder: (column) => column);

  GeneratedColumn<int> get cicilanKe =>
      $composableBuilder(column: $table.cicilanKe, builder: (column) => column);

  GeneratedColumn<int> get jumlahPerBulan => $composableBuilder(
    column: $table.jumlahPerBulan,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get tanggalMulai => $composableBuilder(
    column: $table.tanggalMulai,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get tanggalBayarTerakhir => $composableBuilder(
    column: $table.tanggalBayarTerakhir,
    builder: (column) => column,
  );

  GeneratedColumn<String> get catatan =>
      $composableBuilder(column: $table.catatan, builder: (column) => column);

  $$AkunsTableAnnotationComposer get akunId {
    final $$AkunsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.akunId,
      referencedTable: $db.akuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AkunsTableAnnotationComposer(
            $db: $db,
            $table: $db.akuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CicilansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CicilansTable,
          CicilanRow,
          $$CicilansTableFilterComposer,
          $$CicilansTableOrderingComposer,
          $$CicilansTableAnnotationComposer,
          $$CicilansTableCreateCompanionBuilder,
          $$CicilansTableUpdateCompanionBuilder,
          (CicilanRow, $$CicilansTableReferences),
          CicilanRow,
          PrefetchHooks Function({bool akunId})
        > {
  $$CicilansTableTableManager(_$AppDatabase db, $CicilansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CicilansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CicilansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CicilansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> namaCicilan = const Value.absent(),
                Value<int> akunId = const Value.absent(),
                Value<int> totalHargaBarang = const Value.absent(),
                Value<int> tenor = const Value.absent(),
                Value<int> cicilanKe = const Value.absent(),
                Value<int> jumlahPerBulan = const Value.absent(),
                Value<DateTime> tanggalMulai = const Value.absent(),
                Value<DateTime?> tanggalBayarTerakhir = const Value.absent(),
                Value<String?> catatan = const Value.absent(),
              }) => CicilansCompanion(
                id: id,
                namaCicilan: namaCicilan,
                akunId: akunId,
                totalHargaBarang: totalHargaBarang,
                tenor: tenor,
                cicilanKe: cicilanKe,
                jumlahPerBulan: jumlahPerBulan,
                tanggalMulai: tanggalMulai,
                tanggalBayarTerakhir: tanggalBayarTerakhir,
                catatan: catatan,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String namaCicilan,
                required int akunId,
                required int totalHargaBarang,
                required int tenor,
                Value<int> cicilanKe = const Value.absent(),
                required int jumlahPerBulan,
                required DateTime tanggalMulai,
                Value<DateTime?> tanggalBayarTerakhir = const Value.absent(),
                Value<String?> catatan = const Value.absent(),
              }) => CicilansCompanion.insert(
                id: id,
                namaCicilan: namaCicilan,
                akunId: akunId,
                totalHargaBarang: totalHargaBarang,
                tenor: tenor,
                cicilanKe: cicilanKe,
                jumlahPerBulan: jumlahPerBulan,
                tanggalMulai: tanggalMulai,
                tanggalBayarTerakhir: tanggalBayarTerakhir,
                catatan: catatan,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CicilansTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({akunId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (akunId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.akunId,
                                referencedTable: $$CicilansTableReferences
                                    ._akunIdTable(db),
                                referencedColumn: $$CicilansTableReferences
                                    ._akunIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CicilansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CicilansTable,
      CicilanRow,
      $$CicilansTableFilterComposer,
      $$CicilansTableOrderingComposer,
      $$CicilansTableAnnotationComposer,
      $$CicilansTableCreateCompanionBuilder,
      $$CicilansTableUpdateCompanionBuilder,
      (CicilanRow, $$CicilansTableReferences),
      CicilanRow,
      PrefetchHooks Function({bool akunId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required int value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<int> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<int> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSettingRow,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSettingRow,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingRow>,
          ),
          AppSettingRow,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<int> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required int value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSettingRow,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSettingRow,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingRow>,
      ),
      AppSettingRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AkunsTableTableManager get akuns =>
      $$AkunsTableTableManager(_db, _db.akuns);
  $$SubscriptionsTableTableManager get subscriptions =>
      $$SubscriptionsTableTableManager(_db, _db.subscriptions);
  $$TransaksisTableTableManager get transaksis =>
      $$TransaksisTableTableManager(_db, _db.transaksis);
  $$SplitGroupOrdersTableTableManager get splitGroupOrders =>
      $$SplitGroupOrdersTableTableManager(_db, _db.splitGroupOrders);
  $$CicilansTableTableManager get cicilans =>
      $$CicilansTableTableManager(_db, _db.cicilans);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
