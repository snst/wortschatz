// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $FlashcardsTableTable extends FlashcardsTable
    with TableInfo<$FlashcardsTableTable, FlashcardsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FlashcardsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _frontMeta = const VerificationMeta('front');
  @override
  late final GeneratedColumn<String> front = GeneratedColumn<String>(
      'front', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _backMeta = const VerificationMeta('back');
  @override
  late final GeneratedColumn<String> back = GeneratedColumn<String>(
      'back', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _nextReviewMeta =
      const VerificationMeta('nextReview');
  @override
  late final GeneratedColumn<DateTime> nextReview = GeneratedColumn<DateTime>(
      'next_review', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _lastReviewMeta =
      const VerificationMeta('lastReview');
  @override
  late final GeneratedColumn<DateTime> lastReview = GeneratedColumn<DateTime>(
      'last_review', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
      'priority', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _stabilityMeta =
      const VerificationMeta('stability');
  @override
  late final GeneratedColumn<double> stability = GeneratedColumn<double>(
      'stability', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.0));
  static const VerificationMeta _difficultyMeta =
      const VerificationMeta('difficulty');
  @override
  late final GeneratedColumn<double> difficulty = GeneratedColumn<double>(
      'difficulty', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(5.0));
  static const VerificationMeta _reviewCountMeta =
      const VerificationMeta('reviewCount');
  @override
  late final GeneratedColumn<int> reviewCount = GeneratedColumn<int>(
      'review_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        front,
        back,
        note,
        nextReview,
        lastReview,
        priority,
        stability,
        difficulty,
        reviewCount
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'flashcards_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<FlashcardsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('front')) {
      context.handle(
          _frontMeta, front.isAcceptableOrUnknown(data['front']!, _frontMeta));
    } else if (isInserting) {
      context.missing(_frontMeta);
    }
    if (data.containsKey('back')) {
      context.handle(
          _backMeta, back.isAcceptableOrUnknown(data['back']!, _backMeta));
    } else if (isInserting) {
      context.missing(_backMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('next_review')) {
      context.handle(
          _nextReviewMeta,
          nextReview.isAcceptableOrUnknown(
              data['next_review']!, _nextReviewMeta));
    }
    if (data.containsKey('last_review')) {
      context.handle(
          _lastReviewMeta,
          lastReview.isAcceptableOrUnknown(
              data['last_review']!, _lastReviewMeta));
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('stability')) {
      context.handle(_stabilityMeta,
          stability.isAcceptableOrUnknown(data['stability']!, _stabilityMeta));
    }
    if (data.containsKey('difficulty')) {
      context.handle(
          _difficultyMeta,
          difficulty.isAcceptableOrUnknown(
              data['difficulty']!, _difficultyMeta));
    }
    if (data.containsKey('review_count')) {
      context.handle(
          _reviewCountMeta,
          reviewCount.isAcceptableOrUnknown(
              data['review_count']!, _reviewCountMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FlashcardsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FlashcardsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      front: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}front'])!,
      back: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}back'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note'])!,
      nextReview: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}next_review'])!,
      lastReview: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_review'])!,
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}priority'])!,
      stability: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}stability'])!,
      difficulty: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}difficulty'])!,
      reviewCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}review_count'])!,
    );
  }

  @override
  $FlashcardsTableTable createAlias(String alias) {
    return $FlashcardsTableTable(attachedDatabase, alias);
  }
}

class FlashcardsTableData extends DataClass
    implements Insertable<FlashcardsTableData> {
  final int id;
  final String front;
  final String back;
  final String note;
  final DateTime nextReview;
  final DateTime lastReview;
  final int priority;
  final double stability;
  final double difficulty;
  final int reviewCount;
  const FlashcardsTableData(
      {required this.id,
      required this.front,
      required this.back,
      required this.note,
      required this.nextReview,
      required this.lastReview,
      required this.priority,
      required this.stability,
      required this.difficulty,
      required this.reviewCount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['front'] = Variable<String>(front);
    map['back'] = Variable<String>(back);
    map['note'] = Variable<String>(note);
    map['next_review'] = Variable<DateTime>(nextReview);
    map['last_review'] = Variable<DateTime>(lastReview);
    map['priority'] = Variable<int>(priority);
    map['stability'] = Variable<double>(stability);
    map['difficulty'] = Variable<double>(difficulty);
    map['review_count'] = Variable<int>(reviewCount);
    return map;
  }

  FlashcardsTableCompanion toCompanion(bool nullToAbsent) {
    return FlashcardsTableCompanion(
      id: Value(id),
      front: Value(front),
      back: Value(back),
      note: Value(note),
      nextReview: Value(nextReview),
      lastReview: Value(lastReview),
      priority: Value(priority),
      stability: Value(stability),
      difficulty: Value(difficulty),
      reviewCount: Value(reviewCount),
    );
  }

  factory FlashcardsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FlashcardsTableData(
      id: serializer.fromJson<int>(json['id']),
      front: serializer.fromJson<String>(json['front']),
      back: serializer.fromJson<String>(json['back']),
      note: serializer.fromJson<String>(json['note']),
      nextReview: serializer.fromJson<DateTime>(json['nextReview']),
      lastReview: serializer.fromJson<DateTime>(json['lastReview']),
      priority: serializer.fromJson<int>(json['priority']),
      stability: serializer.fromJson<double>(json['stability']),
      difficulty: serializer.fromJson<double>(json['difficulty']),
      reviewCount: serializer.fromJson<int>(json['reviewCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'front': serializer.toJson<String>(front),
      'back': serializer.toJson<String>(back),
      'note': serializer.toJson<String>(note),
      'nextReview': serializer.toJson<DateTime>(nextReview),
      'lastReview': serializer.toJson<DateTime>(lastReview),
      'priority': serializer.toJson<int>(priority),
      'stability': serializer.toJson<double>(stability),
      'difficulty': serializer.toJson<double>(difficulty),
      'reviewCount': serializer.toJson<int>(reviewCount),
    };
  }

  FlashcardsTableData copyWith(
          {int? id,
          String? front,
          String? back,
          String? note,
          DateTime? nextReview,
          DateTime? lastReview,
          int? priority,
          double? stability,
          double? difficulty,
          int? reviewCount}) =>
      FlashcardsTableData(
        id: id ?? this.id,
        front: front ?? this.front,
        back: back ?? this.back,
        note: note ?? this.note,
        nextReview: nextReview ?? this.nextReview,
        lastReview: lastReview ?? this.lastReview,
        priority: priority ?? this.priority,
        stability: stability ?? this.stability,
        difficulty: difficulty ?? this.difficulty,
        reviewCount: reviewCount ?? this.reviewCount,
      );
  FlashcardsTableData copyWithCompanion(FlashcardsTableCompanion data) {
    return FlashcardsTableData(
      id: data.id.present ? data.id.value : this.id,
      front: data.front.present ? data.front.value : this.front,
      back: data.back.present ? data.back.value : this.back,
      note: data.note.present ? data.note.value : this.note,
      nextReview:
          data.nextReview.present ? data.nextReview.value : this.nextReview,
      lastReview:
          data.lastReview.present ? data.lastReview.value : this.lastReview,
      priority: data.priority.present ? data.priority.value : this.priority,
      stability: data.stability.present ? data.stability.value : this.stability,
      difficulty:
          data.difficulty.present ? data.difficulty.value : this.difficulty,
      reviewCount:
          data.reviewCount.present ? data.reviewCount.value : this.reviewCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FlashcardsTableData(')
          ..write('id: $id, ')
          ..write('front: $front, ')
          ..write('back: $back, ')
          ..write('note: $note, ')
          ..write('nextReview: $nextReview, ')
          ..write('lastReview: $lastReview, ')
          ..write('priority: $priority, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('reviewCount: $reviewCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, front, back, note, nextReview, lastReview,
      priority, stability, difficulty, reviewCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FlashcardsTableData &&
          other.id == this.id &&
          other.front == this.front &&
          other.back == this.back &&
          other.note == this.note &&
          other.nextReview == this.nextReview &&
          other.lastReview == this.lastReview &&
          other.priority == this.priority &&
          other.stability == this.stability &&
          other.difficulty == this.difficulty &&
          other.reviewCount == this.reviewCount);
}

class FlashcardsTableCompanion extends UpdateCompanion<FlashcardsTableData> {
  final Value<int> id;
  final Value<String> front;
  final Value<String> back;
  final Value<String> note;
  final Value<DateTime> nextReview;
  final Value<DateTime> lastReview;
  final Value<int> priority;
  final Value<double> stability;
  final Value<double> difficulty;
  final Value<int> reviewCount;
  const FlashcardsTableCompanion({
    this.id = const Value.absent(),
    this.front = const Value.absent(),
    this.back = const Value.absent(),
    this.note = const Value.absent(),
    this.nextReview = const Value.absent(),
    this.lastReview = const Value.absent(),
    this.priority = const Value.absent(),
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.reviewCount = const Value.absent(),
  });
  FlashcardsTableCompanion.insert({
    this.id = const Value.absent(),
    required String front,
    required String back,
    this.note = const Value.absent(),
    this.nextReview = const Value.absent(),
    this.lastReview = const Value.absent(),
    this.priority = const Value.absent(),
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.reviewCount = const Value.absent(),
  })  : front = Value(front),
        back = Value(back);
  static Insertable<FlashcardsTableData> custom({
    Expression<int>? id,
    Expression<String>? front,
    Expression<String>? back,
    Expression<String>? note,
    Expression<DateTime>? nextReview,
    Expression<DateTime>? lastReview,
    Expression<int>? priority,
    Expression<double>? stability,
    Expression<double>? difficulty,
    Expression<int>? reviewCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (front != null) 'front': front,
      if (back != null) 'back': back,
      if (note != null) 'note': note,
      if (nextReview != null) 'next_review': nextReview,
      if (lastReview != null) 'last_review': lastReview,
      if (priority != null) 'priority': priority,
      if (stability != null) 'stability': stability,
      if (difficulty != null) 'difficulty': difficulty,
      if (reviewCount != null) 'review_count': reviewCount,
    });
  }

  FlashcardsTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? front,
      Value<String>? back,
      Value<String>? note,
      Value<DateTime>? nextReview,
      Value<DateTime>? lastReview,
      Value<int>? priority,
      Value<double>? stability,
      Value<double>? difficulty,
      Value<int>? reviewCount}) {
    return FlashcardsTableCompanion(
      id: id ?? this.id,
      front: front ?? this.front,
      back: back ?? this.back,
      note: note ?? this.note,
      nextReview: nextReview ?? this.nextReview,
      lastReview: lastReview ?? this.lastReview,
      priority: priority ?? this.priority,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (front.present) {
      map['front'] = Variable<String>(front.value);
    }
    if (back.present) {
      map['back'] = Variable<String>(back.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (nextReview.present) {
      map['next_review'] = Variable<DateTime>(nextReview.value);
    }
    if (lastReview.present) {
      map['last_review'] = Variable<DateTime>(lastReview.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (stability.present) {
      map['stability'] = Variable<double>(stability.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<double>(difficulty.value);
    }
    if (reviewCount.present) {
      map['review_count'] = Variable<int>(reviewCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FlashcardsTableCompanion(')
          ..write('id: $id, ')
          ..write('front: $front, ')
          ..write('back: $back, ')
          ..write('note: $note, ')
          ..write('nextReview: $nextReview, ')
          ..write('lastReview: $lastReview, ')
          ..write('priority: $priority, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('reviewCount: $reviewCount')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FlashcardsTableTable flashcardsTable =
      $FlashcardsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [flashcardsTable];
}

typedef $$FlashcardsTableTableCreateCompanionBuilder = FlashcardsTableCompanion
    Function({
  Value<int> id,
  required String front,
  required String back,
  Value<String> note,
  Value<DateTime> nextReview,
  Value<DateTime> lastReview,
  Value<int> priority,
  Value<double> stability,
  Value<double> difficulty,
  Value<int> reviewCount,
});
typedef $$FlashcardsTableTableUpdateCompanionBuilder = FlashcardsTableCompanion
    Function({
  Value<int> id,
  Value<String> front,
  Value<String> back,
  Value<String> note,
  Value<DateTime> nextReview,
  Value<DateTime> lastReview,
  Value<int> priority,
  Value<double> stability,
  Value<double> difficulty,
  Value<int> reviewCount,
});

class $$FlashcardsTableTableFilterComposer
    extends Composer<_$AppDatabase, $FlashcardsTableTable> {
  $$FlashcardsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get front => $composableBuilder(
      column: $table.front, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get back => $composableBuilder(
      column: $table.back, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextReview => $composableBuilder(
      column: $table.nextReview, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastReview => $composableBuilder(
      column: $table.lastReview, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get stability => $composableBuilder(
      column: $table.stability, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reviewCount => $composableBuilder(
      column: $table.reviewCount, builder: (column) => ColumnFilters(column));
}

class $$FlashcardsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $FlashcardsTableTable> {
  $$FlashcardsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get front => $composableBuilder(
      column: $table.front, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get back => $composableBuilder(
      column: $table.back, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextReview => $composableBuilder(
      column: $table.nextReview, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastReview => $composableBuilder(
      column: $table.lastReview, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get stability => $composableBuilder(
      column: $table.stability, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reviewCount => $composableBuilder(
      column: $table.reviewCount, builder: (column) => ColumnOrderings(column));
}

class $$FlashcardsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $FlashcardsTableTable> {
  $$FlashcardsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get front =>
      $composableBuilder(column: $table.front, builder: (column) => column);

  GeneratedColumn<String> get back =>
      $composableBuilder(column: $table.back, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get nextReview => $composableBuilder(
      column: $table.nextReview, builder: (column) => column);

  GeneratedColumn<DateTime> get lastReview => $composableBuilder(
      column: $table.lastReview, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<double> get stability =>
      $composableBuilder(column: $table.stability, builder: (column) => column);

  GeneratedColumn<double> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => column);

  GeneratedColumn<int> get reviewCount => $composableBuilder(
      column: $table.reviewCount, builder: (column) => column);
}

class $$FlashcardsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FlashcardsTableTable,
    FlashcardsTableData,
    $$FlashcardsTableTableFilterComposer,
    $$FlashcardsTableTableOrderingComposer,
    $$FlashcardsTableTableAnnotationComposer,
    $$FlashcardsTableTableCreateCompanionBuilder,
    $$FlashcardsTableTableUpdateCompanionBuilder,
    (
      FlashcardsTableData,
      BaseReferences<_$AppDatabase, $FlashcardsTableTable, FlashcardsTableData>
    ),
    FlashcardsTableData,
    PrefetchHooks Function()> {
  $$FlashcardsTableTableTableManager(
      _$AppDatabase db, $FlashcardsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FlashcardsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FlashcardsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FlashcardsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> front = const Value.absent(),
            Value<String> back = const Value.absent(),
            Value<String> note = const Value.absent(),
            Value<DateTime> nextReview = const Value.absent(),
            Value<DateTime> lastReview = const Value.absent(),
            Value<int> priority = const Value.absent(),
            Value<double> stability = const Value.absent(),
            Value<double> difficulty = const Value.absent(),
            Value<int> reviewCount = const Value.absent(),
          }) =>
              FlashcardsTableCompanion(
            id: id,
            front: front,
            back: back,
            note: note,
            nextReview: nextReview,
            lastReview: lastReview,
            priority: priority,
            stability: stability,
            difficulty: difficulty,
            reviewCount: reviewCount,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String front,
            required String back,
            Value<String> note = const Value.absent(),
            Value<DateTime> nextReview = const Value.absent(),
            Value<DateTime> lastReview = const Value.absent(),
            Value<int> priority = const Value.absent(),
            Value<double> stability = const Value.absent(),
            Value<double> difficulty = const Value.absent(),
            Value<int> reviewCount = const Value.absent(),
          }) =>
              FlashcardsTableCompanion.insert(
            id: id,
            front: front,
            back: back,
            note: note,
            nextReview: nextReview,
            lastReview: lastReview,
            priority: priority,
            stability: stability,
            difficulty: difficulty,
            reviewCount: reviewCount,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FlashcardsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FlashcardsTableTable,
    FlashcardsTableData,
    $$FlashcardsTableTableFilterComposer,
    $$FlashcardsTableTableOrderingComposer,
    $$FlashcardsTableTableAnnotationComposer,
    $$FlashcardsTableTableCreateCompanionBuilder,
    $$FlashcardsTableTableUpdateCompanionBuilder,
    (
      FlashcardsTableData,
      BaseReferences<_$AppDatabase, $FlashcardsTableTable, FlashcardsTableData>
    ),
    FlashcardsTableData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FlashcardsTableTableTableManager get flashcardsTable =>
      $$FlashcardsTableTableTableManager(_db, _db.flashcardsTable);
}
