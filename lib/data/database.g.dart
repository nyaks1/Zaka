// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $AccountsTable extends Accounts with TableInfo<$AccountsTable, Account> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _institutionMeta = const VerificationMeta(
    'institution',
  );
  @override
  late final GeneratedColumn<String> institution = GeneratedColumn<String>(
    'institution',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('cash'),
  );
  static const VerificationMeta _openingBalanceCentsMeta =
      const VerificationMeta('openingBalanceCents');
  @override
  late final GeneratedColumn<int> openingBalanceCents = GeneratedColumn<int>(
    'opening_balance_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    name,
    institution,
    kind,
    openingBalanceCents,
    archived,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Account> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('institution')) {
      context.handle(
        _institutionMeta,
        institution.isAcceptableOrUnknown(
          data['institution']!,
          _institutionMeta,
        ),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('opening_balance_cents')) {
      context.handle(
        _openingBalanceCentsMeta,
        openingBalanceCents.isAcceptableOrUnknown(
          data['opening_balance_cents']!,
          _openingBalanceCentsMeta,
        ),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
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
  Account map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Account(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      institution: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}institution'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      openingBalanceCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}opening_balance_cents'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class Account extends DataClass implements Insertable<Account> {
  final int id;
  final String name;
  final String institution;

  /// One of `cash`, `cheque`, `savings`, `credit`.
  final String kind;

  /// The balance before Zaka started tracking this account.
  final int openingBalanceCents;
  final bool archived;
  final DateTime createdAt;
  const Account({
    required this.id,
    required this.name,
    required this.institution,
    required this.kind,
    required this.openingBalanceCents,
    required this.archived,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['institution'] = Variable<String>(institution);
    map['kind'] = Variable<String>(kind);
    map['opening_balance_cents'] = Variable<int>(openingBalanceCents);
    map['archived'] = Variable<bool>(archived);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      name: Value(name),
      institution: Value(institution),
      kind: Value(kind),
      openingBalanceCents: Value(openingBalanceCents),
      archived: Value(archived),
      createdAt: Value(createdAt),
    );
  }

  factory Account.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      institution: serializer.fromJson<String>(json['institution']),
      kind: serializer.fromJson<String>(json['kind']),
      openingBalanceCents: serializer.fromJson<int>(
        json['openingBalanceCents'],
      ),
      archived: serializer.fromJson<bool>(json['archived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'institution': serializer.toJson<String>(institution),
      'kind': serializer.toJson<String>(kind),
      'openingBalanceCents': serializer.toJson<int>(openingBalanceCents),
      'archived': serializer.toJson<bool>(archived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Account copyWith({
    int? id,
    String? name,
    String? institution,
    String? kind,
    int? openingBalanceCents,
    bool? archived,
    DateTime? createdAt,
  }) => Account(
    id: id ?? this.id,
    name: name ?? this.name,
    institution: institution ?? this.institution,
    kind: kind ?? this.kind,
    openingBalanceCents: openingBalanceCents ?? this.openingBalanceCents,
    archived: archived ?? this.archived,
    createdAt: createdAt ?? this.createdAt,
  );
  Account copyWithCompanion(AccountsCompanion data) {
    return Account(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      institution: data.institution.present
          ? data.institution.value
          : this.institution,
      kind: data.kind.present ? data.kind.value : this.kind,
      openingBalanceCents: data.openingBalanceCents.present
          ? data.openingBalanceCents.value
          : this.openingBalanceCents,
      archived: data.archived.present ? data.archived.value : this.archived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('institution: $institution, ')
          ..write('kind: $kind, ')
          ..write('openingBalanceCents: $openingBalanceCents, ')
          ..write('archived: $archived, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    institution,
    kind,
    openingBalanceCents,
    archived,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.id == this.id &&
          other.name == this.name &&
          other.institution == this.institution &&
          other.kind == this.kind &&
          other.openingBalanceCents == this.openingBalanceCents &&
          other.archived == this.archived &&
          other.createdAt == this.createdAt);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> institution;
  final Value<String> kind;
  final Value<int> openingBalanceCents;
  final Value<bool> archived;
  final Value<DateTime> createdAt;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.institution = const Value.absent(),
    this.kind = const Value.absent(),
    this.openingBalanceCents = const Value.absent(),
    this.archived = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AccountsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.institution = const Value.absent(),
    this.kind = const Value.absent(),
    this.openingBalanceCents = const Value.absent(),
    this.archived = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Account> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? institution,
    Expression<String>? kind,
    Expression<int>? openingBalanceCents,
    Expression<bool>? archived,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (institution != null) 'institution': institution,
      if (kind != null) 'kind': kind,
      if (openingBalanceCents != null)
        'opening_balance_cents': openingBalanceCents,
      if (archived != null) 'archived': archived,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AccountsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? institution,
    Value<String>? kind,
    Value<int>? openingBalanceCents,
    Value<bool>? archived,
    Value<DateTime>? createdAt,
  }) {
    return AccountsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      institution: institution ?? this.institution,
      kind: kind ?? this.kind,
      openingBalanceCents: openingBalanceCents ?? this.openingBalanceCents,
      archived: archived ?? this.archived,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (institution.present) {
      map['institution'] = Variable<String>(institution.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (openingBalanceCents.present) {
      map['opening_balance_cents'] = Variable<int>(openingBalanceCents.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('institution: $institution, ')
          ..write('kind: $kind, ')
          ..write('openingBalanceCents: $openingBalanceCents, ')
          ..write('archived: $archived, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $WithdrawalsTable extends Withdrawals
    with TableInfo<$WithdrawalsTable, Withdrawal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WithdrawalsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _withdrawnAtMeta = const VerificationMeta(
    'withdrawnAt',
  );
  @override
  late final GeneratedColumn<DateTime> withdrawnAt = GeneratedColumn<DateTime>(
    'withdrawn_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
    'account_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _importKeyMeta = const VerificationMeta(
    'importKey',
  );
  @override
  late final GeneratedColumn<String> importKey = GeneratedColumn<String>(
    'import_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
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
    amountCents,
    withdrawnAt,
    note,
    accountId,
    importKey,
    source,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'withdrawals';
  @override
  VerificationContext validateIntegrity(
    Insertable<Withdrawal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('withdrawn_at')) {
      context.handle(
        _withdrawnAtMeta,
        withdrawnAt.isAcceptableOrUnknown(
          data['withdrawn_at']!,
          _withdrawnAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_withdrawnAtMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    }
    if (data.containsKey('import_key')) {
      context.handle(
        _importKeyMeta,
        importKey.isAcceptableOrUnknown(data['import_key']!, _importKeyMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
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
  Withdrawal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Withdrawal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
      withdrawnAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}withdrawn_at'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}account_id'],
      ),
      importKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}import_key'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $WithdrawalsTable createAlias(String alias) {
    return $WithdrawalsTable(attachedDatabase, alias);
  }
}

class Withdrawal extends DataClass implements Insertable<Withdrawal> {
  final int id;
  final int amountCents;
  final DateTime withdrawnAt;
  final String? note;
  final int? accountId;

  /// Stable key used to skip a statement row that was already imported.
  final String? importKey;

  /// `manual`, `import`, or `sync` (a future bank feed).
  final String source;
  final DateTime createdAt;
  const Withdrawal({
    required this.id,
    required this.amountCents,
    required this.withdrawnAt,
    this.note,
    this.accountId,
    this.importKey,
    required this.source,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['amount_cents'] = Variable<int>(amountCents);
    map['withdrawn_at'] = Variable<DateTime>(withdrawnAt);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<int>(accountId);
    }
    if (!nullToAbsent || importKey != null) {
      map['import_key'] = Variable<String>(importKey);
    }
    map['source'] = Variable<String>(source);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WithdrawalsCompanion toCompanion(bool nullToAbsent) {
    return WithdrawalsCompanion(
      id: Value(id),
      amountCents: Value(amountCents),
      withdrawnAt: Value(withdrawnAt),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      importKey: importKey == null && nullToAbsent
          ? const Value.absent()
          : Value(importKey),
      source: Value(source),
      createdAt: Value(createdAt),
    );
  }

  factory Withdrawal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Withdrawal(
      id: serializer.fromJson<int>(json['id']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      withdrawnAt: serializer.fromJson<DateTime>(json['withdrawnAt']),
      note: serializer.fromJson<String?>(json['note']),
      accountId: serializer.fromJson<int?>(json['accountId']),
      importKey: serializer.fromJson<String?>(json['importKey']),
      source: serializer.fromJson<String>(json['source']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'amountCents': serializer.toJson<int>(amountCents),
      'withdrawnAt': serializer.toJson<DateTime>(withdrawnAt),
      'note': serializer.toJson<String?>(note),
      'accountId': serializer.toJson<int?>(accountId),
      'importKey': serializer.toJson<String?>(importKey),
      'source': serializer.toJson<String>(source),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Withdrawal copyWith({
    int? id,
    int? amountCents,
    DateTime? withdrawnAt,
    Value<String?> note = const Value.absent(),
    Value<int?> accountId = const Value.absent(),
    Value<String?> importKey = const Value.absent(),
    String? source,
    DateTime? createdAt,
  }) => Withdrawal(
    id: id ?? this.id,
    amountCents: amountCents ?? this.amountCents,
    withdrawnAt: withdrawnAt ?? this.withdrawnAt,
    note: note.present ? note.value : this.note,
    accountId: accountId.present ? accountId.value : this.accountId,
    importKey: importKey.present ? importKey.value : this.importKey,
    source: source ?? this.source,
    createdAt: createdAt ?? this.createdAt,
  );
  Withdrawal copyWithCompanion(WithdrawalsCompanion data) {
    return Withdrawal(
      id: data.id.present ? data.id.value : this.id,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      withdrawnAt: data.withdrawnAt.present
          ? data.withdrawnAt.value
          : this.withdrawnAt,
      note: data.note.present ? data.note.value : this.note,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      importKey: data.importKey.present ? data.importKey.value : this.importKey,
      source: data.source.present ? data.source.value : this.source,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Withdrawal(')
          ..write('id: $id, ')
          ..write('amountCents: $amountCents, ')
          ..write('withdrawnAt: $withdrawnAt, ')
          ..write('note: $note, ')
          ..write('accountId: $accountId, ')
          ..write('importKey: $importKey, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    amountCents,
    withdrawnAt,
    note,
    accountId,
    importKey,
    source,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Withdrawal &&
          other.id == this.id &&
          other.amountCents == this.amountCents &&
          other.withdrawnAt == this.withdrawnAt &&
          other.note == this.note &&
          other.accountId == this.accountId &&
          other.importKey == this.importKey &&
          other.source == this.source &&
          other.createdAt == this.createdAt);
}

class WithdrawalsCompanion extends UpdateCompanion<Withdrawal> {
  final Value<int> id;
  final Value<int> amountCents;
  final Value<DateTime> withdrawnAt;
  final Value<String?> note;
  final Value<int?> accountId;
  final Value<String?> importKey;
  final Value<String> source;
  final Value<DateTime> createdAt;
  const WithdrawalsCompanion({
    this.id = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.withdrawnAt = const Value.absent(),
    this.note = const Value.absent(),
    this.accountId = const Value.absent(),
    this.importKey = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  WithdrawalsCompanion.insert({
    this.id = const Value.absent(),
    required int amountCents,
    required DateTime withdrawnAt,
    this.note = const Value.absent(),
    this.accountId = const Value.absent(),
    this.importKey = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : amountCents = Value(amountCents),
       withdrawnAt = Value(withdrawnAt);
  static Insertable<Withdrawal> custom({
    Expression<int>? id,
    Expression<int>? amountCents,
    Expression<DateTime>? withdrawnAt,
    Expression<String>? note,
    Expression<int>? accountId,
    Expression<String>? importKey,
    Expression<String>? source,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amountCents != null) 'amount_cents': amountCents,
      if (withdrawnAt != null) 'withdrawn_at': withdrawnAt,
      if (note != null) 'note': note,
      if (accountId != null) 'account_id': accountId,
      if (importKey != null) 'import_key': importKey,
      if (source != null) 'source': source,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  WithdrawalsCompanion copyWith({
    Value<int>? id,
    Value<int>? amountCents,
    Value<DateTime>? withdrawnAt,
    Value<String?>? note,
    Value<int?>? accountId,
    Value<String?>? importKey,
    Value<String>? source,
    Value<DateTime>? createdAt,
  }) {
    return WithdrawalsCompanion(
      id: id ?? this.id,
      amountCents: amountCents ?? this.amountCents,
      withdrawnAt: withdrawnAt ?? this.withdrawnAt,
      note: note ?? this.note,
      accountId: accountId ?? this.accountId,
      importKey: importKey ?? this.importKey,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (withdrawnAt.present) {
      map['withdrawn_at'] = Variable<DateTime>(withdrawnAt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (importKey.present) {
      map['import_key'] = Variable<String>(importKey.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WithdrawalsCompanion(')
          ..write('id: $id, ')
          ..write('amountCents: $amountCents, ')
          ..write('withdrawnAt: $withdrawnAt, ')
          ..write('note: $note, ')
          ..write('accountId: $accountId, ')
          ..write('importKey: $importKey, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $RecurringRulesTable extends RecurringRules
    with TableInfo<$RecurringRulesTable, RecurringRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringRulesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
    'account_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _daysOfWeekMeta = const VerificationMeta(
    'daysOfWeek',
  );
  @override
  late final GeneratedColumn<String> daysOfWeek = GeneratedColumn<String>(
    'days_of_week',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startsOnMeta = const VerificationMeta(
    'startsOn',
  );
  @override
  late final GeneratedColumn<DateTime> startsOn = GeneratedColumn<DateTime>(
    'starts_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endsOnMeta = const VerificationMeta('endsOn');
  @override
  late final GeneratedColumn<DateTime> endsOn = GeneratedColumn<DateTime>(
    'ends_on',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastPostedOnMeta = const VerificationMeta(
    'lastPostedOn',
  );
  @override
  late final GeneratedColumn<DateTime> lastPostedOn = GeneratedColumn<DateTime>(
    'last_posted_on',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
    amountCents,
    category,
    note,
    accountId,
    daysOfWeek,
    startsOn,
    endsOn,
    active,
    lastPostedOn,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecurringRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    }
    if (data.containsKey('days_of_week')) {
      context.handle(
        _daysOfWeekMeta,
        daysOfWeek.isAcceptableOrUnknown(
          data['days_of_week']!,
          _daysOfWeekMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_daysOfWeekMeta);
    }
    if (data.containsKey('starts_on')) {
      context.handle(
        _startsOnMeta,
        startsOn.isAcceptableOrUnknown(data['starts_on']!, _startsOnMeta),
      );
    } else if (isInserting) {
      context.missing(_startsOnMeta);
    }
    if (data.containsKey('ends_on')) {
      context.handle(
        _endsOnMeta,
        endsOn.isAcceptableOrUnknown(data['ends_on']!, _endsOnMeta),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('last_posted_on')) {
      context.handle(
        _lastPostedOnMeta,
        lastPostedOn.isAcceptableOrUnknown(
          data['last_posted_on']!,
          _lastPostedOnMeta,
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
  RecurringRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}account_id'],
      ),
      daysOfWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}days_of_week'],
      )!,
      startsOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}starts_on'],
      )!,
      endsOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ends_on'],
      ),
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      lastPostedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_posted_on'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RecurringRulesTable createAlias(String alias) {
    return $RecurringRulesTable(attachedDatabase, alias);
  }
}

class RecurringRule extends DataClass implements Insertable<RecurringRule> {
  final int id;
  final int amountCents;
  final String category;
  final String? note;
  final int? accountId;

  /// ISO weekdays, comma separated: 1 = Monday ... 7 = Sunday.
  final String daysOfWeek;
  final DateTime startsOn;
  final DateTime? endsOn;
  final bool active;

  /// The last day this rule generated a spend for. Prevents duplicates.
  final DateTime? lastPostedOn;
  final DateTime createdAt;
  const RecurringRule({
    required this.id,
    required this.amountCents,
    required this.category,
    this.note,
    this.accountId,
    required this.daysOfWeek,
    required this.startsOn,
    this.endsOn,
    required this.active,
    this.lastPostedOn,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['amount_cents'] = Variable<int>(amountCents);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<int>(accountId);
    }
    map['days_of_week'] = Variable<String>(daysOfWeek);
    map['starts_on'] = Variable<DateTime>(startsOn);
    if (!nullToAbsent || endsOn != null) {
      map['ends_on'] = Variable<DateTime>(endsOn);
    }
    map['active'] = Variable<bool>(active);
    if (!nullToAbsent || lastPostedOn != null) {
      map['last_posted_on'] = Variable<DateTime>(lastPostedOn);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RecurringRulesCompanion toCompanion(bool nullToAbsent) {
    return RecurringRulesCompanion(
      id: Value(id),
      amountCents: Value(amountCents),
      category: Value(category),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      daysOfWeek: Value(daysOfWeek),
      startsOn: Value(startsOn),
      endsOn: endsOn == null && nullToAbsent
          ? const Value.absent()
          : Value(endsOn),
      active: Value(active),
      lastPostedOn: lastPostedOn == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPostedOn),
      createdAt: Value(createdAt),
    );
  }

  factory RecurringRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringRule(
      id: serializer.fromJson<int>(json['id']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      category: serializer.fromJson<String>(json['category']),
      note: serializer.fromJson<String?>(json['note']),
      accountId: serializer.fromJson<int?>(json['accountId']),
      daysOfWeek: serializer.fromJson<String>(json['daysOfWeek']),
      startsOn: serializer.fromJson<DateTime>(json['startsOn']),
      endsOn: serializer.fromJson<DateTime?>(json['endsOn']),
      active: serializer.fromJson<bool>(json['active']),
      lastPostedOn: serializer.fromJson<DateTime?>(json['lastPostedOn']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'amountCents': serializer.toJson<int>(amountCents),
      'category': serializer.toJson<String>(category),
      'note': serializer.toJson<String?>(note),
      'accountId': serializer.toJson<int?>(accountId),
      'daysOfWeek': serializer.toJson<String>(daysOfWeek),
      'startsOn': serializer.toJson<DateTime>(startsOn),
      'endsOn': serializer.toJson<DateTime?>(endsOn),
      'active': serializer.toJson<bool>(active),
      'lastPostedOn': serializer.toJson<DateTime?>(lastPostedOn),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  RecurringRule copyWith({
    int? id,
    int? amountCents,
    String? category,
    Value<String?> note = const Value.absent(),
    Value<int?> accountId = const Value.absent(),
    String? daysOfWeek,
    DateTime? startsOn,
    Value<DateTime?> endsOn = const Value.absent(),
    bool? active,
    Value<DateTime?> lastPostedOn = const Value.absent(),
    DateTime? createdAt,
  }) => RecurringRule(
    id: id ?? this.id,
    amountCents: amountCents ?? this.amountCents,
    category: category ?? this.category,
    note: note.present ? note.value : this.note,
    accountId: accountId.present ? accountId.value : this.accountId,
    daysOfWeek: daysOfWeek ?? this.daysOfWeek,
    startsOn: startsOn ?? this.startsOn,
    endsOn: endsOn.present ? endsOn.value : this.endsOn,
    active: active ?? this.active,
    lastPostedOn: lastPostedOn.present ? lastPostedOn.value : this.lastPostedOn,
    createdAt: createdAt ?? this.createdAt,
  );
  RecurringRule copyWithCompanion(RecurringRulesCompanion data) {
    return RecurringRule(
      id: data.id.present ? data.id.value : this.id,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      category: data.category.present ? data.category.value : this.category,
      note: data.note.present ? data.note.value : this.note,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      daysOfWeek: data.daysOfWeek.present
          ? data.daysOfWeek.value
          : this.daysOfWeek,
      startsOn: data.startsOn.present ? data.startsOn.value : this.startsOn,
      endsOn: data.endsOn.present ? data.endsOn.value : this.endsOn,
      active: data.active.present ? data.active.value : this.active,
      lastPostedOn: data.lastPostedOn.present
          ? data.lastPostedOn.value
          : this.lastPostedOn,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringRule(')
          ..write('id: $id, ')
          ..write('amountCents: $amountCents, ')
          ..write('category: $category, ')
          ..write('note: $note, ')
          ..write('accountId: $accountId, ')
          ..write('daysOfWeek: $daysOfWeek, ')
          ..write('startsOn: $startsOn, ')
          ..write('endsOn: $endsOn, ')
          ..write('active: $active, ')
          ..write('lastPostedOn: $lastPostedOn, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    amountCents,
    category,
    note,
    accountId,
    daysOfWeek,
    startsOn,
    endsOn,
    active,
    lastPostedOn,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringRule &&
          other.id == this.id &&
          other.amountCents == this.amountCents &&
          other.category == this.category &&
          other.note == this.note &&
          other.accountId == this.accountId &&
          other.daysOfWeek == this.daysOfWeek &&
          other.startsOn == this.startsOn &&
          other.endsOn == this.endsOn &&
          other.active == this.active &&
          other.lastPostedOn == this.lastPostedOn &&
          other.createdAt == this.createdAt);
}

class RecurringRulesCompanion extends UpdateCompanion<RecurringRule> {
  final Value<int> id;
  final Value<int> amountCents;
  final Value<String> category;
  final Value<String?> note;
  final Value<int?> accountId;
  final Value<String> daysOfWeek;
  final Value<DateTime> startsOn;
  final Value<DateTime?> endsOn;
  final Value<bool> active;
  final Value<DateTime?> lastPostedOn;
  final Value<DateTime> createdAt;
  const RecurringRulesCompanion({
    this.id = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.category = const Value.absent(),
    this.note = const Value.absent(),
    this.accountId = const Value.absent(),
    this.daysOfWeek = const Value.absent(),
    this.startsOn = const Value.absent(),
    this.endsOn = const Value.absent(),
    this.active = const Value.absent(),
    this.lastPostedOn = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  RecurringRulesCompanion.insert({
    this.id = const Value.absent(),
    required int amountCents,
    required String category,
    this.note = const Value.absent(),
    this.accountId = const Value.absent(),
    required String daysOfWeek,
    required DateTime startsOn,
    this.endsOn = const Value.absent(),
    this.active = const Value.absent(),
    this.lastPostedOn = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : amountCents = Value(amountCents),
       category = Value(category),
       daysOfWeek = Value(daysOfWeek),
       startsOn = Value(startsOn);
  static Insertable<RecurringRule> custom({
    Expression<int>? id,
    Expression<int>? amountCents,
    Expression<String>? category,
    Expression<String>? note,
    Expression<int>? accountId,
    Expression<String>? daysOfWeek,
    Expression<DateTime>? startsOn,
    Expression<DateTime>? endsOn,
    Expression<bool>? active,
    Expression<DateTime>? lastPostedOn,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amountCents != null) 'amount_cents': amountCents,
      if (category != null) 'category': category,
      if (note != null) 'note': note,
      if (accountId != null) 'account_id': accountId,
      if (daysOfWeek != null) 'days_of_week': daysOfWeek,
      if (startsOn != null) 'starts_on': startsOn,
      if (endsOn != null) 'ends_on': endsOn,
      if (active != null) 'active': active,
      if (lastPostedOn != null) 'last_posted_on': lastPostedOn,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  RecurringRulesCompanion copyWith({
    Value<int>? id,
    Value<int>? amountCents,
    Value<String>? category,
    Value<String?>? note,
    Value<int?>? accountId,
    Value<String>? daysOfWeek,
    Value<DateTime>? startsOn,
    Value<DateTime?>? endsOn,
    Value<bool>? active,
    Value<DateTime?>? lastPostedOn,
    Value<DateTime>? createdAt,
  }) {
    return RecurringRulesCompanion(
      id: id ?? this.id,
      amountCents: amountCents ?? this.amountCents,
      category: category ?? this.category,
      note: note ?? this.note,
      accountId: accountId ?? this.accountId,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      startsOn: startsOn ?? this.startsOn,
      endsOn: endsOn ?? this.endsOn,
      active: active ?? this.active,
      lastPostedOn: lastPostedOn ?? this.lastPostedOn,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (daysOfWeek.present) {
      map['days_of_week'] = Variable<String>(daysOfWeek.value);
    }
    if (startsOn.present) {
      map['starts_on'] = Variable<DateTime>(startsOn.value);
    }
    if (endsOn.present) {
      map['ends_on'] = Variable<DateTime>(endsOn.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (lastPostedOn.present) {
      map['last_posted_on'] = Variable<DateTime>(lastPostedOn.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringRulesCompanion(')
          ..write('id: $id, ')
          ..write('amountCents: $amountCents, ')
          ..write('category: $category, ')
          ..write('note: $note, ')
          ..write('accountId: $accountId, ')
          ..write('daysOfWeek: $daysOfWeek, ')
          ..write('startsOn: $startsOn, ')
          ..write('endsOn: $endsOn, ')
          ..write('active: $active, ')
          ..write('lastPostedOn: $lastPostedOn, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SpendsTable extends Spends with TableInfo<$SpendsTable, Spend> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpendsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spentAtMeta = const VerificationMeta(
    'spentAt',
  );
  @override
  late final GeneratedColumn<DateTime> spentAt = GeneratedColumn<DateTime>(
    'spent_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
    'account_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _recurringRuleIdMeta = const VerificationMeta(
    'recurringRuleId',
  );
  @override
  late final GeneratedColumn<int> recurringRuleId = GeneratedColumn<int>(
    'recurring_rule_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES recurring_rules (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _importKeyMeta = const VerificationMeta(
    'importKey',
  );
  @override
  late final GeneratedColumn<String> importKey = GeneratedColumn<String>(
    'import_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
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
    amountCents,
    category,
    spentAt,
    note,
    accountId,
    recurringRuleId,
    importKey,
    source,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'spends';
  @override
  VerificationContext validateIntegrity(
    Insertable<Spend> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('spent_at')) {
      context.handle(
        _spentAtMeta,
        spentAt.isAcceptableOrUnknown(data['spent_at']!, _spentAtMeta),
      );
    } else if (isInserting) {
      context.missing(_spentAtMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    }
    if (data.containsKey('recurring_rule_id')) {
      context.handle(
        _recurringRuleIdMeta,
        recurringRuleId.isAcceptableOrUnknown(
          data['recurring_rule_id']!,
          _recurringRuleIdMeta,
        ),
      );
    }
    if (data.containsKey('import_key')) {
      context.handle(
        _importKeyMeta,
        importKey.isAcceptableOrUnknown(data['import_key']!, _importKeyMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
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
  Spend map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Spend(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      spentAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}spent_at'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}account_id'],
      ),
      recurringRuleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recurring_rule_id'],
      ),
      importKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}import_key'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SpendsTable createAlias(String alias) {
    return $SpendsTable(attachedDatabase, alias);
  }
}

class Spend extends DataClass implements Insertable<Spend> {
  final int id;
  final int amountCents;
  final String category;
  final DateTime spentAt;
  final String? note;
  final int? accountId;

  /// Set when this spend was generated from a recurring rule.
  final int? recurringRuleId;
  final String? importKey;
  final String source;
  final DateTime createdAt;
  const Spend({
    required this.id,
    required this.amountCents,
    required this.category,
    required this.spentAt,
    this.note,
    this.accountId,
    this.recurringRuleId,
    this.importKey,
    required this.source,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['amount_cents'] = Variable<int>(amountCents);
    map['category'] = Variable<String>(category);
    map['spent_at'] = Variable<DateTime>(spentAt);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<int>(accountId);
    }
    if (!nullToAbsent || recurringRuleId != null) {
      map['recurring_rule_id'] = Variable<int>(recurringRuleId);
    }
    if (!nullToAbsent || importKey != null) {
      map['import_key'] = Variable<String>(importKey);
    }
    map['source'] = Variable<String>(source);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SpendsCompanion toCompanion(bool nullToAbsent) {
    return SpendsCompanion(
      id: Value(id),
      amountCents: Value(amountCents),
      category: Value(category),
      spentAt: Value(spentAt),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      recurringRuleId: recurringRuleId == null && nullToAbsent
          ? const Value.absent()
          : Value(recurringRuleId),
      importKey: importKey == null && nullToAbsent
          ? const Value.absent()
          : Value(importKey),
      source: Value(source),
      createdAt: Value(createdAt),
    );
  }

  factory Spend.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Spend(
      id: serializer.fromJson<int>(json['id']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      category: serializer.fromJson<String>(json['category']),
      spentAt: serializer.fromJson<DateTime>(json['spentAt']),
      note: serializer.fromJson<String?>(json['note']),
      accountId: serializer.fromJson<int?>(json['accountId']),
      recurringRuleId: serializer.fromJson<int?>(json['recurringRuleId']),
      importKey: serializer.fromJson<String?>(json['importKey']),
      source: serializer.fromJson<String>(json['source']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'amountCents': serializer.toJson<int>(amountCents),
      'category': serializer.toJson<String>(category),
      'spentAt': serializer.toJson<DateTime>(spentAt),
      'note': serializer.toJson<String?>(note),
      'accountId': serializer.toJson<int?>(accountId),
      'recurringRuleId': serializer.toJson<int?>(recurringRuleId),
      'importKey': serializer.toJson<String?>(importKey),
      'source': serializer.toJson<String>(source),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Spend copyWith({
    int? id,
    int? amountCents,
    String? category,
    DateTime? spentAt,
    Value<String?> note = const Value.absent(),
    Value<int?> accountId = const Value.absent(),
    Value<int?> recurringRuleId = const Value.absent(),
    Value<String?> importKey = const Value.absent(),
    String? source,
    DateTime? createdAt,
  }) => Spend(
    id: id ?? this.id,
    amountCents: amountCents ?? this.amountCents,
    category: category ?? this.category,
    spentAt: spentAt ?? this.spentAt,
    note: note.present ? note.value : this.note,
    accountId: accountId.present ? accountId.value : this.accountId,
    recurringRuleId: recurringRuleId.present
        ? recurringRuleId.value
        : this.recurringRuleId,
    importKey: importKey.present ? importKey.value : this.importKey,
    source: source ?? this.source,
    createdAt: createdAt ?? this.createdAt,
  );
  Spend copyWithCompanion(SpendsCompanion data) {
    return Spend(
      id: data.id.present ? data.id.value : this.id,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      category: data.category.present ? data.category.value : this.category,
      spentAt: data.spentAt.present ? data.spentAt.value : this.spentAt,
      note: data.note.present ? data.note.value : this.note,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      recurringRuleId: data.recurringRuleId.present
          ? data.recurringRuleId.value
          : this.recurringRuleId,
      importKey: data.importKey.present ? data.importKey.value : this.importKey,
      source: data.source.present ? data.source.value : this.source,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Spend(')
          ..write('id: $id, ')
          ..write('amountCents: $amountCents, ')
          ..write('category: $category, ')
          ..write('spentAt: $spentAt, ')
          ..write('note: $note, ')
          ..write('accountId: $accountId, ')
          ..write('recurringRuleId: $recurringRuleId, ')
          ..write('importKey: $importKey, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    amountCents,
    category,
    spentAt,
    note,
    accountId,
    recurringRuleId,
    importKey,
    source,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Spend &&
          other.id == this.id &&
          other.amountCents == this.amountCents &&
          other.category == this.category &&
          other.spentAt == this.spentAt &&
          other.note == this.note &&
          other.accountId == this.accountId &&
          other.recurringRuleId == this.recurringRuleId &&
          other.importKey == this.importKey &&
          other.source == this.source &&
          other.createdAt == this.createdAt);
}

class SpendsCompanion extends UpdateCompanion<Spend> {
  final Value<int> id;
  final Value<int> amountCents;
  final Value<String> category;
  final Value<DateTime> spentAt;
  final Value<String?> note;
  final Value<int?> accountId;
  final Value<int?> recurringRuleId;
  final Value<String?> importKey;
  final Value<String> source;
  final Value<DateTime> createdAt;
  const SpendsCompanion({
    this.id = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.category = const Value.absent(),
    this.spentAt = const Value.absent(),
    this.note = const Value.absent(),
    this.accountId = const Value.absent(),
    this.recurringRuleId = const Value.absent(),
    this.importKey = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SpendsCompanion.insert({
    this.id = const Value.absent(),
    required int amountCents,
    required String category,
    required DateTime spentAt,
    this.note = const Value.absent(),
    this.accountId = const Value.absent(),
    this.recurringRuleId = const Value.absent(),
    this.importKey = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : amountCents = Value(amountCents),
       category = Value(category),
       spentAt = Value(spentAt);
  static Insertable<Spend> custom({
    Expression<int>? id,
    Expression<int>? amountCents,
    Expression<String>? category,
    Expression<DateTime>? spentAt,
    Expression<String>? note,
    Expression<int>? accountId,
    Expression<int>? recurringRuleId,
    Expression<String>? importKey,
    Expression<String>? source,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amountCents != null) 'amount_cents': amountCents,
      if (category != null) 'category': category,
      if (spentAt != null) 'spent_at': spentAt,
      if (note != null) 'note': note,
      if (accountId != null) 'account_id': accountId,
      if (recurringRuleId != null) 'recurring_rule_id': recurringRuleId,
      if (importKey != null) 'import_key': importKey,
      if (source != null) 'source': source,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SpendsCompanion copyWith({
    Value<int>? id,
    Value<int>? amountCents,
    Value<String>? category,
    Value<DateTime>? spentAt,
    Value<String?>? note,
    Value<int?>? accountId,
    Value<int?>? recurringRuleId,
    Value<String?>? importKey,
    Value<String>? source,
    Value<DateTime>? createdAt,
  }) {
    return SpendsCompanion(
      id: id ?? this.id,
      amountCents: amountCents ?? this.amountCents,
      category: category ?? this.category,
      spentAt: spentAt ?? this.spentAt,
      note: note ?? this.note,
      accountId: accountId ?? this.accountId,
      recurringRuleId: recurringRuleId ?? this.recurringRuleId,
      importKey: importKey ?? this.importKey,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (spentAt.present) {
      map['spent_at'] = Variable<DateTime>(spentAt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (recurringRuleId.present) {
      map['recurring_rule_id'] = Variable<int>(recurringRuleId.value);
    }
    if (importKey.present) {
      map['import_key'] = Variable<String>(importKey.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpendsCompanion(')
          ..write('id: $id, ')
          ..write('amountCents: $amountCents, ')
          ..write('category: $category, ')
          ..write('spentAt: $spentAt, ')
          ..write('note: $note, ')
          ..write('accountId: $accountId, ')
          ..write('recurringRuleId: $recurringRuleId, ')
          ..write('importKey: $importKey, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TransfersTable extends Transfers
    with TableInfo<$TransfersTable, Transfer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransfersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _fromAccountIdMeta = const VerificationMeta(
    'fromAccountId',
  );
  @override
  late final GeneratedColumn<int> fromAccountId = GeneratedColumn<int>(
    'from_account_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _toAccountIdMeta = const VerificationMeta(
    'toAccountId',
  );
  @override
  late final GeneratedColumn<int> toAccountId = GeneratedColumn<int>(
    'to_account_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transferredAtMeta = const VerificationMeta(
    'transferredAt',
  );
  @override
  late final GeneratedColumn<DateTime> transferredAt =
      GeneratedColumn<DateTime>(
        'transferred_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _importKeyMeta = const VerificationMeta(
    'importKey',
  );
  @override
  late final GeneratedColumn<String> importKey = GeneratedColumn<String>(
    'import_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    fromAccountId,
    toAccountId,
    amountCents,
    transferredAt,
    note,
    importKey,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transfers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transfer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('from_account_id')) {
      context.handle(
        _fromAccountIdMeta,
        fromAccountId.isAcceptableOrUnknown(
          data['from_account_id']!,
          _fromAccountIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fromAccountIdMeta);
    }
    if (data.containsKey('to_account_id')) {
      context.handle(
        _toAccountIdMeta,
        toAccountId.isAcceptableOrUnknown(
          data['to_account_id']!,
          _toAccountIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_toAccountIdMeta);
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('transferred_at')) {
      context.handle(
        _transferredAtMeta,
        transferredAt.isAcceptableOrUnknown(
          data['transferred_at']!,
          _transferredAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transferredAtMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('import_key')) {
      context.handle(
        _importKeyMeta,
        importKey.isAcceptableOrUnknown(data['import_key']!, _importKeyMeta),
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
  Transfer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transfer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      fromAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}from_account_id'],
      )!,
      toAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}to_account_id'],
      )!,
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
      transferredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}transferred_at'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      importKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}import_key'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TransfersTable createAlias(String alias) {
    return $TransfersTable(attachedDatabase, alias);
  }
}

class Transfer extends DataClass implements Insertable<Transfer> {
  final int id;
  final int fromAccountId;
  final int toAccountId;
  final int amountCents;
  final DateTime transferredAt;
  final String? note;
  final String? importKey;
  final DateTime createdAt;
  const Transfer({
    required this.id,
    required this.fromAccountId,
    required this.toAccountId,
    required this.amountCents,
    required this.transferredAt,
    this.note,
    this.importKey,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['from_account_id'] = Variable<int>(fromAccountId);
    map['to_account_id'] = Variable<int>(toAccountId);
    map['amount_cents'] = Variable<int>(amountCents);
    map['transferred_at'] = Variable<DateTime>(transferredAt);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || importKey != null) {
      map['import_key'] = Variable<String>(importKey);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TransfersCompanion toCompanion(bool nullToAbsent) {
    return TransfersCompanion(
      id: Value(id),
      fromAccountId: Value(fromAccountId),
      toAccountId: Value(toAccountId),
      amountCents: Value(amountCents),
      transferredAt: Value(transferredAt),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      importKey: importKey == null && nullToAbsent
          ? const Value.absent()
          : Value(importKey),
      createdAt: Value(createdAt),
    );
  }

  factory Transfer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transfer(
      id: serializer.fromJson<int>(json['id']),
      fromAccountId: serializer.fromJson<int>(json['fromAccountId']),
      toAccountId: serializer.fromJson<int>(json['toAccountId']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      transferredAt: serializer.fromJson<DateTime>(json['transferredAt']),
      note: serializer.fromJson<String?>(json['note']),
      importKey: serializer.fromJson<String?>(json['importKey']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'fromAccountId': serializer.toJson<int>(fromAccountId),
      'toAccountId': serializer.toJson<int>(toAccountId),
      'amountCents': serializer.toJson<int>(amountCents),
      'transferredAt': serializer.toJson<DateTime>(transferredAt),
      'note': serializer.toJson<String?>(note),
      'importKey': serializer.toJson<String?>(importKey),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Transfer copyWith({
    int? id,
    int? fromAccountId,
    int? toAccountId,
    int? amountCents,
    DateTime? transferredAt,
    Value<String?> note = const Value.absent(),
    Value<String?> importKey = const Value.absent(),
    DateTime? createdAt,
  }) => Transfer(
    id: id ?? this.id,
    fromAccountId: fromAccountId ?? this.fromAccountId,
    toAccountId: toAccountId ?? this.toAccountId,
    amountCents: amountCents ?? this.amountCents,
    transferredAt: transferredAt ?? this.transferredAt,
    note: note.present ? note.value : this.note,
    importKey: importKey.present ? importKey.value : this.importKey,
    createdAt: createdAt ?? this.createdAt,
  );
  Transfer copyWithCompanion(TransfersCompanion data) {
    return Transfer(
      id: data.id.present ? data.id.value : this.id,
      fromAccountId: data.fromAccountId.present
          ? data.fromAccountId.value
          : this.fromAccountId,
      toAccountId: data.toAccountId.present
          ? data.toAccountId.value
          : this.toAccountId,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      transferredAt: data.transferredAt.present
          ? data.transferredAt.value
          : this.transferredAt,
      note: data.note.present ? data.note.value : this.note,
      importKey: data.importKey.present ? data.importKey.value : this.importKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transfer(')
          ..write('id: $id, ')
          ..write('fromAccountId: $fromAccountId, ')
          ..write('toAccountId: $toAccountId, ')
          ..write('amountCents: $amountCents, ')
          ..write('transferredAt: $transferredAt, ')
          ..write('note: $note, ')
          ..write('importKey: $importKey, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    fromAccountId,
    toAccountId,
    amountCents,
    transferredAt,
    note,
    importKey,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transfer &&
          other.id == this.id &&
          other.fromAccountId == this.fromAccountId &&
          other.toAccountId == this.toAccountId &&
          other.amountCents == this.amountCents &&
          other.transferredAt == this.transferredAt &&
          other.note == this.note &&
          other.importKey == this.importKey &&
          other.createdAt == this.createdAt);
}

class TransfersCompanion extends UpdateCompanion<Transfer> {
  final Value<int> id;
  final Value<int> fromAccountId;
  final Value<int> toAccountId;
  final Value<int> amountCents;
  final Value<DateTime> transferredAt;
  final Value<String?> note;
  final Value<String?> importKey;
  final Value<DateTime> createdAt;
  const TransfersCompanion({
    this.id = const Value.absent(),
    this.fromAccountId = const Value.absent(),
    this.toAccountId = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.transferredAt = const Value.absent(),
    this.note = const Value.absent(),
    this.importKey = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TransfersCompanion.insert({
    this.id = const Value.absent(),
    required int fromAccountId,
    required int toAccountId,
    required int amountCents,
    required DateTime transferredAt,
    this.note = const Value.absent(),
    this.importKey = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : fromAccountId = Value(fromAccountId),
       toAccountId = Value(toAccountId),
       amountCents = Value(amountCents),
       transferredAt = Value(transferredAt);
  static Insertable<Transfer> custom({
    Expression<int>? id,
    Expression<int>? fromAccountId,
    Expression<int>? toAccountId,
    Expression<int>? amountCents,
    Expression<DateTime>? transferredAt,
    Expression<String>? note,
    Expression<String>? importKey,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fromAccountId != null) 'from_account_id': fromAccountId,
      if (toAccountId != null) 'to_account_id': toAccountId,
      if (amountCents != null) 'amount_cents': amountCents,
      if (transferredAt != null) 'transferred_at': transferredAt,
      if (note != null) 'note': note,
      if (importKey != null) 'import_key': importKey,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TransfersCompanion copyWith({
    Value<int>? id,
    Value<int>? fromAccountId,
    Value<int>? toAccountId,
    Value<int>? amountCents,
    Value<DateTime>? transferredAt,
    Value<String?>? note,
    Value<String?>? importKey,
    Value<DateTime>? createdAt,
  }) {
    return TransfersCompanion(
      id: id ?? this.id,
      fromAccountId: fromAccountId ?? this.fromAccountId,
      toAccountId: toAccountId ?? this.toAccountId,
      amountCents: amountCents ?? this.amountCents,
      transferredAt: transferredAt ?? this.transferredAt,
      note: note ?? this.note,
      importKey: importKey ?? this.importKey,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (fromAccountId.present) {
      map['from_account_id'] = Variable<int>(fromAccountId.value);
    }
    if (toAccountId.present) {
      map['to_account_id'] = Variable<int>(toAccountId.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (transferredAt.present) {
      map['transferred_at'] = Variable<DateTime>(transferredAt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (importKey.present) {
      map['import_key'] = Variable<String>(importKey.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransfersCompanion(')
          ..write('id: $id, ')
          ..write('fromAccountId: $fromAccountId, ')
          ..write('toAccountId: $toAccountId, ')
          ..write('amountCents: $amountCents, ')
          ..write('transferredAt: $transferredAt, ')
          ..write('note: $note, ')
          ..write('importKey: $importKey, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $WithdrawalsTable withdrawals = $WithdrawalsTable(this);
  late final $RecurringRulesTable recurringRules = $RecurringRulesTable(this);
  late final $SpendsTable spends = $SpendsTable(this);
  late final $TransfersTable transfers = $TransfersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    accounts,
    withdrawals,
    recurringRules,
    spends,
    transfers,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'accounts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('withdrawals', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'accounts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('recurring_rules', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'accounts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('spends', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'recurring_rules',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('spends', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'accounts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('transfers', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'accounts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('transfers', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$AccountsTableCreateCompanionBuilder = AccountsCompanion Function({
  Value<int> id,
  required String name,
  Value<String> institution,
  Value<String> kind,
  Value<int> openingBalanceCents,
  Value<bool> archived,
  Value<DateTime> createdAt,
});
typedef $$AccountsTableUpdateCompanionBuilder = AccountsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> institution,
  Value<String> kind,
  Value<int> openingBalanceCents,
  Value<bool> archived,
  Value<DateTime> createdAt,
});

final class $$AccountsTableReferences
    extends BaseReferences<_$AppDatabase, $AccountsTable, Account> {
  $$AccountsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WithdrawalsTable, List<Withdrawal>>
  _withdrawalsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.withdrawals,
    aliasName: 'accounts__id__withdrawals__account_id',
  );

  $$WithdrawalsTableProcessedTableManager get withdrawalsRefs {
    final manager = $$WithdrawalsTableTableManager(
      $_db,
      $_db.withdrawals,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_withdrawalsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RecurringRulesTable, List<RecurringRule>>
  _recurringRulesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.recurringRules,
    aliasName: 'accounts__id__recurring_rules__account_id',
  );

  $$RecurringRulesTableProcessedTableManager get recurringRulesRefs {
    final manager = $$RecurringRulesTableTableManager(
      $_db,
      $_db.recurringRules,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_recurringRulesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SpendsTable, List<Spend>> _spendsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.spends,
    aliasName: 'accounts__id__spends__account_id',
  );

  $$SpendsTableProcessedTableManager get spendsRefs {
    final manager = $$SpendsTableTableManager(
      $_db,
      $_db.spends,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_spendsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get institution => $composableBuilder(
    column: $table.institution,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get openingBalanceCents => $composableBuilder(
    column: $table.openingBalanceCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> withdrawalsRefs(
    Expression<bool> Function($$WithdrawalsTableFilterComposer f) f,
  ) {
    final $$WithdrawalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.withdrawals,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WithdrawalsTableFilterComposer(
            $db: $db,
            $table: $db.withdrawals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> recurringRulesRefs(
    Expression<bool> Function($$RecurringRulesTableFilterComposer f) f,
  ) {
    final $$RecurringRulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recurringRules,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecurringRulesTableFilterComposer(
            $db: $db,
            $table: $db.recurringRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> spendsRefs(
    Expression<bool> Function($$SpendsTableFilterComposer f) f,
  ) {
    final $$SpendsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.spends,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpendsTableFilterComposer(
            $db: $db,
            $table: $db.spends,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get institution => $composableBuilder(
    column: $table.institution,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get openingBalanceCents => $composableBuilder(
    column: $table.openingBalanceCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get institution => $composableBuilder(
    column: $table.institution,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get openingBalanceCents => $composableBuilder(
    column: $table.openingBalanceCents,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> withdrawalsRefs<T extends Object>(
    Expression<T> Function($$WithdrawalsTableAnnotationComposer a) f,
  ) {
    final $$WithdrawalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.withdrawals,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WithdrawalsTableAnnotationComposer(
            $db: $db,
            $table: $db.withdrawals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> recurringRulesRefs<T extends Object>(
    Expression<T> Function($$RecurringRulesTableAnnotationComposer a) f,
  ) {
    final $$RecurringRulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recurringRules,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecurringRulesTableAnnotationComposer(
            $db: $db,
            $table: $db.recurringRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> spendsRefs<T extends Object>(
    Expression<T> Function($$SpendsTableAnnotationComposer a) f,
  ) {
    final $$SpendsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.spends,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpendsTableAnnotationComposer(
            $db: $db,
            $table: $db.spends,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountsTable,
          Account,
          $$AccountsTableFilterComposer,
          $$AccountsTableOrderingComposer,
          $$AccountsTableAnnotationComposer,
          $$AccountsTableCreateCompanionBuilder,
          $$AccountsTableUpdateCompanionBuilder,
          (Account, $$AccountsTableReferences),
          Account,
          PrefetchHooks Function({
            bool withdrawalsRefs,
            bool recurringRulesRefs,
            bool spendsRefs,
          })
        > {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> institution = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> openingBalanceCents = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AccountsCompanion(
                id: id,
                name: name,
                institution: institution,
                kind: kind,
                openingBalanceCents: openingBalanceCents,
                archived: archived,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> institution = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> openingBalanceCents = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AccountsCompanion.insert(
                id: id,
                name: name,
                institution: institution,
                kind: kind,
                openingBalanceCents: openingBalanceCents,
                archived: archived,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AccountsTable, Account>(table),
                  $$AccountsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                withdrawalsRefs = false,
                recurringRulesRefs = false,
                spendsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (withdrawalsRefs) db.withdrawals,
                    if (recurringRulesRefs) db.recurringRules,
                    if (spendsRefs) db.spends,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (withdrawalsRefs)
                        await $_getPrefetchedDataByColumns<
                          Account,
                          $AccountsTable,
                          Withdrawal,
                          $WithdrawalsTable
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._withdrawalsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).withdrawalsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'account_id',
                          typedResults: items,
                        ),
                      if (recurringRulesRefs)
                        await $_getPrefetchedDataByColumns<
                          Account,
                          $AccountsTable,
                          RecurringRule,
                          $RecurringRulesTable
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._recurringRulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).recurringRulesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'account_id',
                          typedResults: items,
                        ),
                      if (spendsRefs)
                        await $_getPrefetchedDataByColumns<
                          Account,
                          $AccountsTable,
                          Spend,
                          $SpendsTable
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._spendsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).spendsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'account_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountsTable,
      Account,
      $$AccountsTableFilterComposer,
      $$AccountsTableOrderingComposer,
      $$AccountsTableAnnotationComposer,
      $$AccountsTableCreateCompanionBuilder,
      $$AccountsTableUpdateCompanionBuilder,
      (Account, $$AccountsTableReferences),
      Account,
      PrefetchHooks Function({
        bool withdrawalsRefs,
        bool recurringRulesRefs,
        bool spendsRefs,
      })
    >;
typedef $$WithdrawalsTableCreateCompanionBuilder =
    WithdrawalsCompanion Function({
      Value<int> id,
      required int amountCents,
      required DateTime withdrawnAt,
      Value<String?> note,
      Value<int?> accountId,
      Value<String?> importKey,
      Value<String> source,
      Value<DateTime> createdAt,
    });
typedef $$WithdrawalsTableUpdateCompanionBuilder =
    WithdrawalsCompanion Function({
      Value<int> id,
      Value<int> amountCents,
      Value<DateTime> withdrawnAt,
      Value<String?> note,
      Value<int?> accountId,
      Value<String?> importKey,
      Value<String> source,
      Value<DateTime> createdAt,
    });

final class $$WithdrawalsTableReferences
    extends BaseReferences<_$AppDatabase, $WithdrawalsTable, Withdrawal> {
  $$WithdrawalsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _accountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias('withdrawals__account_id__accounts__id');

  $$AccountsTableProcessedTableManager? get accountId {
    final $_column = $_itemColumn<int>('account_id');
    if ($_column == null) return null;
    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WithdrawalsTableFilterComposer
    extends Composer<_$AppDatabase, $WithdrawalsTable> {
  $$WithdrawalsTableFilterComposer({
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

  ColumnFilters<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get withdrawnAt => $composableBuilder(
    column: $table.withdrawnAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get importKey => $composableBuilder(
    column: $table.importKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WithdrawalsTableOrderingComposer
    extends Composer<_$AppDatabase, $WithdrawalsTable> {
  $$WithdrawalsTableOrderingComposer({
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

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get withdrawnAt => $composableBuilder(
    column: $table.withdrawnAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get importKey => $composableBuilder(
    column: $table.importKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WithdrawalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WithdrawalsTable> {
  $$WithdrawalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get withdrawnAt => $composableBuilder(
    column: $table.withdrawnAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get importKey =>
      $composableBuilder(column: $table.importKey, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WithdrawalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WithdrawalsTable,
          Withdrawal,
          $$WithdrawalsTableFilterComposer,
          $$WithdrawalsTableOrderingComposer,
          $$WithdrawalsTableAnnotationComposer,
          $$WithdrawalsTableCreateCompanionBuilder,
          $$WithdrawalsTableUpdateCompanionBuilder,
          (Withdrawal, $$WithdrawalsTableReferences),
          Withdrawal,
          PrefetchHooks Function({bool accountId})
        > {
  $$WithdrawalsTableTableManager(_$AppDatabase db, $WithdrawalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WithdrawalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WithdrawalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WithdrawalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<DateTime> withdrawnAt = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int?> accountId = const Value.absent(),
                Value<String?> importKey = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => WithdrawalsCompanion(
                id: id,
                amountCents: amountCents,
                withdrawnAt: withdrawnAt,
                note: note,
                accountId: accountId,
                importKey: importKey,
                source: source,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int amountCents,
                required DateTime withdrawnAt,
                Value<String?> note = const Value.absent(),
                Value<int?> accountId = const Value.absent(),
                Value<String?> importKey = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => WithdrawalsCompanion.insert(
                id: id,
                amountCents: amountCents,
                withdrawnAt: withdrawnAt,
                note: note,
                accountId: accountId,
                importKey: importKey,
                source: source,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WithdrawalsTable, Withdrawal>(table),
                  $$WithdrawalsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({accountId = false}) {
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
                    if (accountId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.accountId,
                        referencedTable: $$WithdrawalsTableReferences
                            ._accountIdTable(db),
                        referencedColumn: $$WithdrawalsTableReferences
                            ._accountIdTable(db)
                            .id,
                      ) as T;
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

typedef $$WithdrawalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WithdrawalsTable,
      Withdrawal,
      $$WithdrawalsTableFilterComposer,
      $$WithdrawalsTableOrderingComposer,
      $$WithdrawalsTableAnnotationComposer,
      $$WithdrawalsTableCreateCompanionBuilder,
      $$WithdrawalsTableUpdateCompanionBuilder,
      (Withdrawal, $$WithdrawalsTableReferences),
      Withdrawal,
      PrefetchHooks Function({bool accountId})
    >;
typedef $$RecurringRulesTableCreateCompanionBuilder =
    RecurringRulesCompanion Function({
      Value<int> id,
      required int amountCents,
      required String category,
      Value<String?> note,
      Value<int?> accountId,
      required String daysOfWeek,
      required DateTime startsOn,
      Value<DateTime?> endsOn,
      Value<bool> active,
      Value<DateTime?> lastPostedOn,
      Value<DateTime> createdAt,
    });
typedef $$RecurringRulesTableUpdateCompanionBuilder =
    RecurringRulesCompanion Function({
      Value<int> id,
      Value<int> amountCents,
      Value<String> category,
      Value<String?> note,
      Value<int?> accountId,
      Value<String> daysOfWeek,
      Value<DateTime> startsOn,
      Value<DateTime?> endsOn,
      Value<bool> active,
      Value<DateTime?> lastPostedOn,
      Value<DateTime> createdAt,
    });

final class $$RecurringRulesTableReferences
    extends BaseReferences<_$AppDatabase, $RecurringRulesTable, RecurringRule> {
  $$RecurringRulesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AccountsTable _accountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias('recurring_rules__account_id__accounts__id');

  $$AccountsTableProcessedTableManager? get accountId {
    final $_column = $_itemColumn<int>('account_id');
    if ($_column == null) return null;
    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SpendsTable, List<Spend>> _spendsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.spends,
    aliasName: 'recurring_rules__id__spends__recurring_rule_id',
  );

  $$SpendsTableProcessedTableManager get spendsRefs {
    final manager = $$SpendsTableTableManager(
      $_db,
      $_db.spends,
    ).filter((f) => f.recurringRuleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_spendsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RecurringRulesTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringRulesTable> {
  $$RecurringRulesTableFilterComposer({
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

  ColumnFilters<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get daysOfWeek => $composableBuilder(
    column: $table.daysOfWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startsOn => $composableBuilder(
    column: $table.startsOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endsOn => $composableBuilder(
    column: $table.endsOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPostedOn => $composableBuilder(
    column: $table.lastPostedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> spendsRefs(
    Expression<bool> Function($$SpendsTableFilterComposer f) f,
  ) {
    final $$SpendsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.spends,
      getReferencedColumn: (t) => t.recurringRuleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpendsTableFilterComposer(
            $db: $db,
            $table: $db.spends,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RecurringRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringRulesTable> {
  $$RecurringRulesTableOrderingComposer({
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

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get daysOfWeek => $composableBuilder(
    column: $table.daysOfWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startsOn => $composableBuilder(
    column: $table.startsOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endsOn => $composableBuilder(
    column: $table.endsOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPostedOn => $composableBuilder(
    column: $table.lastPostedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecurringRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringRulesTable> {
  $$RecurringRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get daysOfWeek => $composableBuilder(
    column: $table.daysOfWeek,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startsOn =>
      $composableBuilder(column: $table.startsOn, builder: (column) => column);

  GeneratedColumn<DateTime> get endsOn =>
      $composableBuilder(column: $table.endsOn, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<DateTime> get lastPostedOn => $composableBuilder(
    column: $table.lastPostedOn,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> spendsRefs<T extends Object>(
    Expression<T> Function($$SpendsTableAnnotationComposer a) f,
  ) {
    final $$SpendsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.spends,
      getReferencedColumn: (t) => t.recurringRuleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpendsTableAnnotationComposer(
            $db: $db,
            $table: $db.spends,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RecurringRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecurringRulesTable,
          RecurringRule,
          $$RecurringRulesTableFilterComposer,
          $$RecurringRulesTableOrderingComposer,
          $$RecurringRulesTableAnnotationComposer,
          $$RecurringRulesTableCreateCompanionBuilder,
          $$RecurringRulesTableUpdateCompanionBuilder,
          (RecurringRule, $$RecurringRulesTableReferences),
          RecurringRule,
          PrefetchHooks Function({bool accountId, bool spendsRefs})
        > {
  $$RecurringRulesTableTableManager(
    _$AppDatabase db,
    $RecurringRulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurringRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int?> accountId = const Value.absent(),
                Value<String> daysOfWeek = const Value.absent(),
                Value<DateTime> startsOn = const Value.absent(),
                Value<DateTime?> endsOn = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<DateTime?> lastPostedOn = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => RecurringRulesCompanion(
                id: id,
                amountCents: amountCents,
                category: category,
                note: note,
                accountId: accountId,
                daysOfWeek: daysOfWeek,
                startsOn: startsOn,
                endsOn: endsOn,
                active: active,
                lastPostedOn: lastPostedOn,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int amountCents,
                required String category,
                Value<String?> note = const Value.absent(),
                Value<int?> accountId = const Value.absent(),
                required String daysOfWeek,
                required DateTime startsOn,
                Value<DateTime?> endsOn = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<DateTime?> lastPostedOn = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => RecurringRulesCompanion.insert(
                id: id,
                amountCents: amountCents,
                category: category,
                note: note,
                accountId: accountId,
                daysOfWeek: daysOfWeek,
                startsOn: startsOn,
                endsOn: endsOn,
                active: active,
                lastPostedOn: lastPostedOn,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecurringRulesTable, RecurringRule>(table),
                  $$RecurringRulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({accountId = false, spendsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (spendsRefs) db.spends],
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
                    if (accountId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.accountId,
                        referencedTable: $$RecurringRulesTableReferences
                            ._accountIdTable(db),
                        referencedColumn: $$RecurringRulesTableReferences
                            ._accountIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (spendsRefs)
                    await $_getPrefetchedDataByColumns<
                      RecurringRule,
                      $RecurringRulesTable,
                      Spend,
                      $SpendsTable
                    >(
                      currentTable: table,
                      referencedTable: $$RecurringRulesTableReferences
                          ._spendsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$RecurringRulesTableReferences(
                            db,
                            table,
                            p0,
                          ).spendsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'recurring_rule_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RecurringRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecurringRulesTable,
      RecurringRule,
      $$RecurringRulesTableFilterComposer,
      $$RecurringRulesTableOrderingComposer,
      $$RecurringRulesTableAnnotationComposer,
      $$RecurringRulesTableCreateCompanionBuilder,
      $$RecurringRulesTableUpdateCompanionBuilder,
      (RecurringRule, $$RecurringRulesTableReferences),
      RecurringRule,
      PrefetchHooks Function({bool accountId, bool spendsRefs})
    >;
typedef $$SpendsTableCreateCompanionBuilder = SpendsCompanion Function({
  Value<int> id,
  required int amountCents,
  required String category,
  required DateTime spentAt,
  Value<String?> note,
  Value<int?> accountId,
  Value<int?> recurringRuleId,
  Value<String?> importKey,
  Value<String> source,
  Value<DateTime> createdAt,
});
typedef $$SpendsTableUpdateCompanionBuilder = SpendsCompanion Function({
  Value<int> id,
  Value<int> amountCents,
  Value<String> category,
  Value<DateTime> spentAt,
  Value<String?> note,
  Value<int?> accountId,
  Value<int?> recurringRuleId,
  Value<String?> importKey,
  Value<String> source,
  Value<DateTime> createdAt,
});

final class $$SpendsTableReferences
    extends BaseReferences<_$AppDatabase, $SpendsTable, Spend> {
  $$SpendsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _accountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias('spends__account_id__accounts__id');

  $$AccountsTableProcessedTableManager? get accountId {
    final $_column = $_itemColumn<int>('account_id');
    if ($_column == null) return null;
    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RecurringRulesTable _recurringRuleIdTable(_$AppDatabase db) => db
      .recurringRules
      .createAlias('spends__recurring_rule_id__recurring_rules__id');

  $$RecurringRulesTableProcessedTableManager? get recurringRuleId {
    final $_column = $_itemColumn<int>('recurring_rule_id');
    if ($_column == null) return null;
    final manager = $$RecurringRulesTableTableManager(
      $_db,
      $_db.recurringRules,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recurringRuleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SpendsTableFilterComposer
    extends Composer<_$AppDatabase, $SpendsTable> {
  $$SpendsTableFilterComposer({
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

  ColumnFilters<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get spentAt => $composableBuilder(
    column: $table.spentAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get importKey => $composableBuilder(
    column: $table.importKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RecurringRulesTableFilterComposer get recurringRuleId {
    final $$RecurringRulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recurringRuleId,
      referencedTable: $db.recurringRules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecurringRulesTableFilterComposer(
            $db: $db,
            $table: $db.recurringRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SpendsTableOrderingComposer
    extends Composer<_$AppDatabase, $SpendsTable> {
  $$SpendsTableOrderingComposer({
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

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get spentAt => $composableBuilder(
    column: $table.spentAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get importKey => $composableBuilder(
    column: $table.importKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RecurringRulesTableOrderingComposer get recurringRuleId {
    final $$RecurringRulesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recurringRuleId,
      referencedTable: $db.recurringRules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecurringRulesTableOrderingComposer(
            $db: $db,
            $table: $db.recurringRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SpendsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SpendsTable> {
  $$SpendsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<DateTime> get spentAt =>
      $composableBuilder(column: $table.spentAt, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get importKey =>
      $composableBuilder(column: $table.importKey, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RecurringRulesTableAnnotationComposer get recurringRuleId {
    final $$RecurringRulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recurringRuleId,
      referencedTable: $db.recurringRules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecurringRulesTableAnnotationComposer(
            $db: $db,
            $table: $db.recurringRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SpendsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SpendsTable,
          Spend,
          $$SpendsTableFilterComposer,
          $$SpendsTableOrderingComposer,
          $$SpendsTableAnnotationComposer,
          $$SpendsTableCreateCompanionBuilder,
          $$SpendsTableUpdateCompanionBuilder,
          (Spend, $$SpendsTableReferences),
          Spend,
          PrefetchHooks Function({bool accountId, bool recurringRuleId})
        > {
  $$SpendsTableTableManager(_$AppDatabase db, $SpendsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SpendsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SpendsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SpendsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<DateTime> spentAt = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int?> accountId = const Value.absent(),
                Value<int?> recurringRuleId = const Value.absent(),
                Value<String?> importKey = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SpendsCompanion(
                id: id,
                amountCents: amountCents,
                category: category,
                spentAt: spentAt,
                note: note,
                accountId: accountId,
                recurringRuleId: recurringRuleId,
                importKey: importKey,
                source: source,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int amountCents,
                required String category,
                required DateTime spentAt,
                Value<String?> note = const Value.absent(),
                Value<int?> accountId = const Value.absent(),
                Value<int?> recurringRuleId = const Value.absent(),
                Value<String?> importKey = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SpendsCompanion.insert(
                id: id,
                amountCents: amountCents,
                category: category,
                spentAt: spentAt,
                note: note,
                accountId: accountId,
                recurringRuleId: recurringRuleId,
                importKey: importKey,
                source: source,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SpendsTable, Spend>(table),
                  $$SpendsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({accountId = false, recurringRuleId = false}) {
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
                        if (accountId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.accountId,
                            referencedTable: $$SpendsTableReferences
                                ._accountIdTable(db),
                            referencedColumn: $$SpendsTableReferences
                                ._accountIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (recurringRuleId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.recurringRuleId,
                            referencedTable: $$SpendsTableReferences
                                ._recurringRuleIdTable(db),
                            referencedColumn: $$SpendsTableReferences
                                ._recurringRuleIdTable(db)
                                .id,
                          ) as T;
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

typedef $$SpendsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SpendsTable,
      Spend,
      $$SpendsTableFilterComposer,
      $$SpendsTableOrderingComposer,
      $$SpendsTableAnnotationComposer,
      $$SpendsTableCreateCompanionBuilder,
      $$SpendsTableUpdateCompanionBuilder,
      (Spend, $$SpendsTableReferences),
      Spend,
      PrefetchHooks Function({bool accountId, bool recurringRuleId})
    >;
typedef $$TransfersTableCreateCompanionBuilder = TransfersCompanion Function({
  Value<int> id,
  required int fromAccountId,
  required int toAccountId,
  required int amountCents,
  required DateTime transferredAt,
  Value<String?> note,
  Value<String?> importKey,
  Value<DateTime> createdAt,
});
typedef $$TransfersTableUpdateCompanionBuilder = TransfersCompanion Function({
  Value<int> id,
  Value<int> fromAccountId,
  Value<int> toAccountId,
  Value<int> amountCents,
  Value<DateTime> transferredAt,
  Value<String?> note,
  Value<String?> importKey,
  Value<DateTime> createdAt,
});

final class $$TransfersTableReferences
    extends BaseReferences<_$AppDatabase, $TransfersTable, Transfer> {
  $$TransfersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _fromAccountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias('transfers__from_account_id__accounts__id');

  $$AccountsTableProcessedTableManager get fromAccountId {
    final $_column = $_itemColumn<int>('from_account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fromAccountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AccountsTable _toAccountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias('transfers__to_account_id__accounts__id');

  $$AccountsTableProcessedTableManager get toAccountId {
    final $_column = $_itemColumn<int>('to_account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_toAccountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TransfersTableFilterComposer
    extends Composer<_$AppDatabase, $TransfersTable> {
  $$TransfersTableFilterComposer({
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

  ColumnFilters<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get transferredAt => $composableBuilder(
    column: $table.transferredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get importKey => $composableBuilder(
    column: $table.importKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get fromAccountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableFilterComposer get toAccountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransfersTableOrderingComposer
    extends Composer<_$AppDatabase, $TransfersTable> {
  $$TransfersTableOrderingComposer({
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

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get transferredAt => $composableBuilder(
    column: $table.transferredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get importKey => $composableBuilder(
    column: $table.importKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get fromAccountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableOrderingComposer get toAccountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransfersTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransfersTable> {
  $$TransfersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get transferredAt => $composableBuilder(
    column: $table.transferredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get importKey =>
      $composableBuilder(column: $table.importKey, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$AccountsTableAnnotationComposer get fromAccountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableAnnotationComposer get toAccountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransfersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransfersTable,
          Transfer,
          $$TransfersTableFilterComposer,
          $$TransfersTableOrderingComposer,
          $$TransfersTableAnnotationComposer,
          $$TransfersTableCreateCompanionBuilder,
          $$TransfersTableUpdateCompanionBuilder,
          (Transfer, $$TransfersTableReferences),
          Transfer,
          PrefetchHooks Function({bool fromAccountId, bool toAccountId})
        > {
  $$TransfersTableTableManager(_$AppDatabase db, $TransfersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransfersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransfersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransfersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> fromAccountId = const Value.absent(),
                Value<int> toAccountId = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<DateTime> transferredAt = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> importKey = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TransfersCompanion(
                id: id,
                fromAccountId: fromAccountId,
                toAccountId: toAccountId,
                amountCents: amountCents,
                transferredAt: transferredAt,
                note: note,
                importKey: importKey,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int fromAccountId,
                required int toAccountId,
                required int amountCents,
                required DateTime transferredAt,
                Value<String?> note = const Value.absent(),
                Value<String?> importKey = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TransfersCompanion.insert(
                id: id,
                fromAccountId: fromAccountId,
                toAccountId: toAccountId,
                amountCents: amountCents,
                transferredAt: transferredAt,
                note: note,
                importKey: importKey,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TransfersTable, Transfer>(table),
                  $$TransfersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({fromAccountId = false, toAccountId = false}) {
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
                        if (fromAccountId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.fromAccountId,
                            referencedTable: $$TransfersTableReferences
                                ._fromAccountIdTable(db),
                            referencedColumn: $$TransfersTableReferences
                                ._fromAccountIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (toAccountId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.toAccountId,
                            referencedTable: $$TransfersTableReferences
                                ._toAccountIdTable(db),
                            referencedColumn: $$TransfersTableReferences
                                ._toAccountIdTable(db)
                                .id,
                          ) as T;
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

typedef $$TransfersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransfersTable,
      Transfer,
      $$TransfersTableFilterComposer,
      $$TransfersTableOrderingComposer,
      $$TransfersTableAnnotationComposer,
      $$TransfersTableCreateCompanionBuilder,
      $$TransfersTableUpdateCompanionBuilder,
      (Transfer, $$TransfersTableReferences),
      Transfer,
      PrefetchHooks Function({bool fromAccountId, bool toAccountId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$WithdrawalsTableTableManager get withdrawals =>
      $$WithdrawalsTableTableManager(_db, _db.withdrawals);
  $$RecurringRulesTableTableManager get recurringRules =>
      $$RecurringRulesTableTableManager(_db, _db.recurringRules);
  $$SpendsTableTableManager get spends =>
      $$SpendsTableTableManager(_db, _db.spends);
  $$TransfersTableTableManager get transfers =>
      $$TransfersTableTableManager(_db, _db.transfers);
}
