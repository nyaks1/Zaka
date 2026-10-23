// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
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
  final DateTime createdAt;
  const Withdrawal({
    required this.id,
    required this.amountCents,
    required this.withdrawnAt,
    this.note,
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
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WithdrawalsCompanion toCompanion(bool nullToAbsent) {
    return WithdrawalsCompanion(
      id: Value(id),
      amountCents: Value(amountCents),
      withdrawnAt: Value(withdrawnAt),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
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
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Withdrawal copyWith({
    int? id,
    int? amountCents,
    DateTime? withdrawnAt,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
  }) => Withdrawal(
    id: id ?? this.id,
    amountCents: amountCents ?? this.amountCents,
    withdrawnAt: withdrawnAt ?? this.withdrawnAt,
    note: note.present ? note.value : this.note,
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
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, amountCents, withdrawnAt, note, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Withdrawal &&
          other.id == this.id &&
          other.amountCents == this.amountCents &&
          other.withdrawnAt == this.withdrawnAt &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class WithdrawalsCompanion extends UpdateCompanion<Withdrawal> {
  final Value<int> id;
  final Value<int> amountCents;
  final Value<DateTime> withdrawnAt;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  const WithdrawalsCompanion({
    this.id = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.withdrawnAt = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  WithdrawalsCompanion.insert({
    this.id = const Value.absent(),
    required int amountCents,
    required DateTime withdrawnAt,
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : amountCents = Value(amountCents),
       withdrawnAt = Value(withdrawnAt);
  static Insertable<Withdrawal> custom({
    Expression<int>? id,
    Expression<int>? amountCents,
    Expression<DateTime>? withdrawnAt,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amountCents != null) 'amount_cents': amountCents,
      if (withdrawnAt != null) 'withdrawn_at': withdrawnAt,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  WithdrawalsCompanion copyWith({
    Value<int>? id,
    Value<int>? amountCents,
    Value<DateTime>? withdrawnAt,
    Value<String?>? note,
    Value<DateTime>? createdAt,
  }) {
    return WithdrawalsCompanion(
      id: id ?? this.id,
      amountCents: amountCents ?? this.amountCents,
      withdrawnAt: withdrawnAt ?? this.withdrawnAt,
      note: note ?? this.note,
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
    recurringRuleId,
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
    if (data.containsKey('recurring_rule_id')) {
      context.handle(
        _recurringRuleIdMeta,
        recurringRuleId.isAcceptableOrUnknown(
          data['recurring_rule_id']!,
          _recurringRuleIdMeta,
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
      recurringRuleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recurring_rule_id'],
      ),
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

  /// Set when this spend was generated from a recurring rule.
  final int? recurringRuleId;
  final DateTime createdAt;
  const Spend({
    required this.id,
    required this.amountCents,
    required this.category,
    required this.spentAt,
    this.note,
    this.recurringRuleId,
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
    if (!nullToAbsent || recurringRuleId != null) {
      map['recurring_rule_id'] = Variable<int>(recurringRuleId);
    }
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
      recurringRuleId: recurringRuleId == null && nullToAbsent
          ? const Value.absent()
          : Value(recurringRuleId),
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
      recurringRuleId: serializer.fromJson<int?>(json['recurringRuleId']),
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
      'recurringRuleId': serializer.toJson<int?>(recurringRuleId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Spend copyWith({
    int? id,
    int? amountCents,
    String? category,
    DateTime? spentAt,
    Value<String?> note = const Value.absent(),
    Value<int?> recurringRuleId = const Value.absent(),
    DateTime? createdAt,
  }) => Spend(
    id: id ?? this.id,
    amountCents: amountCents ?? this.amountCents,
    category: category ?? this.category,
    spentAt: spentAt ?? this.spentAt,
    note: note.present ? note.value : this.note,
    recurringRuleId: recurringRuleId.present
        ? recurringRuleId.value
        : this.recurringRuleId,
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
      recurringRuleId: data.recurringRuleId.present
          ? data.recurringRuleId.value
          : this.recurringRuleId,
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
          ..write('recurringRuleId: $recurringRuleId, ')
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
    recurringRuleId,
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
          other.recurringRuleId == this.recurringRuleId &&
          other.createdAt == this.createdAt);
}

class SpendsCompanion extends UpdateCompanion<Spend> {
  final Value<int> id;
  final Value<int> amountCents;
  final Value<String> category;
  final Value<DateTime> spentAt;
  final Value<String?> note;
  final Value<int?> recurringRuleId;
  final Value<DateTime> createdAt;
  const SpendsCompanion({
    this.id = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.category = const Value.absent(),
    this.spentAt = const Value.absent(),
    this.note = const Value.absent(),
    this.recurringRuleId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SpendsCompanion.insert({
    this.id = const Value.absent(),
    required int amountCents,
    required String category,
    required DateTime spentAt,
    this.note = const Value.absent(),
    this.recurringRuleId = const Value.absent(),
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
    Expression<int>? recurringRuleId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amountCents != null) 'amount_cents': amountCents,
      if (category != null) 'category': category,
      if (spentAt != null) 'spent_at': spentAt,
      if (note != null) 'note': note,
      if (recurringRuleId != null) 'recurring_rule_id': recurringRuleId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SpendsCompanion copyWith({
    Value<int>? id,
    Value<int>? amountCents,
    Value<String>? category,
    Value<DateTime>? spentAt,
    Value<String?>? note,
    Value<int?>? recurringRuleId,
    Value<DateTime>? createdAt,
  }) {
    return SpendsCompanion(
      id: id ?? this.id,
      amountCents: amountCents ?? this.amountCents,
      category: category ?? this.category,
      spentAt: spentAt ?? this.spentAt,
      note: note ?? this.note,
      recurringRuleId: recurringRuleId ?? this.recurringRuleId,
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
    if (recurringRuleId.present) {
      map['recurring_rule_id'] = Variable<int>(recurringRuleId.value);
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
          ..write('recurringRuleId: $recurringRuleId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WithdrawalsTable withdrawals = $WithdrawalsTable(this);
  late final $RecurringRulesTable recurringRules = $RecurringRulesTable(this);
  late final $SpendsTable spends = $SpendsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    withdrawals,
    recurringRules,
    spends,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'recurring_rules',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('spends', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $$WithdrawalsTableCreateCompanionBuilder =
    WithdrawalsCompanion Function({
      Value<int> id,
      required int amountCents,
      required DateTime withdrawnAt,
      Value<String?> note,
      Value<DateTime> createdAt,
    });
typedef $$WithdrawalsTableUpdateCompanionBuilder =
    WithdrawalsCompanion Function({
      Value<int> id,
      Value<int> amountCents,
      Value<DateTime> withdrawnAt,
      Value<String?> note,
      Value<DateTime> createdAt,
    });

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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
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

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
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
          (
            Withdrawal,
            BaseReferences<_$AppDatabase, $WithdrawalsTable, Withdrawal>,
          ),
          Withdrawal,
          PrefetchHooks Function()
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
                Value<DateTime> createdAt = const Value.absent(),
              }) => WithdrawalsCompanion(
                id: id,
                amountCents: amountCents,
                withdrawnAt: withdrawnAt,
                note: note,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int amountCents,
                required DateTime withdrawnAt,
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => WithdrawalsCompanion.insert(
                id: id,
                amountCents: amountCents,
                withdrawnAt: withdrawnAt,
                note: note,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WithdrawalsTable, Withdrawal>(table),
                  BaseReferences<_$AppDatabase, $WithdrawalsTable, Withdrawal>(
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
      (
        Withdrawal,
        BaseReferences<_$AppDatabase, $WithdrawalsTable, Withdrawal>,
      ),
      Withdrawal,
      PrefetchHooks Function()
    >;
typedef $$RecurringRulesTableCreateCompanionBuilder =
    RecurringRulesCompanion Function({
      Value<int> id,
      required int amountCents,
      required String category,
      Value<String?> note,
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
          PrefetchHooks Function({bool spendsRefs})
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
          prefetchHooksCallback: ({spendsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (spendsRefs) db.spends],
              addJoins: null,
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
      PrefetchHooks Function({bool spendsRefs})
    >;
typedef $$SpendsTableCreateCompanionBuilder = SpendsCompanion Function({
  Value<int> id,
  required int amountCents,
  required String category,
  required DateTime spentAt,
  Value<String?> note,
  Value<int?> recurringRuleId,
  Value<DateTime> createdAt,
});
typedef $$SpendsTableUpdateCompanionBuilder = SpendsCompanion Function({
  Value<int> id,
  Value<int> amountCents,
  Value<String> category,
  Value<DateTime> spentAt,
  Value<String?> note,
  Value<int?> recurringRuleId,
  Value<DateTime> createdAt,
});

final class $$SpendsTableReferences
    extends BaseReferences<_$AppDatabase, $SpendsTable, Spend> {
  $$SpendsTableReferences(super.$_db, super.$_table, super.$_typedResult);

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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

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

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

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
          PrefetchHooks Function({bool recurringRuleId})
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
                Value<int?> recurringRuleId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SpendsCompanion(
                id: id,
                amountCents: amountCents,
                category: category,
                spentAt: spentAt,
                note: note,
                recurringRuleId: recurringRuleId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int amountCents,
                required String category,
                required DateTime spentAt,
                Value<String?> note = const Value.absent(),
                Value<int?> recurringRuleId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SpendsCompanion.insert(
                id: id,
                amountCents: amountCents,
                category: category,
                spentAt: spentAt,
                note: note,
                recurringRuleId: recurringRuleId,
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
          prefetchHooksCallback: ({recurringRuleId = false}) {
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
      PrefetchHooks Function({bool recurringRuleId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WithdrawalsTableTableManager get withdrawals =>
      $$WithdrawalsTableTableManager(_db, _db.withdrawals);
  $$RecurringRulesTableTableManager get recurringRules =>
      $$RecurringRulesTableTableManager(_db, _db.recurringRules);
  $$SpendsTableTableManager get spends =>
      $$SpendsTableTableManager(_db, _db.spends);
}
