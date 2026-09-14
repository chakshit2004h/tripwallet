// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalTripsTable extends LocalTrips
    with TableInfo<$LocalTripsTable, LocalTrip> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalTripsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _inviteCodeMeta = const VerificationMeta(
    'inviteCode',
  );
  @override
  late final GeneratedColumn<String> inviteCode = GeneratedColumn<String>(
    'invite_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _baseCurrencyMeta = const VerificationMeta(
    'baseCurrency',
  );
  @override
  late final GeneratedColumn<String> baseCurrency = GeneratedColumn<String>(
    'base_currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('INR'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _crdtSnapshotMeta = const VerificationMeta(
    'crdtSnapshot',
  );
  @override
  late final GeneratedColumn<Uint8List> crdtSnapshot =
      GeneratedColumn<Uint8List>(
        'crdt_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    inviteCode,
    name,
    startDate,
    endDate,
    baseCurrency,
    status,
    crdtSnapshot,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_trips';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalTrip> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('invite_code')) {
      context.handle(
        _inviteCodeMeta,
        inviteCode.isAcceptableOrUnknown(data['invite_code']!, _inviteCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_inviteCodeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('base_currency')) {
      context.handle(
        _baseCurrencyMeta,
        baseCurrency.isAcceptableOrUnknown(
          data['base_currency']!,
          _baseCurrencyMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('crdt_snapshot')) {
      context.handle(
        _crdtSnapshotMeta,
        crdtSnapshot.isAcceptableOrUnknown(
          data['crdt_snapshot']!,
          _crdtSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalTrip map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalTrip(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      inviteCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invite_code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      ),
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      baseCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_currency'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      crdtSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}crdt_snapshot'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalTripsTable createAlias(String alias) {
    return $LocalTripsTable(attachedDatabase, alias);
  }
}

class LocalTrip extends DataClass implements Insertable<LocalTrip> {
  final String id;
  final String inviteCode;
  final String name;
  final DateTime? startDate;
  final DateTime? endDate;
  final String baseCurrency;
  final String status;
  final Uint8List? crdtSnapshot;
  final DateTime updatedAt;
  const LocalTrip({
    required this.id,
    required this.inviteCode,
    required this.name,
    this.startDate,
    this.endDate,
    required this.baseCurrency,
    required this.status,
    this.crdtSnapshot,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['invite_code'] = Variable<String>(inviteCode);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    map['base_currency'] = Variable<String>(baseCurrency);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || crdtSnapshot != null) {
      map['crdt_snapshot'] = Variable<Uint8List>(crdtSnapshot);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalTripsCompanion toCompanion(bool nullToAbsent) {
    return LocalTripsCompanion(
      id: Value(id),
      inviteCode: Value(inviteCode),
      name: Value(name),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      baseCurrency: Value(baseCurrency),
      status: Value(status),
      crdtSnapshot: crdtSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(crdtSnapshot),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalTrip.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalTrip(
      id: serializer.fromJson<String>(json['id']),
      inviteCode: serializer.fromJson<String>(json['inviteCode']),
      name: serializer.fromJson<String>(json['name']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      baseCurrency: serializer.fromJson<String>(json['baseCurrency']),
      status: serializer.fromJson<String>(json['status']),
      crdtSnapshot: serializer.fromJson<Uint8List?>(json['crdtSnapshot']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'inviteCode': serializer.toJson<String>(inviteCode),
      'name': serializer.toJson<String>(name),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'baseCurrency': serializer.toJson<String>(baseCurrency),
      'status': serializer.toJson<String>(status),
      'crdtSnapshot': serializer.toJson<Uint8List?>(crdtSnapshot),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalTrip copyWith({
    String? id,
    String? inviteCode,
    String? name,
    Value<DateTime?> startDate = const Value.absent(),
    Value<DateTime?> endDate = const Value.absent(),
    String? baseCurrency,
    String? status,
    Value<Uint8List?> crdtSnapshot = const Value.absent(),
    DateTime? updatedAt,
  }) => LocalTrip(
    id: id ?? this.id,
    inviteCode: inviteCode ?? this.inviteCode,
    name: name ?? this.name,
    startDate: startDate.present ? startDate.value : this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    baseCurrency: baseCurrency ?? this.baseCurrency,
    status: status ?? this.status,
    crdtSnapshot: crdtSnapshot.present ? crdtSnapshot.value : this.crdtSnapshot,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalTrip copyWithCompanion(LocalTripsCompanion data) {
    return LocalTrip(
      id: data.id.present ? data.id.value : this.id,
      inviteCode: data.inviteCode.present
          ? data.inviteCode.value
          : this.inviteCode,
      name: data.name.present ? data.name.value : this.name,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      baseCurrency: data.baseCurrency.present
          ? data.baseCurrency.value
          : this.baseCurrency,
      status: data.status.present ? data.status.value : this.status,
      crdtSnapshot: data.crdtSnapshot.present
          ? data.crdtSnapshot.value
          : this.crdtSnapshot,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalTrip(')
          ..write('id: $id, ')
          ..write('inviteCode: $inviteCode, ')
          ..write('name: $name, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('baseCurrency: $baseCurrency, ')
          ..write('status: $status, ')
          ..write('crdtSnapshot: $crdtSnapshot, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    inviteCode,
    name,
    startDate,
    endDate,
    baseCurrency,
    status,
    $driftBlobEquality.hash(crdtSnapshot),
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalTrip &&
          other.id == this.id &&
          other.inviteCode == this.inviteCode &&
          other.name == this.name &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.baseCurrency == this.baseCurrency &&
          other.status == this.status &&
          $driftBlobEquality.equals(other.crdtSnapshot, this.crdtSnapshot) &&
          other.updatedAt == this.updatedAt);
}

class LocalTripsCompanion extends UpdateCompanion<LocalTrip> {
  final Value<String> id;
  final Value<String> inviteCode;
  final Value<String> name;
  final Value<DateTime?> startDate;
  final Value<DateTime?> endDate;
  final Value<String> baseCurrency;
  final Value<String> status;
  final Value<Uint8List?> crdtSnapshot;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalTripsCompanion({
    this.id = const Value.absent(),
    this.inviteCode = const Value.absent(),
    this.name = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.baseCurrency = const Value.absent(),
    this.status = const Value.absent(),
    this.crdtSnapshot = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalTripsCompanion.insert({
    required String id,
    required String inviteCode,
    required String name,
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.baseCurrency = const Value.absent(),
    this.status = const Value.absent(),
    this.crdtSnapshot = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       inviteCode = Value(inviteCode),
       name = Value(name);
  static Insertable<LocalTrip> custom({
    Expression<String>? id,
    Expression<String>? inviteCode,
    Expression<String>? name,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? baseCurrency,
    Expression<String>? status,
    Expression<Uint8List>? crdtSnapshot,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (inviteCode != null) 'invite_code': inviteCode,
      if (name != null) 'name': name,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (baseCurrency != null) 'base_currency': baseCurrency,
      if (status != null) 'status': status,
      if (crdtSnapshot != null) 'crdt_snapshot': crdtSnapshot,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalTripsCompanion copyWith({
    Value<String>? id,
    Value<String>? inviteCode,
    Value<String>? name,
    Value<DateTime?>? startDate,
    Value<DateTime?>? endDate,
    Value<String>? baseCurrency,
    Value<String>? status,
    Value<Uint8List?>? crdtSnapshot,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalTripsCompanion(
      id: id ?? this.id,
      inviteCode: inviteCode ?? this.inviteCode,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      status: status ?? this.status,
      crdtSnapshot: crdtSnapshot ?? this.crdtSnapshot,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (inviteCode.present) {
      map['invite_code'] = Variable<String>(inviteCode.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (baseCurrency.present) {
      map['base_currency'] = Variable<String>(baseCurrency.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (crdtSnapshot.present) {
      map['crdt_snapshot'] = Variable<Uint8List>(crdtSnapshot.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalTripsCompanion(')
          ..write('id: $id, ')
          ..write('inviteCode: $inviteCode, ')
          ..write('name: $name, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('baseCurrency: $baseCurrency, ')
          ..write('status: $status, ')
          ..write('crdtSnapshot: $crdtSnapshot, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalMembersTable extends LocalMembers
    with TableInfo<$LocalMembersTable, LocalMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarUrlMeta = const VerificationMeta(
    'avatarUrl',
  );
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
    'avatar_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('member'),
  );
  static const VerificationMeta _paymentVpaMeta = const VerificationMeta(
    'paymentVpa',
  );
  @override
  late final GeneratedColumn<String> paymentVpa = GeneratedColumn<String>(
    'payment_vpa',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tripId,
    displayName,
    avatarUrl,
    role,
    paymentVpa,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalMember> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('avatar_url')) {
      context.handle(
        _avatarUrlMeta,
        avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('payment_vpa')) {
      context.handle(
        _paymentVpaMeta,
        paymentVpa.isAcceptableOrUnknown(data['payment_vpa']!, _paymentVpaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalMember(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      avatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_url'],
      ),
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      paymentVpa: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_vpa'],
      ),
    );
  }

  @override
  $LocalMembersTable createAlias(String alias) {
    return $LocalMembersTable(attachedDatabase, alias);
  }
}

class LocalMember extends DataClass implements Insertable<LocalMember> {
  final String id;
  final String tripId;
  final String displayName;
  final String? avatarUrl;
  final String role;
  final String? paymentVpa;
  const LocalMember({
    required this.id,
    required this.tripId,
    required this.displayName,
    this.avatarUrl,
    required this.role,
    this.paymentVpa,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || paymentVpa != null) {
      map['payment_vpa'] = Variable<String>(paymentVpa);
    }
    return map;
  }

  LocalMembersCompanion toCompanion(bool nullToAbsent) {
    return LocalMembersCompanion(
      id: Value(id),
      tripId: Value(tripId),
      displayName: Value(displayName),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      role: Value(role),
      paymentVpa: paymentVpa == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentVpa),
    );
  }

  factory LocalMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalMember(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      role: serializer.fromJson<String>(json['role']),
      paymentVpa: serializer.fromJson<String?>(json['paymentVpa']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'displayName': serializer.toJson<String>(displayName),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'role': serializer.toJson<String>(role),
      'paymentVpa': serializer.toJson<String?>(paymentVpa),
    };
  }

  LocalMember copyWith({
    String? id,
    String? tripId,
    String? displayName,
    Value<String?> avatarUrl = const Value.absent(),
    String? role,
    Value<String?> paymentVpa = const Value.absent(),
  }) => LocalMember(
    id: id ?? this.id,
    tripId: tripId ?? this.tripId,
    displayName: displayName ?? this.displayName,
    avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
    role: role ?? this.role,
    paymentVpa: paymentVpa.present ? paymentVpa.value : this.paymentVpa,
  );
  LocalMember copyWithCompanion(LocalMembersCompanion data) {
    return LocalMember(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      role: data.role.present ? data.role.value : this.role,
      paymentVpa: data.paymentVpa.present
          ? data.paymentVpa.value
          : this.paymentVpa,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalMember(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('displayName: $displayName, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('role: $role, ')
          ..write('paymentVpa: $paymentVpa')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, tripId, displayName, avatarUrl, role, paymentVpa);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalMember &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.displayName == this.displayName &&
          other.avatarUrl == this.avatarUrl &&
          other.role == this.role &&
          other.paymentVpa == this.paymentVpa);
}

class LocalMembersCompanion extends UpdateCompanion<LocalMember> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<String> displayName;
  final Value<String?> avatarUrl;
  final Value<String> role;
  final Value<String?> paymentVpa;
  final Value<int> rowid;
  const LocalMembersCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.role = const Value.absent(),
    this.paymentVpa = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalMembersCompanion.insert({
    required String id,
    required String tripId,
    required String displayName,
    this.avatarUrl = const Value.absent(),
    this.role = const Value.absent(),
    this.paymentVpa = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tripId = Value(tripId),
       displayName = Value(displayName);
  static Insertable<LocalMember> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<String>? displayName,
    Expression<String>? avatarUrl,
    Expression<String>? role,
    Expression<String>? paymentVpa,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (displayName != null) 'display_name': displayName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (role != null) 'role': role,
      if (paymentVpa != null) 'payment_vpa': paymentVpa,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalMembersCompanion copyWith({
    Value<String>? id,
    Value<String>? tripId,
    Value<String>? displayName,
    Value<String?>? avatarUrl,
    Value<String>? role,
    Value<String?>? paymentVpa,
    Value<int>? rowid,
  }) {
    return LocalMembersCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      paymentVpa: paymentVpa ?? this.paymentVpa,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (paymentVpa.present) {
      map['payment_vpa'] = Variable<String>(paymentVpa.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalMembersCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('displayName: $displayName, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('role: $role, ')
          ..write('paymentVpa: $paymentVpa, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalExpensesTable extends LocalExpenses
    with TableInfo<$LocalExpensesTable, LocalExpense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paidByMemberIdMeta = const VerificationMeta(
    'paidByMemberId',
  );
  @override
  late final GeneratedColumn<String> paidByMemberId = GeneratedColumn<String>(
    'paid_by_member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _splitMethodMeta = const VerificationMeta(
    'splitMethod',
  );
  @override
  late final GeneratedColumn<String> splitMethod = GeneratedColumn<String>(
    'split_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('equal'),
  );
  static const VerificationMeta _taxMinorMeta = const VerificationMeta(
    'taxMinor',
  );
  @override
  late final GeneratedColumn<int> taxMinor = GeneratedColumn<int>(
    'tax_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _serviceChargeMinorMeta =
      const VerificationMeta('serviceChargeMinor');
  @override
  late final GeneratedColumn<int> serviceChargeMinor = GeneratedColumn<int>(
    'service_charge_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tripId,
    title,
    amountMinor,
    currency,
    paidByMemberId,
    splitMethod,
    taxMinor,
    serviceChargeMinor,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalExpense> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('paid_by_member_id')) {
      context.handle(
        _paidByMemberIdMeta,
        paidByMemberId.isAcceptableOrUnknown(
          data['paid_by_member_id']!,
          _paidByMemberIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paidByMemberIdMeta);
    }
    if (data.containsKey('split_method')) {
      context.handle(
        _splitMethodMeta,
        splitMethod.isAcceptableOrUnknown(
          data['split_method']!,
          _splitMethodMeta,
        ),
      );
    }
    if (data.containsKey('tax_minor')) {
      context.handle(
        _taxMinorMeta,
        taxMinor.isAcceptableOrUnknown(data['tax_minor']!, _taxMinorMeta),
      );
    }
    if (data.containsKey('service_charge_minor')) {
      context.handle(
        _serviceChargeMinorMeta,
        serviceChargeMinor.isAcceptableOrUnknown(
          data['service_charge_minor']!,
          _serviceChargeMinorMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalExpense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalExpense(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      paidByMemberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}paid_by_member_id'],
      )!,
      splitMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}split_method'],
      )!,
      taxMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tax_minor'],
      )!,
      serviceChargeMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}service_charge_minor'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LocalExpensesTable createAlias(String alias) {
    return $LocalExpensesTable(attachedDatabase, alias);
  }
}

class LocalExpense extends DataClass implements Insertable<LocalExpense> {
  final String id;
  final String tripId;
  final String title;
  final int amountMinor;
  final String currency;
  final String paidByMemberId;
  final String splitMethod;
  final int taxMinor;
  final int serviceChargeMinor;
  final DateTime createdAt;
  const LocalExpense({
    required this.id,
    required this.tripId,
    required this.title,
    required this.amountMinor,
    required this.currency,
    required this.paidByMemberId,
    required this.splitMethod,
    required this.taxMinor,
    required this.serviceChargeMinor,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    map['title'] = Variable<String>(title);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency'] = Variable<String>(currency);
    map['paid_by_member_id'] = Variable<String>(paidByMemberId);
    map['split_method'] = Variable<String>(splitMethod);
    map['tax_minor'] = Variable<int>(taxMinor);
    map['service_charge_minor'] = Variable<int>(serviceChargeMinor);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LocalExpensesCompanion toCompanion(bool nullToAbsent) {
    return LocalExpensesCompanion(
      id: Value(id),
      tripId: Value(tripId),
      title: Value(title),
      amountMinor: Value(amountMinor),
      currency: Value(currency),
      paidByMemberId: Value(paidByMemberId),
      splitMethod: Value(splitMethod),
      taxMinor: Value(taxMinor),
      serviceChargeMinor: Value(serviceChargeMinor),
      createdAt: Value(createdAt),
    );
  }

  factory LocalExpense.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalExpense(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      title: serializer.fromJson<String>(json['title']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      paidByMemberId: serializer.fromJson<String>(json['paidByMemberId']),
      splitMethod: serializer.fromJson<String>(json['splitMethod']),
      taxMinor: serializer.fromJson<int>(json['taxMinor']),
      serviceChargeMinor: serializer.fromJson<int>(json['serviceChargeMinor']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'title': serializer.toJson<String>(title),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currency': serializer.toJson<String>(currency),
      'paidByMemberId': serializer.toJson<String>(paidByMemberId),
      'splitMethod': serializer.toJson<String>(splitMethod),
      'taxMinor': serializer.toJson<int>(taxMinor),
      'serviceChargeMinor': serializer.toJson<int>(serviceChargeMinor),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LocalExpense copyWith({
    String? id,
    String? tripId,
    String? title,
    int? amountMinor,
    String? currency,
    String? paidByMemberId,
    String? splitMethod,
    int? taxMinor,
    int? serviceChargeMinor,
    DateTime? createdAt,
  }) => LocalExpense(
    id: id ?? this.id,
    tripId: tripId ?? this.tripId,
    title: title ?? this.title,
    amountMinor: amountMinor ?? this.amountMinor,
    currency: currency ?? this.currency,
    paidByMemberId: paidByMemberId ?? this.paidByMemberId,
    splitMethod: splitMethod ?? this.splitMethod,
    taxMinor: taxMinor ?? this.taxMinor,
    serviceChargeMinor: serviceChargeMinor ?? this.serviceChargeMinor,
    createdAt: createdAt ?? this.createdAt,
  );
  LocalExpense copyWithCompanion(LocalExpensesCompanion data) {
    return LocalExpense(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      title: data.title.present ? data.title.value : this.title,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      paidByMemberId: data.paidByMemberId.present
          ? data.paidByMemberId.value
          : this.paidByMemberId,
      splitMethod: data.splitMethod.present
          ? data.splitMethod.value
          : this.splitMethod,
      taxMinor: data.taxMinor.present ? data.taxMinor.value : this.taxMinor,
      serviceChargeMinor: data.serviceChargeMinor.present
          ? data.serviceChargeMinor.value
          : this.serviceChargeMinor,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalExpense(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('title: $title, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('paidByMemberId: $paidByMemberId, ')
          ..write('splitMethod: $splitMethod, ')
          ..write('taxMinor: $taxMinor, ')
          ..write('serviceChargeMinor: $serviceChargeMinor, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tripId,
    title,
    amountMinor,
    currency,
    paidByMemberId,
    splitMethod,
    taxMinor,
    serviceChargeMinor,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalExpense &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.title == this.title &&
          other.amountMinor == this.amountMinor &&
          other.currency == this.currency &&
          other.paidByMemberId == this.paidByMemberId &&
          other.splitMethod == this.splitMethod &&
          other.taxMinor == this.taxMinor &&
          other.serviceChargeMinor == this.serviceChargeMinor &&
          other.createdAt == this.createdAt);
}

class LocalExpensesCompanion extends UpdateCompanion<LocalExpense> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<String> title;
  final Value<int> amountMinor;
  final Value<String> currency;
  final Value<String> paidByMemberId;
  final Value<String> splitMethod;
  final Value<int> taxMinor;
  final Value<int> serviceChargeMinor;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LocalExpensesCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.title = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.paidByMemberId = const Value.absent(),
    this.splitMethod = const Value.absent(),
    this.taxMinor = const Value.absent(),
    this.serviceChargeMinor = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalExpensesCompanion.insert({
    required String id,
    required String tripId,
    required String title,
    required int amountMinor,
    required String currency,
    required String paidByMemberId,
    this.splitMethod = const Value.absent(),
    this.taxMinor = const Value.absent(),
    this.serviceChargeMinor = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tripId = Value(tripId),
       title = Value(title),
       amountMinor = Value(amountMinor),
       currency = Value(currency),
       paidByMemberId = Value(paidByMemberId);
  static Insertable<LocalExpense> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<String>? title,
    Expression<int>? amountMinor,
    Expression<String>? currency,
    Expression<String>? paidByMemberId,
    Expression<String>? splitMethod,
    Expression<int>? taxMinor,
    Expression<int>? serviceChargeMinor,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (title != null) 'title': title,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currency != null) 'currency': currency,
      if (paidByMemberId != null) 'paid_by_member_id': paidByMemberId,
      if (splitMethod != null) 'split_method': splitMethod,
      if (taxMinor != null) 'tax_minor': taxMinor,
      if (serviceChargeMinor != null)
        'service_charge_minor': serviceChargeMinor,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalExpensesCompanion copyWith({
    Value<String>? id,
    Value<String>? tripId,
    Value<String>? title,
    Value<int>? amountMinor,
    Value<String>? currency,
    Value<String>? paidByMemberId,
    Value<String>? splitMethod,
    Value<int>? taxMinor,
    Value<int>? serviceChargeMinor,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return LocalExpensesCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      paidByMemberId: paidByMemberId ?? this.paidByMemberId,
      splitMethod: splitMethod ?? this.splitMethod,
      taxMinor: taxMinor ?? this.taxMinor,
      serviceChargeMinor: serviceChargeMinor ?? this.serviceChargeMinor,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (paidByMemberId.present) {
      map['paid_by_member_id'] = Variable<String>(paidByMemberId.value);
    }
    if (splitMethod.present) {
      map['split_method'] = Variable<String>(splitMethod.value);
    }
    if (taxMinor.present) {
      map['tax_minor'] = Variable<int>(taxMinor.value);
    }
    if (serviceChargeMinor.present) {
      map['service_charge_minor'] = Variable<int>(serviceChargeMinor.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalExpensesCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('title: $title, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('paidByMemberId: $paidByMemberId, ')
          ..write('splitMethod: $splitMethod, ')
          ..write('taxMinor: $taxMinor, ')
          ..write('serviceChargeMinor: $serviceChargeMinor, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalLineItemsTable extends LocalLineItems
    with TableInfo<$LocalLineItemsTable, LocalLineItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalLineItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expenseIdMeta = const VerificationMeta(
    'expenseId',
  );
  @override
  late final GeneratedColumn<String> expenseId = GeneratedColumn<String>(
    'expense_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceMinorMeta = const VerificationMeta(
    'priceMinor',
  );
  @override
  late final GeneratedColumn<int> priceMinor = GeneratedColumn<int>(
    'price_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ocrConfidenceMeta = const VerificationMeta(
    'ocrConfidence',
  );
  @override
  late final GeneratedColumn<double> ocrConfidence = GeneratedColumn<double>(
    'ocr_confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    expenseId,
    label,
    priceMinor,
    ocrConfidence,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_line_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalLineItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('expense_id')) {
      context.handle(
        _expenseIdMeta,
        expenseId.isAcceptableOrUnknown(data['expense_id']!, _expenseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_expenseIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('price_minor')) {
      context.handle(
        _priceMinorMeta,
        priceMinor.isAcceptableOrUnknown(data['price_minor']!, _priceMinorMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMinorMeta);
    }
    if (data.containsKey('ocr_confidence')) {
      context.handle(
        _ocrConfidenceMeta,
        ocrConfidence.isAcceptableOrUnknown(
          data['ocr_confidence']!,
          _ocrConfidenceMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalLineItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalLineItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      expenseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expense_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      priceMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price_minor'],
      )!,
      ocrConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ocr_confidence'],
      )!,
    );
  }

  @override
  $LocalLineItemsTable createAlias(String alias) {
    return $LocalLineItemsTable(attachedDatabase, alias);
  }
}

class LocalLineItem extends DataClass implements Insertable<LocalLineItem> {
  final String id;
  final String expenseId;
  final String label;
  final int priceMinor;
  final double ocrConfidence;
  const LocalLineItem({
    required this.id,
    required this.expenseId,
    required this.label,
    required this.priceMinor,
    required this.ocrConfidence,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['expense_id'] = Variable<String>(expenseId);
    map['label'] = Variable<String>(label);
    map['price_minor'] = Variable<int>(priceMinor);
    map['ocr_confidence'] = Variable<double>(ocrConfidence);
    return map;
  }

  LocalLineItemsCompanion toCompanion(bool nullToAbsent) {
    return LocalLineItemsCompanion(
      id: Value(id),
      expenseId: Value(expenseId),
      label: Value(label),
      priceMinor: Value(priceMinor),
      ocrConfidence: Value(ocrConfidence),
    );
  }

  factory LocalLineItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalLineItem(
      id: serializer.fromJson<String>(json['id']),
      expenseId: serializer.fromJson<String>(json['expenseId']),
      label: serializer.fromJson<String>(json['label']),
      priceMinor: serializer.fromJson<int>(json['priceMinor']),
      ocrConfidence: serializer.fromJson<double>(json['ocrConfidence']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'expenseId': serializer.toJson<String>(expenseId),
      'label': serializer.toJson<String>(label),
      'priceMinor': serializer.toJson<int>(priceMinor),
      'ocrConfidence': serializer.toJson<double>(ocrConfidence),
    };
  }

  LocalLineItem copyWith({
    String? id,
    String? expenseId,
    String? label,
    int? priceMinor,
    double? ocrConfidence,
  }) => LocalLineItem(
    id: id ?? this.id,
    expenseId: expenseId ?? this.expenseId,
    label: label ?? this.label,
    priceMinor: priceMinor ?? this.priceMinor,
    ocrConfidence: ocrConfidence ?? this.ocrConfidence,
  );
  LocalLineItem copyWithCompanion(LocalLineItemsCompanion data) {
    return LocalLineItem(
      id: data.id.present ? data.id.value : this.id,
      expenseId: data.expenseId.present ? data.expenseId.value : this.expenseId,
      label: data.label.present ? data.label.value : this.label,
      priceMinor: data.priceMinor.present
          ? data.priceMinor.value
          : this.priceMinor,
      ocrConfidence: data.ocrConfidence.present
          ? data.ocrConfidence.value
          : this.ocrConfidence,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalLineItem(')
          ..write('id: $id, ')
          ..write('expenseId: $expenseId, ')
          ..write('label: $label, ')
          ..write('priceMinor: $priceMinor, ')
          ..write('ocrConfidence: $ocrConfidence')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, expenseId, label, priceMinor, ocrConfidence);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalLineItem &&
          other.id == this.id &&
          other.expenseId == this.expenseId &&
          other.label == this.label &&
          other.priceMinor == this.priceMinor &&
          other.ocrConfidence == this.ocrConfidence);
}

class LocalLineItemsCompanion extends UpdateCompanion<LocalLineItem> {
  final Value<String> id;
  final Value<String> expenseId;
  final Value<String> label;
  final Value<int> priceMinor;
  final Value<double> ocrConfidence;
  final Value<int> rowid;
  const LocalLineItemsCompanion({
    this.id = const Value.absent(),
    this.expenseId = const Value.absent(),
    this.label = const Value.absent(),
    this.priceMinor = const Value.absent(),
    this.ocrConfidence = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalLineItemsCompanion.insert({
    required String id,
    required String expenseId,
    required String label,
    required int priceMinor,
    this.ocrConfidence = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       expenseId = Value(expenseId),
       label = Value(label),
       priceMinor = Value(priceMinor);
  static Insertable<LocalLineItem> custom({
    Expression<String>? id,
    Expression<String>? expenseId,
    Expression<String>? label,
    Expression<int>? priceMinor,
    Expression<double>? ocrConfidence,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (expenseId != null) 'expense_id': expenseId,
      if (label != null) 'label': label,
      if (priceMinor != null) 'price_minor': priceMinor,
      if (ocrConfidence != null) 'ocr_confidence': ocrConfidence,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalLineItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? expenseId,
    Value<String>? label,
    Value<int>? priceMinor,
    Value<double>? ocrConfidence,
    Value<int>? rowid,
  }) {
    return LocalLineItemsCompanion(
      id: id ?? this.id,
      expenseId: expenseId ?? this.expenseId,
      label: label ?? this.label,
      priceMinor: priceMinor ?? this.priceMinor,
      ocrConfidence: ocrConfidence ?? this.ocrConfidence,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (expenseId.present) {
      map['expense_id'] = Variable<String>(expenseId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (priceMinor.present) {
      map['price_minor'] = Variable<int>(priceMinor.value);
    }
    if (ocrConfidence.present) {
      map['ocr_confidence'] = Variable<double>(ocrConfidence.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalLineItemsCompanion(')
          ..write('id: $id, ')
          ..write('expenseId: $expenseId, ')
          ..write('label: $label, ')
          ..write('priceMinor: $priceMinor, ')
          ..write('ocrConfidence: $ocrConfidence, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalItemClaimsTable extends LocalItemClaims
    with TableInfo<$LocalItemClaimsTable, LocalItemClaim> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalItemClaimsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lineItemIdMeta = const VerificationMeta(
    'lineItemId',
  );
  @override
  late final GeneratedColumn<String> lineItemId = GeneratedColumn<String>(
    'line_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memberIdMeta = const VerificationMeta(
    'memberId',
  );
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
    'member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shareFractionMeta = const VerificationMeta(
    'shareFraction',
  );
  @override
  late final GeneratedColumn<double> shareFraction = GeneratedColumn<double>(
    'share_fraction',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    lineItemId,
    memberId,
    shareFraction,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_item_claims';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalItemClaim> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('line_item_id')) {
      context.handle(
        _lineItemIdMeta,
        lineItemId.isAcceptableOrUnknown(
          data['line_item_id']!,
          _lineItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lineItemIdMeta);
    }
    if (data.containsKey('member_id')) {
      context.handle(
        _memberIdMeta,
        memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta),
      );
    } else if (isInserting) {
      context.missing(_memberIdMeta);
    }
    if (data.containsKey('share_fraction')) {
      context.handle(
        _shareFractionMeta,
        shareFraction.isAcceptableOrUnknown(
          data['share_fraction']!,
          _shareFractionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalItemClaim map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalItemClaim(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      lineItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}line_item_id'],
      )!,
      memberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_id'],
      )!,
      shareFraction: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}share_fraction'],
      )!,
    );
  }

  @override
  $LocalItemClaimsTable createAlias(String alias) {
    return $LocalItemClaimsTable(attachedDatabase, alias);
  }
}

class LocalItemClaim extends DataClass implements Insertable<LocalItemClaim> {
  final String id;
  final String lineItemId;
  final String memberId;
  final double shareFraction;
  const LocalItemClaim({
    required this.id,
    required this.lineItemId,
    required this.memberId,
    required this.shareFraction,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['line_item_id'] = Variable<String>(lineItemId);
    map['member_id'] = Variable<String>(memberId);
    map['share_fraction'] = Variable<double>(shareFraction);
    return map;
  }

  LocalItemClaimsCompanion toCompanion(bool nullToAbsent) {
    return LocalItemClaimsCompanion(
      id: Value(id),
      lineItemId: Value(lineItemId),
      memberId: Value(memberId),
      shareFraction: Value(shareFraction),
    );
  }

  factory LocalItemClaim.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalItemClaim(
      id: serializer.fromJson<String>(json['id']),
      lineItemId: serializer.fromJson<String>(json['lineItemId']),
      memberId: serializer.fromJson<String>(json['memberId']),
      shareFraction: serializer.fromJson<double>(json['shareFraction']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'lineItemId': serializer.toJson<String>(lineItemId),
      'memberId': serializer.toJson<String>(memberId),
      'shareFraction': serializer.toJson<double>(shareFraction),
    };
  }

  LocalItemClaim copyWith({
    String? id,
    String? lineItemId,
    String? memberId,
    double? shareFraction,
  }) => LocalItemClaim(
    id: id ?? this.id,
    lineItemId: lineItemId ?? this.lineItemId,
    memberId: memberId ?? this.memberId,
    shareFraction: shareFraction ?? this.shareFraction,
  );
  LocalItemClaim copyWithCompanion(LocalItemClaimsCompanion data) {
    return LocalItemClaim(
      id: data.id.present ? data.id.value : this.id,
      lineItemId: data.lineItemId.present
          ? data.lineItemId.value
          : this.lineItemId,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      shareFraction: data.shareFraction.present
          ? data.shareFraction.value
          : this.shareFraction,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalItemClaim(')
          ..write('id: $id, ')
          ..write('lineItemId: $lineItemId, ')
          ..write('memberId: $memberId, ')
          ..write('shareFraction: $shareFraction')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, lineItemId, memberId, shareFraction);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalItemClaim &&
          other.id == this.id &&
          other.lineItemId == this.lineItemId &&
          other.memberId == this.memberId &&
          other.shareFraction == this.shareFraction);
}

class LocalItemClaimsCompanion extends UpdateCompanion<LocalItemClaim> {
  final Value<String> id;
  final Value<String> lineItemId;
  final Value<String> memberId;
  final Value<double> shareFraction;
  final Value<int> rowid;
  const LocalItemClaimsCompanion({
    this.id = const Value.absent(),
    this.lineItemId = const Value.absent(),
    this.memberId = const Value.absent(),
    this.shareFraction = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalItemClaimsCompanion.insert({
    required String id,
    required String lineItemId,
    required String memberId,
    this.shareFraction = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       lineItemId = Value(lineItemId),
       memberId = Value(memberId);
  static Insertable<LocalItemClaim> custom({
    Expression<String>? id,
    Expression<String>? lineItemId,
    Expression<String>? memberId,
    Expression<double>? shareFraction,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lineItemId != null) 'line_item_id': lineItemId,
      if (memberId != null) 'member_id': memberId,
      if (shareFraction != null) 'share_fraction': shareFraction,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalItemClaimsCompanion copyWith({
    Value<String>? id,
    Value<String>? lineItemId,
    Value<String>? memberId,
    Value<double>? shareFraction,
    Value<int>? rowid,
  }) {
    return LocalItemClaimsCompanion(
      id: id ?? this.id,
      lineItemId: lineItemId ?? this.lineItemId,
      memberId: memberId ?? this.memberId,
      shareFraction: shareFraction ?? this.shareFraction,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (lineItemId.present) {
      map['line_item_id'] = Variable<String>(lineItemId.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (shareFraction.present) {
      map['share_fraction'] = Variable<double>(shareFraction.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalItemClaimsCompanion(')
          ..write('id: $id, ')
          ..write('lineItemId: $lineItemId, ')
          ..write('memberId: $memberId, ')
          ..write('shareFraction: $shareFraction, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboundSyncQueueTable extends OutboundSyncQueue
    with TableInfo<$OutboundSyncQueueTable, OutboundSyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboundSyncQueueTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _crdtUpdateMeta = const VerificationMeta(
    'crdtUpdate',
  );
  @override
  late final GeneratedColumn<Uint8List> crdtUpdate = GeneratedColumn<Uint8List>(
    'crdt_update',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tripId,
    crdtUpdate,
    createdAt,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbound_sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboundSyncQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('crdt_update')) {
      context.handle(
        _crdtUpdateMeta,
        crdtUpdate.isAcceptableOrUnknown(data['crdt_update']!, _crdtUpdateMeta),
      );
    } else if (isInserting) {
      context.missing(_crdtUpdateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboundSyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboundSyncQueueData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      crdtUpdate: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}crdt_update'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $OutboundSyncQueueTable createAlias(String alias) {
    return $OutboundSyncQueueTable(attachedDatabase, alias);
  }
}

class OutboundSyncQueueData extends DataClass
    implements Insertable<OutboundSyncQueueData> {
  final int id;
  final String tripId;
  final Uint8List crdtUpdate;
  final DateTime createdAt;
  final String status;
  const OutboundSyncQueueData({
    required this.id,
    required this.tripId,
    required this.crdtUpdate,
    required this.createdAt,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['trip_id'] = Variable<String>(tripId);
    map['crdt_update'] = Variable<Uint8List>(crdtUpdate);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['status'] = Variable<String>(status);
    return map;
  }

  OutboundSyncQueueCompanion toCompanion(bool nullToAbsent) {
    return OutboundSyncQueueCompanion(
      id: Value(id),
      tripId: Value(tripId),
      crdtUpdate: Value(crdtUpdate),
      createdAt: Value(createdAt),
      status: Value(status),
    );
  }

  factory OutboundSyncQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboundSyncQueueData(
      id: serializer.fromJson<int>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      crdtUpdate: serializer.fromJson<Uint8List>(json['crdtUpdate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tripId': serializer.toJson<String>(tripId),
      'crdtUpdate': serializer.toJson<Uint8List>(crdtUpdate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'status': serializer.toJson<String>(status),
    };
  }

  OutboundSyncQueueData copyWith({
    int? id,
    String? tripId,
    Uint8List? crdtUpdate,
    DateTime? createdAt,
    String? status,
  }) => OutboundSyncQueueData(
    id: id ?? this.id,
    tripId: tripId ?? this.tripId,
    crdtUpdate: crdtUpdate ?? this.crdtUpdate,
    createdAt: createdAt ?? this.createdAt,
    status: status ?? this.status,
  );
  OutboundSyncQueueData copyWithCompanion(OutboundSyncQueueCompanion data) {
    return OutboundSyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      crdtUpdate: data.crdtUpdate.present
          ? data.crdtUpdate.value
          : this.crdtUpdate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboundSyncQueueData(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('crdtUpdate: $crdtUpdate, ')
          ..write('createdAt: $createdAt, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tripId,
    $driftBlobEquality.hash(crdtUpdate),
    createdAt,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboundSyncQueueData &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          $driftBlobEquality.equals(other.crdtUpdate, this.crdtUpdate) &&
          other.createdAt == this.createdAt &&
          other.status == this.status);
}

class OutboundSyncQueueCompanion
    extends UpdateCompanion<OutboundSyncQueueData> {
  final Value<int> id;
  final Value<String> tripId;
  final Value<Uint8List> crdtUpdate;
  final Value<DateTime> createdAt;
  final Value<String> status;
  const OutboundSyncQueueCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.crdtUpdate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.status = const Value.absent(),
  });
  OutboundSyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String tripId,
    required Uint8List crdtUpdate,
    this.createdAt = const Value.absent(),
    this.status = const Value.absent(),
  }) : tripId = Value(tripId),
       crdtUpdate = Value(crdtUpdate);
  static Insertable<OutboundSyncQueueData> custom({
    Expression<int>? id,
    Expression<String>? tripId,
    Expression<Uint8List>? crdtUpdate,
    Expression<DateTime>? createdAt,
    Expression<String>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (crdtUpdate != null) 'crdt_update': crdtUpdate,
      if (createdAt != null) 'created_at': createdAt,
      if (status != null) 'status': status,
    });
  }

  OutboundSyncQueueCompanion copyWith({
    Value<int>? id,
    Value<String>? tripId,
    Value<Uint8List>? crdtUpdate,
    Value<DateTime>? createdAt,
    Value<String>? status,
  }) {
    return OutboundSyncQueueCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      crdtUpdate: crdtUpdate ?? this.crdtUpdate,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (crdtUpdate.present) {
      map['crdt_update'] = Variable<Uint8List>(crdtUpdate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboundSyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('crdtUpdate: $crdtUpdate, ')
          ..write('createdAt: $createdAt, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalTripsTable localTrips = $LocalTripsTable(this);
  late final $LocalMembersTable localMembers = $LocalMembersTable(this);
  late final $LocalExpensesTable localExpenses = $LocalExpensesTable(this);
  late final $LocalLineItemsTable localLineItems = $LocalLineItemsTable(this);
  late final $LocalItemClaimsTable localItemClaims = $LocalItemClaimsTable(
    this,
  );
  late final $OutboundSyncQueueTable outboundSyncQueue =
      $OutboundSyncQueueTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localTrips,
    localMembers,
    localExpenses,
    localLineItems,
    localItemClaims,
    outboundSyncQueue,
  ];
}

typedef $$LocalTripsTableCreateCompanionBuilder =
    LocalTripsCompanion Function({
      required String id,
      required String inviteCode,
      required String name,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      Value<String> baseCurrency,
      Value<String> status,
      Value<Uint8List?> crdtSnapshot,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$LocalTripsTableUpdateCompanionBuilder =
    LocalTripsCompanion Function({
      Value<String> id,
      Value<String> inviteCode,
      Value<String> name,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      Value<String> baseCurrency,
      Value<String> status,
      Value<Uint8List?> crdtSnapshot,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalTripsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalTripsTable> {
  $$LocalTripsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inviteCode => $composableBuilder(
    column: $table.inviteCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get crdtSnapshot => $composableBuilder(
    column: $table.crdtSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalTripsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalTripsTable> {
  $$LocalTripsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inviteCode => $composableBuilder(
    column: $table.inviteCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get crdtSnapshot => $composableBuilder(
    column: $table.crdtSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalTripsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalTripsTable> {
  $$LocalTripsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get inviteCode => $composableBuilder(
    column: $table.inviteCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<Uint8List> get crdtSnapshot => $composableBuilder(
    column: $table.crdtSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalTripsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalTripsTable,
          LocalTrip,
          $$LocalTripsTableFilterComposer,
          $$LocalTripsTableOrderingComposer,
          $$LocalTripsTableAnnotationComposer,
          $$LocalTripsTableCreateCompanionBuilder,
          $$LocalTripsTableUpdateCompanionBuilder,
          (
            LocalTrip,
            BaseReferences<_$AppDatabase, $LocalTripsTable, LocalTrip>,
          ),
          LocalTrip,
          PrefetchHooks Function()
        > {
  $$LocalTripsTableTableManager(_$AppDatabase db, $LocalTripsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalTripsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalTripsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalTripsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> inviteCode = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<String> baseCurrency = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<Uint8List?> crdtSnapshot = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalTripsCompanion(
                id: id,
                inviteCode: inviteCode,
                name: name,
                startDate: startDate,
                endDate: endDate,
                baseCurrency: baseCurrency,
                status: status,
                crdtSnapshot: crdtSnapshot,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String inviteCode,
                required String name,
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<String> baseCurrency = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<Uint8List?> crdtSnapshot = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalTripsCompanion.insert(
                id: id,
                inviteCode: inviteCode,
                name: name,
                startDate: startDate,
                endDate: endDate,
                baseCurrency: baseCurrency,
                status: status,
                crdtSnapshot: crdtSnapshot,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalTripsTable, LocalTrip>(table),
                  BaseReferences<_$AppDatabase, $LocalTripsTable, LocalTrip>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalTripsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalTripsTable,
      LocalTrip,
      $$LocalTripsTableFilterComposer,
      $$LocalTripsTableOrderingComposer,
      $$LocalTripsTableAnnotationComposer,
      $$LocalTripsTableCreateCompanionBuilder,
      $$LocalTripsTableUpdateCompanionBuilder,
      (LocalTrip, BaseReferences<_$AppDatabase, $LocalTripsTable, LocalTrip>),
      LocalTrip,
      PrefetchHooks Function()
    >;
typedef $$LocalMembersTableCreateCompanionBuilder =
    LocalMembersCompanion Function({
      required String id,
      required String tripId,
      required String displayName,
      Value<String?> avatarUrl,
      Value<String> role,
      Value<String?> paymentVpa,
      Value<int> rowid,
    });
typedef $$LocalMembersTableUpdateCompanionBuilder =
    LocalMembersCompanion Function({
      Value<String> id,
      Value<String> tripId,
      Value<String> displayName,
      Value<String?> avatarUrl,
      Value<String> role,
      Value<String?> paymentVpa,
      Value<int> rowid,
    });

class $$LocalMembersTableFilterComposer
    extends Composer<_$AppDatabase, $LocalMembersTable> {
  $$LocalMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentVpa => $composableBuilder(
    column: $table.paymentVpa,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalMembersTable> {
  $$LocalMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentVpa => $composableBuilder(
    column: $table.paymentVpa,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalMembersTable> {
  $$LocalMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tripId =>
      $composableBuilder(column: $table.tripId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get paymentVpa => $composableBuilder(
    column: $table.paymentVpa,
    builder: (column) => column,
  );
}

class $$LocalMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalMembersTable,
          LocalMember,
          $$LocalMembersTableFilterComposer,
          $$LocalMembersTableOrderingComposer,
          $$LocalMembersTableAnnotationComposer,
          $$LocalMembersTableCreateCompanionBuilder,
          $$LocalMembersTableUpdateCompanionBuilder,
          (
            LocalMember,
            BaseReferences<_$AppDatabase, $LocalMembersTable, LocalMember>,
          ),
          LocalMember,
          PrefetchHooks Function()
        > {
  $$LocalMembersTableTableManager(_$AppDatabase db, $LocalMembersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String?> paymentVpa = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalMembersCompanion(
                id: id,
                tripId: tripId,
                displayName: displayName,
                avatarUrl: avatarUrl,
                role: role,
                paymentVpa: paymentVpa,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tripId,
                required String displayName,
                Value<String?> avatarUrl = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String?> paymentVpa = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalMembersCompanion.insert(
                id: id,
                tripId: tripId,
                displayName: displayName,
                avatarUrl: avatarUrl,
                role: role,
                paymentVpa: paymentVpa,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalMembersTable, LocalMember>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalMembersTable,
                    LocalMember
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalMembersTable,
      LocalMember,
      $$LocalMembersTableFilterComposer,
      $$LocalMembersTableOrderingComposer,
      $$LocalMembersTableAnnotationComposer,
      $$LocalMembersTableCreateCompanionBuilder,
      $$LocalMembersTableUpdateCompanionBuilder,
      (
        LocalMember,
        BaseReferences<_$AppDatabase, $LocalMembersTable, LocalMember>,
      ),
      LocalMember,
      PrefetchHooks Function()
    >;
typedef $$LocalExpensesTableCreateCompanionBuilder =
    LocalExpensesCompanion Function({
      required String id,
      required String tripId,
      required String title,
      required int amountMinor,
      required String currency,
      required String paidByMemberId,
      Value<String> splitMethod,
      Value<int> taxMinor,
      Value<int> serviceChargeMinor,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$LocalExpensesTableUpdateCompanionBuilder =
    LocalExpensesCompanion Function({
      Value<String> id,
      Value<String> tripId,
      Value<String> title,
      Value<int> amountMinor,
      Value<String> currency,
      Value<String> paidByMemberId,
      Value<String> splitMethod,
      Value<int> taxMinor,
      Value<int> serviceChargeMinor,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$LocalExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalExpensesTable> {
  $$LocalExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paidByMemberId => $composableBuilder(
    column: $table.paidByMemberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get splitMethod => $composableBuilder(
    column: $table.splitMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get taxMinor => $composableBuilder(
    column: $table.taxMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serviceChargeMinor => $composableBuilder(
    column: $table.serviceChargeMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalExpensesTable> {
  $$LocalExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paidByMemberId => $composableBuilder(
    column: $table.paidByMemberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get splitMethod => $composableBuilder(
    column: $table.splitMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get taxMinor => $composableBuilder(
    column: $table.taxMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serviceChargeMinor => $composableBuilder(
    column: $table.serviceChargeMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalExpensesTable> {
  $$LocalExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tripId =>
      $composableBuilder(column: $table.tripId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get paidByMemberId => $composableBuilder(
    column: $table.paidByMemberId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get splitMethod => $composableBuilder(
    column: $table.splitMethod,
    builder: (column) => column,
  );

  GeneratedColumn<int> get taxMinor =>
      $composableBuilder(column: $table.taxMinor, builder: (column) => column);

  GeneratedColumn<int> get serviceChargeMinor => $composableBuilder(
    column: $table.serviceChargeMinor,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LocalExpensesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalExpensesTable,
          LocalExpense,
          $$LocalExpensesTableFilterComposer,
          $$LocalExpensesTableOrderingComposer,
          $$LocalExpensesTableAnnotationComposer,
          $$LocalExpensesTableCreateCompanionBuilder,
          $$LocalExpensesTableUpdateCompanionBuilder,
          (
            LocalExpense,
            BaseReferences<_$AppDatabase, $LocalExpensesTable, LocalExpense>,
          ),
          LocalExpense,
          PrefetchHooks Function()
        > {
  $$LocalExpensesTableTableManager(_$AppDatabase db, $LocalExpensesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> paidByMemberId = const Value.absent(),
                Value<String> splitMethod = const Value.absent(),
                Value<int> taxMinor = const Value.absent(),
                Value<int> serviceChargeMinor = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalExpensesCompanion(
                id: id,
                tripId: tripId,
                title: title,
                amountMinor: amountMinor,
                currency: currency,
                paidByMemberId: paidByMemberId,
                splitMethod: splitMethod,
                taxMinor: taxMinor,
                serviceChargeMinor: serviceChargeMinor,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tripId,
                required String title,
                required int amountMinor,
                required String currency,
                required String paidByMemberId,
                Value<String> splitMethod = const Value.absent(),
                Value<int> taxMinor = const Value.absent(),
                Value<int> serviceChargeMinor = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalExpensesCompanion.insert(
                id: id,
                tripId: tripId,
                title: title,
                amountMinor: amountMinor,
                currency: currency,
                paidByMemberId: paidByMemberId,
                splitMethod: splitMethod,
                taxMinor: taxMinor,
                serviceChargeMinor: serviceChargeMinor,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalExpensesTable, LocalExpense>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalExpensesTable,
                    LocalExpense
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalExpensesTable,
      LocalExpense,
      $$LocalExpensesTableFilterComposer,
      $$LocalExpensesTableOrderingComposer,
      $$LocalExpensesTableAnnotationComposer,
      $$LocalExpensesTableCreateCompanionBuilder,
      $$LocalExpensesTableUpdateCompanionBuilder,
      (
        LocalExpense,
        BaseReferences<_$AppDatabase, $LocalExpensesTable, LocalExpense>,
      ),
      LocalExpense,
      PrefetchHooks Function()
    >;
typedef $$LocalLineItemsTableCreateCompanionBuilder =
    LocalLineItemsCompanion Function({
      required String id,
      required String expenseId,
      required String label,
      required int priceMinor,
      Value<double> ocrConfidence,
      Value<int> rowid,
    });
typedef $$LocalLineItemsTableUpdateCompanionBuilder =
    LocalLineItemsCompanion Function({
      Value<String> id,
      Value<String> expenseId,
      Value<String> label,
      Value<int> priceMinor,
      Value<double> ocrConfidence,
      Value<int> rowid,
    });

class $$LocalLineItemsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalLineItemsTable> {
  $$LocalLineItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get expenseId => $composableBuilder(
    column: $table.expenseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priceMinor => $composableBuilder(
    column: $table.priceMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ocrConfidence => $composableBuilder(
    column: $table.ocrConfidence,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalLineItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalLineItemsTable> {
  $$LocalLineItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expenseId => $composableBuilder(
    column: $table.expenseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priceMinor => $composableBuilder(
    column: $table.priceMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ocrConfidence => $composableBuilder(
    column: $table.ocrConfidence,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalLineItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalLineItemsTable> {
  $$LocalLineItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get expenseId =>
      $composableBuilder(column: $table.expenseId, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get priceMinor => $composableBuilder(
    column: $table.priceMinor,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ocrConfidence => $composableBuilder(
    column: $table.ocrConfidence,
    builder: (column) => column,
  );
}

class $$LocalLineItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalLineItemsTable,
          LocalLineItem,
          $$LocalLineItemsTableFilterComposer,
          $$LocalLineItemsTableOrderingComposer,
          $$LocalLineItemsTableAnnotationComposer,
          $$LocalLineItemsTableCreateCompanionBuilder,
          $$LocalLineItemsTableUpdateCompanionBuilder,
          (
            LocalLineItem,
            BaseReferences<_$AppDatabase, $LocalLineItemsTable, LocalLineItem>,
          ),
          LocalLineItem,
          PrefetchHooks Function()
        > {
  $$LocalLineItemsTableTableManager(
    _$AppDatabase db,
    $LocalLineItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalLineItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalLineItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalLineItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> expenseId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<int> priceMinor = const Value.absent(),
                Value<double> ocrConfidence = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalLineItemsCompanion(
                id: id,
                expenseId: expenseId,
                label: label,
                priceMinor: priceMinor,
                ocrConfidence: ocrConfidence,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String expenseId,
                required String label,
                required int priceMinor,
                Value<double> ocrConfidence = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalLineItemsCompanion.insert(
                id: id,
                expenseId: expenseId,
                label: label,
                priceMinor: priceMinor,
                ocrConfidence: ocrConfidence,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalLineItemsTable, LocalLineItem>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalLineItemsTable,
                    LocalLineItem
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalLineItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalLineItemsTable,
      LocalLineItem,
      $$LocalLineItemsTableFilterComposer,
      $$LocalLineItemsTableOrderingComposer,
      $$LocalLineItemsTableAnnotationComposer,
      $$LocalLineItemsTableCreateCompanionBuilder,
      $$LocalLineItemsTableUpdateCompanionBuilder,
      (
        LocalLineItem,
        BaseReferences<_$AppDatabase, $LocalLineItemsTable, LocalLineItem>,
      ),
      LocalLineItem,
      PrefetchHooks Function()
    >;
typedef $$LocalItemClaimsTableCreateCompanionBuilder =
    LocalItemClaimsCompanion Function({
      required String id,
      required String lineItemId,
      required String memberId,
      Value<double> shareFraction,
      Value<int> rowid,
    });
typedef $$LocalItemClaimsTableUpdateCompanionBuilder =
    LocalItemClaimsCompanion Function({
      Value<String> id,
      Value<String> lineItemId,
      Value<String> memberId,
      Value<double> shareFraction,
      Value<int> rowid,
    });

class $$LocalItemClaimsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalItemClaimsTable> {
  $$LocalItemClaimsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lineItemId => $composableBuilder(
    column: $table.lineItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get shareFraction => $composableBuilder(
    column: $table.shareFraction,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalItemClaimsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalItemClaimsTable> {
  $$LocalItemClaimsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lineItemId => $composableBuilder(
    column: $table.lineItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get shareFraction => $composableBuilder(
    column: $table.shareFraction,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalItemClaimsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalItemClaimsTable> {
  $$LocalItemClaimsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get lineItemId => $composableBuilder(
    column: $table.lineItemId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get memberId =>
      $composableBuilder(column: $table.memberId, builder: (column) => column);

  GeneratedColumn<double> get shareFraction => $composableBuilder(
    column: $table.shareFraction,
    builder: (column) => column,
  );
}

class $$LocalItemClaimsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalItemClaimsTable,
          LocalItemClaim,
          $$LocalItemClaimsTableFilterComposer,
          $$LocalItemClaimsTableOrderingComposer,
          $$LocalItemClaimsTableAnnotationComposer,
          $$LocalItemClaimsTableCreateCompanionBuilder,
          $$LocalItemClaimsTableUpdateCompanionBuilder,
          (
            LocalItemClaim,
            BaseReferences<
              _$AppDatabase,
              $LocalItemClaimsTable,
              LocalItemClaim
            >,
          ),
          LocalItemClaim,
          PrefetchHooks Function()
        > {
  $$LocalItemClaimsTableTableManager(
    _$AppDatabase db,
    $LocalItemClaimsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalItemClaimsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalItemClaimsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalItemClaimsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> lineItemId = const Value.absent(),
                Value<String> memberId = const Value.absent(),
                Value<double> shareFraction = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalItemClaimsCompanion(
                id: id,
                lineItemId: lineItemId,
                memberId: memberId,
                shareFraction: shareFraction,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String lineItemId,
                required String memberId,
                Value<double> shareFraction = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalItemClaimsCompanion.insert(
                id: id,
                lineItemId: lineItemId,
                memberId: memberId,
                shareFraction: shareFraction,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalItemClaimsTable, LocalItemClaim>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalItemClaimsTable,
                    LocalItemClaim
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalItemClaimsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalItemClaimsTable,
      LocalItemClaim,
      $$LocalItemClaimsTableFilterComposer,
      $$LocalItemClaimsTableOrderingComposer,
      $$LocalItemClaimsTableAnnotationComposer,
      $$LocalItemClaimsTableCreateCompanionBuilder,
      $$LocalItemClaimsTableUpdateCompanionBuilder,
      (
        LocalItemClaim,
        BaseReferences<_$AppDatabase, $LocalItemClaimsTable, LocalItemClaim>,
      ),
      LocalItemClaim,
      PrefetchHooks Function()
    >;
typedef $$OutboundSyncQueueTableCreateCompanionBuilder =
    OutboundSyncQueueCompanion Function({
      Value<int> id,
      required String tripId,
      required Uint8List crdtUpdate,
      Value<DateTime> createdAt,
      Value<String> status,
    });
typedef $$OutboundSyncQueueTableUpdateCompanionBuilder =
    OutboundSyncQueueCompanion Function({
      Value<int> id,
      Value<String> tripId,
      Value<Uint8List> crdtUpdate,
      Value<DateTime> createdAt,
      Value<String> status,
    });

class $$OutboundSyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $OutboundSyncQueueTable> {
  $$OutboundSyncQueueTableFilterComposer({
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

  ColumnFilters<String> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get crdtUpdate => $composableBuilder(
    column: $table.crdtUpdate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboundSyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboundSyncQueueTable> {
  $$OutboundSyncQueueTableOrderingComposer({
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

  ColumnOrderings<String> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get crdtUpdate => $composableBuilder(
    column: $table.crdtUpdate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboundSyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboundSyncQueueTable> {
  $$OutboundSyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tripId =>
      $composableBuilder(column: $table.tripId, builder: (column) => column);

  GeneratedColumn<Uint8List> get crdtUpdate => $composableBuilder(
    column: $table.crdtUpdate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$OutboundSyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboundSyncQueueTable,
          OutboundSyncQueueData,
          $$OutboundSyncQueueTableFilterComposer,
          $$OutboundSyncQueueTableOrderingComposer,
          $$OutboundSyncQueueTableAnnotationComposer,
          $$OutboundSyncQueueTableCreateCompanionBuilder,
          $$OutboundSyncQueueTableUpdateCompanionBuilder,
          (
            OutboundSyncQueueData,
            BaseReferences<
              _$AppDatabase,
              $OutboundSyncQueueTable,
              OutboundSyncQueueData
            >,
          ),
          OutboundSyncQueueData,
          PrefetchHooks Function()
        > {
  $$OutboundSyncQueueTableTableManager(
    _$AppDatabase db,
    $OutboundSyncQueueTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboundSyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboundSyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboundSyncQueueTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<Uint8List> crdtUpdate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> status = const Value.absent(),
              }) => OutboundSyncQueueCompanion(
                id: id,
                tripId: tripId,
                crdtUpdate: crdtUpdate,
                createdAt: createdAt,
                status: status,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String tripId,
                required Uint8List crdtUpdate,
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> status = const Value.absent(),
              }) => OutboundSyncQueueCompanion.insert(
                id: id,
                tripId: tripId,
                crdtUpdate: crdtUpdate,
                createdAt: createdAt,
                status: status,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OutboundSyncQueueTable, OutboundSyncQueueData>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $OutboundSyncQueueTable,
                    OutboundSyncQueueData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboundSyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboundSyncQueueTable,
      OutboundSyncQueueData,
      $$OutboundSyncQueueTableFilterComposer,
      $$OutboundSyncQueueTableOrderingComposer,
      $$OutboundSyncQueueTableAnnotationComposer,
      $$OutboundSyncQueueTableCreateCompanionBuilder,
      $$OutboundSyncQueueTableUpdateCompanionBuilder,
      (
        OutboundSyncQueueData,
        BaseReferences<
          _$AppDatabase,
          $OutboundSyncQueueTable,
          OutboundSyncQueueData
        >,
      ),
      OutboundSyncQueueData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalTripsTableTableManager get localTrips =>
      $$LocalTripsTableTableManager(_db, _db.localTrips);
  $$LocalMembersTableTableManager get localMembers =>
      $$LocalMembersTableTableManager(_db, _db.localMembers);
  $$LocalExpensesTableTableManager get localExpenses =>
      $$LocalExpensesTableTableManager(_db, _db.localExpenses);
  $$LocalLineItemsTableTableManager get localLineItems =>
      $$LocalLineItemsTableTableManager(_db, _db.localLineItems);
  $$LocalItemClaimsTableTableManager get localItemClaims =>
      $$LocalItemClaimsTableTableManager(_db, _db.localItemClaims);
  $$OutboundSyncQueueTableTableManager get outboundSyncQueue =>
      $$OutboundSyncQueueTableTableManager(_db, _db.outboundSyncQueue);
}
