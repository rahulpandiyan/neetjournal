// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SubjectsTable extends Subjects with TableInfo<$SubjectsTable, Subject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubjectsTable(this.attachedDatabase, [this._alias]);
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
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorValueMeta = const VerificationMeta(
    'colorValue',
  );
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
    'color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, colorValue, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subjects';
  @override
  VerificationContext validateIntegrity(
    Insertable<Subject> instance, {
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
    if (data.containsKey('color_value')) {
      context.handle(
        _colorValueMeta,
        colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta),
      );
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Subject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Subject(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      colorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_value'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $SubjectsTable createAlias(String alias) {
    return $SubjectsTable(attachedDatabase, alias);
  }
}

class Subject extends DataClass implements Insertable<Subject> {
  final int id;
  final String name;
  final int colorValue;
  final int sortOrder;
  const Subject({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['color_value'] = Variable<int>(colorValue);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  SubjectsCompanion toCompanion(bool nullToAbsent) {
    return SubjectsCompanion(
      id: Value(id),
      name: Value(name),
      colorValue: Value(colorValue),
      sortOrder: Value(sortOrder),
    );
  }

  factory Subject.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Subject(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'colorValue': serializer.toJson<int>(colorValue),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Subject copyWith({int? id, String? name, int? colorValue, int? sortOrder}) =>
      Subject(
        id: id ?? this.id,
        name: name ?? this.name,
        colorValue: colorValue ?? this.colorValue,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  Subject copyWithCompanion(SubjectsCompanion data) {
    return Subject(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      colorValue: data.colorValue.present
          ? data.colorValue.value
          : this.colorValue,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Subject(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorValue: $colorValue, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, colorValue, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Subject &&
          other.id == this.id &&
          other.name == this.name &&
          other.colorValue == this.colorValue &&
          other.sortOrder == this.sortOrder);
}

class SubjectsCompanion extends UpdateCompanion<Subject> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> colorValue;
  final Value<int> sortOrder;
  const SubjectsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  SubjectsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int colorValue,
    this.sortOrder = const Value.absent(),
  }) : name = Value(name),
       colorValue = Value(colorValue);
  static Insertable<Subject> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? colorValue,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (colorValue != null) 'color_value': colorValue,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  SubjectsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? colorValue,
    Value<int>? sortOrder,
  }) {
    return SubjectsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      sortOrder: sortOrder ?? this.sortOrder,
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
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubjectsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorValue: $colorValue, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $ChaptersTable extends Chapters with TableInfo<$ChaptersTable, Chapter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChaptersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<int> subjectId = GeneratedColumn<int>(
    'subject_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ChapterStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ChapterStatus>($ChaptersTable.$converterstatus);
  @override
  List<GeneratedColumn> get $columns => [id, subjectId, name, status];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chapters';
  @override
  VerificationContext validateIntegrity(
    Insertable<Chapter> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Chapter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Chapter(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}subject_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      status: $ChaptersTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
    );
  }

  @override
  $ChaptersTable createAlias(String alias) {
    return $ChaptersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ChapterStatus, String, String> $converterstatus =
      const EnumNameConverter<ChapterStatus>(ChapterStatus.values);
}

class Chapter extends DataClass implements Insertable<Chapter> {
  final int id;
  final int subjectId;
  final String name;
  final ChapterStatus status;
  const Chapter({
    required this.id,
    required this.subjectId,
    required this.name,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['subject_id'] = Variable<int>(subjectId);
    map['name'] = Variable<String>(name);
    {
      map['status'] = Variable<String>(
        $ChaptersTable.$converterstatus.toSql(status),
      );
    }
    return map;
  }

  ChaptersCompanion toCompanion(bool nullToAbsent) {
    return ChaptersCompanion(
      id: Value(id),
      subjectId: Value(subjectId),
      name: Value(name),
      status: Value(status),
    );
  }

  factory Chapter.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Chapter(
      id: serializer.fromJson<int>(json['id']),
      subjectId: serializer.fromJson<int>(json['subjectId']),
      name: serializer.fromJson<String>(json['name']),
      status: $ChaptersTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'subjectId': serializer.toJson<int>(subjectId),
      'name': serializer.toJson<String>(name),
      'status': serializer.toJson<String>(
        $ChaptersTable.$converterstatus.toJson(status),
      ),
    };
  }

  Chapter copyWith({
    int? id,
    int? subjectId,
    String? name,
    ChapterStatus? status,
  }) => Chapter(
    id: id ?? this.id,
    subjectId: subjectId ?? this.subjectId,
    name: name ?? this.name,
    status: status ?? this.status,
  );
  Chapter copyWithCompanion(ChaptersCompanion data) {
    return Chapter(
      id: data.id.present ? data.id.value : this.id,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      name: data.name.present ? data.name.value : this.name,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Chapter(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('name: $name, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, subjectId, name, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Chapter &&
          other.id == this.id &&
          other.subjectId == this.subjectId &&
          other.name == this.name &&
          other.status == this.status);
}

class ChaptersCompanion extends UpdateCompanion<Chapter> {
  final Value<int> id;
  final Value<int> subjectId;
  final Value<String> name;
  final Value<ChapterStatus> status;
  const ChaptersCompanion({
    this.id = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.name = const Value.absent(),
    this.status = const Value.absent(),
  });
  ChaptersCompanion.insert({
    this.id = const Value.absent(),
    required int subjectId,
    required String name,
    required ChapterStatus status,
  }) : subjectId = Value(subjectId),
       name = Value(name),
       status = Value(status);
  static Insertable<Chapter> custom({
    Expression<int>? id,
    Expression<int>? subjectId,
    Expression<String>? name,
    Expression<String>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subjectId != null) 'subject_id': subjectId,
      if (name != null) 'name': name,
      if (status != null) 'status': status,
    });
  }

  ChaptersCompanion copyWith({
    Value<int>? id,
    Value<int>? subjectId,
    Value<String>? name,
    Value<ChapterStatus>? status,
  }) {
    return ChaptersCompanion(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      name: name ?? this.name,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<int>(subjectId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $ChaptersTable.$converterstatus.toSql(status.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChaptersCompanion(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('name: $name, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $TimetableSlotsTable extends TimetableSlots
    with TableInfo<$TimetableSlotsTable, TimetableSlot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimetableSlotsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dayOfWeekMeta = const VerificationMeta(
    'dayOfWeek',
  );
  @override
  late final GeneratedColumn<int> dayOfWeek = GeneratedColumn<int>(
    'day_of_week',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _templateSlotIdMeta = const VerificationMeta(
    'templateSlotId',
  );
  @override
  late final GeneratedColumn<int> templateSlotId = GeneratedColumn<int>(
    'template_slot_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startMinMeta = const VerificationMeta(
    'startMin',
  );
  @override
  late final GeneratedColumn<int> startMin = GeneratedColumn<int>(
    'start_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endMinMeta = const VerificationMeta('endMin');
  @override
  late final GeneratedColumn<int> endMin = GeneratedColumn<int>(
    'end_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<int> subjectId = GeneratedColumn<int>(
    'subject_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ActivityType, String>
  activityType = GeneratedColumn<String>(
    'activity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<ActivityType>($TimetableSlotsTable.$converteractivityType);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetMeta = const VerificationMeta('target');
  @override
  late final GeneratedColumn<String> target = GeneratedColumn<String>(
    'target',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isRecurringMeta = const VerificationMeta(
    'isRecurring',
  );
  @override
  late final GeneratedColumn<bool> isRecurring = GeneratedColumn<bool>(
    'is_recurring',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_recurring" IN (0, 1))',
    ),
  );
  static const VerificationMeta _isOptionalMeta = const VerificationMeta(
    'isOptional',
  );
  @override
  late final GeneratedColumn<bool> isOptional = GeneratedColumn<bool>(
    'is_optional',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_optional" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dayOfWeek,
    date,
    templateSlotId,
    startMin,
    endMin,
    subjectId,
    activityType,
    title,
    target,
    isRecurring,
    isOptional,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timetable_slots';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimetableSlot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('day_of_week')) {
      context.handle(
        _dayOfWeekMeta,
        dayOfWeek.isAcceptableOrUnknown(data['day_of_week']!, _dayOfWeekMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    if (data.containsKey('template_slot_id')) {
      context.handle(
        _templateSlotIdMeta,
        templateSlotId.isAcceptableOrUnknown(
          data['template_slot_id']!,
          _templateSlotIdMeta,
        ),
      );
    }
    if (data.containsKey('start_min')) {
      context.handle(
        _startMinMeta,
        startMin.isAcceptableOrUnknown(data['start_min']!, _startMinMeta),
      );
    } else if (isInserting) {
      context.missing(_startMinMeta);
    }
    if (data.containsKey('end_min')) {
      context.handle(
        _endMinMeta,
        endMin.isAcceptableOrUnknown(data['end_min']!, _endMinMeta),
      );
    } else if (isInserting) {
      context.missing(_endMinMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('target')) {
      context.handle(
        _targetMeta,
        target.isAcceptableOrUnknown(data['target']!, _targetMeta),
      );
    }
    if (data.containsKey('is_recurring')) {
      context.handle(
        _isRecurringMeta,
        isRecurring.isAcceptableOrUnknown(
          data['is_recurring']!,
          _isRecurringMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_isRecurringMeta);
    }
    if (data.containsKey('is_optional')) {
      context.handle(
        _isOptionalMeta,
        isOptional.isAcceptableOrUnknown(data['is_optional']!, _isOptionalMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimetableSlot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimetableSlot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      dayOfWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_of_week'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      ),
      templateSlotId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}template_slot_id'],
      ),
      startMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_min'],
      )!,
      endMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_min'],
      )!,
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}subject_id'],
      ),
      activityType: $TimetableSlotsTable.$converteractivityType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}activity_type'],
        )!,
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      target: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target'],
      ),
      isRecurring: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_recurring'],
      )!,
      isOptional: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_optional'],
      )!,
    );
  }

  @override
  $TimetableSlotsTable createAlias(String alias) {
    return $TimetableSlotsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ActivityType, String, String>
  $converteractivityType = const EnumNameConverter<ActivityType>(
    ActivityType.values,
  );
}

class TimetableSlot extends DataClass implements Insertable<TimetableSlot> {
  final int id;

  /// Weekly template: day of week (1=Mon..7=Sun). Null for pure one-off slots.
  final int? dayOfWeek;

  /// One-off (Edit Today / moved) slots have a concrete date. Null for template.
  final String? date;

  /// For one-off slots that replace a template slot: links to the template slot id.
  final int? templateSlotId;
  final int startMin;
  final int endMin;
  final int? subjectId;
  final ActivityType activityType;
  final String title;
  final String? target;

  /// Whether this row is part of the weekly template (recurring every week).
  final bool isRecurring;

  /// Sunday recovery items are optional.
  final bool isOptional;
  const TimetableSlot({
    required this.id,
    this.dayOfWeek,
    this.date,
    this.templateSlotId,
    required this.startMin,
    required this.endMin,
    this.subjectId,
    required this.activityType,
    required this.title,
    this.target,
    required this.isRecurring,
    required this.isOptional,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || dayOfWeek != null) {
      map['day_of_week'] = Variable<int>(dayOfWeek);
    }
    if (!nullToAbsent || date != null) {
      map['date'] = Variable<String>(date);
    }
    if (!nullToAbsent || templateSlotId != null) {
      map['template_slot_id'] = Variable<int>(templateSlotId);
    }
    map['start_min'] = Variable<int>(startMin);
    map['end_min'] = Variable<int>(endMin);
    if (!nullToAbsent || subjectId != null) {
      map['subject_id'] = Variable<int>(subjectId);
    }
    {
      map['activity_type'] = Variable<String>(
        $TimetableSlotsTable.$converteractivityType.toSql(activityType),
      );
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || target != null) {
      map['target'] = Variable<String>(target);
    }
    map['is_recurring'] = Variable<bool>(isRecurring);
    map['is_optional'] = Variable<bool>(isOptional);
    return map;
  }

  TimetableSlotsCompanion toCompanion(bool nullToAbsent) {
    return TimetableSlotsCompanion(
      id: Value(id),
      dayOfWeek: dayOfWeek == null && nullToAbsent
          ? const Value.absent()
          : Value(dayOfWeek),
      date: date == null && nullToAbsent ? const Value.absent() : Value(date),
      templateSlotId: templateSlotId == null && nullToAbsent
          ? const Value.absent()
          : Value(templateSlotId),
      startMin: Value(startMin),
      endMin: Value(endMin),
      subjectId: subjectId == null && nullToAbsent
          ? const Value.absent()
          : Value(subjectId),
      activityType: Value(activityType),
      title: Value(title),
      target: target == null && nullToAbsent
          ? const Value.absent()
          : Value(target),
      isRecurring: Value(isRecurring),
      isOptional: Value(isOptional),
    );
  }

  factory TimetableSlot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimetableSlot(
      id: serializer.fromJson<int>(json['id']),
      dayOfWeek: serializer.fromJson<int?>(json['dayOfWeek']),
      date: serializer.fromJson<String?>(json['date']),
      templateSlotId: serializer.fromJson<int?>(json['templateSlotId']),
      startMin: serializer.fromJson<int>(json['startMin']),
      endMin: serializer.fromJson<int>(json['endMin']),
      subjectId: serializer.fromJson<int?>(json['subjectId']),
      activityType: $TimetableSlotsTable.$converteractivityType.fromJson(
        serializer.fromJson<String>(json['activityType']),
      ),
      title: serializer.fromJson<String>(json['title']),
      target: serializer.fromJson<String?>(json['target']),
      isRecurring: serializer.fromJson<bool>(json['isRecurring']),
      isOptional: serializer.fromJson<bool>(json['isOptional']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dayOfWeek': serializer.toJson<int?>(dayOfWeek),
      'date': serializer.toJson<String?>(date),
      'templateSlotId': serializer.toJson<int?>(templateSlotId),
      'startMin': serializer.toJson<int>(startMin),
      'endMin': serializer.toJson<int>(endMin),
      'subjectId': serializer.toJson<int?>(subjectId),
      'activityType': serializer.toJson<String>(
        $TimetableSlotsTable.$converteractivityType.toJson(activityType),
      ),
      'title': serializer.toJson<String>(title),
      'target': serializer.toJson<String?>(target),
      'isRecurring': serializer.toJson<bool>(isRecurring),
      'isOptional': serializer.toJson<bool>(isOptional),
    };
  }

  TimetableSlot copyWith({
    int? id,
    Value<int?> dayOfWeek = const Value.absent(),
    Value<String?> date = const Value.absent(),
    Value<int?> templateSlotId = const Value.absent(),
    int? startMin,
    int? endMin,
    Value<int?> subjectId = const Value.absent(),
    ActivityType? activityType,
    String? title,
    Value<String?> target = const Value.absent(),
    bool? isRecurring,
    bool? isOptional,
  }) => TimetableSlot(
    id: id ?? this.id,
    dayOfWeek: dayOfWeek.present ? dayOfWeek.value : this.dayOfWeek,
    date: date.present ? date.value : this.date,
    templateSlotId: templateSlotId.present
        ? templateSlotId.value
        : this.templateSlotId,
    startMin: startMin ?? this.startMin,
    endMin: endMin ?? this.endMin,
    subjectId: subjectId.present ? subjectId.value : this.subjectId,
    activityType: activityType ?? this.activityType,
    title: title ?? this.title,
    target: target.present ? target.value : this.target,
    isRecurring: isRecurring ?? this.isRecurring,
    isOptional: isOptional ?? this.isOptional,
  );
  TimetableSlot copyWithCompanion(TimetableSlotsCompanion data) {
    return TimetableSlot(
      id: data.id.present ? data.id.value : this.id,
      dayOfWeek: data.dayOfWeek.present ? data.dayOfWeek.value : this.dayOfWeek,
      date: data.date.present ? data.date.value : this.date,
      templateSlotId: data.templateSlotId.present
          ? data.templateSlotId.value
          : this.templateSlotId,
      startMin: data.startMin.present ? data.startMin.value : this.startMin,
      endMin: data.endMin.present ? data.endMin.value : this.endMin,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      activityType: data.activityType.present
          ? data.activityType.value
          : this.activityType,
      title: data.title.present ? data.title.value : this.title,
      target: data.target.present ? data.target.value : this.target,
      isRecurring: data.isRecurring.present
          ? data.isRecurring.value
          : this.isRecurring,
      isOptional: data.isOptional.present
          ? data.isOptional.value
          : this.isOptional,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimetableSlot(')
          ..write('id: $id, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('date: $date, ')
          ..write('templateSlotId: $templateSlotId, ')
          ..write('startMin: $startMin, ')
          ..write('endMin: $endMin, ')
          ..write('subjectId: $subjectId, ')
          ..write('activityType: $activityType, ')
          ..write('title: $title, ')
          ..write('target: $target, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('isOptional: $isOptional')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    dayOfWeek,
    date,
    templateSlotId,
    startMin,
    endMin,
    subjectId,
    activityType,
    title,
    target,
    isRecurring,
    isOptional,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimetableSlot &&
          other.id == this.id &&
          other.dayOfWeek == this.dayOfWeek &&
          other.date == this.date &&
          other.templateSlotId == this.templateSlotId &&
          other.startMin == this.startMin &&
          other.endMin == this.endMin &&
          other.subjectId == this.subjectId &&
          other.activityType == this.activityType &&
          other.title == this.title &&
          other.target == this.target &&
          other.isRecurring == this.isRecurring &&
          other.isOptional == this.isOptional);
}

class TimetableSlotsCompanion extends UpdateCompanion<TimetableSlot> {
  final Value<int> id;
  final Value<int?> dayOfWeek;
  final Value<String?> date;
  final Value<int?> templateSlotId;
  final Value<int> startMin;
  final Value<int> endMin;
  final Value<int?> subjectId;
  final Value<ActivityType> activityType;
  final Value<String> title;
  final Value<String?> target;
  final Value<bool> isRecurring;
  final Value<bool> isOptional;
  const TimetableSlotsCompanion({
    this.id = const Value.absent(),
    this.dayOfWeek = const Value.absent(),
    this.date = const Value.absent(),
    this.templateSlotId = const Value.absent(),
    this.startMin = const Value.absent(),
    this.endMin = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.activityType = const Value.absent(),
    this.title = const Value.absent(),
    this.target = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.isOptional = const Value.absent(),
  });
  TimetableSlotsCompanion.insert({
    this.id = const Value.absent(),
    this.dayOfWeek = const Value.absent(),
    this.date = const Value.absent(),
    this.templateSlotId = const Value.absent(),
    required int startMin,
    required int endMin,
    this.subjectId = const Value.absent(),
    required ActivityType activityType,
    required String title,
    this.target = const Value.absent(),
    required bool isRecurring,
    this.isOptional = const Value.absent(),
  }) : startMin = Value(startMin),
       endMin = Value(endMin),
       activityType = Value(activityType),
       title = Value(title),
       isRecurring = Value(isRecurring);
  static Insertable<TimetableSlot> custom({
    Expression<int>? id,
    Expression<int>? dayOfWeek,
    Expression<String>? date,
    Expression<int>? templateSlotId,
    Expression<int>? startMin,
    Expression<int>? endMin,
    Expression<int>? subjectId,
    Expression<String>? activityType,
    Expression<String>? title,
    Expression<String>? target,
    Expression<bool>? isRecurring,
    Expression<bool>? isOptional,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dayOfWeek != null) 'day_of_week': dayOfWeek,
      if (date != null) 'date': date,
      if (templateSlotId != null) 'template_slot_id': templateSlotId,
      if (startMin != null) 'start_min': startMin,
      if (endMin != null) 'end_min': endMin,
      if (subjectId != null) 'subject_id': subjectId,
      if (activityType != null) 'activity_type': activityType,
      if (title != null) 'title': title,
      if (target != null) 'target': target,
      if (isRecurring != null) 'is_recurring': isRecurring,
      if (isOptional != null) 'is_optional': isOptional,
    });
  }

  TimetableSlotsCompanion copyWith({
    Value<int>? id,
    Value<int?>? dayOfWeek,
    Value<String?>? date,
    Value<int?>? templateSlotId,
    Value<int>? startMin,
    Value<int>? endMin,
    Value<int?>? subjectId,
    Value<ActivityType>? activityType,
    Value<String>? title,
    Value<String?>? target,
    Value<bool>? isRecurring,
    Value<bool>? isOptional,
  }) {
    return TimetableSlotsCompanion(
      id: id ?? this.id,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      date: date ?? this.date,
      templateSlotId: templateSlotId ?? this.templateSlotId,
      startMin: startMin ?? this.startMin,
      endMin: endMin ?? this.endMin,
      subjectId: subjectId ?? this.subjectId,
      activityType: activityType ?? this.activityType,
      title: title ?? this.title,
      target: target ?? this.target,
      isRecurring: isRecurring ?? this.isRecurring,
      isOptional: isOptional ?? this.isOptional,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dayOfWeek.present) {
      map['day_of_week'] = Variable<int>(dayOfWeek.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (templateSlotId.present) {
      map['template_slot_id'] = Variable<int>(templateSlotId.value);
    }
    if (startMin.present) {
      map['start_min'] = Variable<int>(startMin.value);
    }
    if (endMin.present) {
      map['end_min'] = Variable<int>(endMin.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<int>(subjectId.value);
    }
    if (activityType.present) {
      map['activity_type'] = Variable<String>(
        $TimetableSlotsTable.$converteractivityType.toSql(activityType.value),
      );
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (target.present) {
      map['target'] = Variable<String>(target.value);
    }
    if (isRecurring.present) {
      map['is_recurring'] = Variable<bool>(isRecurring.value);
    }
    if (isOptional.present) {
      map['is_optional'] = Variable<bool>(isOptional.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimetableSlotsCompanion(')
          ..write('id: $id, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('date: $date, ')
          ..write('templateSlotId: $templateSlotId, ')
          ..write('startMin: $startMin, ')
          ..write('endMin: $endMin, ')
          ..write('subjectId: $subjectId, ')
          ..write('activityType: $activityType, ')
          ..write('title: $title, ')
          ..write('target: $target, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('isOptional: $isOptional')
          ..write(')'))
        .toString();
  }
}

class $StudySessionsTable extends StudySessions
    with TableInfo<$StudySessionsTable, StudySession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudySessionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _slotIdMeta = const VerificationMeta('slotId');
  @override
  late final GeneratedColumn<int> slotId = GeneratedColumn<int>(
    'slot_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<int> subjectId = GeneratedColumn<int>(
    'subject_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ActivityType, String>
  activityType = GeneratedColumn<String>(
    'activity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<ActivityType>($StudySessionsTable.$converteractivityType);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
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
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SessionStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SessionStatus>($StudySessionsTable.$converterstatus);
  static const VerificationMeta _learnedMeta = const VerificationMeta(
    'learned',
  );
  @override
  late final GeneratedColumn<String> learned = GeneratedColumn<String>(
    'learned',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pendingNoteMeta = const VerificationMeta(
    'pendingNote',
  );
  @override
  late final GeneratedColumn<String> pendingNote = GeneratedColumn<String>(
    'pending_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _questionsSolvedMeta = const VerificationMeta(
    'questionsSolved',
  );
  @override
  late final GeneratedColumn<int> questionsSolved = GeneratedColumn<int>(
    'questions_solved',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _focusMinutesMeta = const VerificationMeta(
    'focusMinutes',
  );
  @override
  late final GeneratedColumn<int> focusMinutes = GeneratedColumn<int>(
    'focus_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    slotId,
    subjectId,
    activityType,
    title,
    date,
    startedAt,
    endedAt,
    status,
    learned,
    pendingNote,
    questionsSolved,
    focusMinutes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'study_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<StudySession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('slot_id')) {
      context.handle(
        _slotIdMeta,
        slotId.isAcceptableOrUnknown(data['slot_id']!, _slotIdMeta),
      );
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('learned')) {
      context.handle(
        _learnedMeta,
        learned.isAcceptableOrUnknown(data['learned']!, _learnedMeta),
      );
    }
    if (data.containsKey('pending_note')) {
      context.handle(
        _pendingNoteMeta,
        pendingNote.isAcceptableOrUnknown(
          data['pending_note']!,
          _pendingNoteMeta,
        ),
      );
    }
    if (data.containsKey('questions_solved')) {
      context.handle(
        _questionsSolvedMeta,
        questionsSolved.isAcceptableOrUnknown(
          data['questions_solved']!,
          _questionsSolvedMeta,
        ),
      );
    }
    if (data.containsKey('focus_minutes')) {
      context.handle(
        _focusMinutesMeta,
        focusMinutes.isAcceptableOrUnknown(
          data['focus_minutes']!,
          _focusMinutesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StudySession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudySession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      slotId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}slot_id'],
      ),
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}subject_id'],
      ),
      activityType: $StudySessionsTable.$converteractivityType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}activity_type'],
        )!,
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      status: $StudySessionsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      learned: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}learned'],
      ),
      pendingNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pending_note'],
      ),
      questionsSolved: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}questions_solved'],
      )!,
      focusMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}focus_minutes'],
      )!,
    );
  }

  @override
  $StudySessionsTable createAlias(String alias) {
    return $StudySessionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ActivityType, String, String>
  $converteractivityType = const EnumNameConverter<ActivityType>(
    ActivityType.values,
  );
  static JsonTypeConverter2<SessionStatus, String, String> $converterstatus =
      const EnumNameConverter<SessionStatus>(SessionStatus.values);
}

class StudySession extends DataClass implements Insertable<StudySession> {
  final int id;
  final int? slotId;
  final int? subjectId;
  final ActivityType activityType;
  final String title;
  final String date;
  final DateTime startedAt;
  final DateTime? endedAt;
  final SessionStatus status;
  final String? learned;
  final String? pendingNote;
  final int questionsSolved;
  final int focusMinutes;
  const StudySession({
    required this.id,
    this.slotId,
    this.subjectId,
    required this.activityType,
    required this.title,
    required this.date,
    required this.startedAt,
    this.endedAt,
    required this.status,
    this.learned,
    this.pendingNote,
    required this.questionsSolved,
    required this.focusMinutes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || slotId != null) {
      map['slot_id'] = Variable<int>(slotId);
    }
    if (!nullToAbsent || subjectId != null) {
      map['subject_id'] = Variable<int>(subjectId);
    }
    {
      map['activity_type'] = Variable<String>(
        $StudySessionsTable.$converteractivityType.toSql(activityType),
      );
    }
    map['title'] = Variable<String>(title);
    map['date'] = Variable<String>(date);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    {
      map['status'] = Variable<String>(
        $StudySessionsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || learned != null) {
      map['learned'] = Variable<String>(learned);
    }
    if (!nullToAbsent || pendingNote != null) {
      map['pending_note'] = Variable<String>(pendingNote);
    }
    map['questions_solved'] = Variable<int>(questionsSolved);
    map['focus_minutes'] = Variable<int>(focusMinutes);
    return map;
  }

  StudySessionsCompanion toCompanion(bool nullToAbsent) {
    return StudySessionsCompanion(
      id: Value(id),
      slotId: slotId == null && nullToAbsent
          ? const Value.absent()
          : Value(slotId),
      subjectId: subjectId == null && nullToAbsent
          ? const Value.absent()
          : Value(subjectId),
      activityType: Value(activityType),
      title: Value(title),
      date: Value(date),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      status: Value(status),
      learned: learned == null && nullToAbsent
          ? const Value.absent()
          : Value(learned),
      pendingNote: pendingNote == null && nullToAbsent
          ? const Value.absent()
          : Value(pendingNote),
      questionsSolved: Value(questionsSolved),
      focusMinutes: Value(focusMinutes),
    );
  }

  factory StudySession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudySession(
      id: serializer.fromJson<int>(json['id']),
      slotId: serializer.fromJson<int?>(json['slotId']),
      subjectId: serializer.fromJson<int?>(json['subjectId']),
      activityType: $StudySessionsTable.$converteractivityType.fromJson(
        serializer.fromJson<String>(json['activityType']),
      ),
      title: serializer.fromJson<String>(json['title']),
      date: serializer.fromJson<String>(json['date']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      status: $StudySessionsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      learned: serializer.fromJson<String?>(json['learned']),
      pendingNote: serializer.fromJson<String?>(json['pendingNote']),
      questionsSolved: serializer.fromJson<int>(json['questionsSolved']),
      focusMinutes: serializer.fromJson<int>(json['focusMinutes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'slotId': serializer.toJson<int?>(slotId),
      'subjectId': serializer.toJson<int?>(subjectId),
      'activityType': serializer.toJson<String>(
        $StudySessionsTable.$converteractivityType.toJson(activityType),
      ),
      'title': serializer.toJson<String>(title),
      'date': serializer.toJson<String>(date),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'status': serializer.toJson<String>(
        $StudySessionsTable.$converterstatus.toJson(status),
      ),
      'learned': serializer.toJson<String?>(learned),
      'pendingNote': serializer.toJson<String?>(pendingNote),
      'questionsSolved': serializer.toJson<int>(questionsSolved),
      'focusMinutes': serializer.toJson<int>(focusMinutes),
    };
  }

  StudySession copyWith({
    int? id,
    Value<int?> slotId = const Value.absent(),
    Value<int?> subjectId = const Value.absent(),
    ActivityType? activityType,
    String? title,
    String? date,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    SessionStatus? status,
    Value<String?> learned = const Value.absent(),
    Value<String?> pendingNote = const Value.absent(),
    int? questionsSolved,
    int? focusMinutes,
  }) => StudySession(
    id: id ?? this.id,
    slotId: slotId.present ? slotId.value : this.slotId,
    subjectId: subjectId.present ? subjectId.value : this.subjectId,
    activityType: activityType ?? this.activityType,
    title: title ?? this.title,
    date: date ?? this.date,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    status: status ?? this.status,
    learned: learned.present ? learned.value : this.learned,
    pendingNote: pendingNote.present ? pendingNote.value : this.pendingNote,
    questionsSolved: questionsSolved ?? this.questionsSolved,
    focusMinutes: focusMinutes ?? this.focusMinutes,
  );
  StudySession copyWithCompanion(StudySessionsCompanion data) {
    return StudySession(
      id: data.id.present ? data.id.value : this.id,
      slotId: data.slotId.present ? data.slotId.value : this.slotId,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      activityType: data.activityType.present
          ? data.activityType.value
          : this.activityType,
      title: data.title.present ? data.title.value : this.title,
      date: data.date.present ? data.date.value : this.date,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      status: data.status.present ? data.status.value : this.status,
      learned: data.learned.present ? data.learned.value : this.learned,
      pendingNote: data.pendingNote.present
          ? data.pendingNote.value
          : this.pendingNote,
      questionsSolved: data.questionsSolved.present
          ? data.questionsSolved.value
          : this.questionsSolved,
      focusMinutes: data.focusMinutes.present
          ? data.focusMinutes.value
          : this.focusMinutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudySession(')
          ..write('id: $id, ')
          ..write('slotId: $slotId, ')
          ..write('subjectId: $subjectId, ')
          ..write('activityType: $activityType, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('status: $status, ')
          ..write('learned: $learned, ')
          ..write('pendingNote: $pendingNote, ')
          ..write('questionsSolved: $questionsSolved, ')
          ..write('focusMinutes: $focusMinutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    slotId,
    subjectId,
    activityType,
    title,
    date,
    startedAt,
    endedAt,
    status,
    learned,
    pendingNote,
    questionsSolved,
    focusMinutes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudySession &&
          other.id == this.id &&
          other.slotId == this.slotId &&
          other.subjectId == this.subjectId &&
          other.activityType == this.activityType &&
          other.title == this.title &&
          other.date == this.date &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.status == this.status &&
          other.learned == this.learned &&
          other.pendingNote == this.pendingNote &&
          other.questionsSolved == this.questionsSolved &&
          other.focusMinutes == this.focusMinutes);
}

class StudySessionsCompanion extends UpdateCompanion<StudySession> {
  final Value<int> id;
  final Value<int?> slotId;
  final Value<int?> subjectId;
  final Value<ActivityType> activityType;
  final Value<String> title;
  final Value<String> date;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<SessionStatus> status;
  final Value<String?> learned;
  final Value<String?> pendingNote;
  final Value<int> questionsSolved;
  final Value<int> focusMinutes;
  const StudySessionsCompanion({
    this.id = const Value.absent(),
    this.slotId = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.activityType = const Value.absent(),
    this.title = const Value.absent(),
    this.date = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.learned = const Value.absent(),
    this.pendingNote = const Value.absent(),
    this.questionsSolved = const Value.absent(),
    this.focusMinutes = const Value.absent(),
  });
  StudySessionsCompanion.insert({
    this.id = const Value.absent(),
    this.slotId = const Value.absent(),
    this.subjectId = const Value.absent(),
    required ActivityType activityType,
    required String title,
    required String date,
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    required SessionStatus status,
    this.learned = const Value.absent(),
    this.pendingNote = const Value.absent(),
    this.questionsSolved = const Value.absent(),
    this.focusMinutes = const Value.absent(),
  }) : activityType = Value(activityType),
       title = Value(title),
       date = Value(date),
       startedAt = Value(startedAt),
       status = Value(status);
  static Insertable<StudySession> custom({
    Expression<int>? id,
    Expression<int>? slotId,
    Expression<int>? subjectId,
    Expression<String>? activityType,
    Expression<String>? title,
    Expression<String>? date,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<String>? status,
    Expression<String>? learned,
    Expression<String>? pendingNote,
    Expression<int>? questionsSolved,
    Expression<int>? focusMinutes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (slotId != null) 'slot_id': slotId,
      if (subjectId != null) 'subject_id': subjectId,
      if (activityType != null) 'activity_type': activityType,
      if (title != null) 'title': title,
      if (date != null) 'date': date,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (status != null) 'status': status,
      if (learned != null) 'learned': learned,
      if (pendingNote != null) 'pending_note': pendingNote,
      if (questionsSolved != null) 'questions_solved': questionsSolved,
      if (focusMinutes != null) 'focus_minutes': focusMinutes,
    });
  }

  StudySessionsCompanion copyWith({
    Value<int>? id,
    Value<int?>? slotId,
    Value<int?>? subjectId,
    Value<ActivityType>? activityType,
    Value<String>? title,
    Value<String>? date,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<SessionStatus>? status,
    Value<String?>? learned,
    Value<String?>? pendingNote,
    Value<int>? questionsSolved,
    Value<int>? focusMinutes,
  }) {
    return StudySessionsCompanion(
      id: id ?? this.id,
      slotId: slotId ?? this.slotId,
      subjectId: subjectId ?? this.subjectId,
      activityType: activityType ?? this.activityType,
      title: title ?? this.title,
      date: date ?? this.date,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      status: status ?? this.status,
      learned: learned ?? this.learned,
      pendingNote: pendingNote ?? this.pendingNote,
      questionsSolved: questionsSolved ?? this.questionsSolved,
      focusMinutes: focusMinutes ?? this.focusMinutes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (slotId.present) {
      map['slot_id'] = Variable<int>(slotId.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<int>(subjectId.value);
    }
    if (activityType.present) {
      map['activity_type'] = Variable<String>(
        $StudySessionsTable.$converteractivityType.toSql(activityType.value),
      );
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $StudySessionsTable.$converterstatus.toSql(status.value),
      );
    }
    if (learned.present) {
      map['learned'] = Variable<String>(learned.value);
    }
    if (pendingNote.present) {
      map['pending_note'] = Variable<String>(pendingNote.value);
    }
    if (questionsSolved.present) {
      map['questions_solved'] = Variable<int>(questionsSolved.value);
    }
    if (focusMinutes.present) {
      map['focus_minutes'] = Variable<int>(focusMinutes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudySessionsCompanion(')
          ..write('id: $id, ')
          ..write('slotId: $slotId, ')
          ..write('subjectId: $subjectId, ')
          ..write('activityType: $activityType, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('status: $status, ')
          ..write('learned: $learned, ')
          ..write('pendingNote: $pendingNote, ')
          ..write('questionsSolved: $questionsSolved, ')
          ..write('focusMinutes: $focusMinutes')
          ..write(')'))
        .toString();
  }
}

class $JournalEntriesTable extends JournalEntries
    with TableInfo<$JournalEntriesTable, JournalEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JournalEntriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _learnedTextMeta = const VerificationMeta(
    'learnedText',
  );
  @override
  late final GeneratedColumn<String> learnedText = GeneratedColumn<String>(
    'learned_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<JournalMood?, String> mood =
      GeneratedColumn<String>(
        'mood',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<JournalMood?>($JournalEntriesTable.$convertermoodn);
  static const VerificationMeta _reflectionMeta = const VerificationMeta(
    'reflection',
  );
  @override
  late final GeneratedColumn<String> reflection = GeneratedColumn<String>(
    'reflection',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCompleteMeta = const VerificationMeta(
    'isComplete',
  );
  @override
  late final GeneratedColumn<bool> isComplete = GeneratedColumn<bool>(
    'is_complete',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_complete" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    learnedText,
    mood,
    reflection,
    isComplete,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journal_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<JournalEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('learned_text')) {
      context.handle(
        _learnedTextMeta,
        learnedText.isAcceptableOrUnknown(
          data['learned_text']!,
          _learnedTextMeta,
        ),
      );
    }
    if (data.containsKey('reflection')) {
      context.handle(
        _reflectionMeta,
        reflection.isAcceptableOrUnknown(data['reflection']!, _reflectionMeta),
      );
    }
    if (data.containsKey('is_complete')) {
      context.handle(
        _isCompleteMeta,
        isComplete.isAcceptableOrUnknown(data['is_complete']!, _isCompleteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JournalEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JournalEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      learnedText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}learned_text'],
      )!,
      mood: $JournalEntriesTable.$convertermoodn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}mood'],
        ),
      ),
      reflection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reflection'],
      ),
      isComplete: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_complete'],
      )!,
    );
  }

  @override
  $JournalEntriesTable createAlias(String alias) {
    return $JournalEntriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<JournalMood, String, String> $convertermood =
      const EnumNameConverter<JournalMood>(JournalMood.values);
  static JsonTypeConverter2<JournalMood?, String?, String?> $convertermoodn =
      JsonTypeConverter2.asNullable($convertermood);
}

class JournalEntry extends DataClass implements Insertable<JournalEntry> {
  final int id;
  final String date;
  final String learnedText;
  final JournalMood? mood;
  final String? reflection;
  final bool isComplete;
  const JournalEntry({
    required this.id,
    required this.date,
    required this.learnedText,
    this.mood,
    this.reflection,
    required this.isComplete,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<String>(date);
    map['learned_text'] = Variable<String>(learnedText);
    if (!nullToAbsent || mood != null) {
      map['mood'] = Variable<String>(
        $JournalEntriesTable.$convertermoodn.toSql(mood),
      );
    }
    if (!nullToAbsent || reflection != null) {
      map['reflection'] = Variable<String>(reflection);
    }
    map['is_complete'] = Variable<bool>(isComplete);
    return map;
  }

  JournalEntriesCompanion toCompanion(bool nullToAbsent) {
    return JournalEntriesCompanion(
      id: Value(id),
      date: Value(date),
      learnedText: Value(learnedText),
      mood: mood == null && nullToAbsent ? const Value.absent() : Value(mood),
      reflection: reflection == null && nullToAbsent
          ? const Value.absent()
          : Value(reflection),
      isComplete: Value(isComplete),
    );
  }

  factory JournalEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JournalEntry(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      learnedText: serializer.fromJson<String>(json['learnedText']),
      mood: $JournalEntriesTable.$convertermoodn.fromJson(
        serializer.fromJson<String?>(json['mood']),
      ),
      reflection: serializer.fromJson<String?>(json['reflection']),
      isComplete: serializer.fromJson<bool>(json['isComplete']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<String>(date),
      'learnedText': serializer.toJson<String>(learnedText),
      'mood': serializer.toJson<String?>(
        $JournalEntriesTable.$convertermoodn.toJson(mood),
      ),
      'reflection': serializer.toJson<String?>(reflection),
      'isComplete': serializer.toJson<bool>(isComplete),
    };
  }

  JournalEntry copyWith({
    int? id,
    String? date,
    String? learnedText,
    Value<JournalMood?> mood = const Value.absent(),
    Value<String?> reflection = const Value.absent(),
    bool? isComplete,
  }) => JournalEntry(
    id: id ?? this.id,
    date: date ?? this.date,
    learnedText: learnedText ?? this.learnedText,
    mood: mood.present ? mood.value : this.mood,
    reflection: reflection.present ? reflection.value : this.reflection,
    isComplete: isComplete ?? this.isComplete,
  );
  JournalEntry copyWithCompanion(JournalEntriesCompanion data) {
    return JournalEntry(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      learnedText: data.learnedText.present
          ? data.learnedText.value
          : this.learnedText,
      mood: data.mood.present ? data.mood.value : this.mood,
      reflection: data.reflection.present
          ? data.reflection.value
          : this.reflection,
      isComplete: data.isComplete.present
          ? data.isComplete.value
          : this.isComplete,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JournalEntry(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('learnedText: $learnedText, ')
          ..write('mood: $mood, ')
          ..write('reflection: $reflection, ')
          ..write('isComplete: $isComplete')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, date, learnedText, mood, reflection, isComplete);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JournalEntry &&
          other.id == this.id &&
          other.date == this.date &&
          other.learnedText == this.learnedText &&
          other.mood == this.mood &&
          other.reflection == this.reflection &&
          other.isComplete == this.isComplete);
}

class JournalEntriesCompanion extends UpdateCompanion<JournalEntry> {
  final Value<int> id;
  final Value<String> date;
  final Value<String> learnedText;
  final Value<JournalMood?> mood;
  final Value<String?> reflection;
  final Value<bool> isComplete;
  const JournalEntriesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.learnedText = const Value.absent(),
    this.mood = const Value.absent(),
    this.reflection = const Value.absent(),
    this.isComplete = const Value.absent(),
  });
  JournalEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String date,
    this.learnedText = const Value.absent(),
    this.mood = const Value.absent(),
    this.reflection = const Value.absent(),
    this.isComplete = const Value.absent(),
  }) : date = Value(date);
  static Insertable<JournalEntry> custom({
    Expression<int>? id,
    Expression<String>? date,
    Expression<String>? learnedText,
    Expression<String>? mood,
    Expression<String>? reflection,
    Expression<bool>? isComplete,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (learnedText != null) 'learned_text': learnedText,
      if (mood != null) 'mood': mood,
      if (reflection != null) 'reflection': reflection,
      if (isComplete != null) 'is_complete': isComplete,
    });
  }

  JournalEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? date,
    Value<String>? learnedText,
    Value<JournalMood?>? mood,
    Value<String?>? reflection,
    Value<bool>? isComplete,
  }) {
    return JournalEntriesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      learnedText: learnedText ?? this.learnedText,
      mood: mood ?? this.mood,
      reflection: reflection ?? this.reflection,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (learnedText.present) {
      map['learned_text'] = Variable<String>(learnedText.value);
    }
    if (mood.present) {
      map['mood'] = Variable<String>(
        $JournalEntriesTable.$convertermoodn.toSql(mood.value),
      );
    }
    if (reflection.present) {
      map['reflection'] = Variable<String>(reflection.value);
    }
    if (isComplete.present) {
      map['is_complete'] = Variable<bool>(isComplete.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JournalEntriesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('learnedText: $learnedText, ')
          ..write('mood: $mood, ')
          ..write('reflection: $reflection, ')
          ..write('isComplete: $isComplete')
          ..write(')'))
        .toString();
  }
}

class $PendingTasksTable extends PendingTasks
    with TableInfo<$PendingTasksTable, PendingTask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingTasksTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<int> subjectId = GeneratedColumn<int>(
    'subject_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<String> dueDate = GeneratedColumn<String>(
    'due_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  @override
  late final GeneratedColumnWithTypeConverter<PendingStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PendingStatus>($PendingTasksTable.$converterstatus);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    subjectId,
    description,
    dueDate,
    source,
    status,
    createdAt,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingTask> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_dueDateMeta);
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
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingTask map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingTask(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}subject_id'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}due_date'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      status: $PendingTasksTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $PendingTasksTable createAlias(String alias) {
    return $PendingTasksTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PendingStatus, String, String> $converterstatus =
      const EnumNameConverter<PendingStatus>(PendingStatus.values);
}

class PendingTask extends DataClass implements Insertable<PendingTask> {
  final int id;
  final int? subjectId;
  final String description;
  final String dueDate;
  final String source;
  final PendingStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  const PendingTask({
    required this.id,
    this.subjectId,
    required this.description,
    required this.dueDate,
    required this.source,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || subjectId != null) {
      map['subject_id'] = Variable<int>(subjectId);
    }
    map['description'] = Variable<String>(description);
    map['due_date'] = Variable<String>(dueDate);
    map['source'] = Variable<String>(source);
    {
      map['status'] = Variable<String>(
        $PendingTasksTable.$converterstatus.toSql(status),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  PendingTasksCompanion toCompanion(bool nullToAbsent) {
    return PendingTasksCompanion(
      id: Value(id),
      subjectId: subjectId == null && nullToAbsent
          ? const Value.absent()
          : Value(subjectId),
      description: Value(description),
      dueDate: Value(dueDate),
      source: Value(source),
      status: Value(status),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory PendingTask.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingTask(
      id: serializer.fromJson<int>(json['id']),
      subjectId: serializer.fromJson<int?>(json['subjectId']),
      description: serializer.fromJson<String>(json['description']),
      dueDate: serializer.fromJson<String>(json['dueDate']),
      source: serializer.fromJson<String>(json['source']),
      status: $PendingTasksTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'subjectId': serializer.toJson<int?>(subjectId),
      'description': serializer.toJson<String>(description),
      'dueDate': serializer.toJson<String>(dueDate),
      'source': serializer.toJson<String>(source),
      'status': serializer.toJson<String>(
        $PendingTasksTable.$converterstatus.toJson(status),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  PendingTask copyWith({
    int? id,
    Value<int?> subjectId = const Value.absent(),
    String? description,
    String? dueDate,
    String? source,
    PendingStatus? status,
    DateTime? createdAt,
    Value<DateTime?> completedAt = const Value.absent(),
  }) => PendingTask(
    id: id ?? this.id,
    subjectId: subjectId.present ? subjectId.value : this.subjectId,
    description: description ?? this.description,
    dueDate: dueDate ?? this.dueDate,
    source: source ?? this.source,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  PendingTask copyWithCompanion(PendingTasksCompanion data) {
    return PendingTask(
      id: data.id.present ? data.id.value : this.id,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      description: data.description.present
          ? data.description.value
          : this.description,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      source: data.source.present ? data.source.value : this.source,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingTask(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('description: $description, ')
          ..write('dueDate: $dueDate, ')
          ..write('source: $source, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    subjectId,
    description,
    dueDate,
    source,
    status,
    createdAt,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingTask &&
          other.id == this.id &&
          other.subjectId == this.subjectId &&
          other.description == this.description &&
          other.dueDate == this.dueDate &&
          other.source == this.source &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt);
}

class PendingTasksCompanion extends UpdateCompanion<PendingTask> {
  final Value<int> id;
  final Value<int?> subjectId;
  final Value<String> description;
  final Value<String> dueDate;
  final Value<String> source;
  final Value<PendingStatus> status;
  final Value<DateTime> createdAt;
  final Value<DateTime?> completedAt;
  const PendingTasksCompanion({
    this.id = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.description = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.source = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
  });
  PendingTasksCompanion.insert({
    this.id = const Value.absent(),
    this.subjectId = const Value.absent(),
    required String description,
    required String dueDate,
    this.source = const Value.absent(),
    required PendingStatus status,
    required DateTime createdAt,
    this.completedAt = const Value.absent(),
  }) : description = Value(description),
       dueDate = Value(dueDate),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<PendingTask> custom({
    Expression<int>? id,
    Expression<int>? subjectId,
    Expression<String>? description,
    Expression<String>? dueDate,
    Expression<String>? source,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? completedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subjectId != null) 'subject_id': subjectId,
      if (description != null) 'description': description,
      if (dueDate != null) 'due_date': dueDate,
      if (source != null) 'source': source,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
    });
  }

  PendingTasksCompanion copyWith({
    Value<int>? id,
    Value<int?>? subjectId,
    Value<String>? description,
    Value<String>? dueDate,
    Value<String>? source,
    Value<PendingStatus>? status,
    Value<DateTime>? createdAt,
    Value<DateTime?>? completedAt,
  }) {
    return PendingTasksCompanion(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      source: source ?? this.source,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<int>(subjectId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<String>(dueDate.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $PendingTasksTable.$converterstatus.toSql(status.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingTasksCompanion(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('description: $description, ')
          ..write('dueDate: $dueDate, ')
          ..write('source: $source, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }
}

class $TestsTable extends Tests with TableInfo<$TestsTable, Test> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TestsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _physicsScoreMeta = const VerificationMeta(
    'physicsScore',
  );
  @override
  late final GeneratedColumn<int> physicsScore = GeneratedColumn<int>(
    'physics_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chemistryScoreMeta = const VerificationMeta(
    'chemistryScore',
  );
  @override
  late final GeneratedColumn<int> chemistryScore = GeneratedColumn<int>(
    'chemistry_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _biologyScoreMeta = const VerificationMeta(
    'biologyScore',
  );
  @override
  late final GeneratedColumn<int> biologyScore = GeneratedColumn<int>(
    'biology_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalScoreMeta = const VerificationMeta(
    'totalScore',
  );
  @override
  late final GeneratedColumn<int> totalScore = GeneratedColumn<int>(
    'total_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    date,
    physicsScore,
    chemistryScore,
    biologyScore,
    totalScore,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tests';
  @override
  VerificationContext validateIntegrity(
    Insertable<Test> instance, {
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
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('physics_score')) {
      context.handle(
        _physicsScoreMeta,
        physicsScore.isAcceptableOrUnknown(
          data['physics_score']!,
          _physicsScoreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_physicsScoreMeta);
    }
    if (data.containsKey('chemistry_score')) {
      context.handle(
        _chemistryScoreMeta,
        chemistryScore.isAcceptableOrUnknown(
          data['chemistry_score']!,
          _chemistryScoreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chemistryScoreMeta);
    }
    if (data.containsKey('biology_score')) {
      context.handle(
        _biologyScoreMeta,
        biologyScore.isAcceptableOrUnknown(
          data['biology_score']!,
          _biologyScoreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_biologyScoreMeta);
    }
    if (data.containsKey('total_score')) {
      context.handle(
        _totalScoreMeta,
        totalScore.isAcceptableOrUnknown(data['total_score']!, _totalScoreMeta),
      );
    } else if (isInserting) {
      context.missing(_totalScoreMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Test map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Test(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      physicsScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}physics_score'],
      )!,
      chemistryScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chemistry_score'],
      )!,
      biologyScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}biology_score'],
      )!,
      totalScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_score'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $TestsTable createAlias(String alias) {
    return $TestsTable(attachedDatabase, alias);
  }
}

class Test extends DataClass implements Insertable<Test> {
  final int id;
  final String name;
  final String date;
  final int physicsScore;
  final int chemistryScore;
  final int biologyScore;
  final int totalScore;
  final String? notes;
  const Test({
    required this.id,
    required this.name,
    required this.date,
    required this.physicsScore,
    required this.chemistryScore,
    required this.biologyScore,
    required this.totalScore,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['date'] = Variable<String>(date);
    map['physics_score'] = Variable<int>(physicsScore);
    map['chemistry_score'] = Variable<int>(chemistryScore);
    map['biology_score'] = Variable<int>(biologyScore);
    map['total_score'] = Variable<int>(totalScore);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  TestsCompanion toCompanion(bool nullToAbsent) {
    return TestsCompanion(
      id: Value(id),
      name: Value(name),
      date: Value(date),
      physicsScore: Value(physicsScore),
      chemistryScore: Value(chemistryScore),
      biologyScore: Value(biologyScore),
      totalScore: Value(totalScore),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory Test.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Test(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      date: serializer.fromJson<String>(json['date']),
      physicsScore: serializer.fromJson<int>(json['physicsScore']),
      chemistryScore: serializer.fromJson<int>(json['chemistryScore']),
      biologyScore: serializer.fromJson<int>(json['biologyScore']),
      totalScore: serializer.fromJson<int>(json['totalScore']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'date': serializer.toJson<String>(date),
      'physicsScore': serializer.toJson<int>(physicsScore),
      'chemistryScore': serializer.toJson<int>(chemistryScore),
      'biologyScore': serializer.toJson<int>(biologyScore),
      'totalScore': serializer.toJson<int>(totalScore),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  Test copyWith({
    int? id,
    String? name,
    String? date,
    int? physicsScore,
    int? chemistryScore,
    int? biologyScore,
    int? totalScore,
    Value<String?> notes = const Value.absent(),
  }) => Test(
    id: id ?? this.id,
    name: name ?? this.name,
    date: date ?? this.date,
    physicsScore: physicsScore ?? this.physicsScore,
    chemistryScore: chemistryScore ?? this.chemistryScore,
    biologyScore: biologyScore ?? this.biologyScore,
    totalScore: totalScore ?? this.totalScore,
    notes: notes.present ? notes.value : this.notes,
  );
  Test copyWithCompanion(TestsCompanion data) {
    return Test(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      date: data.date.present ? data.date.value : this.date,
      physicsScore: data.physicsScore.present
          ? data.physicsScore.value
          : this.physicsScore,
      chemistryScore: data.chemistryScore.present
          ? data.chemistryScore.value
          : this.chemistryScore,
      biologyScore: data.biologyScore.present
          ? data.biologyScore.value
          : this.biologyScore,
      totalScore: data.totalScore.present
          ? data.totalScore.value
          : this.totalScore,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Test(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('date: $date, ')
          ..write('physicsScore: $physicsScore, ')
          ..write('chemistryScore: $chemistryScore, ')
          ..write('biologyScore: $biologyScore, ')
          ..write('totalScore: $totalScore, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    date,
    physicsScore,
    chemistryScore,
    biologyScore,
    totalScore,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Test &&
          other.id == this.id &&
          other.name == this.name &&
          other.date == this.date &&
          other.physicsScore == this.physicsScore &&
          other.chemistryScore == this.chemistryScore &&
          other.biologyScore == this.biologyScore &&
          other.totalScore == this.totalScore &&
          other.notes == this.notes);
}

class TestsCompanion extends UpdateCompanion<Test> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> date;
  final Value<int> physicsScore;
  final Value<int> chemistryScore;
  final Value<int> biologyScore;
  final Value<int> totalScore;
  final Value<String?> notes;
  const TestsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.date = const Value.absent(),
    this.physicsScore = const Value.absent(),
    this.chemistryScore = const Value.absent(),
    this.biologyScore = const Value.absent(),
    this.totalScore = const Value.absent(),
    this.notes = const Value.absent(),
  });
  TestsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String date,
    required int physicsScore,
    required int chemistryScore,
    required int biologyScore,
    required int totalScore,
    this.notes = const Value.absent(),
  }) : name = Value(name),
       date = Value(date),
       physicsScore = Value(physicsScore),
       chemistryScore = Value(chemistryScore),
       biologyScore = Value(biologyScore),
       totalScore = Value(totalScore);
  static Insertable<Test> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? date,
    Expression<int>? physicsScore,
    Expression<int>? chemistryScore,
    Expression<int>? biologyScore,
    Expression<int>? totalScore,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (date != null) 'date': date,
      if (physicsScore != null) 'physics_score': physicsScore,
      if (chemistryScore != null) 'chemistry_score': chemistryScore,
      if (biologyScore != null) 'biology_score': biologyScore,
      if (totalScore != null) 'total_score': totalScore,
      if (notes != null) 'notes': notes,
    });
  }

  TestsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? date,
    Value<int>? physicsScore,
    Value<int>? chemistryScore,
    Value<int>? biologyScore,
    Value<int>? totalScore,
    Value<String?>? notes,
  }) {
    return TestsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      physicsScore: physicsScore ?? this.physicsScore,
      chemistryScore: chemistryScore ?? this.chemistryScore,
      biologyScore: biologyScore ?? this.biologyScore,
      totalScore: totalScore ?? this.totalScore,
      notes: notes ?? this.notes,
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
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (physicsScore.present) {
      map['physics_score'] = Variable<int>(physicsScore.value);
    }
    if (chemistryScore.present) {
      map['chemistry_score'] = Variable<int>(chemistryScore.value);
    }
    if (biologyScore.present) {
      map['biology_score'] = Variable<int>(biologyScore.value);
    }
    if (totalScore.present) {
      map['total_score'] = Variable<int>(totalScore.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TestsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('date: $date, ')
          ..write('physicsScore: $physicsScore, ')
          ..write('chemistryScore: $chemistryScore, ')
          ..write('biologyScore: $biologyScore, ')
          ..write('totalScore: $totalScore, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $TestMistakesTable extends TestMistakes
    with TableInfo<$TestMistakesTable, TestMistake> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TestMistakesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _testIdMeta = const VerificationMeta('testId');
  @override
  late final GeneratedColumn<int> testId = GeneratedColumn<int>(
    'test_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<int> subjectId = GeneratedColumn<int>(
    'subject_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<MistakeCategory, String>
  category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<MistakeCategory>($TestMistakesTable.$convertercategory);
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isRevisionedMeta = const VerificationMeta(
    'isRevisioned',
  );
  @override
  late final GeneratedColumn<bool> isRevisioned = GeneratedColumn<bool>(
    'is_revisioned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_revisioned" IN (0, 1))',
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    testId,
    subjectId,
    category,
    description,
    isRevisioned,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'test_mistakes';
  @override
  VerificationContext validateIntegrity(
    Insertable<TestMistake> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('test_id')) {
      context.handle(
        _testIdMeta,
        testId.isAcceptableOrUnknown(data['test_id']!, _testIdMeta),
      );
    } else if (isInserting) {
      context.missing(_testIdMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('is_revisioned')) {
      context.handle(
        _isRevisionedMeta,
        isRevisioned.isAcceptableOrUnknown(
          data['is_revisioned']!,
          _isRevisionedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TestMistake map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TestMistake(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      testId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}test_id'],
      )!,
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}subject_id'],
      ),
      category: $TestMistakesTable.$convertercategory.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}category'],
        )!,
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      isRevisioned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_revisioned'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TestMistakesTable createAlias(String alias) {
    return $TestMistakesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MistakeCategory, String, String>
  $convertercategory = const EnumNameConverter<MistakeCategory>(
    MistakeCategory.values,
  );
}

class TestMistake extends DataClass implements Insertable<TestMistake> {
  final int id;
  final int testId;
  final int? subjectId;
  final MistakeCategory category;
  final String description;
  final bool isRevisioned;
  final DateTime createdAt;
  const TestMistake({
    required this.id,
    required this.testId,
    this.subjectId,
    required this.category,
    required this.description,
    required this.isRevisioned,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['test_id'] = Variable<int>(testId);
    if (!nullToAbsent || subjectId != null) {
      map['subject_id'] = Variable<int>(subjectId);
    }
    {
      map['category'] = Variable<String>(
        $TestMistakesTable.$convertercategory.toSql(category),
      );
    }
    map['description'] = Variable<String>(description);
    map['is_revisioned'] = Variable<bool>(isRevisioned);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TestMistakesCompanion toCompanion(bool nullToAbsent) {
    return TestMistakesCompanion(
      id: Value(id),
      testId: Value(testId),
      subjectId: subjectId == null && nullToAbsent
          ? const Value.absent()
          : Value(subjectId),
      category: Value(category),
      description: Value(description),
      isRevisioned: Value(isRevisioned),
      createdAt: Value(createdAt),
    );
  }

  factory TestMistake.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TestMistake(
      id: serializer.fromJson<int>(json['id']),
      testId: serializer.fromJson<int>(json['testId']),
      subjectId: serializer.fromJson<int?>(json['subjectId']),
      category: $TestMistakesTable.$convertercategory.fromJson(
        serializer.fromJson<String>(json['category']),
      ),
      description: serializer.fromJson<String>(json['description']),
      isRevisioned: serializer.fromJson<bool>(json['isRevisioned']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'testId': serializer.toJson<int>(testId),
      'subjectId': serializer.toJson<int?>(subjectId),
      'category': serializer.toJson<String>(
        $TestMistakesTable.$convertercategory.toJson(category),
      ),
      'description': serializer.toJson<String>(description),
      'isRevisioned': serializer.toJson<bool>(isRevisioned),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TestMistake copyWith({
    int? id,
    int? testId,
    Value<int?> subjectId = const Value.absent(),
    MistakeCategory? category,
    String? description,
    bool? isRevisioned,
    DateTime? createdAt,
  }) => TestMistake(
    id: id ?? this.id,
    testId: testId ?? this.testId,
    subjectId: subjectId.present ? subjectId.value : this.subjectId,
    category: category ?? this.category,
    description: description ?? this.description,
    isRevisioned: isRevisioned ?? this.isRevisioned,
    createdAt: createdAt ?? this.createdAt,
  );
  TestMistake copyWithCompanion(TestMistakesCompanion data) {
    return TestMistake(
      id: data.id.present ? data.id.value : this.id,
      testId: data.testId.present ? data.testId.value : this.testId,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      category: data.category.present ? data.category.value : this.category,
      description: data.description.present
          ? data.description.value
          : this.description,
      isRevisioned: data.isRevisioned.present
          ? data.isRevisioned.value
          : this.isRevisioned,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TestMistake(')
          ..write('id: $id, ')
          ..write('testId: $testId, ')
          ..write('subjectId: $subjectId, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('isRevisioned: $isRevisioned, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    testId,
    subjectId,
    category,
    description,
    isRevisioned,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TestMistake &&
          other.id == this.id &&
          other.testId == this.testId &&
          other.subjectId == this.subjectId &&
          other.category == this.category &&
          other.description == this.description &&
          other.isRevisioned == this.isRevisioned &&
          other.createdAt == this.createdAt);
}

class TestMistakesCompanion extends UpdateCompanion<TestMistake> {
  final Value<int> id;
  final Value<int> testId;
  final Value<int?> subjectId;
  final Value<MistakeCategory> category;
  final Value<String> description;
  final Value<bool> isRevisioned;
  final Value<DateTime> createdAt;
  const TestMistakesCompanion({
    this.id = const Value.absent(),
    this.testId = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.category = const Value.absent(),
    this.description = const Value.absent(),
    this.isRevisioned = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TestMistakesCompanion.insert({
    this.id = const Value.absent(),
    required int testId,
    this.subjectId = const Value.absent(),
    required MistakeCategory category,
    required String description,
    this.isRevisioned = const Value.absent(),
    required DateTime createdAt,
  }) : testId = Value(testId),
       category = Value(category),
       description = Value(description),
       createdAt = Value(createdAt);
  static Insertable<TestMistake> custom({
    Expression<int>? id,
    Expression<int>? testId,
    Expression<int>? subjectId,
    Expression<String>? category,
    Expression<String>? description,
    Expression<bool>? isRevisioned,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (testId != null) 'test_id': testId,
      if (subjectId != null) 'subject_id': subjectId,
      if (category != null) 'category': category,
      if (description != null) 'description': description,
      if (isRevisioned != null) 'is_revisioned': isRevisioned,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TestMistakesCompanion copyWith({
    Value<int>? id,
    Value<int>? testId,
    Value<int?>? subjectId,
    Value<MistakeCategory>? category,
    Value<String>? description,
    Value<bool>? isRevisioned,
    Value<DateTime>? createdAt,
  }) {
    return TestMistakesCompanion(
      id: id ?? this.id,
      testId: testId ?? this.testId,
      subjectId: subjectId ?? this.subjectId,
      category: category ?? this.category,
      description: description ?? this.description,
      isRevisioned: isRevisioned ?? this.isRevisioned,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (testId.present) {
      map['test_id'] = Variable<int>(testId.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<int>(subjectId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(
        $TestMistakesTable.$convertercategory.toSql(category.value),
      );
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isRevisioned.present) {
      map['is_revisioned'] = Variable<bool>(isRevisioned.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TestMistakesCompanion(')
          ..write('id: $id, ')
          ..write('testId: $testId, ')
          ..write('subjectId: $subjectId, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('isRevisioned: $isRevisioned, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
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
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
    Insertable<AppSetting> instance, {
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
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
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
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
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
    Value<String>? value,
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
      map['value'] = Variable<String>(value.value);
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
  late final $SubjectsTable subjects = $SubjectsTable(this);
  late final $ChaptersTable chapters = $ChaptersTable(this);
  late final $TimetableSlotsTable timetableSlots = $TimetableSlotsTable(this);
  late final $StudySessionsTable studySessions = $StudySessionsTable(this);
  late final $JournalEntriesTable journalEntries = $JournalEntriesTable(this);
  late final $PendingTasksTable pendingTasks = $PendingTasksTable(this);
  late final $TestsTable tests = $TestsTable(this);
  late final $TestMistakesTable testMistakes = $TestMistakesTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    subjects,
    chapters,
    timetableSlots,
    studySessions,
    journalEntries,
    pendingTasks,
    tests,
    testMistakes,
    appSettings,
  ];
}

typedef $$SubjectsTableCreateCompanionBuilder =
    SubjectsCompanion Function({
      Value<int> id,
      required String name,
      required int colorValue,
      Value<int> sortOrder,
    });
typedef $$SubjectsTableUpdateCompanionBuilder =
    SubjectsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> colorValue,
      Value<int> sortOrder,
    });

class $$SubjectsTableFilterComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableFilterComposer({
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

  ColumnFilters<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SubjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableOrderingComposer({
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

  ColumnOrderings<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SubjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableAnnotationComposer({
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

  GeneratedColumn<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$SubjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubjectsTable,
          Subject,
          $$SubjectsTableFilterComposer,
          $$SubjectsTableOrderingComposer,
          $$SubjectsTableAnnotationComposer,
          $$SubjectsTableCreateCompanionBuilder,
          $$SubjectsTableUpdateCompanionBuilder,
          (Subject, BaseReferences<_$AppDatabase, $SubjectsTable, Subject>),
          Subject,
          PrefetchHooks Function()
        > {
  $$SubjectsTableTableManager(_$AppDatabase db, $SubjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> colorValue = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => SubjectsCompanion(
                id: id,
                name: name,
                colorValue: colorValue,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int colorValue,
                Value<int> sortOrder = const Value.absent(),
              }) => SubjectsCompanion.insert(
                id: id,
                name: name,
                colorValue: colorValue,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SubjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubjectsTable,
      Subject,
      $$SubjectsTableFilterComposer,
      $$SubjectsTableOrderingComposer,
      $$SubjectsTableAnnotationComposer,
      $$SubjectsTableCreateCompanionBuilder,
      $$SubjectsTableUpdateCompanionBuilder,
      (Subject, BaseReferences<_$AppDatabase, $SubjectsTable, Subject>),
      Subject,
      PrefetchHooks Function()
    >;
typedef $$ChaptersTableCreateCompanionBuilder =
    ChaptersCompanion Function({
      Value<int> id,
      required int subjectId,
      required String name,
      required ChapterStatus status,
    });
typedef $$ChaptersTableUpdateCompanionBuilder =
    ChaptersCompanion Function({
      Value<int> id,
      Value<int> subjectId,
      Value<String> name,
      Value<ChapterStatus> status,
    });

class $$ChaptersTableFilterComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableFilterComposer({
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

  ColumnFilters<int> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ChapterStatus, ChapterStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$ChaptersTableOrderingComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableOrderingComposer({
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

  ColumnOrderings<int> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChaptersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ChapterStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$ChaptersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChaptersTable,
          Chapter,
          $$ChaptersTableFilterComposer,
          $$ChaptersTableOrderingComposer,
          $$ChaptersTableAnnotationComposer,
          $$ChaptersTableCreateCompanionBuilder,
          $$ChaptersTableUpdateCompanionBuilder,
          (Chapter, BaseReferences<_$AppDatabase, $ChaptersTable, Chapter>),
          Chapter,
          PrefetchHooks Function()
        > {
  $$ChaptersTableTableManager(_$AppDatabase db, $ChaptersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChaptersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChaptersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChaptersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> subjectId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<ChapterStatus> status = const Value.absent(),
              }) => ChaptersCompanion(
                id: id,
                subjectId: subjectId,
                name: name,
                status: status,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int subjectId,
                required String name,
                required ChapterStatus status,
              }) => ChaptersCompanion.insert(
                id: id,
                subjectId: subjectId,
                name: name,
                status: status,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChaptersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChaptersTable,
      Chapter,
      $$ChaptersTableFilterComposer,
      $$ChaptersTableOrderingComposer,
      $$ChaptersTableAnnotationComposer,
      $$ChaptersTableCreateCompanionBuilder,
      $$ChaptersTableUpdateCompanionBuilder,
      (Chapter, BaseReferences<_$AppDatabase, $ChaptersTable, Chapter>),
      Chapter,
      PrefetchHooks Function()
    >;
typedef $$TimetableSlotsTableCreateCompanionBuilder =
    TimetableSlotsCompanion Function({
      Value<int> id,
      Value<int?> dayOfWeek,
      Value<String?> date,
      Value<int?> templateSlotId,
      required int startMin,
      required int endMin,
      Value<int?> subjectId,
      required ActivityType activityType,
      required String title,
      Value<String?> target,
      required bool isRecurring,
      Value<bool> isOptional,
    });
typedef $$TimetableSlotsTableUpdateCompanionBuilder =
    TimetableSlotsCompanion Function({
      Value<int> id,
      Value<int?> dayOfWeek,
      Value<String?> date,
      Value<int?> templateSlotId,
      Value<int> startMin,
      Value<int> endMin,
      Value<int?> subjectId,
      Value<ActivityType> activityType,
      Value<String> title,
      Value<String?> target,
      Value<bool> isRecurring,
      Value<bool> isOptional,
    });

class $$TimetableSlotsTableFilterComposer
    extends Composer<_$AppDatabase, $TimetableSlotsTable> {
  $$TimetableSlotsTableFilterComposer({
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

  ColumnFilters<int> get dayOfWeek => $composableBuilder(
    column: $table.dayOfWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get templateSlotId => $composableBuilder(
    column: $table.templateSlotId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMin => $composableBuilder(
    column: $table.startMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endMin => $composableBuilder(
    column: $table.endMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ActivityType, ActivityType, String>
  get activityType => $composableBuilder(
    column: $table.activityType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRecurring => $composableBuilder(
    column: $table.isRecurring,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOptional => $composableBuilder(
    column: $table.isOptional,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TimetableSlotsTableOrderingComposer
    extends Composer<_$AppDatabase, $TimetableSlotsTable> {
  $$TimetableSlotsTableOrderingComposer({
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

  ColumnOrderings<int> get dayOfWeek => $composableBuilder(
    column: $table.dayOfWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get templateSlotId => $composableBuilder(
    column: $table.templateSlotId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMin => $composableBuilder(
    column: $table.startMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endMin => $composableBuilder(
    column: $table.endMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activityType => $composableBuilder(
    column: $table.activityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRecurring => $composableBuilder(
    column: $table.isRecurring,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOptional => $composableBuilder(
    column: $table.isOptional,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TimetableSlotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimetableSlotsTable> {
  $$TimetableSlotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get dayOfWeek =>
      $composableBuilder(column: $table.dayOfWeek, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get templateSlotId => $composableBuilder(
    column: $table.templateSlotId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startMin =>
      $composableBuilder(column: $table.startMin, builder: (column) => column);

  GeneratedColumn<int> get endMin =>
      $composableBuilder(column: $table.endMin, builder: (column) => column);

  GeneratedColumn<int> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ActivityType, String> get activityType =>
      $composableBuilder(
        column: $table.activityType,
        builder: (column) => column,
      );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get target =>
      $composableBuilder(column: $table.target, builder: (column) => column);

  GeneratedColumn<bool> get isRecurring => $composableBuilder(
    column: $table.isRecurring,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isOptional => $composableBuilder(
    column: $table.isOptional,
    builder: (column) => column,
  );
}

class $$TimetableSlotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TimetableSlotsTable,
          TimetableSlot,
          $$TimetableSlotsTableFilterComposer,
          $$TimetableSlotsTableOrderingComposer,
          $$TimetableSlotsTableAnnotationComposer,
          $$TimetableSlotsTableCreateCompanionBuilder,
          $$TimetableSlotsTableUpdateCompanionBuilder,
          (
            TimetableSlot,
            BaseReferences<_$AppDatabase, $TimetableSlotsTable, TimetableSlot>,
          ),
          TimetableSlot,
          PrefetchHooks Function()
        > {
  $$TimetableSlotsTableTableManager(
    _$AppDatabase db,
    $TimetableSlotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimetableSlotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimetableSlotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimetableSlotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> dayOfWeek = const Value.absent(),
                Value<String?> date = const Value.absent(),
                Value<int?> templateSlotId = const Value.absent(),
                Value<int> startMin = const Value.absent(),
                Value<int> endMin = const Value.absent(),
                Value<int?> subjectId = const Value.absent(),
                Value<ActivityType> activityType = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> target = const Value.absent(),
                Value<bool> isRecurring = const Value.absent(),
                Value<bool> isOptional = const Value.absent(),
              }) => TimetableSlotsCompanion(
                id: id,
                dayOfWeek: dayOfWeek,
                date: date,
                templateSlotId: templateSlotId,
                startMin: startMin,
                endMin: endMin,
                subjectId: subjectId,
                activityType: activityType,
                title: title,
                target: target,
                isRecurring: isRecurring,
                isOptional: isOptional,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> dayOfWeek = const Value.absent(),
                Value<String?> date = const Value.absent(),
                Value<int?> templateSlotId = const Value.absent(),
                required int startMin,
                required int endMin,
                Value<int?> subjectId = const Value.absent(),
                required ActivityType activityType,
                required String title,
                Value<String?> target = const Value.absent(),
                required bool isRecurring,
                Value<bool> isOptional = const Value.absent(),
              }) => TimetableSlotsCompanion.insert(
                id: id,
                dayOfWeek: dayOfWeek,
                date: date,
                templateSlotId: templateSlotId,
                startMin: startMin,
                endMin: endMin,
                subjectId: subjectId,
                activityType: activityType,
                title: title,
                target: target,
                isRecurring: isRecurring,
                isOptional: isOptional,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TimetableSlotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TimetableSlotsTable,
      TimetableSlot,
      $$TimetableSlotsTableFilterComposer,
      $$TimetableSlotsTableOrderingComposer,
      $$TimetableSlotsTableAnnotationComposer,
      $$TimetableSlotsTableCreateCompanionBuilder,
      $$TimetableSlotsTableUpdateCompanionBuilder,
      (
        TimetableSlot,
        BaseReferences<_$AppDatabase, $TimetableSlotsTable, TimetableSlot>,
      ),
      TimetableSlot,
      PrefetchHooks Function()
    >;
typedef $$StudySessionsTableCreateCompanionBuilder =
    StudySessionsCompanion Function({
      Value<int> id,
      Value<int?> slotId,
      Value<int?> subjectId,
      required ActivityType activityType,
      required String title,
      required String date,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      required SessionStatus status,
      Value<String?> learned,
      Value<String?> pendingNote,
      Value<int> questionsSolved,
      Value<int> focusMinutes,
    });
typedef $$StudySessionsTableUpdateCompanionBuilder =
    StudySessionsCompanion Function({
      Value<int> id,
      Value<int?> slotId,
      Value<int?> subjectId,
      Value<ActivityType> activityType,
      Value<String> title,
      Value<String> date,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<SessionStatus> status,
      Value<String?> learned,
      Value<String?> pendingNote,
      Value<int> questionsSolved,
      Value<int> focusMinutes,
    });

class $$StudySessionsTableFilterComposer
    extends Composer<_$AppDatabase, $StudySessionsTable> {
  $$StudySessionsTableFilterComposer({
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

  ColumnFilters<int> get slotId => $composableBuilder(
    column: $table.slotId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ActivityType, ActivityType, String>
  get activityType => $composableBuilder(
    column: $table.activityType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SessionStatus, SessionStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get learned => $composableBuilder(
    column: $table.learned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pendingNote => $composableBuilder(
    column: $table.pendingNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get questionsSolved => $composableBuilder(
    column: $table.questionsSolved,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get focusMinutes => $composableBuilder(
    column: $table.focusMinutes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StudySessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $StudySessionsTable> {
  $$StudySessionsTableOrderingComposer({
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

  ColumnOrderings<int> get slotId => $composableBuilder(
    column: $table.slotId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activityType => $composableBuilder(
    column: $table.activityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get learned => $composableBuilder(
    column: $table.learned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pendingNote => $composableBuilder(
    column: $table.pendingNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get questionsSolved => $composableBuilder(
    column: $table.questionsSolved,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get focusMinutes => $composableBuilder(
    column: $table.focusMinutes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StudySessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudySessionsTable> {
  $$StudySessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get slotId =>
      $composableBuilder(column: $table.slotId, builder: (column) => column);

  GeneratedColumn<int> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ActivityType, String> get activityType =>
      $composableBuilder(
        column: $table.activityType,
        builder: (column) => column,
      );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SessionStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get learned =>
      $composableBuilder(column: $table.learned, builder: (column) => column);

  GeneratedColumn<String> get pendingNote => $composableBuilder(
    column: $table.pendingNote,
    builder: (column) => column,
  );

  GeneratedColumn<int> get questionsSolved => $composableBuilder(
    column: $table.questionsSolved,
    builder: (column) => column,
  );

  GeneratedColumn<int> get focusMinutes => $composableBuilder(
    column: $table.focusMinutes,
    builder: (column) => column,
  );
}

class $$StudySessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StudySessionsTable,
          StudySession,
          $$StudySessionsTableFilterComposer,
          $$StudySessionsTableOrderingComposer,
          $$StudySessionsTableAnnotationComposer,
          $$StudySessionsTableCreateCompanionBuilder,
          $$StudySessionsTableUpdateCompanionBuilder,
          (
            StudySession,
            BaseReferences<_$AppDatabase, $StudySessionsTable, StudySession>,
          ),
          StudySession,
          PrefetchHooks Function()
        > {
  $$StudySessionsTableTableManager(_$AppDatabase db, $StudySessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudySessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudySessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudySessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> slotId = const Value.absent(),
                Value<int?> subjectId = const Value.absent(),
                Value<ActivityType> activityType = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<SessionStatus> status = const Value.absent(),
                Value<String?> learned = const Value.absent(),
                Value<String?> pendingNote = const Value.absent(),
                Value<int> questionsSolved = const Value.absent(),
                Value<int> focusMinutes = const Value.absent(),
              }) => StudySessionsCompanion(
                id: id,
                slotId: slotId,
                subjectId: subjectId,
                activityType: activityType,
                title: title,
                date: date,
                startedAt: startedAt,
                endedAt: endedAt,
                status: status,
                learned: learned,
                pendingNote: pendingNote,
                questionsSolved: questionsSolved,
                focusMinutes: focusMinutes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> slotId = const Value.absent(),
                Value<int?> subjectId = const Value.absent(),
                required ActivityType activityType,
                required String title,
                required String date,
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                required SessionStatus status,
                Value<String?> learned = const Value.absent(),
                Value<String?> pendingNote = const Value.absent(),
                Value<int> questionsSolved = const Value.absent(),
                Value<int> focusMinutes = const Value.absent(),
              }) => StudySessionsCompanion.insert(
                id: id,
                slotId: slotId,
                subjectId: subjectId,
                activityType: activityType,
                title: title,
                date: date,
                startedAt: startedAt,
                endedAt: endedAt,
                status: status,
                learned: learned,
                pendingNote: pendingNote,
                questionsSolved: questionsSolved,
                focusMinutes: focusMinutes,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StudySessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StudySessionsTable,
      StudySession,
      $$StudySessionsTableFilterComposer,
      $$StudySessionsTableOrderingComposer,
      $$StudySessionsTableAnnotationComposer,
      $$StudySessionsTableCreateCompanionBuilder,
      $$StudySessionsTableUpdateCompanionBuilder,
      (
        StudySession,
        BaseReferences<_$AppDatabase, $StudySessionsTable, StudySession>,
      ),
      StudySession,
      PrefetchHooks Function()
    >;
typedef $$JournalEntriesTableCreateCompanionBuilder =
    JournalEntriesCompanion Function({
      Value<int> id,
      required String date,
      Value<String> learnedText,
      Value<JournalMood?> mood,
      Value<String?> reflection,
      Value<bool> isComplete,
    });
typedef $$JournalEntriesTableUpdateCompanionBuilder =
    JournalEntriesCompanion Function({
      Value<int> id,
      Value<String> date,
      Value<String> learnedText,
      Value<JournalMood?> mood,
      Value<String?> reflection,
      Value<bool> isComplete,
    });

class $$JournalEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableFilterComposer({
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

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get learnedText => $composableBuilder(
    column: $table.learnedText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<JournalMood?, JournalMood, String> get mood =>
      $composableBuilder(
        column: $table.mood,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get reflection => $composableBuilder(
    column: $table.reflection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isComplete => $composableBuilder(
    column: $table.isComplete,
    builder: (column) => ColumnFilters(column),
  );
}

class $$JournalEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get learnedText => $composableBuilder(
    column: $table.learnedText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reflection => $composableBuilder(
    column: $table.reflection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isComplete => $composableBuilder(
    column: $table.isComplete,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JournalEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get learnedText => $composableBuilder(
    column: $table.learnedText,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<JournalMood?, String> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<String> get reflection => $composableBuilder(
    column: $table.reflection,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isComplete => $composableBuilder(
    column: $table.isComplete,
    builder: (column) => column,
  );
}

class $$JournalEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JournalEntriesTable,
          JournalEntry,
          $$JournalEntriesTableFilterComposer,
          $$JournalEntriesTableOrderingComposer,
          $$JournalEntriesTableAnnotationComposer,
          $$JournalEntriesTableCreateCompanionBuilder,
          $$JournalEntriesTableUpdateCompanionBuilder,
          (
            JournalEntry,
            BaseReferences<_$AppDatabase, $JournalEntriesTable, JournalEntry>,
          ),
          JournalEntry,
          PrefetchHooks Function()
        > {
  $$JournalEntriesTableTableManager(
    _$AppDatabase db,
    $JournalEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JournalEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JournalEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JournalEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> learnedText = const Value.absent(),
                Value<JournalMood?> mood = const Value.absent(),
                Value<String?> reflection = const Value.absent(),
                Value<bool> isComplete = const Value.absent(),
              }) => JournalEntriesCompanion(
                id: id,
                date: date,
                learnedText: learnedText,
                mood: mood,
                reflection: reflection,
                isComplete: isComplete,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String date,
                Value<String> learnedText = const Value.absent(),
                Value<JournalMood?> mood = const Value.absent(),
                Value<String?> reflection = const Value.absent(),
                Value<bool> isComplete = const Value.absent(),
              }) => JournalEntriesCompanion.insert(
                id: id,
                date: date,
                learnedText: learnedText,
                mood: mood,
                reflection: reflection,
                isComplete: isComplete,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$JournalEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JournalEntriesTable,
      JournalEntry,
      $$JournalEntriesTableFilterComposer,
      $$JournalEntriesTableOrderingComposer,
      $$JournalEntriesTableAnnotationComposer,
      $$JournalEntriesTableCreateCompanionBuilder,
      $$JournalEntriesTableUpdateCompanionBuilder,
      (
        JournalEntry,
        BaseReferences<_$AppDatabase, $JournalEntriesTable, JournalEntry>,
      ),
      JournalEntry,
      PrefetchHooks Function()
    >;
typedef $$PendingTasksTableCreateCompanionBuilder =
    PendingTasksCompanion Function({
      Value<int> id,
      Value<int?> subjectId,
      required String description,
      required String dueDate,
      Value<String> source,
      required PendingStatus status,
      required DateTime createdAt,
      Value<DateTime?> completedAt,
    });
typedef $$PendingTasksTableUpdateCompanionBuilder =
    PendingTasksCompanion Function({
      Value<int> id,
      Value<int?> subjectId,
      Value<String> description,
      Value<String> dueDate,
      Value<String> source,
      Value<PendingStatus> status,
      Value<DateTime> createdAt,
      Value<DateTime?> completedAt,
    });

class $$PendingTasksTableFilterComposer
    extends Composer<_$AppDatabase, $PendingTasksTable> {
  $$PendingTasksTableFilterComposer({
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

  ColumnFilters<int> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PendingStatus, PendingStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingTasksTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingTasksTable> {
  $$PendingTasksTableOrderingComposer({
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

  ColumnOrderings<int> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingTasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingTasksTable> {
  $$PendingTasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PendingStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$PendingTasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingTasksTable,
          PendingTask,
          $$PendingTasksTableFilterComposer,
          $$PendingTasksTableOrderingComposer,
          $$PendingTasksTableAnnotationComposer,
          $$PendingTasksTableCreateCompanionBuilder,
          $$PendingTasksTableUpdateCompanionBuilder,
          (
            PendingTask,
            BaseReferences<_$AppDatabase, $PendingTasksTable, PendingTask>,
          ),
          PendingTask,
          PrefetchHooks Function()
        > {
  $$PendingTasksTableTableManager(_$AppDatabase db, $PendingTasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> subjectId = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> dueDate = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<PendingStatus> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
              }) => PendingTasksCompanion(
                id: id,
                subjectId: subjectId,
                description: description,
                dueDate: dueDate,
                source: source,
                status: status,
                createdAt: createdAt,
                completedAt: completedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> subjectId = const Value.absent(),
                required String description,
                required String dueDate,
                Value<String> source = const Value.absent(),
                required PendingStatus status,
                required DateTime createdAt,
                Value<DateTime?> completedAt = const Value.absent(),
              }) => PendingTasksCompanion.insert(
                id: id,
                subjectId: subjectId,
                description: description,
                dueDate: dueDate,
                source: source,
                status: status,
                createdAt: createdAt,
                completedAt: completedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingTasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingTasksTable,
      PendingTask,
      $$PendingTasksTableFilterComposer,
      $$PendingTasksTableOrderingComposer,
      $$PendingTasksTableAnnotationComposer,
      $$PendingTasksTableCreateCompanionBuilder,
      $$PendingTasksTableUpdateCompanionBuilder,
      (
        PendingTask,
        BaseReferences<_$AppDatabase, $PendingTasksTable, PendingTask>,
      ),
      PendingTask,
      PrefetchHooks Function()
    >;
typedef $$TestsTableCreateCompanionBuilder =
    TestsCompanion Function({
      Value<int> id,
      required String name,
      required String date,
      required int physicsScore,
      required int chemistryScore,
      required int biologyScore,
      required int totalScore,
      Value<String?> notes,
    });
typedef $$TestsTableUpdateCompanionBuilder =
    TestsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> date,
      Value<int> physicsScore,
      Value<int> chemistryScore,
      Value<int> biologyScore,
      Value<int> totalScore,
      Value<String?> notes,
    });

class $$TestsTableFilterComposer extends Composer<_$AppDatabase, $TestsTable> {
  $$TestsTableFilterComposer({
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

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get physicsScore => $composableBuilder(
    column: $table.physicsScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chemistryScore => $composableBuilder(
    column: $table.chemistryScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get biologyScore => $composableBuilder(
    column: $table.biologyScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalScore => $composableBuilder(
    column: $table.totalScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TestsTableOrderingComposer
    extends Composer<_$AppDatabase, $TestsTable> {
  $$TestsTableOrderingComposer({
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

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get physicsScore => $composableBuilder(
    column: $table.physicsScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chemistryScore => $composableBuilder(
    column: $table.chemistryScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get biologyScore => $composableBuilder(
    column: $table.biologyScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalScore => $composableBuilder(
    column: $table.totalScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TestsTable> {
  $$TestsTableAnnotationComposer({
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

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get physicsScore => $composableBuilder(
    column: $table.physicsScore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get chemistryScore => $composableBuilder(
    column: $table.chemistryScore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get biologyScore => $composableBuilder(
    column: $table.biologyScore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalScore => $composableBuilder(
    column: $table.totalScore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$TestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TestsTable,
          Test,
          $$TestsTableFilterComposer,
          $$TestsTableOrderingComposer,
          $$TestsTableAnnotationComposer,
          $$TestsTableCreateCompanionBuilder,
          $$TestsTableUpdateCompanionBuilder,
          (Test, BaseReferences<_$AppDatabase, $TestsTable, Test>),
          Test,
          PrefetchHooks Function()
        > {
  $$TestsTableTableManager(_$AppDatabase db, $TestsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<int> physicsScore = const Value.absent(),
                Value<int> chemistryScore = const Value.absent(),
                Value<int> biologyScore = const Value.absent(),
                Value<int> totalScore = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => TestsCompanion(
                id: id,
                name: name,
                date: date,
                physicsScore: physicsScore,
                chemistryScore: chemistryScore,
                biologyScore: biologyScore,
                totalScore: totalScore,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String date,
                required int physicsScore,
                required int chemistryScore,
                required int biologyScore,
                required int totalScore,
                Value<String?> notes = const Value.absent(),
              }) => TestsCompanion.insert(
                id: id,
                name: name,
                date: date,
                physicsScore: physicsScore,
                chemistryScore: chemistryScore,
                biologyScore: biologyScore,
                totalScore: totalScore,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TestsTable,
      Test,
      $$TestsTableFilterComposer,
      $$TestsTableOrderingComposer,
      $$TestsTableAnnotationComposer,
      $$TestsTableCreateCompanionBuilder,
      $$TestsTableUpdateCompanionBuilder,
      (Test, BaseReferences<_$AppDatabase, $TestsTable, Test>),
      Test,
      PrefetchHooks Function()
    >;
typedef $$TestMistakesTableCreateCompanionBuilder =
    TestMistakesCompanion Function({
      Value<int> id,
      required int testId,
      Value<int?> subjectId,
      required MistakeCategory category,
      required String description,
      Value<bool> isRevisioned,
      required DateTime createdAt,
    });
typedef $$TestMistakesTableUpdateCompanionBuilder =
    TestMistakesCompanion Function({
      Value<int> id,
      Value<int> testId,
      Value<int?> subjectId,
      Value<MistakeCategory> category,
      Value<String> description,
      Value<bool> isRevisioned,
      Value<DateTime> createdAt,
    });

class $$TestMistakesTableFilterComposer
    extends Composer<_$AppDatabase, $TestMistakesTable> {
  $$TestMistakesTableFilterComposer({
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

  ColumnFilters<int> get testId => $composableBuilder(
    column: $table.testId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MistakeCategory, MistakeCategory, String>
  get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRevisioned => $composableBuilder(
    column: $table.isRevisioned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TestMistakesTableOrderingComposer
    extends Composer<_$AppDatabase, $TestMistakesTable> {
  $$TestMistakesTableOrderingComposer({
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

  ColumnOrderings<int> get testId => $composableBuilder(
    column: $table.testId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRevisioned => $composableBuilder(
    column: $table.isRevisioned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TestMistakesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TestMistakesTable> {
  $$TestMistakesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get testId =>
      $composableBuilder(column: $table.testId, builder: (column) => column);

  GeneratedColumn<int> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MistakeCategory, String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isRevisioned => $composableBuilder(
    column: $table.isRevisioned,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TestMistakesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TestMistakesTable,
          TestMistake,
          $$TestMistakesTableFilterComposer,
          $$TestMistakesTableOrderingComposer,
          $$TestMistakesTableAnnotationComposer,
          $$TestMistakesTableCreateCompanionBuilder,
          $$TestMistakesTableUpdateCompanionBuilder,
          (
            TestMistake,
            BaseReferences<_$AppDatabase, $TestMistakesTable, TestMistake>,
          ),
          TestMistake,
          PrefetchHooks Function()
        > {
  $$TestMistakesTableTableManager(_$AppDatabase db, $TestMistakesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TestMistakesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TestMistakesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TestMistakesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> testId = const Value.absent(),
                Value<int?> subjectId = const Value.absent(),
                Value<MistakeCategory> category = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<bool> isRevisioned = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TestMistakesCompanion(
                id: id,
                testId: testId,
                subjectId: subjectId,
                category: category,
                description: description,
                isRevisioned: isRevisioned,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int testId,
                Value<int?> subjectId = const Value.absent(),
                required MistakeCategory category,
                required String description,
                Value<bool> isRevisioned = const Value.absent(),
                required DateTime createdAt,
              }) => TestMistakesCompanion.insert(
                id: id,
                testId: testId,
                subjectId: subjectId,
                category: category,
                description: description,
                isRevisioned: isRevisioned,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TestMistakesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TestMistakesTable,
      TestMistake,
      $$TestMistakesTableFilterComposer,
      $$TestMistakesTableOrderingComposer,
      $$TestMistakesTableAnnotationComposer,
      $$TestMistakesTableCreateCompanionBuilder,
      $$TestMistakesTableUpdateCompanionBuilder,
      (
        TestMistake,
        BaseReferences<_$AppDatabase, $TestMistakesTable, TestMistake>,
      ),
      TestMistake,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
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

  ColumnFilters<String> get value => $composableBuilder(
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

  ColumnOrderings<String> get value => $composableBuilder(
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

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
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
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
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
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SubjectsTableTableManager get subjects =>
      $$SubjectsTableTableManager(_db, _db.subjects);
  $$ChaptersTableTableManager get chapters =>
      $$ChaptersTableTableManager(_db, _db.chapters);
  $$TimetableSlotsTableTableManager get timetableSlots =>
      $$TimetableSlotsTableTableManager(_db, _db.timetableSlots);
  $$StudySessionsTableTableManager get studySessions =>
      $$StudySessionsTableTableManager(_db, _db.studySessions);
  $$JournalEntriesTableTableManager get journalEntries =>
      $$JournalEntriesTableTableManager(_db, _db.journalEntries);
  $$PendingTasksTableTableManager get pendingTasks =>
      $$PendingTasksTableTableManager(_db, _db.pendingTasks);
  $$TestsTableTableManager get tests =>
      $$TestsTableTableManager(_db, _db.tests);
  $$TestMistakesTableTableManager get testMistakes =>
      $$TestMistakesTableTableManager(_db, _db.testMistakes);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
