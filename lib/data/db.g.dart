// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db.dart';

// ignore_for_file: type=lint
class $SmokeEventsTable extends SmokeEvents
    with TableInfo<$SmokeEventsTable, SmokeEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SmokeEventsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, timestamp];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'smoke_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<SmokeEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SmokeEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SmokeEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
    );
  }

  @override
  $SmokeEventsTable createAlias(String alias) {
    return $SmokeEventsTable(attachedDatabase, alias);
  }
}

class SmokeEvent extends DataClass implements Insertable<SmokeEvent> {
  final int id;
  final DateTime timestamp;
  const SmokeEvent({required this.id, required this.timestamp});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  SmokeEventsCompanion toCompanion(bool nullToAbsent) {
    return SmokeEventsCompanion(id: Value(id), timestamp: Value(timestamp));
  }

  factory SmokeEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SmokeEvent(
      id: serializer.fromJson<int>(json['id']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  SmokeEvent copyWith({int? id, DateTime? timestamp}) =>
      SmokeEvent(id: id ?? this.id, timestamp: timestamp ?? this.timestamp);
  SmokeEvent copyWithCompanion(SmokeEventsCompanion data) {
    return SmokeEvent(
      id: data.id.present ? data.id.value : this.id,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SmokeEvent(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SmokeEvent &&
          other.id == this.id &&
          other.timestamp == this.timestamp);
}

class SmokeEventsCompanion extends UpdateCompanion<SmokeEvent> {
  final Value<int> id;
  final Value<DateTime> timestamp;
  const SmokeEventsCompanion({
    this.id = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  SmokeEventsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime timestamp,
  }) : timestamp = Value(timestamp);
  static Insertable<SmokeEvent> custom({
    Expression<int>? id,
    Expression<DateTime>? timestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  SmokeEventsCompanion copyWith({Value<int>? id, Value<DateTime>? timestamp}) {
    return SmokeEventsCompanion(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SmokeEventsCompanion(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }
}

class $DailyBudgetsTable extends DailyBudgets
    with TableInfo<$DailyBudgetsTable, DailyBudget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyBudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _limitMeta = const VerificationMeta('limit');
  @override
  late final GeneratedColumn<int> limit = GeneratedColumn<int>(
    'limit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [date, limit];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_budgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyBudget> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('limit')) {
      context.handle(
        _limitMeta,
        limit.isAcceptableOrUnknown(data['limit']!, _limitMeta),
      );
    } else if (isInserting) {
      context.missing(_limitMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  DailyBudget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyBudget(
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      limit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}limit'],
      )!,
    );
  }

  @override
  $DailyBudgetsTable createAlias(String alias) {
    return $DailyBudgetsTable(attachedDatabase, alias);
  }
}

class DailyBudget extends DataClass implements Insertable<DailyBudget> {
  final String date;
  final int limit;
  const DailyBudget({required this.date, required this.limit});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<String>(date);
    map['limit'] = Variable<int>(limit);
    return map;
  }

  DailyBudgetsCompanion toCompanion(bool nullToAbsent) {
    return DailyBudgetsCompanion(date: Value(date), limit: Value(limit));
  }

  factory DailyBudget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyBudget(
      date: serializer.fromJson<String>(json['date']),
      limit: serializer.fromJson<int>(json['limit']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<String>(date),
      'limit': serializer.toJson<int>(limit),
    };
  }

  DailyBudget copyWith({String? date, int? limit}) =>
      DailyBudget(date: date ?? this.date, limit: limit ?? this.limit);
  DailyBudget copyWithCompanion(DailyBudgetsCompanion data) {
    return DailyBudget(
      date: data.date.present ? data.date.value : this.date,
      limit: data.limit.present ? data.limit.value : this.limit,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyBudget(')
          ..write('date: $date, ')
          ..write('limit: $limit')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(date, limit);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyBudget &&
          other.date == this.date &&
          other.limit == this.limit);
}

class DailyBudgetsCompanion extends UpdateCompanion<DailyBudget> {
  final Value<String> date;
  final Value<int> limit;
  final Value<int> rowid;
  const DailyBudgetsCompanion({
    this.date = const Value.absent(),
    this.limit = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyBudgetsCompanion.insert({
    required String date,
    required int limit,
    this.rowid = const Value.absent(),
  }) : date = Value(date),
       limit = Value(limit);
  static Insertable<DailyBudget> custom({
    Expression<String>? date,
    Expression<int>? limit,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (limit != null) 'limit': limit,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyBudgetsCompanion copyWith({
    Value<String>? date,
    Value<int>? limit,
    Value<int>? rowid,
  }) {
    return DailyBudgetsCompanion(
      date: date ?? this.date,
      limit: limit ?? this.limit,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (limit.present) {
      map['limit'] = Variable<int>(limit.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyBudgetsCompanion(')
          ..write('date: $date, ')
          ..write('limit: $limit, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _usualBaselineMeta = const VerificationMeta(
    'usualBaseline',
  );
  @override
  late final GeneratedColumn<int> usualBaseline = GeneratedColumn<int>(
    'usual_baseline',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _defaultBudgetMeta = const VerificationMeta(
    'defaultBudget',
  );
  @override
  late final GeneratedColumn<int> defaultBudget = GeneratedColumn<int>(
    'default_budget',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _onboardingDoneMeta = const VerificationMeta(
    'onboardingDone',
  );
  @override
  late final GeneratedColumn<bool> onboardingDone = GeneratedColumn<bool>(
    'onboarding_done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("onboarding_done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _buddyNameMeta = const VerificationMeta(
    'buddyName',
  );
  @override
  late final GeneratedColumn<String> buddyName = GeneratedColumn<String>(
    'buddy_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Buddy'),
  );
  static const VerificationMeta _bestStreakMeta = const VerificationMeta(
    'bestStreak',
  );
  @override
  late final GeneratedColumn<int> bestStreak = GeneratedColumn<int>(
    'best_streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _packCostMeta = const VerificationMeta(
    'packCost',
  );
  @override
  late final GeneratedColumn<double> packCost = GeneratedColumn<double>(
    'pack_cost',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(40.0),
  );
  static const VerificationMeta _cigsPerPackMeta = const VerificationMeta(
    'cigsPerPack',
  );
  @override
  late final GeneratedColumn<int> cigsPerPack = GeneratedColumn<int>(
    'cigs_per_pack',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(20),
  );
  static const VerificationMeta _isPlusMeta = const VerificationMeta('isPlus');
  @override
  late final GeneratedColumn<bool> isPlus = GeneratedColumn<bool>(
    'is_plus',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_plus" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _equippedCosmeticIdMeta =
      const VerificationMeta('equippedCosmeticId');
  @override
  late final GeneratedColumn<String> equippedCosmeticId =
      GeneratedColumn<String>(
        'equipped_cosmetic_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('none'),
      );
  static const VerificationMeta _remindersEnabledMeta = const VerificationMeta(
    'remindersEnabled',
  );
  @override
  late final GeneratedColumn<bool> remindersEnabled = GeneratedColumn<bool>(
    'reminders_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reminders_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _reminderHourMeta = const VerificationMeta(
    'reminderHour',
  );
  @override
  late final GeneratedColumn<int> reminderHour = GeneratedColumn<int>(
    'reminder_hour',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(20),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    usualBaseline,
    defaultBudget,
    onboardingDone,
    buddyName,
    bestStreak,
    packCost,
    cigsPerPack,
    isPlus,
    equippedCosmeticId,
    remindersEnabled,
    reminderHour,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('usual_baseline')) {
      context.handle(
        _usualBaselineMeta,
        usualBaseline.isAcceptableOrUnknown(
          data['usual_baseline']!,
          _usualBaselineMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_usualBaselineMeta);
    }
    if (data.containsKey('default_budget')) {
      context.handle(
        _defaultBudgetMeta,
        defaultBudget.isAcceptableOrUnknown(
          data['default_budget']!,
          _defaultBudgetMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defaultBudgetMeta);
    }
    if (data.containsKey('onboarding_done')) {
      context.handle(
        _onboardingDoneMeta,
        onboardingDone.isAcceptableOrUnknown(
          data['onboarding_done']!,
          _onboardingDoneMeta,
        ),
      );
    }
    if (data.containsKey('buddy_name')) {
      context.handle(
        _buddyNameMeta,
        buddyName.isAcceptableOrUnknown(data['buddy_name']!, _buddyNameMeta),
      );
    }
    if (data.containsKey('best_streak')) {
      context.handle(
        _bestStreakMeta,
        bestStreak.isAcceptableOrUnknown(data['best_streak']!, _bestStreakMeta),
      );
    }
    if (data.containsKey('pack_cost')) {
      context.handle(
        _packCostMeta,
        packCost.isAcceptableOrUnknown(data['pack_cost']!, _packCostMeta),
      );
    }
    if (data.containsKey('cigs_per_pack')) {
      context.handle(
        _cigsPerPackMeta,
        cigsPerPack.isAcceptableOrUnknown(
          data['cigs_per_pack']!,
          _cigsPerPackMeta,
        ),
      );
    }
    if (data.containsKey('is_plus')) {
      context.handle(
        _isPlusMeta,
        isPlus.isAcceptableOrUnknown(data['is_plus']!, _isPlusMeta),
      );
    }
    if (data.containsKey('equipped_cosmetic_id')) {
      context.handle(
        _equippedCosmeticIdMeta,
        equippedCosmeticId.isAcceptableOrUnknown(
          data['equipped_cosmetic_id']!,
          _equippedCosmeticIdMeta,
        ),
      );
    }
    if (data.containsKey('reminders_enabled')) {
      context.handle(
        _remindersEnabledMeta,
        remindersEnabled.isAcceptableOrUnknown(
          data['reminders_enabled']!,
          _remindersEnabledMeta,
        ),
      );
    }
    if (data.containsKey('reminder_hour')) {
      context.handle(
        _reminderHourMeta,
        reminderHour.isAcceptableOrUnknown(
          data['reminder_hour']!,
          _reminderHourMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      usualBaseline: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}usual_baseline'],
      )!,
      defaultBudget: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_budget'],
      )!,
      onboardingDone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}onboarding_done'],
      )!,
      buddyName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}buddy_name'],
      )!,
      bestStreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_streak'],
      )!,
      packCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pack_cost'],
      )!,
      cigsPerPack: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cigs_per_pack'],
      )!,
      isPlus: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_plus'],
      )!,
      equippedCosmeticId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipped_cosmetic_id'],
      )!,
      remindersEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reminders_enabled'],
      )!,
      reminderHour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_hour'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final int id;
  final int usualBaseline;
  final int defaultBudget;
  final bool onboardingDone;
  final String buddyName;
  final int bestStreak;
  final double packCost;
  final int cigsPerPack;
  final bool isPlus;
  final String equippedCosmeticId;
  final bool remindersEnabled;
  final int reminderHour;
  const Setting({
    required this.id,
    required this.usualBaseline,
    required this.defaultBudget,
    required this.onboardingDone,
    required this.buddyName,
    required this.bestStreak,
    required this.packCost,
    required this.cigsPerPack,
    required this.isPlus,
    required this.equippedCosmeticId,
    required this.remindersEnabled,
    required this.reminderHour,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['usual_baseline'] = Variable<int>(usualBaseline);
    map['default_budget'] = Variable<int>(defaultBudget);
    map['onboarding_done'] = Variable<bool>(onboardingDone);
    map['buddy_name'] = Variable<String>(buddyName);
    map['best_streak'] = Variable<int>(bestStreak);
    map['pack_cost'] = Variable<double>(packCost);
    map['cigs_per_pack'] = Variable<int>(cigsPerPack);
    map['is_plus'] = Variable<bool>(isPlus);
    map['equipped_cosmetic_id'] = Variable<String>(equippedCosmeticId);
    map['reminders_enabled'] = Variable<bool>(remindersEnabled);
    map['reminder_hour'] = Variable<int>(reminderHour);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      id: Value(id),
      usualBaseline: Value(usualBaseline),
      defaultBudget: Value(defaultBudget),
      onboardingDone: Value(onboardingDone),
      buddyName: Value(buddyName),
      bestStreak: Value(bestStreak),
      packCost: Value(packCost),
      cigsPerPack: Value(cigsPerPack),
      isPlus: Value(isPlus),
      equippedCosmeticId: Value(equippedCosmeticId),
      remindersEnabled: Value(remindersEnabled),
      reminderHour: Value(reminderHour),
    );
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      id: serializer.fromJson<int>(json['id']),
      usualBaseline: serializer.fromJson<int>(json['usualBaseline']),
      defaultBudget: serializer.fromJson<int>(json['defaultBudget']),
      onboardingDone: serializer.fromJson<bool>(json['onboardingDone']),
      buddyName: serializer.fromJson<String>(json['buddyName']),
      bestStreak: serializer.fromJson<int>(json['bestStreak']),
      packCost: serializer.fromJson<double>(json['packCost']),
      cigsPerPack: serializer.fromJson<int>(json['cigsPerPack']),
      isPlus: serializer.fromJson<bool>(json['isPlus']),
      equippedCosmeticId: serializer.fromJson<String>(
        json['equippedCosmeticId'],
      ),
      remindersEnabled: serializer.fromJson<bool>(json['remindersEnabled']),
      reminderHour: serializer.fromJson<int>(json['reminderHour']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'usualBaseline': serializer.toJson<int>(usualBaseline),
      'defaultBudget': serializer.toJson<int>(defaultBudget),
      'onboardingDone': serializer.toJson<bool>(onboardingDone),
      'buddyName': serializer.toJson<String>(buddyName),
      'bestStreak': serializer.toJson<int>(bestStreak),
      'packCost': serializer.toJson<double>(packCost),
      'cigsPerPack': serializer.toJson<int>(cigsPerPack),
      'isPlus': serializer.toJson<bool>(isPlus),
      'equippedCosmeticId': serializer.toJson<String>(equippedCosmeticId),
      'remindersEnabled': serializer.toJson<bool>(remindersEnabled),
      'reminderHour': serializer.toJson<int>(reminderHour),
    };
  }

  Setting copyWith({
    int? id,
    int? usualBaseline,
    int? defaultBudget,
    bool? onboardingDone,
    String? buddyName,
    int? bestStreak,
    double? packCost,
    int? cigsPerPack,
    bool? isPlus,
    String? equippedCosmeticId,
    bool? remindersEnabled,
    int? reminderHour,
  }) => Setting(
    id: id ?? this.id,
    usualBaseline: usualBaseline ?? this.usualBaseline,
    defaultBudget: defaultBudget ?? this.defaultBudget,
    onboardingDone: onboardingDone ?? this.onboardingDone,
    buddyName: buddyName ?? this.buddyName,
    bestStreak: bestStreak ?? this.bestStreak,
    packCost: packCost ?? this.packCost,
    cigsPerPack: cigsPerPack ?? this.cigsPerPack,
    isPlus: isPlus ?? this.isPlus,
    equippedCosmeticId: equippedCosmeticId ?? this.equippedCosmeticId,
    remindersEnabled: remindersEnabled ?? this.remindersEnabled,
    reminderHour: reminderHour ?? this.reminderHour,
  );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      id: data.id.present ? data.id.value : this.id,
      usualBaseline: data.usualBaseline.present
          ? data.usualBaseline.value
          : this.usualBaseline,
      defaultBudget: data.defaultBudget.present
          ? data.defaultBudget.value
          : this.defaultBudget,
      onboardingDone: data.onboardingDone.present
          ? data.onboardingDone.value
          : this.onboardingDone,
      buddyName: data.buddyName.present ? data.buddyName.value : this.buddyName,
      bestStreak: data.bestStreak.present
          ? data.bestStreak.value
          : this.bestStreak,
      packCost: data.packCost.present ? data.packCost.value : this.packCost,
      cigsPerPack: data.cigsPerPack.present
          ? data.cigsPerPack.value
          : this.cigsPerPack,
      isPlus: data.isPlus.present ? data.isPlus.value : this.isPlus,
      equippedCosmeticId: data.equippedCosmeticId.present
          ? data.equippedCosmeticId.value
          : this.equippedCosmeticId,
      remindersEnabled: data.remindersEnabled.present
          ? data.remindersEnabled.value
          : this.remindersEnabled,
      reminderHour: data.reminderHour.present
          ? data.reminderHour.value
          : this.reminderHour,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('id: $id, ')
          ..write('usualBaseline: $usualBaseline, ')
          ..write('defaultBudget: $defaultBudget, ')
          ..write('onboardingDone: $onboardingDone, ')
          ..write('buddyName: $buddyName, ')
          ..write('bestStreak: $bestStreak, ')
          ..write('packCost: $packCost, ')
          ..write('cigsPerPack: $cigsPerPack, ')
          ..write('isPlus: $isPlus, ')
          ..write('equippedCosmeticId: $equippedCosmeticId, ')
          ..write('remindersEnabled: $remindersEnabled, ')
          ..write('reminderHour: $reminderHour')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    usualBaseline,
    defaultBudget,
    onboardingDone,
    buddyName,
    bestStreak,
    packCost,
    cigsPerPack,
    isPlus,
    equippedCosmeticId,
    remindersEnabled,
    reminderHour,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting &&
          other.id == this.id &&
          other.usualBaseline == this.usualBaseline &&
          other.defaultBudget == this.defaultBudget &&
          other.onboardingDone == this.onboardingDone &&
          other.buddyName == this.buddyName &&
          other.bestStreak == this.bestStreak &&
          other.packCost == this.packCost &&
          other.cigsPerPack == this.cigsPerPack &&
          other.isPlus == this.isPlus &&
          other.equippedCosmeticId == this.equippedCosmeticId &&
          other.remindersEnabled == this.remindersEnabled &&
          other.reminderHour == this.reminderHour);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<int> id;
  final Value<int> usualBaseline;
  final Value<int> defaultBudget;
  final Value<bool> onboardingDone;
  final Value<String> buddyName;
  final Value<int> bestStreak;
  final Value<double> packCost;
  final Value<int> cigsPerPack;
  final Value<bool> isPlus;
  final Value<String> equippedCosmeticId;
  final Value<bool> remindersEnabled;
  final Value<int> reminderHour;
  const SettingsCompanion({
    this.id = const Value.absent(),
    this.usualBaseline = const Value.absent(),
    this.defaultBudget = const Value.absent(),
    this.onboardingDone = const Value.absent(),
    this.buddyName = const Value.absent(),
    this.bestStreak = const Value.absent(),
    this.packCost = const Value.absent(),
    this.cigsPerPack = const Value.absent(),
    this.isPlus = const Value.absent(),
    this.equippedCosmeticId = const Value.absent(),
    this.remindersEnabled = const Value.absent(),
    this.reminderHour = const Value.absent(),
  });
  SettingsCompanion.insert({
    this.id = const Value.absent(),
    required int usualBaseline,
    required int defaultBudget,
    this.onboardingDone = const Value.absent(),
    this.buddyName = const Value.absent(),
    this.bestStreak = const Value.absent(),
    this.packCost = const Value.absent(),
    this.cigsPerPack = const Value.absent(),
    this.isPlus = const Value.absent(),
    this.equippedCosmeticId = const Value.absent(),
    this.remindersEnabled = const Value.absent(),
    this.reminderHour = const Value.absent(),
  }) : usualBaseline = Value(usualBaseline),
       defaultBudget = Value(defaultBudget);
  static Insertable<Setting> custom({
    Expression<int>? id,
    Expression<int>? usualBaseline,
    Expression<int>? defaultBudget,
    Expression<bool>? onboardingDone,
    Expression<String>? buddyName,
    Expression<int>? bestStreak,
    Expression<double>? packCost,
    Expression<int>? cigsPerPack,
    Expression<bool>? isPlus,
    Expression<String>? equippedCosmeticId,
    Expression<bool>? remindersEnabled,
    Expression<int>? reminderHour,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (usualBaseline != null) 'usual_baseline': usualBaseline,
      if (defaultBudget != null) 'default_budget': defaultBudget,
      if (onboardingDone != null) 'onboarding_done': onboardingDone,
      if (buddyName != null) 'buddy_name': buddyName,
      if (bestStreak != null) 'best_streak': bestStreak,
      if (packCost != null) 'pack_cost': packCost,
      if (cigsPerPack != null) 'cigs_per_pack': cigsPerPack,
      if (isPlus != null) 'is_plus': isPlus,
      if (equippedCosmeticId != null)
        'equipped_cosmetic_id': equippedCosmeticId,
      if (remindersEnabled != null) 'reminders_enabled': remindersEnabled,
      if (reminderHour != null) 'reminder_hour': reminderHour,
    });
  }

  SettingsCompanion copyWith({
    Value<int>? id,
    Value<int>? usualBaseline,
    Value<int>? defaultBudget,
    Value<bool>? onboardingDone,
    Value<String>? buddyName,
    Value<int>? bestStreak,
    Value<double>? packCost,
    Value<int>? cigsPerPack,
    Value<bool>? isPlus,
    Value<String>? equippedCosmeticId,
    Value<bool>? remindersEnabled,
    Value<int>? reminderHour,
  }) {
    return SettingsCompanion(
      id: id ?? this.id,
      usualBaseline: usualBaseline ?? this.usualBaseline,
      defaultBudget: defaultBudget ?? this.defaultBudget,
      onboardingDone: onboardingDone ?? this.onboardingDone,
      buddyName: buddyName ?? this.buddyName,
      bestStreak: bestStreak ?? this.bestStreak,
      packCost: packCost ?? this.packCost,
      cigsPerPack: cigsPerPack ?? this.cigsPerPack,
      isPlus: isPlus ?? this.isPlus,
      equippedCosmeticId: equippedCosmeticId ?? this.equippedCosmeticId,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (usualBaseline.present) {
      map['usual_baseline'] = Variable<int>(usualBaseline.value);
    }
    if (defaultBudget.present) {
      map['default_budget'] = Variable<int>(defaultBudget.value);
    }
    if (onboardingDone.present) {
      map['onboarding_done'] = Variable<bool>(onboardingDone.value);
    }
    if (buddyName.present) {
      map['buddy_name'] = Variable<String>(buddyName.value);
    }
    if (bestStreak.present) {
      map['best_streak'] = Variable<int>(bestStreak.value);
    }
    if (packCost.present) {
      map['pack_cost'] = Variable<double>(packCost.value);
    }
    if (cigsPerPack.present) {
      map['cigs_per_pack'] = Variable<int>(cigsPerPack.value);
    }
    if (isPlus.present) {
      map['is_plus'] = Variable<bool>(isPlus.value);
    }
    if (equippedCosmeticId.present) {
      map['equipped_cosmetic_id'] = Variable<String>(equippedCosmeticId.value);
    }
    if (remindersEnabled.present) {
      map['reminders_enabled'] = Variable<bool>(remindersEnabled.value);
    }
    if (reminderHour.present) {
      map['reminder_hour'] = Variable<int>(reminderHour.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('id: $id, ')
          ..write('usualBaseline: $usualBaseline, ')
          ..write('defaultBudget: $defaultBudget, ')
          ..write('onboardingDone: $onboardingDone, ')
          ..write('buddyName: $buddyName, ')
          ..write('bestStreak: $bestStreak, ')
          ..write('packCost: $packCost, ')
          ..write('cigsPerPack: $cigsPerPack, ')
          ..write('isPlus: $isPlus, ')
          ..write('equippedCosmeticId: $equippedCosmeticId, ')
          ..write('remindersEnabled: $remindersEnabled, ')
          ..write('reminderHour: $reminderHour')
          ..write(')'))
        .toString();
  }
}

class $ChallengeRowsTable extends ChallengeRows
    with TableInfo<$ChallengeRowsTable, ChallengeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChallengeRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _catalogIdMeta = const VerificationMeta(
    'catalogId',
  );
  @override
  late final GeneratedColumn<String> catalogId = GeneratedColumn<String>(
    'catalog_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _daysCompletedMeta = const VerificationMeta(
    'daysCompleted',
  );
  @override
  late final GeneratedColumn<int> daysCompleted = GeneratedColumn<int>(
    'days_completed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    catalogId,
    status,
    startedAt,
    daysCompleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'challenge_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChallengeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('catalog_id')) {
      context.handle(
        _catalogIdMeta,
        catalogId.isAcceptableOrUnknown(data['catalog_id']!, _catalogIdMeta),
      );
    } else if (isInserting) {
      context.missing(_catalogIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('days_completed')) {
      context.handle(
        _daysCompletedMeta,
        daysCompleted.isAcceptableOrUnknown(
          data['days_completed']!,
          _daysCompletedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {catalogId};
  @override
  ChallengeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChallengeRow(
      catalogId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      ),
      daysCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}days_completed'],
      )!,
    );
  }

  @override
  $ChallengeRowsTable createAlias(String alias) {
    return $ChallengeRowsTable(attachedDatabase, alias);
  }
}

class ChallengeRow extends DataClass implements Insertable<ChallengeRow> {
  final String catalogId;
  final String status;
  final DateTime? startedAt;
  final int daysCompleted;
  const ChallengeRow({
    required this.catalogId,
    required this.status,
    this.startedAt,
    required this.daysCompleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['catalog_id'] = Variable<String>(catalogId);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    map['days_completed'] = Variable<int>(daysCompleted);
    return map;
  }

  ChallengeRowsCompanion toCompanion(bool nullToAbsent) {
    return ChallengeRowsCompanion(
      catalogId: Value(catalogId),
      status: Value(status),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      daysCompleted: Value(daysCompleted),
    );
  }

  factory ChallengeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChallengeRow(
      catalogId: serializer.fromJson<String>(json['catalogId']),
      status: serializer.fromJson<String>(json['status']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      daysCompleted: serializer.fromJson<int>(json['daysCompleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'catalogId': serializer.toJson<String>(catalogId),
      'status': serializer.toJson<String>(status),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'daysCompleted': serializer.toJson<int>(daysCompleted),
    };
  }

  ChallengeRow copyWith({
    String? catalogId,
    String? status,
    Value<DateTime?> startedAt = const Value.absent(),
    int? daysCompleted,
  }) => ChallengeRow(
    catalogId: catalogId ?? this.catalogId,
    status: status ?? this.status,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
    daysCompleted: daysCompleted ?? this.daysCompleted,
  );
  ChallengeRow copyWithCompanion(ChallengeRowsCompanion data) {
    return ChallengeRow(
      catalogId: data.catalogId.present ? data.catalogId.value : this.catalogId,
      status: data.status.present ? data.status.value : this.status,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      daysCompleted: data.daysCompleted.present
          ? data.daysCompleted.value
          : this.daysCompleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChallengeRow(')
          ..write('catalogId: $catalogId, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('daysCompleted: $daysCompleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(catalogId, status, startedAt, daysCompleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChallengeRow &&
          other.catalogId == this.catalogId &&
          other.status == this.status &&
          other.startedAt == this.startedAt &&
          other.daysCompleted == this.daysCompleted);
}

class ChallengeRowsCompanion extends UpdateCompanion<ChallengeRow> {
  final Value<String> catalogId;
  final Value<String> status;
  final Value<DateTime?> startedAt;
  final Value<int> daysCompleted;
  final Value<int> rowid;
  const ChallengeRowsCompanion({
    this.catalogId = const Value.absent(),
    this.status = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.daysCompleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChallengeRowsCompanion.insert({
    required String catalogId,
    required String status,
    this.startedAt = const Value.absent(),
    this.daysCompleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : catalogId = Value(catalogId),
       status = Value(status);
  static Insertable<ChallengeRow> custom({
    Expression<String>? catalogId,
    Expression<String>? status,
    Expression<DateTime>? startedAt,
    Expression<int>? daysCompleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (catalogId != null) 'catalog_id': catalogId,
      if (status != null) 'status': status,
      if (startedAt != null) 'started_at': startedAt,
      if (daysCompleted != null) 'days_completed': daysCompleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChallengeRowsCompanion copyWith({
    Value<String>? catalogId,
    Value<String>? status,
    Value<DateTime?>? startedAt,
    Value<int>? daysCompleted,
    Value<int>? rowid,
  }) {
    return ChallengeRowsCompanion(
      catalogId: catalogId ?? this.catalogId,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      daysCompleted: daysCompleted ?? this.daysCompleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (catalogId.present) {
      map['catalog_id'] = Variable<String>(catalogId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (daysCompleted.present) {
      map['days_completed'] = Variable<int>(daysCompleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChallengeRowsCompanion(')
          ..write('catalogId: $catalogId, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('daysCompleted: $daysCompleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RewardRowsTable extends RewardRows
    with TableInfo<$RewardRowsTable, RewardRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RewardRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unlockedAtMeta = const VerificationMeta(
    'unlockedAt',
  );
  @override
  late final GeneratedColumn<DateTime> unlockedAt = GeneratedColumn<DateTime>(
    'unlocked_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, unlockedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reward_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<RewardRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
        _unlockedAtMeta,
        unlockedAt.isAcceptableOrUnknown(data['unlocked_at']!, _unlockedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_unlockedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RewardRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RewardRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      unlockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}unlocked_at'],
      )!,
    );
  }

  @override
  $RewardRowsTable createAlias(String alias) {
    return $RewardRowsTable(attachedDatabase, alias);
  }
}

class RewardRow extends DataClass implements Insertable<RewardRow> {
  final String id;
  final DateTime unlockedAt;
  const RewardRow({required this.id, required this.unlockedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['unlocked_at'] = Variable<DateTime>(unlockedAt);
    return map;
  }

  RewardRowsCompanion toCompanion(bool nullToAbsent) {
    return RewardRowsCompanion(id: Value(id), unlockedAt: Value(unlockedAt));
  }

  factory RewardRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RewardRow(
      id: serializer.fromJson<String>(json['id']),
      unlockedAt: serializer.fromJson<DateTime>(json['unlockedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'unlockedAt': serializer.toJson<DateTime>(unlockedAt),
    };
  }

  RewardRow copyWith({String? id, DateTime? unlockedAt}) =>
      RewardRow(id: id ?? this.id, unlockedAt: unlockedAt ?? this.unlockedAt);
  RewardRow copyWithCompanion(RewardRowsCompanion data) {
    return RewardRow(
      id: data.id.present ? data.id.value : this.id,
      unlockedAt: data.unlockedAt.present
          ? data.unlockedAt.value
          : this.unlockedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RewardRow(')
          ..write('id: $id, ')
          ..write('unlockedAt: $unlockedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, unlockedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RewardRow &&
          other.id == this.id &&
          other.unlockedAt == this.unlockedAt);
}

class RewardRowsCompanion extends UpdateCompanion<RewardRow> {
  final Value<String> id;
  final Value<DateTime> unlockedAt;
  final Value<int> rowid;
  const RewardRowsCompanion({
    this.id = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RewardRowsCompanion.insert({
    required String id,
    required DateTime unlockedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       unlockedAt = Value(unlockedAt);
  static Insertable<RewardRow> custom({
    Expression<String>? id,
    Expression<DateTime>? unlockedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RewardRowsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? unlockedAt,
    Value<int>? rowid,
  }) {
    return RewardRowsCompanion(
      id: id ?? this.id,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RewardRowsCompanion(')
          ..write('id: $id, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SmokeEventsTable smokeEvents = $SmokeEventsTable(this);
  late final $DailyBudgetsTable dailyBudgets = $DailyBudgetsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $ChallengeRowsTable challengeRows = $ChallengeRowsTable(this);
  late final $RewardRowsTable rewardRows = $RewardRowsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    smokeEvents,
    dailyBudgets,
    settings,
    challengeRows,
    rewardRows,
  ];
}

typedef $$SmokeEventsTableCreateCompanionBuilder =
    SmokeEventsCompanion Function({Value<int> id, required DateTime timestamp});
typedef $$SmokeEventsTableUpdateCompanionBuilder =
    SmokeEventsCompanion Function({Value<int> id, Value<DateTime> timestamp});

class $$SmokeEventsTableFilterComposer
    extends Composer<_$AppDatabase, $SmokeEventsTable> {
  $$SmokeEventsTableFilterComposer({
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

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SmokeEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $SmokeEventsTable> {
  $$SmokeEventsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SmokeEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SmokeEventsTable> {
  $$SmokeEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);
}

class $$SmokeEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SmokeEventsTable,
          SmokeEvent,
          $$SmokeEventsTableFilterComposer,
          $$SmokeEventsTableOrderingComposer,
          $$SmokeEventsTableAnnotationComposer,
          $$SmokeEventsTableCreateCompanionBuilder,
          $$SmokeEventsTableUpdateCompanionBuilder,
          (
            SmokeEvent,
            BaseReferences<_$AppDatabase, $SmokeEventsTable, SmokeEvent>,
          ),
          SmokeEvent,
          PrefetchHooks Function()
        > {
  $$SmokeEventsTableTableManager(_$AppDatabase db, $SmokeEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SmokeEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SmokeEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SmokeEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
              }) => SmokeEventsCompanion(id: id, timestamp: timestamp),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime timestamp,
              }) => SmokeEventsCompanion.insert(id: id, timestamp: timestamp),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SmokeEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SmokeEventsTable,
      SmokeEvent,
      $$SmokeEventsTableFilterComposer,
      $$SmokeEventsTableOrderingComposer,
      $$SmokeEventsTableAnnotationComposer,
      $$SmokeEventsTableCreateCompanionBuilder,
      $$SmokeEventsTableUpdateCompanionBuilder,
      (
        SmokeEvent,
        BaseReferences<_$AppDatabase, $SmokeEventsTable, SmokeEvent>,
      ),
      SmokeEvent,
      PrefetchHooks Function()
    >;
typedef $$DailyBudgetsTableCreateCompanionBuilder =
    DailyBudgetsCompanion Function({
      required String date,
      required int limit,
      Value<int> rowid,
    });
typedef $$DailyBudgetsTableUpdateCompanionBuilder =
    DailyBudgetsCompanion Function({
      Value<String> date,
      Value<int> limit,
      Value<int> rowid,
    });

class $$DailyBudgetsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyBudgetsTable> {
  $$DailyBudgetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get limit => $composableBuilder(
    column: $table.limit,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyBudgetsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyBudgetsTable> {
  $$DailyBudgetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get limit => $composableBuilder(
    column: $table.limit,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyBudgetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyBudgetsTable> {
  $$DailyBudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get limit =>
      $composableBuilder(column: $table.limit, builder: (column) => column);
}

class $$DailyBudgetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyBudgetsTable,
          DailyBudget,
          $$DailyBudgetsTableFilterComposer,
          $$DailyBudgetsTableOrderingComposer,
          $$DailyBudgetsTableAnnotationComposer,
          $$DailyBudgetsTableCreateCompanionBuilder,
          $$DailyBudgetsTableUpdateCompanionBuilder,
          (
            DailyBudget,
            BaseReferences<_$AppDatabase, $DailyBudgetsTable, DailyBudget>,
          ),
          DailyBudget,
          PrefetchHooks Function()
        > {
  $$DailyBudgetsTableTableManager(_$AppDatabase db, $DailyBudgetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyBudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyBudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyBudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> date = const Value.absent(),
                Value<int> limit = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  DailyBudgetsCompanion(date: date, limit: limit, rowid: rowid),
          createCompanionCallback:
              ({
                required String date,
                required int limit,
                Value<int> rowid = const Value.absent(),
              }) => DailyBudgetsCompanion.insert(
                date: date,
                limit: limit,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyBudgetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyBudgetsTable,
      DailyBudget,
      $$DailyBudgetsTableFilterComposer,
      $$DailyBudgetsTableOrderingComposer,
      $$DailyBudgetsTableAnnotationComposer,
      $$DailyBudgetsTableCreateCompanionBuilder,
      $$DailyBudgetsTableUpdateCompanionBuilder,
      (
        DailyBudget,
        BaseReferences<_$AppDatabase, $DailyBudgetsTable, DailyBudget>,
      ),
      DailyBudget,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      Value<int> id,
      required int usualBaseline,
      required int defaultBudget,
      Value<bool> onboardingDone,
      Value<String> buddyName,
      Value<int> bestStreak,
      Value<double> packCost,
      Value<int> cigsPerPack,
      Value<bool> isPlus,
      Value<String> equippedCosmeticId,
      Value<bool> remindersEnabled,
      Value<int> reminderHour,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<int> id,
      Value<int> usualBaseline,
      Value<int> defaultBudget,
      Value<bool> onboardingDone,
      Value<String> buddyName,
      Value<int> bestStreak,
      Value<double> packCost,
      Value<int> cigsPerPack,
      Value<bool> isPlus,
      Value<String> equippedCosmeticId,
      Value<bool> remindersEnabled,
      Value<int> reminderHour,
    });

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
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

  ColumnFilters<int> get usualBaseline => $composableBuilder(
    column: $table.usualBaseline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultBudget => $composableBuilder(
    column: $table.defaultBudget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get onboardingDone => $composableBuilder(
    column: $table.onboardingDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get buddyName => $composableBuilder(
    column: $table.buddyName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bestStreak => $composableBuilder(
    column: $table.bestStreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get packCost => $composableBuilder(
    column: $table.packCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cigsPerPack => $composableBuilder(
    column: $table.cigsPerPack,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPlus => $composableBuilder(
    column: $table.isPlus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equippedCosmeticId => $composableBuilder(
    column: $table.equippedCosmeticId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get remindersEnabled => $composableBuilder(
    column: $table.remindersEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderHour => $composableBuilder(
    column: $table.reminderHour,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
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

  ColumnOrderings<int> get usualBaseline => $composableBuilder(
    column: $table.usualBaseline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultBudget => $composableBuilder(
    column: $table.defaultBudget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get onboardingDone => $composableBuilder(
    column: $table.onboardingDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get buddyName => $composableBuilder(
    column: $table.buddyName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bestStreak => $composableBuilder(
    column: $table.bestStreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get packCost => $composableBuilder(
    column: $table.packCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cigsPerPack => $composableBuilder(
    column: $table.cigsPerPack,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPlus => $composableBuilder(
    column: $table.isPlus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equippedCosmeticId => $composableBuilder(
    column: $table.equippedCosmeticId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get remindersEnabled => $composableBuilder(
    column: $table.remindersEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderHour => $composableBuilder(
    column: $table.reminderHour,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get usualBaseline => $composableBuilder(
    column: $table.usualBaseline,
    builder: (column) => column,
  );

  GeneratedColumn<int> get defaultBudget => $composableBuilder(
    column: $table.defaultBudget,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get onboardingDone => $composableBuilder(
    column: $table.onboardingDone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get buddyName =>
      $composableBuilder(column: $table.buddyName, builder: (column) => column);

  GeneratedColumn<int> get bestStreak => $composableBuilder(
    column: $table.bestStreak,
    builder: (column) => column,
  );

  GeneratedColumn<double> get packCost =>
      $composableBuilder(column: $table.packCost, builder: (column) => column);

  GeneratedColumn<int> get cigsPerPack => $composableBuilder(
    column: $table.cigsPerPack,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPlus =>
      $composableBuilder(column: $table.isPlus, builder: (column) => column);

  GeneratedColumn<String> get equippedCosmeticId => $composableBuilder(
    column: $table.equippedCosmeticId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get remindersEnabled => $composableBuilder(
    column: $table.remindersEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderHour => $composableBuilder(
    column: $table.reminderHour,
    builder: (column) => column,
  );
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> usualBaseline = const Value.absent(),
                Value<int> defaultBudget = const Value.absent(),
                Value<bool> onboardingDone = const Value.absent(),
                Value<String> buddyName = const Value.absent(),
                Value<int> bestStreak = const Value.absent(),
                Value<double> packCost = const Value.absent(),
                Value<int> cigsPerPack = const Value.absent(),
                Value<bool> isPlus = const Value.absent(),
                Value<String> equippedCosmeticId = const Value.absent(),
                Value<bool> remindersEnabled = const Value.absent(),
                Value<int> reminderHour = const Value.absent(),
              }) => SettingsCompanion(
                id: id,
                usualBaseline: usualBaseline,
                defaultBudget: defaultBudget,
                onboardingDone: onboardingDone,
                buddyName: buddyName,
                bestStreak: bestStreak,
                packCost: packCost,
                cigsPerPack: cigsPerPack,
                isPlus: isPlus,
                equippedCosmeticId: equippedCosmeticId,
                remindersEnabled: remindersEnabled,
                reminderHour: reminderHour,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int usualBaseline,
                required int defaultBudget,
                Value<bool> onboardingDone = const Value.absent(),
                Value<String> buddyName = const Value.absent(),
                Value<int> bestStreak = const Value.absent(),
                Value<double> packCost = const Value.absent(),
                Value<int> cigsPerPack = const Value.absent(),
                Value<bool> isPlus = const Value.absent(),
                Value<String> equippedCosmeticId = const Value.absent(),
                Value<bool> remindersEnabled = const Value.absent(),
                Value<int> reminderHour = const Value.absent(),
              }) => SettingsCompanion.insert(
                id: id,
                usualBaseline: usualBaseline,
                defaultBudget: defaultBudget,
                onboardingDone: onboardingDone,
                buddyName: buddyName,
                bestStreak: bestStreak,
                packCost: packCost,
                cigsPerPack: cigsPerPack,
                isPlus: isPlus,
                equippedCosmeticId: equippedCosmeticId,
                remindersEnabled: remindersEnabled,
                reminderHour: reminderHour,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;
typedef $$ChallengeRowsTableCreateCompanionBuilder =
    ChallengeRowsCompanion Function({
      required String catalogId,
      required String status,
      Value<DateTime?> startedAt,
      Value<int> daysCompleted,
      Value<int> rowid,
    });
typedef $$ChallengeRowsTableUpdateCompanionBuilder =
    ChallengeRowsCompanion Function({
      Value<String> catalogId,
      Value<String> status,
      Value<DateTime?> startedAt,
      Value<int> daysCompleted,
      Value<int> rowid,
    });

class $$ChallengeRowsTableFilterComposer
    extends Composer<_$AppDatabase, $ChallengeRowsTable> {
  $$ChallengeRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get catalogId => $composableBuilder(
    column: $table.catalogId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get daysCompleted => $composableBuilder(
    column: $table.daysCompleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChallengeRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChallengeRowsTable> {
  $$ChallengeRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get catalogId => $composableBuilder(
    column: $table.catalogId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get daysCompleted => $composableBuilder(
    column: $table.daysCompleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChallengeRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChallengeRowsTable> {
  $$ChallengeRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get catalogId =>
      $composableBuilder(column: $table.catalogId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get daysCompleted => $composableBuilder(
    column: $table.daysCompleted,
    builder: (column) => column,
  );
}

class $$ChallengeRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChallengeRowsTable,
          ChallengeRow,
          $$ChallengeRowsTableFilterComposer,
          $$ChallengeRowsTableOrderingComposer,
          $$ChallengeRowsTableAnnotationComposer,
          $$ChallengeRowsTableCreateCompanionBuilder,
          $$ChallengeRowsTableUpdateCompanionBuilder,
          (
            ChallengeRow,
            BaseReferences<_$AppDatabase, $ChallengeRowsTable, ChallengeRow>,
          ),
          ChallengeRow,
          PrefetchHooks Function()
        > {
  $$ChallengeRowsTableTableManager(_$AppDatabase db, $ChallengeRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChallengeRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChallengeRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChallengeRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> catalogId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<int> daysCompleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChallengeRowsCompanion(
                catalogId: catalogId,
                status: status,
                startedAt: startedAt,
                daysCompleted: daysCompleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String catalogId,
                required String status,
                Value<DateTime?> startedAt = const Value.absent(),
                Value<int> daysCompleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChallengeRowsCompanion.insert(
                catalogId: catalogId,
                status: status,
                startedAt: startedAt,
                daysCompleted: daysCompleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChallengeRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChallengeRowsTable,
      ChallengeRow,
      $$ChallengeRowsTableFilterComposer,
      $$ChallengeRowsTableOrderingComposer,
      $$ChallengeRowsTableAnnotationComposer,
      $$ChallengeRowsTableCreateCompanionBuilder,
      $$ChallengeRowsTableUpdateCompanionBuilder,
      (
        ChallengeRow,
        BaseReferences<_$AppDatabase, $ChallengeRowsTable, ChallengeRow>,
      ),
      ChallengeRow,
      PrefetchHooks Function()
    >;
typedef $$RewardRowsTableCreateCompanionBuilder =
    RewardRowsCompanion Function({
      required String id,
      required DateTime unlockedAt,
      Value<int> rowid,
    });
typedef $$RewardRowsTableUpdateCompanionBuilder =
    RewardRowsCompanion Function({
      Value<String> id,
      Value<DateTime> unlockedAt,
      Value<int> rowid,
    });

class $$RewardRowsTableFilterComposer
    extends Composer<_$AppDatabase, $RewardRowsTable> {
  $$RewardRowsTableFilterComposer({
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

  ColumnFilters<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RewardRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $RewardRowsTable> {
  $$RewardRowsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RewardRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RewardRowsTable> {
  $$RewardRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => column,
  );
}

class $$RewardRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RewardRowsTable,
          RewardRow,
          $$RewardRowsTableFilterComposer,
          $$RewardRowsTableOrderingComposer,
          $$RewardRowsTableAnnotationComposer,
          $$RewardRowsTableCreateCompanionBuilder,
          $$RewardRowsTableUpdateCompanionBuilder,
          (
            RewardRow,
            BaseReferences<_$AppDatabase, $RewardRowsTable, RewardRow>,
          ),
          RewardRow,
          PrefetchHooks Function()
        > {
  $$RewardRowsTableTableManager(_$AppDatabase db, $RewardRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RewardRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RewardRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RewardRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> unlockedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RewardRowsCompanion(
                id: id,
                unlockedAt: unlockedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime unlockedAt,
                Value<int> rowid = const Value.absent(),
              }) => RewardRowsCompanion.insert(
                id: id,
                unlockedAt: unlockedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RewardRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RewardRowsTable,
      RewardRow,
      $$RewardRowsTableFilterComposer,
      $$RewardRowsTableOrderingComposer,
      $$RewardRowsTableAnnotationComposer,
      $$RewardRowsTableCreateCompanionBuilder,
      $$RewardRowsTableUpdateCompanionBuilder,
      (RewardRow, BaseReferences<_$AppDatabase, $RewardRowsTable, RewardRow>),
      RewardRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SmokeEventsTableTableManager get smokeEvents =>
      $$SmokeEventsTableTableManager(_db, _db.smokeEvents);
  $$DailyBudgetsTableTableManager get dailyBudgets =>
      $$DailyBudgetsTableTableManager(_db, _db.dailyBudgets);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$ChallengeRowsTableTableManager get challengeRows =>
      $$ChallengeRowsTableTableManager(_db, _db.challengeRows);
  $$RewardRowsTableTableManager get rewardRows =>
      $$RewardRowsTableTableManager(_db, _db.rewardRows);
}
