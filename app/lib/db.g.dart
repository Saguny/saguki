// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db.dart';

// ignore_for_file: type=lint
class $DecksTable extends Decks with TableInfo<$DecksTable, Deck> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DecksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v7(),
  );
  static const VerificationMeta _modifiedAtMeta = const VerificationMeta(
    'modifiedAt',
  );
  @override
  late final GeneratedColumn<int> modifiedAt = GeneratedColumn<int>(
    'modified_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: nowMs,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ja'),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _newPerDayMeta = const VerificationMeta(
    'newPerDay',
  );
  @override
  late final GeneratedColumn<int> newPerDay = GeneratedColumn<int>(
    'new_per_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(20),
  );
  static const VerificationMeta _desiredRetentionMeta = const VerificationMeta(
    'desiredRetention',
  );
  @override
  late final GeneratedColumn<double> desiredRetention = GeneratedColumn<double>(
    'desired_retention',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.9),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    modifiedAt,
    deleted,
    dirty,
    name,
    language,
    description,
    newPerDay,
    desiredRetention,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'decks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Deck> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('modified_at')) {
      context.handle(
        _modifiedAtMeta,
        modifiedAt.isAcceptableOrUnknown(data['modified_at']!, _modifiedAtMeta),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
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
    }
    if (data.containsKey('new_per_day')) {
      context.handle(
        _newPerDayMeta,
        newPerDay.isAcceptableOrUnknown(data['new_per_day']!, _newPerDayMeta),
      );
    }
    if (data.containsKey('desired_retention')) {
      context.handle(
        _desiredRetentionMeta,
        desiredRetention.isAcceptableOrUnknown(
          data['desired_retention']!,
          _desiredRetentionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Deck map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Deck(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      modifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}modified_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      newPerDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}new_per_day'],
      )!,
      desiredRetention: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}desired_retention'],
      )!,
    );
  }

  @override
  $DecksTable createAlias(String alias) {
    return $DecksTable(attachedDatabase, alias);
  }
}

class Deck extends DataClass implements Insertable<Deck> {
  final String id;
  final int modifiedAt;
  final bool deleted;
  final bool dirty;
  final String name;
  final String language;
  final String description;
  final int newPerDay;
  final double desiredRetention;
  const Deck({
    required this.id,
    required this.modifiedAt,
    required this.deleted,
    required this.dirty,
    required this.name,
    required this.language,
    required this.description,
    required this.newPerDay,
    required this.desiredRetention,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['modified_at'] = Variable<int>(modifiedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['dirty'] = Variable<bool>(dirty);
    map['name'] = Variable<String>(name);
    map['language'] = Variable<String>(language);
    map['description'] = Variable<String>(description);
    map['new_per_day'] = Variable<int>(newPerDay);
    map['desired_retention'] = Variable<double>(desiredRetention);
    return map;
  }

  DecksCompanion toCompanion(bool nullToAbsent) {
    return DecksCompanion(
      id: Value(id),
      modifiedAt: Value(modifiedAt),
      deleted: Value(deleted),
      dirty: Value(dirty),
      name: Value(name),
      language: Value(language),
      description: Value(description),
      newPerDay: Value(newPerDay),
      desiredRetention: Value(desiredRetention),
    );
  }

  factory Deck.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Deck(
      id: serializer.fromJson<String>(json['id']),
      modifiedAt: serializer.fromJson<int>(json['modifiedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      name: serializer.fromJson<String>(json['name']),
      language: serializer.fromJson<String>(json['language']),
      description: serializer.fromJson<String>(json['description']),
      newPerDay: serializer.fromJson<int>(json['newPerDay']),
      desiredRetention: serializer.fromJson<double>(json['desiredRetention']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'modifiedAt': serializer.toJson<int>(modifiedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'dirty': serializer.toJson<bool>(dirty),
      'name': serializer.toJson<String>(name),
      'language': serializer.toJson<String>(language),
      'description': serializer.toJson<String>(description),
      'newPerDay': serializer.toJson<int>(newPerDay),
      'desiredRetention': serializer.toJson<double>(desiredRetention),
    };
  }

  Deck copyWith({
    String? id,
    int? modifiedAt,
    bool? deleted,
    bool? dirty,
    String? name,
    String? language,
    String? description,
    int? newPerDay,
    double? desiredRetention,
  }) => Deck(
    id: id ?? this.id,
    modifiedAt: modifiedAt ?? this.modifiedAt,
    deleted: deleted ?? this.deleted,
    dirty: dirty ?? this.dirty,
    name: name ?? this.name,
    language: language ?? this.language,
    description: description ?? this.description,
    newPerDay: newPerDay ?? this.newPerDay,
    desiredRetention: desiredRetention ?? this.desiredRetention,
  );
  Deck copyWithCompanion(DecksCompanion data) {
    return Deck(
      id: data.id.present ? data.id.value : this.id,
      modifiedAt: data.modifiedAt.present
          ? data.modifiedAt.value
          : this.modifiedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      name: data.name.present ? data.name.value : this.name,
      language: data.language.present ? data.language.value : this.language,
      description: data.description.present
          ? data.description.value
          : this.description,
      newPerDay: data.newPerDay.present ? data.newPerDay.value : this.newPerDay,
      desiredRetention: data.desiredRetention.present
          ? data.desiredRetention.value
          : this.desiredRetention,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Deck(')
          ..write('id: $id, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('deleted: $deleted, ')
          ..write('dirty: $dirty, ')
          ..write('name: $name, ')
          ..write('language: $language, ')
          ..write('description: $description, ')
          ..write('newPerDay: $newPerDay, ')
          ..write('desiredRetention: $desiredRetention')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    modifiedAt,
    deleted,
    dirty,
    name,
    language,
    description,
    newPerDay,
    desiredRetention,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Deck &&
          other.id == this.id &&
          other.modifiedAt == this.modifiedAt &&
          other.deleted == this.deleted &&
          other.dirty == this.dirty &&
          other.name == this.name &&
          other.language == this.language &&
          other.description == this.description &&
          other.newPerDay == this.newPerDay &&
          other.desiredRetention == this.desiredRetention);
}

class DecksCompanion extends UpdateCompanion<Deck> {
  final Value<String> id;
  final Value<int> modifiedAt;
  final Value<bool> deleted;
  final Value<bool> dirty;
  final Value<String> name;
  final Value<String> language;
  final Value<String> description;
  final Value<int> newPerDay;
  final Value<double> desiredRetention;
  final Value<int> rowid;
  const DecksCompanion({
    this.id = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.dirty = const Value.absent(),
    this.name = const Value.absent(),
    this.language = const Value.absent(),
    this.description = const Value.absent(),
    this.newPerDay = const Value.absent(),
    this.desiredRetention = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DecksCompanion.insert({
    this.id = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.dirty = const Value.absent(),
    required String name,
    this.language = const Value.absent(),
    this.description = const Value.absent(),
    this.newPerDay = const Value.absent(),
    this.desiredRetention = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Deck> custom({
    Expression<String>? id,
    Expression<int>? modifiedAt,
    Expression<bool>? deleted,
    Expression<bool>? dirty,
    Expression<String>? name,
    Expression<String>? language,
    Expression<String>? description,
    Expression<int>? newPerDay,
    Expression<double>? desiredRetention,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (modifiedAt != null) 'modified_at': modifiedAt,
      if (deleted != null) 'deleted': deleted,
      if (dirty != null) 'dirty': dirty,
      if (name != null) 'name': name,
      if (language != null) 'language': language,
      if (description != null) 'description': description,
      if (newPerDay != null) 'new_per_day': newPerDay,
      if (desiredRetention != null) 'desired_retention': desiredRetention,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DecksCompanion copyWith({
    Value<String>? id,
    Value<int>? modifiedAt,
    Value<bool>? deleted,
    Value<bool>? dirty,
    Value<String>? name,
    Value<String>? language,
    Value<String>? description,
    Value<int>? newPerDay,
    Value<double>? desiredRetention,
    Value<int>? rowid,
  }) {
    return DecksCompanion(
      id: id ?? this.id,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      deleted: deleted ?? this.deleted,
      dirty: dirty ?? this.dirty,
      name: name ?? this.name,
      language: language ?? this.language,
      description: description ?? this.description,
      newPerDay: newPerDay ?? this.newPerDay,
      desiredRetention: desiredRetention ?? this.desiredRetention,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (modifiedAt.present) {
      map['modified_at'] = Variable<int>(modifiedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (newPerDay.present) {
      map['new_per_day'] = Variable<int>(newPerDay.value);
    }
    if (desiredRetention.present) {
      map['desired_retention'] = Variable<double>(desiredRetention.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DecksCompanion(')
          ..write('id: $id, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('deleted: $deleted, ')
          ..write('dirty: $dirty, ')
          ..write('name: $name, ')
          ..write('language: $language, ')
          ..write('description: $description, ')
          ..write('newPerDay: $newPerDay, ')
          ..write('desiredRetention: $desiredRetention, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotesTable extends Notes with TableInfo<$NotesTable, Note> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v7(),
  );
  static const VerificationMeta _modifiedAtMeta = const VerificationMeta(
    'modifiedAt',
  );
  @override
  late final GeneratedColumn<int> modifiedAt = GeneratedColumn<int>(
    'modified_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: nowMs,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _deckIdMeta = const VerificationMeta('deckId');
  @override
  late final GeneratedColumn<String> deckId = GeneratedColumn<String>(
    'deck_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES decks (id)',
    ),
  );
  static const VerificationMeta _termMeta = const VerificationMeta('term');
  @override
  late final GeneratedColumn<String> term = GeneratedColumn<String>(
    'term',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pronunciationMeta = const VerificationMeta(
    'pronunciation',
  );
  @override
  late final GeneratedColumn<String> pronunciation = GeneratedColumn<String>(
    'pronunciation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _meaningMeta = const VerificationMeta(
    'meaning',
  );
  @override
  late final GeneratedColumn<String> meaning = GeneratedColumn<String>(
    'meaning',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _explanationMeta = const VerificationMeta(
    'explanation',
  );
  @override
  late final GeneratedColumn<String> explanation = GeneratedColumn<String>(
    'explanation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _exampleMeta = const VerificationMeta(
    'example',
  );
  @override
  late final GeneratedColumn<String> example = GeneratedColumn<String>(
    'example',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _exampleTranslationMeta =
      const VerificationMeta('exampleTranslation');
  @override
  late final GeneratedColumn<String> exampleTranslation =
      GeneratedColumn<String>(
        'example_translation',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    modifiedAt,
    deleted,
    dirty,
    deckId,
    term,
    pronunciation,
    meaning,
    explanation,
    example,
    exampleTranslation,
    tags,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Note> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('modified_at')) {
      context.handle(
        _modifiedAtMeta,
        modifiedAt.isAcceptableOrUnknown(data['modified_at']!, _modifiedAtMeta),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('deck_id')) {
      context.handle(
        _deckIdMeta,
        deckId.isAcceptableOrUnknown(data['deck_id']!, _deckIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deckIdMeta);
    }
    if (data.containsKey('term')) {
      context.handle(
        _termMeta,
        term.isAcceptableOrUnknown(data['term']!, _termMeta),
      );
    } else if (isInserting) {
      context.missing(_termMeta);
    }
    if (data.containsKey('pronunciation')) {
      context.handle(
        _pronunciationMeta,
        pronunciation.isAcceptableOrUnknown(
          data['pronunciation']!,
          _pronunciationMeta,
        ),
      );
    }
    if (data.containsKey('meaning')) {
      context.handle(
        _meaningMeta,
        meaning.isAcceptableOrUnknown(data['meaning']!, _meaningMeta),
      );
    }
    if (data.containsKey('explanation')) {
      context.handle(
        _explanationMeta,
        explanation.isAcceptableOrUnknown(
          data['explanation']!,
          _explanationMeta,
        ),
      );
    }
    if (data.containsKey('example')) {
      context.handle(
        _exampleMeta,
        example.isAcceptableOrUnknown(data['example']!, _exampleMeta),
      );
    }
    if (data.containsKey('example_translation')) {
      context.handle(
        _exampleTranslationMeta,
        exampleTranslation.isAcceptableOrUnknown(
          data['example_translation']!,
          _exampleTranslationMeta,
        ),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Note map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Note(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      modifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}modified_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      deckId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deck_id'],
      )!,
      term: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}term'],
      )!,
      pronunciation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pronunciation'],
      )!,
      meaning: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning'],
      )!,
      explanation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}explanation'],
      )!,
      example: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}example'],
      )!,
      exampleTranslation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}example_translation'],
      )!,
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      )!,
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }
}

class Note extends DataClass implements Insertable<Note> {
  final String id;
  final int modifiedAt;
  final bool deleted;
  final bool dirty;
  final String deckId;
  final String term;
  final String pronunciation;
  final String meaning;
  final String explanation;
  final String example;
  final String exampleTranslation;
  final String tags;
  const Note({
    required this.id,
    required this.modifiedAt,
    required this.deleted,
    required this.dirty,
    required this.deckId,
    required this.term,
    required this.pronunciation,
    required this.meaning,
    required this.explanation,
    required this.example,
    required this.exampleTranslation,
    required this.tags,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['modified_at'] = Variable<int>(modifiedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['dirty'] = Variable<bool>(dirty);
    map['deck_id'] = Variable<String>(deckId);
    map['term'] = Variable<String>(term);
    map['pronunciation'] = Variable<String>(pronunciation);
    map['meaning'] = Variable<String>(meaning);
    map['explanation'] = Variable<String>(explanation);
    map['example'] = Variable<String>(example);
    map['example_translation'] = Variable<String>(exampleTranslation);
    map['tags'] = Variable<String>(tags);
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      id: Value(id),
      modifiedAt: Value(modifiedAt),
      deleted: Value(deleted),
      dirty: Value(dirty),
      deckId: Value(deckId),
      term: Value(term),
      pronunciation: Value(pronunciation),
      meaning: Value(meaning),
      explanation: Value(explanation),
      example: Value(example),
      exampleTranslation: Value(exampleTranslation),
      tags: Value(tags),
    );
  }

  factory Note.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Note(
      id: serializer.fromJson<String>(json['id']),
      modifiedAt: serializer.fromJson<int>(json['modifiedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      deckId: serializer.fromJson<String>(json['deckId']),
      term: serializer.fromJson<String>(json['term']),
      pronunciation: serializer.fromJson<String>(json['pronunciation']),
      meaning: serializer.fromJson<String>(json['meaning']),
      explanation: serializer.fromJson<String>(json['explanation']),
      example: serializer.fromJson<String>(json['example']),
      exampleTranslation: serializer.fromJson<String>(
        json['exampleTranslation'],
      ),
      tags: serializer.fromJson<String>(json['tags']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'modifiedAt': serializer.toJson<int>(modifiedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'dirty': serializer.toJson<bool>(dirty),
      'deckId': serializer.toJson<String>(deckId),
      'term': serializer.toJson<String>(term),
      'pronunciation': serializer.toJson<String>(pronunciation),
      'meaning': serializer.toJson<String>(meaning),
      'explanation': serializer.toJson<String>(explanation),
      'example': serializer.toJson<String>(example),
      'exampleTranslation': serializer.toJson<String>(exampleTranslation),
      'tags': serializer.toJson<String>(tags),
    };
  }

  Note copyWith({
    String? id,
    int? modifiedAt,
    bool? deleted,
    bool? dirty,
    String? deckId,
    String? term,
    String? pronunciation,
    String? meaning,
    String? explanation,
    String? example,
    String? exampleTranslation,
    String? tags,
  }) => Note(
    id: id ?? this.id,
    modifiedAt: modifiedAt ?? this.modifiedAt,
    deleted: deleted ?? this.deleted,
    dirty: dirty ?? this.dirty,
    deckId: deckId ?? this.deckId,
    term: term ?? this.term,
    pronunciation: pronunciation ?? this.pronunciation,
    meaning: meaning ?? this.meaning,
    explanation: explanation ?? this.explanation,
    example: example ?? this.example,
    exampleTranslation: exampleTranslation ?? this.exampleTranslation,
    tags: tags ?? this.tags,
  );
  Note copyWithCompanion(NotesCompanion data) {
    return Note(
      id: data.id.present ? data.id.value : this.id,
      modifiedAt: data.modifiedAt.present
          ? data.modifiedAt.value
          : this.modifiedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      deckId: data.deckId.present ? data.deckId.value : this.deckId,
      term: data.term.present ? data.term.value : this.term,
      pronunciation: data.pronunciation.present
          ? data.pronunciation.value
          : this.pronunciation,
      meaning: data.meaning.present ? data.meaning.value : this.meaning,
      explanation: data.explanation.present
          ? data.explanation.value
          : this.explanation,
      example: data.example.present ? data.example.value : this.example,
      exampleTranslation: data.exampleTranslation.present
          ? data.exampleTranslation.value
          : this.exampleTranslation,
      tags: data.tags.present ? data.tags.value : this.tags,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Note(')
          ..write('id: $id, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('deleted: $deleted, ')
          ..write('dirty: $dirty, ')
          ..write('deckId: $deckId, ')
          ..write('term: $term, ')
          ..write('pronunciation: $pronunciation, ')
          ..write('meaning: $meaning, ')
          ..write('explanation: $explanation, ')
          ..write('example: $example, ')
          ..write('exampleTranslation: $exampleTranslation, ')
          ..write('tags: $tags')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    modifiedAt,
    deleted,
    dirty,
    deckId,
    term,
    pronunciation,
    meaning,
    explanation,
    example,
    exampleTranslation,
    tags,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Note &&
          other.id == this.id &&
          other.modifiedAt == this.modifiedAt &&
          other.deleted == this.deleted &&
          other.dirty == this.dirty &&
          other.deckId == this.deckId &&
          other.term == this.term &&
          other.pronunciation == this.pronunciation &&
          other.meaning == this.meaning &&
          other.explanation == this.explanation &&
          other.example == this.example &&
          other.exampleTranslation == this.exampleTranslation &&
          other.tags == this.tags);
}

class NotesCompanion extends UpdateCompanion<Note> {
  final Value<String> id;
  final Value<int> modifiedAt;
  final Value<bool> deleted;
  final Value<bool> dirty;
  final Value<String> deckId;
  final Value<String> term;
  final Value<String> pronunciation;
  final Value<String> meaning;
  final Value<String> explanation;
  final Value<String> example;
  final Value<String> exampleTranslation;
  final Value<String> tags;
  final Value<int> rowid;
  const NotesCompanion({
    this.id = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.dirty = const Value.absent(),
    this.deckId = const Value.absent(),
    this.term = const Value.absent(),
    this.pronunciation = const Value.absent(),
    this.meaning = const Value.absent(),
    this.explanation = const Value.absent(),
    this.example = const Value.absent(),
    this.exampleTranslation = const Value.absent(),
    this.tags = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotesCompanion.insert({
    this.id = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.dirty = const Value.absent(),
    required String deckId,
    required String term,
    this.pronunciation = const Value.absent(),
    this.meaning = const Value.absent(),
    this.explanation = const Value.absent(),
    this.example = const Value.absent(),
    this.exampleTranslation = const Value.absent(),
    this.tags = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : deckId = Value(deckId),
       term = Value(term);
  static Insertable<Note> custom({
    Expression<String>? id,
    Expression<int>? modifiedAt,
    Expression<bool>? deleted,
    Expression<bool>? dirty,
    Expression<String>? deckId,
    Expression<String>? term,
    Expression<String>? pronunciation,
    Expression<String>? meaning,
    Expression<String>? explanation,
    Expression<String>? example,
    Expression<String>? exampleTranslation,
    Expression<String>? tags,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (modifiedAt != null) 'modified_at': modifiedAt,
      if (deleted != null) 'deleted': deleted,
      if (dirty != null) 'dirty': dirty,
      if (deckId != null) 'deck_id': deckId,
      if (term != null) 'term': term,
      if (pronunciation != null) 'pronunciation': pronunciation,
      if (meaning != null) 'meaning': meaning,
      if (explanation != null) 'explanation': explanation,
      if (example != null) 'example': example,
      if (exampleTranslation != null) 'example_translation': exampleTranslation,
      if (tags != null) 'tags': tags,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotesCompanion copyWith({
    Value<String>? id,
    Value<int>? modifiedAt,
    Value<bool>? deleted,
    Value<bool>? dirty,
    Value<String>? deckId,
    Value<String>? term,
    Value<String>? pronunciation,
    Value<String>? meaning,
    Value<String>? explanation,
    Value<String>? example,
    Value<String>? exampleTranslation,
    Value<String>? tags,
    Value<int>? rowid,
  }) {
    return NotesCompanion(
      id: id ?? this.id,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      deleted: deleted ?? this.deleted,
      dirty: dirty ?? this.dirty,
      deckId: deckId ?? this.deckId,
      term: term ?? this.term,
      pronunciation: pronunciation ?? this.pronunciation,
      meaning: meaning ?? this.meaning,
      explanation: explanation ?? this.explanation,
      example: example ?? this.example,
      exampleTranslation: exampleTranslation ?? this.exampleTranslation,
      tags: tags ?? this.tags,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (modifiedAt.present) {
      map['modified_at'] = Variable<int>(modifiedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (deckId.present) {
      map['deck_id'] = Variable<String>(deckId.value);
    }
    if (term.present) {
      map['term'] = Variable<String>(term.value);
    }
    if (pronunciation.present) {
      map['pronunciation'] = Variable<String>(pronunciation.value);
    }
    if (meaning.present) {
      map['meaning'] = Variable<String>(meaning.value);
    }
    if (explanation.present) {
      map['explanation'] = Variable<String>(explanation.value);
    }
    if (example.present) {
      map['example'] = Variable<String>(example.value);
    }
    if (exampleTranslation.present) {
      map['example_translation'] = Variable<String>(exampleTranslation.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesCompanion(')
          ..write('id: $id, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('deleted: $deleted, ')
          ..write('dirty: $dirty, ')
          ..write('deckId: $deckId, ')
          ..write('term: $term, ')
          ..write('pronunciation: $pronunciation, ')
          ..write('meaning: $meaning, ')
          ..write('explanation: $explanation, ')
          ..write('example: $example, ')
          ..write('exampleTranslation: $exampleTranslation, ')
          ..write('tags: $tags, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CardsTable extends Cards with TableInfo<$CardsTable, Card> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v7(),
  );
  static const VerificationMeta _modifiedAtMeta = const VerificationMeta(
    'modifiedAt',
  );
  @override
  late final GeneratedColumn<int> modifiedAt = GeneratedColumn<int>(
    'modified_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: nowMs,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _noteIdMeta = const VerificationMeta('noteId');
  @override
  late final GeneratedColumn<String> noteId = GeneratedColumn<String>(
    'note_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES notes (id)',
    ),
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('fwd'),
  );
  static const VerificationMeta _dueMeta = const VerificationMeta('due');
  @override
  late final GeneratedColumn<DateTime> due = GeneratedColumn<DateTime>(
    'due',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<int> state = GeneratedColumn<int>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _stepMeta = const VerificationMeta('step');
  @override
  late final GeneratedColumn<int> step = GeneratedColumn<int>(
    'step',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stabilityMeta = const VerificationMeta(
    'stability',
  );
  @override
  late final GeneratedColumn<double> stability = GeneratedColumn<double>(
    'stability',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<double> difficulty = GeneratedColumn<double>(
    'difficulty',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lapsesMeta = const VerificationMeta('lapses');
  @override
  late final GeneratedColumn<int> lapses = GeneratedColumn<int>(
    'lapses',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastReviewMeta = const VerificationMeta(
    'lastReview',
  );
  @override
  late final GeneratedColumn<DateTime> lastReview = GeneratedColumn<DateTime>(
    'last_review',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    modifiedAt,
    deleted,
    dirty,
    noteId,
    direction,
    due,
    state,
    step,
    stability,
    difficulty,
    reps,
    lapses,
    lastReview,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<Card> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('modified_at')) {
      context.handle(
        _modifiedAtMeta,
        modifiedAt.isAcceptableOrUnknown(data['modified_at']!, _modifiedAtMeta),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('note_id')) {
      context.handle(
        _noteIdMeta,
        noteId.isAcceptableOrUnknown(data['note_id']!, _noteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_noteIdMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    }
    if (data.containsKey('due')) {
      context.handle(
        _dueMeta,
        due.isAcceptableOrUnknown(data['due']!, _dueMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('step')) {
      context.handle(
        _stepMeta,
        step.isAcceptableOrUnknown(data['step']!, _stepMeta),
      );
    }
    if (data.containsKey('stability')) {
      context.handle(
        _stabilityMeta,
        stability.isAcceptableOrUnknown(data['stability']!, _stabilityMeta),
      );
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    }
    if (data.containsKey('lapses')) {
      context.handle(
        _lapsesMeta,
        lapses.isAcceptableOrUnknown(data['lapses']!, _lapsesMeta),
      );
    }
    if (data.containsKey('last_review')) {
      context.handle(
        _lastReviewMeta,
        lastReview.isAcceptableOrUnknown(data['last_review']!, _lastReviewMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Card map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Card(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      modifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}modified_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      noteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_id'],
      )!,
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      )!,
      due: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}state'],
      )!,
      step: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}step'],
      ),
      stability: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stability'],
      ),
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}difficulty'],
      ),
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      )!,
      lapses: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lapses'],
      )!,
      lastReview: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_review'],
      ),
    );
  }

  @override
  $CardsTable createAlias(String alias) {
    return $CardsTable(attachedDatabase, alias);
  }
}

class Card extends DataClass implements Insertable<Card> {
  final String id;
  final int modifiedAt;
  final bool deleted;
  final bool dirty;
  final String noteId;
  final String direction;
  final DateTime due;
  final int state;
  final int? step;
  final double? stability;
  final double? difficulty;
  final int reps;
  final int lapses;
  final DateTime? lastReview;
  const Card({
    required this.id,
    required this.modifiedAt,
    required this.deleted,
    required this.dirty,
    required this.noteId,
    required this.direction,
    required this.due,
    required this.state,
    this.step,
    this.stability,
    this.difficulty,
    required this.reps,
    required this.lapses,
    this.lastReview,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['modified_at'] = Variable<int>(modifiedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['dirty'] = Variable<bool>(dirty);
    map['note_id'] = Variable<String>(noteId);
    map['direction'] = Variable<String>(direction);
    map['due'] = Variable<DateTime>(due);
    map['state'] = Variable<int>(state);
    if (!nullToAbsent || step != null) {
      map['step'] = Variable<int>(step);
    }
    if (!nullToAbsent || stability != null) {
      map['stability'] = Variable<double>(stability);
    }
    if (!nullToAbsent || difficulty != null) {
      map['difficulty'] = Variable<double>(difficulty);
    }
    map['reps'] = Variable<int>(reps);
    map['lapses'] = Variable<int>(lapses);
    if (!nullToAbsent || lastReview != null) {
      map['last_review'] = Variable<DateTime>(lastReview);
    }
    return map;
  }

  CardsCompanion toCompanion(bool nullToAbsent) {
    return CardsCompanion(
      id: Value(id),
      modifiedAt: Value(modifiedAt),
      deleted: Value(deleted),
      dirty: Value(dirty),
      noteId: Value(noteId),
      direction: Value(direction),
      due: Value(due),
      state: Value(state),
      step: step == null && nullToAbsent ? const Value.absent() : Value(step),
      stability: stability == null && nullToAbsent
          ? const Value.absent()
          : Value(stability),
      difficulty: difficulty == null && nullToAbsent
          ? const Value.absent()
          : Value(difficulty),
      reps: Value(reps),
      lapses: Value(lapses),
      lastReview: lastReview == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReview),
    );
  }

  factory Card.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Card(
      id: serializer.fromJson<String>(json['id']),
      modifiedAt: serializer.fromJson<int>(json['modifiedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      noteId: serializer.fromJson<String>(json['noteId']),
      direction: serializer.fromJson<String>(json['direction']),
      due: serializer.fromJson<DateTime>(json['due']),
      state: serializer.fromJson<int>(json['state']),
      step: serializer.fromJson<int?>(json['step']),
      stability: serializer.fromJson<double?>(json['stability']),
      difficulty: serializer.fromJson<double?>(json['difficulty']),
      reps: serializer.fromJson<int>(json['reps']),
      lapses: serializer.fromJson<int>(json['lapses']),
      lastReview: serializer.fromJson<DateTime?>(json['lastReview']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'modifiedAt': serializer.toJson<int>(modifiedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'dirty': serializer.toJson<bool>(dirty),
      'noteId': serializer.toJson<String>(noteId),
      'direction': serializer.toJson<String>(direction),
      'due': serializer.toJson<DateTime>(due),
      'state': serializer.toJson<int>(state),
      'step': serializer.toJson<int?>(step),
      'stability': serializer.toJson<double?>(stability),
      'difficulty': serializer.toJson<double?>(difficulty),
      'reps': serializer.toJson<int>(reps),
      'lapses': serializer.toJson<int>(lapses),
      'lastReview': serializer.toJson<DateTime?>(lastReview),
    };
  }

  Card copyWith({
    String? id,
    int? modifiedAt,
    bool? deleted,
    bool? dirty,
    String? noteId,
    String? direction,
    DateTime? due,
    int? state,
    Value<int?> step = const Value.absent(),
    Value<double?> stability = const Value.absent(),
    Value<double?> difficulty = const Value.absent(),
    int? reps,
    int? lapses,
    Value<DateTime?> lastReview = const Value.absent(),
  }) => Card(
    id: id ?? this.id,
    modifiedAt: modifiedAt ?? this.modifiedAt,
    deleted: deleted ?? this.deleted,
    dirty: dirty ?? this.dirty,
    noteId: noteId ?? this.noteId,
    direction: direction ?? this.direction,
    due: due ?? this.due,
    state: state ?? this.state,
    step: step.present ? step.value : this.step,
    stability: stability.present ? stability.value : this.stability,
    difficulty: difficulty.present ? difficulty.value : this.difficulty,
    reps: reps ?? this.reps,
    lapses: lapses ?? this.lapses,
    lastReview: lastReview.present ? lastReview.value : this.lastReview,
  );
  Card copyWithCompanion(CardsCompanion data) {
    return Card(
      id: data.id.present ? data.id.value : this.id,
      modifiedAt: data.modifiedAt.present
          ? data.modifiedAt.value
          : this.modifiedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      noteId: data.noteId.present ? data.noteId.value : this.noteId,
      direction: data.direction.present ? data.direction.value : this.direction,
      due: data.due.present ? data.due.value : this.due,
      state: data.state.present ? data.state.value : this.state,
      step: data.step.present ? data.step.value : this.step,
      stability: data.stability.present ? data.stability.value : this.stability,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      reps: data.reps.present ? data.reps.value : this.reps,
      lapses: data.lapses.present ? data.lapses.value : this.lapses,
      lastReview: data.lastReview.present
          ? data.lastReview.value
          : this.lastReview,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Card(')
          ..write('id: $id, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('deleted: $deleted, ')
          ..write('dirty: $dirty, ')
          ..write('noteId: $noteId, ')
          ..write('direction: $direction, ')
          ..write('due: $due, ')
          ..write('state: $state, ')
          ..write('step: $step, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('reps: $reps, ')
          ..write('lapses: $lapses, ')
          ..write('lastReview: $lastReview')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    modifiedAt,
    deleted,
    dirty,
    noteId,
    direction,
    due,
    state,
    step,
    stability,
    difficulty,
    reps,
    lapses,
    lastReview,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Card &&
          other.id == this.id &&
          other.modifiedAt == this.modifiedAt &&
          other.deleted == this.deleted &&
          other.dirty == this.dirty &&
          other.noteId == this.noteId &&
          other.direction == this.direction &&
          other.due == this.due &&
          other.state == this.state &&
          other.step == this.step &&
          other.stability == this.stability &&
          other.difficulty == this.difficulty &&
          other.reps == this.reps &&
          other.lapses == this.lapses &&
          other.lastReview == this.lastReview);
}

class CardsCompanion extends UpdateCompanion<Card> {
  final Value<String> id;
  final Value<int> modifiedAt;
  final Value<bool> deleted;
  final Value<bool> dirty;
  final Value<String> noteId;
  final Value<String> direction;
  final Value<DateTime> due;
  final Value<int> state;
  final Value<int?> step;
  final Value<double?> stability;
  final Value<double?> difficulty;
  final Value<int> reps;
  final Value<int> lapses;
  final Value<DateTime?> lastReview;
  final Value<int> rowid;
  const CardsCompanion({
    this.id = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.dirty = const Value.absent(),
    this.noteId = const Value.absent(),
    this.direction = const Value.absent(),
    this.due = const Value.absent(),
    this.state = const Value.absent(),
    this.step = const Value.absent(),
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.reps = const Value.absent(),
    this.lapses = const Value.absent(),
    this.lastReview = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardsCompanion.insert({
    this.id = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.dirty = const Value.absent(),
    required String noteId,
    this.direction = const Value.absent(),
    this.due = const Value.absent(),
    this.state = const Value.absent(),
    this.step = const Value.absent(),
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.reps = const Value.absent(),
    this.lapses = const Value.absent(),
    this.lastReview = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : noteId = Value(noteId);
  static Insertable<Card> custom({
    Expression<String>? id,
    Expression<int>? modifiedAt,
    Expression<bool>? deleted,
    Expression<bool>? dirty,
    Expression<String>? noteId,
    Expression<String>? direction,
    Expression<DateTime>? due,
    Expression<int>? state,
    Expression<int>? step,
    Expression<double>? stability,
    Expression<double>? difficulty,
    Expression<int>? reps,
    Expression<int>? lapses,
    Expression<DateTime>? lastReview,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (modifiedAt != null) 'modified_at': modifiedAt,
      if (deleted != null) 'deleted': deleted,
      if (dirty != null) 'dirty': dirty,
      if (noteId != null) 'note_id': noteId,
      if (direction != null) 'direction': direction,
      if (due != null) 'due': due,
      if (state != null) 'state': state,
      if (step != null) 'step': step,
      if (stability != null) 'stability': stability,
      if (difficulty != null) 'difficulty': difficulty,
      if (reps != null) 'reps': reps,
      if (lapses != null) 'lapses': lapses,
      if (lastReview != null) 'last_review': lastReview,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardsCompanion copyWith({
    Value<String>? id,
    Value<int>? modifiedAt,
    Value<bool>? deleted,
    Value<bool>? dirty,
    Value<String>? noteId,
    Value<String>? direction,
    Value<DateTime>? due,
    Value<int>? state,
    Value<int?>? step,
    Value<double?>? stability,
    Value<double?>? difficulty,
    Value<int>? reps,
    Value<int>? lapses,
    Value<DateTime?>? lastReview,
    Value<int>? rowid,
  }) {
    return CardsCompanion(
      id: id ?? this.id,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      deleted: deleted ?? this.deleted,
      dirty: dirty ?? this.dirty,
      noteId: noteId ?? this.noteId,
      direction: direction ?? this.direction,
      due: due ?? this.due,
      state: state ?? this.state,
      step: step ?? this.step,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      reps: reps ?? this.reps,
      lapses: lapses ?? this.lapses,
      lastReview: lastReview ?? this.lastReview,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (modifiedAt.present) {
      map['modified_at'] = Variable<int>(modifiedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (noteId.present) {
      map['note_id'] = Variable<String>(noteId.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (due.present) {
      map['due'] = Variable<DateTime>(due.value);
    }
    if (state.present) {
      map['state'] = Variable<int>(state.value);
    }
    if (step.present) {
      map['step'] = Variable<int>(step.value);
    }
    if (stability.present) {
      map['stability'] = Variable<double>(stability.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<double>(difficulty.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (lapses.present) {
      map['lapses'] = Variable<int>(lapses.value);
    }
    if (lastReview.present) {
      map['last_review'] = Variable<DateTime>(lastReview.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardsCompanion(')
          ..write('id: $id, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('deleted: $deleted, ')
          ..write('dirty: $dirty, ')
          ..write('noteId: $noteId, ')
          ..write('direction: $direction, ')
          ..write('due: $due, ')
          ..write('state: $state, ')
          ..write('step: $step, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('reps: $reps, ')
          ..write('lapses: $lapses, ')
          ..write('lastReview: $lastReview, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReviewLogsTable extends ReviewLogs
    with TableInfo<$ReviewLogsTable, ReviewLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v7(),
  );
  static const VerificationMeta _modifiedAtMeta = const VerificationMeta(
    'modifiedAt',
  );
  @override
  late final GeneratedColumn<int> modifiedAt = GeneratedColumn<int>(
    'modified_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cards (id)',
    ),
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reviewedAtMeta = const VerificationMeta(
    'reviewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> reviewedAt = GeneratedColumn<DateTime>(
    'reviewed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wasNewMeta = const VerificationMeta('wasNew');
  @override
  late final GeneratedColumn<bool> wasNew = GeneratedColumn<bool>(
    'was_new',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("was_new" IN (0, 1))',
    ),
  );
  static const VerificationMeta _thinkMsMeta = const VerificationMeta(
    'thinkMs',
  );
  @override
  late final GeneratedColumn<int> thinkMs = GeneratedColumn<int>(
    'think_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    modifiedAt,
    deleted,
    cardId,
    rating,
    reviewedAt,
    durationMs,
    wasNew,
    thinkMs,
    dirty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'review_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReviewLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('modified_at')) {
      context.handle(
        _modifiedAtMeta,
        modifiedAt.isAcceptableOrUnknown(data['modified_at']!, _modifiedAtMeta),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    } else if (isInserting) {
      context.missing(_ratingMeta);
    }
    if (data.containsKey('reviewed_at')) {
      context.handle(
        _reviewedAtMeta,
        reviewedAt.isAcceptableOrUnknown(data['reviewed_at']!, _reviewedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_reviewedAtMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('was_new')) {
      context.handle(
        _wasNewMeta,
        wasNew.isAcceptableOrUnknown(data['was_new']!, _wasNewMeta),
      );
    } else if (isInserting) {
      context.missing(_wasNewMeta);
    }
    if (data.containsKey('think_ms')) {
      context.handle(
        _thinkMsMeta,
        thinkMs.isAcceptableOrUnknown(data['think_ms']!, _thinkMsMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReviewLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      modifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}modified_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_id'],
      )!,
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      )!,
      reviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reviewed_at'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      wasNew: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}was_new'],
      )!,
      thinkMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}think_ms'],
      ),
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
    );
  }

  @override
  $ReviewLogsTable createAlias(String alias) {
    return $ReviewLogsTable(attachedDatabase, alias);
  }
}

class ReviewLog extends DataClass implements Insertable<ReviewLog> {
  final String id;
  final int modifiedAt;
  final bool deleted;
  final String cardId;
  final int rating;
  final DateTime reviewedAt;
  final int durationMs;
  final bool wasNew;
  final int? thinkMs;
  final bool dirty;
  const ReviewLog({
    required this.id,
    required this.modifiedAt,
    required this.deleted,
    required this.cardId,
    required this.rating,
    required this.reviewedAt,
    required this.durationMs,
    required this.wasNew,
    this.thinkMs,
    required this.dirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['modified_at'] = Variable<int>(modifiedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['card_id'] = Variable<String>(cardId);
    map['rating'] = Variable<int>(rating);
    map['reviewed_at'] = Variable<DateTime>(reviewedAt);
    map['duration_ms'] = Variable<int>(durationMs);
    map['was_new'] = Variable<bool>(wasNew);
    if (!nullToAbsent || thinkMs != null) {
      map['think_ms'] = Variable<int>(thinkMs);
    }
    map['dirty'] = Variable<bool>(dirty);
    return map;
  }

  ReviewLogsCompanion toCompanion(bool nullToAbsent) {
    return ReviewLogsCompanion(
      id: Value(id),
      modifiedAt: Value(modifiedAt),
      deleted: Value(deleted),
      cardId: Value(cardId),
      rating: Value(rating),
      reviewedAt: Value(reviewedAt),
      durationMs: Value(durationMs),
      wasNew: Value(wasNew),
      thinkMs: thinkMs == null && nullToAbsent
          ? const Value.absent()
          : Value(thinkMs),
      dirty: Value(dirty),
    );
  }

  factory ReviewLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReviewLog(
      id: serializer.fromJson<String>(json['id']),
      modifiedAt: serializer.fromJson<int>(json['modifiedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      cardId: serializer.fromJson<String>(json['cardId']),
      rating: serializer.fromJson<int>(json['rating']),
      reviewedAt: serializer.fromJson<DateTime>(json['reviewedAt']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      wasNew: serializer.fromJson<bool>(json['wasNew']),
      thinkMs: serializer.fromJson<int?>(json['thinkMs']),
      dirty: serializer.fromJson<bool>(json['dirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'modifiedAt': serializer.toJson<int>(modifiedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'cardId': serializer.toJson<String>(cardId),
      'rating': serializer.toJson<int>(rating),
      'reviewedAt': serializer.toJson<DateTime>(reviewedAt),
      'durationMs': serializer.toJson<int>(durationMs),
      'wasNew': serializer.toJson<bool>(wasNew),
      'thinkMs': serializer.toJson<int?>(thinkMs),
      'dirty': serializer.toJson<bool>(dirty),
    };
  }

  ReviewLog copyWith({
    String? id,
    int? modifiedAt,
    bool? deleted,
    String? cardId,
    int? rating,
    DateTime? reviewedAt,
    int? durationMs,
    bool? wasNew,
    Value<int?> thinkMs = const Value.absent(),
    bool? dirty,
  }) => ReviewLog(
    id: id ?? this.id,
    modifiedAt: modifiedAt ?? this.modifiedAt,
    deleted: deleted ?? this.deleted,
    cardId: cardId ?? this.cardId,
    rating: rating ?? this.rating,
    reviewedAt: reviewedAt ?? this.reviewedAt,
    durationMs: durationMs ?? this.durationMs,
    wasNew: wasNew ?? this.wasNew,
    thinkMs: thinkMs.present ? thinkMs.value : this.thinkMs,
    dirty: dirty ?? this.dirty,
  );
  ReviewLog copyWithCompanion(ReviewLogsCompanion data) {
    return ReviewLog(
      id: data.id.present ? data.id.value : this.id,
      modifiedAt: data.modifiedAt.present
          ? data.modifiedAt.value
          : this.modifiedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      rating: data.rating.present ? data.rating.value : this.rating,
      reviewedAt: data.reviewedAt.present
          ? data.reviewedAt.value
          : this.reviewedAt,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      wasNew: data.wasNew.present ? data.wasNew.value : this.wasNew,
      thinkMs: data.thinkMs.present ? data.thinkMs.value : this.thinkMs,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewLog(')
          ..write('id: $id, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('deleted: $deleted, ')
          ..write('cardId: $cardId, ')
          ..write('rating: $rating, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('durationMs: $durationMs, ')
          ..write('wasNew: $wasNew, ')
          ..write('thinkMs: $thinkMs, ')
          ..write('dirty: $dirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    modifiedAt,
    deleted,
    cardId,
    rating,
    reviewedAt,
    durationMs,
    wasNew,
    thinkMs,
    dirty,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewLog &&
          other.id == this.id &&
          other.modifiedAt == this.modifiedAt &&
          other.deleted == this.deleted &&
          other.cardId == this.cardId &&
          other.rating == this.rating &&
          other.reviewedAt == this.reviewedAt &&
          other.durationMs == this.durationMs &&
          other.wasNew == this.wasNew &&
          other.thinkMs == this.thinkMs &&
          other.dirty == this.dirty);
}

class ReviewLogsCompanion extends UpdateCompanion<ReviewLog> {
  final Value<String> id;
  final Value<int> modifiedAt;
  final Value<bool> deleted;
  final Value<String> cardId;
  final Value<int> rating;
  final Value<DateTime> reviewedAt;
  final Value<int> durationMs;
  final Value<bool> wasNew;
  final Value<int?> thinkMs;
  final Value<bool> dirty;
  final Value<int> rowid;
  const ReviewLogsCompanion({
    this.id = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.cardId = const Value.absent(),
    this.rating = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.wasNew = const Value.absent(),
    this.thinkMs = const Value.absent(),
    this.dirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReviewLogsCompanion.insert({
    this.id = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    required String cardId,
    required int rating,
    required DateTime reviewedAt,
    required int durationMs,
    required bool wasNew,
    this.thinkMs = const Value.absent(),
    this.dirty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : cardId = Value(cardId),
       rating = Value(rating),
       reviewedAt = Value(reviewedAt),
       durationMs = Value(durationMs),
       wasNew = Value(wasNew);
  static Insertable<ReviewLog> custom({
    Expression<String>? id,
    Expression<int>? modifiedAt,
    Expression<bool>? deleted,
    Expression<String>? cardId,
    Expression<int>? rating,
    Expression<DateTime>? reviewedAt,
    Expression<int>? durationMs,
    Expression<bool>? wasNew,
    Expression<int>? thinkMs,
    Expression<bool>? dirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (modifiedAt != null) 'modified_at': modifiedAt,
      if (deleted != null) 'deleted': deleted,
      if (cardId != null) 'card_id': cardId,
      if (rating != null) 'rating': rating,
      if (reviewedAt != null) 'reviewed_at': reviewedAt,
      if (durationMs != null) 'duration_ms': durationMs,
      if (wasNew != null) 'was_new': wasNew,
      if (thinkMs != null) 'think_ms': thinkMs,
      if (dirty != null) 'dirty': dirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReviewLogsCompanion copyWith({
    Value<String>? id,
    Value<int>? modifiedAt,
    Value<bool>? deleted,
    Value<String>? cardId,
    Value<int>? rating,
    Value<DateTime>? reviewedAt,
    Value<int>? durationMs,
    Value<bool>? wasNew,
    Value<int?>? thinkMs,
    Value<bool>? dirty,
    Value<int>? rowid,
  }) {
    return ReviewLogsCompanion(
      id: id ?? this.id,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      deleted: deleted ?? this.deleted,
      cardId: cardId ?? this.cardId,
      rating: rating ?? this.rating,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      durationMs: durationMs ?? this.durationMs,
      wasNew: wasNew ?? this.wasNew,
      thinkMs: thinkMs ?? this.thinkMs,
      dirty: dirty ?? this.dirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (modifiedAt.present) {
      map['modified_at'] = Variable<int>(modifiedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (reviewedAt.present) {
      map['reviewed_at'] = Variable<DateTime>(reviewedAt.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (wasNew.present) {
      map['was_new'] = Variable<bool>(wasNew.value);
    }
    if (thinkMs.present) {
      map['think_ms'] = Variable<int>(thinkMs.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewLogsCompanion(')
          ..write('id: $id, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('deleted: $deleted, ')
          ..write('cardId: $cardId, ')
          ..write('rating: $rating, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('durationMs: $durationMs, ')
          ..write('wasNew: $wasNew, ')
          ..write('thinkMs: $thinkMs, ')
          ..write('dirty: $dirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PrefsTable extends Prefs with TableInfo<$PrefsTable, Pref> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrefsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v7(),
  );
  static const VerificationMeta _modifiedAtMeta = const VerificationMeta(
    'modifiedAt',
  );
  @override
  late final GeneratedColumn<int> modifiedAt = GeneratedColumn<int>(
    'modified_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: nowMs,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
  List<GeneratedColumn> get $columns => [id, modifiedAt, deleted, dirty, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prefs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Pref> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('modified_at')) {
      context.handle(
        _modifiedAtMeta,
        modifiedAt.isAcceptableOrUnknown(data['modified_at']!, _modifiedAtMeta),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Pref map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Pref(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      modifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}modified_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $PrefsTable createAlias(String alias) {
    return $PrefsTable(attachedDatabase, alias);
  }
}

class Pref extends DataClass implements Insertable<Pref> {
  final String id;
  final int modifiedAt;
  final bool deleted;
  final bool dirty;
  final String value;
  const Pref({
    required this.id,
    required this.modifiedAt,
    required this.deleted,
    required this.dirty,
    required this.value,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['modified_at'] = Variable<int>(modifiedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['dirty'] = Variable<bool>(dirty);
    map['value'] = Variable<String>(value);
    return map;
  }

  PrefsCompanion toCompanion(bool nullToAbsent) {
    return PrefsCompanion(
      id: Value(id),
      modifiedAt: Value(modifiedAt),
      deleted: Value(deleted),
      dirty: Value(dirty),
      value: Value(value),
    );
  }

  factory Pref.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Pref(
      id: serializer.fromJson<String>(json['id']),
      modifiedAt: serializer.fromJson<int>(json['modifiedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'modifiedAt': serializer.toJson<int>(modifiedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'dirty': serializer.toJson<bool>(dirty),
      'value': serializer.toJson<String>(value),
    };
  }

  Pref copyWith({
    String? id,
    int? modifiedAt,
    bool? deleted,
    bool? dirty,
    String? value,
  }) => Pref(
    id: id ?? this.id,
    modifiedAt: modifiedAt ?? this.modifiedAt,
    deleted: deleted ?? this.deleted,
    dirty: dirty ?? this.dirty,
    value: value ?? this.value,
  );
  Pref copyWithCompanion(PrefsCompanion data) {
    return Pref(
      id: data.id.present ? data.id.value : this.id,
      modifiedAt: data.modifiedAt.present
          ? data.modifiedAt.value
          : this.modifiedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Pref(')
          ..write('id: $id, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('deleted: $deleted, ')
          ..write('dirty: $dirty, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, modifiedAt, deleted, dirty, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Pref &&
          other.id == this.id &&
          other.modifiedAt == this.modifiedAt &&
          other.deleted == this.deleted &&
          other.dirty == this.dirty &&
          other.value == this.value);
}

class PrefsCompanion extends UpdateCompanion<Pref> {
  final Value<String> id;
  final Value<int> modifiedAt;
  final Value<bool> deleted;
  final Value<bool> dirty;
  final Value<String> value;
  final Value<int> rowid;
  const PrefsCompanion({
    this.id = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.dirty = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PrefsCompanion.insert({
    this.id = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.dirty = const Value.absent(),
    required String value,
    this.rowid = const Value.absent(),
  }) : value = Value(value);
  static Insertable<Pref> custom({
    Expression<String>? id,
    Expression<int>? modifiedAt,
    Expression<bool>? deleted,
    Expression<bool>? dirty,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (modifiedAt != null) 'modified_at': modifiedAt,
      if (deleted != null) 'deleted': deleted,
      if (dirty != null) 'dirty': dirty,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PrefsCompanion copyWith({
    Value<String>? id,
    Value<int>? modifiedAt,
    Value<bool>? deleted,
    Value<bool>? dirty,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return PrefsCompanion(
      id: id ?? this.id,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      deleted: deleted ?? this.deleted,
      dirty: dirty ?? this.dirty,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (modifiedAt.present) {
      map['modified_at'] = Variable<int>(modifiedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
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
    return (StringBuffer('PrefsCompanion(')
          ..write('id: $id, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('deleted: $deleted, ')
          ..write('dirty: $dirty, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDb extends GeneratedDatabase {
  _$AppDb(QueryExecutor e) : super(e);
  $AppDbManager get managers => $AppDbManager(this);
  late final $DecksTable decks = $DecksTable(this);
  late final $NotesTable notes = $NotesTable(this);
  late final $CardsTable cards = $CardsTable(this);
  late final $ReviewLogsTable reviewLogs = $ReviewLogsTable(this);
  late final $PrefsTable prefs = $PrefsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    decks,
    notes,
    cards,
    reviewLogs,
    prefs,
  ];
}

typedef $$DecksTableCreateCompanionBuilder = DecksCompanion Function({
  Value<String> id,
  Value<int> modifiedAt,
  Value<bool> deleted,
  Value<bool> dirty,
  required String name,
  Value<String> language,
  Value<String> description,
  Value<int> newPerDay,
  Value<double> desiredRetention,
  Value<int> rowid,
});
typedef $$DecksTableUpdateCompanionBuilder = DecksCompanion Function({
  Value<String> id,
  Value<int> modifiedAt,
  Value<bool> deleted,
  Value<bool> dirty,
  Value<String> name,
  Value<String> language,
  Value<String> description,
  Value<int> newPerDay,
  Value<double> desiredRetention,
  Value<int> rowid,
});

final class $$DecksTableReferences
    extends BaseReferences<_$AppDb, $DecksTable, Deck> {
  $$DecksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$NotesTable, List<Note>> _notesRefsTable(
    _$AppDb db,
  ) => MultiTypedResultKey.fromTable(
    db.notes,
    aliasName: 'decks__id__notes__deck_id',
  );

  $$NotesTableProcessedTableManager get notesRefs {
    final manager = $$NotesTableTableManager(
      $_db,
      $_db.notes,
    ).filter((f) => f.deckId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_notesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DecksTableFilterComposer extends Composer<_$AppDb, $DecksTable> {
  $$DecksTableFilterComposer({
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

  ColumnFilters<int> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get newPerDay => $composableBuilder(
    column: $table.newPerDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get desiredRetention => $composableBuilder(
    column: $table.desiredRetention,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> notesRefs(
    Expression<bool> Function($$NotesTableFilterComposer f) f,
  ) {
    final $$NotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.deckId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableFilterComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DecksTableOrderingComposer extends Composer<_$AppDb, $DecksTable> {
  $$DecksTableOrderingComposer({
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

  ColumnOrderings<int> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get newPerDay => $composableBuilder(
    column: $table.newPerDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get desiredRetention => $composableBuilder(
    column: $table.desiredRetention,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DecksTableAnnotationComposer extends Composer<_$AppDb, $DecksTable> {
  $$DecksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get newPerDay =>
      $composableBuilder(column: $table.newPerDay, builder: (column) => column);

  GeneratedColumn<double> get desiredRetention => $composableBuilder(
    column: $table.desiredRetention,
    builder: (column) => column,
  );

  Expression<T> notesRefs<T extends Object>(
    Expression<T> Function($$NotesTableAnnotationComposer a) f,
  ) {
    final $$NotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.deckId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableAnnotationComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DecksTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $DecksTable,
          Deck,
          $$DecksTableFilterComposer,
          $$DecksTableOrderingComposer,
          $$DecksTableAnnotationComposer,
          $$DecksTableCreateCompanionBuilder,
          $$DecksTableUpdateCompanionBuilder,
          (Deck, $$DecksTableReferences),
          Deck,
          PrefetchHooks Function({bool notesRefs})
        > {
  $$DecksTableTableManager(_$AppDb db, $DecksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DecksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DecksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DecksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> modifiedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> newPerDay = const Value.absent(),
                Value<double> desiredRetention = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DecksCompanion(
                id: id,
                modifiedAt: modifiedAt,
                deleted: deleted,
                dirty: dirty,
                name: name,
                language: language,
                description: description,
                newPerDay: newPerDay,
                desiredRetention: desiredRetention,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> modifiedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                required String name,
                Value<String> language = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> newPerDay = const Value.absent(),
                Value<double> desiredRetention = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DecksCompanion.insert(
                id: id,
                modifiedAt: modifiedAt,
                deleted: deleted,
                dirty: dirty,
                name: name,
                language: language,
                description: description,
                newPerDay: newPerDay,
                desiredRetention: desiredRetention,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DecksTable, Deck>(table),
                  $$DecksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({notesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (notesRefs) db.notes],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (notesRefs)
                    await $_getPrefetchedData<Deck, $DecksTable, Note>(
                      currentTable: table,
                      referencedTable: $$DecksTableReferences._notesRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$DecksTableReferences(db, table, p0).notesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.deckId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$DecksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $DecksTable,
      Deck,
      $$DecksTableFilterComposer,
      $$DecksTableOrderingComposer,
      $$DecksTableAnnotationComposer,
      $$DecksTableCreateCompanionBuilder,
      $$DecksTableUpdateCompanionBuilder,
      (Deck, $$DecksTableReferences),
      Deck,
      PrefetchHooks Function({bool notesRefs})
    >;
typedef $$NotesTableCreateCompanionBuilder = NotesCompanion Function({
  Value<String> id,
  Value<int> modifiedAt,
  Value<bool> deleted,
  Value<bool> dirty,
  required String deckId,
  required String term,
  Value<String> pronunciation,
  Value<String> meaning,
  Value<String> explanation,
  Value<String> example,
  Value<String> exampleTranslation,
  Value<String> tags,
  Value<int> rowid,
});
typedef $$NotesTableUpdateCompanionBuilder = NotesCompanion Function({
  Value<String> id,
  Value<int> modifiedAt,
  Value<bool> deleted,
  Value<bool> dirty,
  Value<String> deckId,
  Value<String> term,
  Value<String> pronunciation,
  Value<String> meaning,
  Value<String> explanation,
  Value<String> example,
  Value<String> exampleTranslation,
  Value<String> tags,
  Value<int> rowid,
});

final class $$NotesTableReferences
    extends BaseReferences<_$AppDb, $NotesTable, Note> {
  $$NotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DecksTable _deckIdTable(_$AppDb db) =>
      db.decks.createAlias('notes__deck_id__decks__id');

  $$DecksTableProcessedTableManager get deckId {
    final $_column = $_itemColumn<String>('deck_id')!;

    final manager = $$DecksTableTableManager(
      $_db,
      $_db.decks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deckIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CardsTable, List<Card>> _cardsRefsTable(
    _$AppDb db,
  ) => MultiTypedResultKey.fromTable(
    db.cards,
    aliasName: 'notes__id__cards__note_id',
  );

  $$CardsTableProcessedTableManager get cardsRefs {
    final manager = $$CardsTableTableManager(
      $_db,
      $_db.cards,
    ).filter((f) => f.noteId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_cardsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$NotesTableFilterComposer extends Composer<_$AppDb, $NotesTable> {
  $$NotesTableFilterComposer({
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

  ColumnFilters<int> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get term => $composableBuilder(
    column: $table.term,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pronunciation => $composableBuilder(
    column: $table.pronunciation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get example => $composableBuilder(
    column: $table.example,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exampleTranslation => $composableBuilder(
    column: $table.exampleTranslation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  $$DecksTableFilterComposer get deckId {
    final $$DecksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableFilterComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> cardsRefs(
    Expression<bool> Function($$CardsTableFilterComposer f) f,
  ) {
    final $$CardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.noteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableFilterComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NotesTableOrderingComposer extends Composer<_$AppDb, $NotesTable> {
  $$NotesTableOrderingComposer({
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

  ColumnOrderings<int> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get term => $composableBuilder(
    column: $table.term,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pronunciation => $composableBuilder(
    column: $table.pronunciation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get example => $composableBuilder(
    column: $table.example,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exampleTranslation => $composableBuilder(
    column: $table.exampleTranslation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  $$DecksTableOrderingComposer get deckId {
    final $$DecksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableOrderingComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotesTableAnnotationComposer extends Composer<_$AppDb, $NotesTable> {
  $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<String> get term =>
      $composableBuilder(column: $table.term, builder: (column) => column);

  GeneratedColumn<String> get pronunciation => $composableBuilder(
    column: $table.pronunciation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get meaning =>
      $composableBuilder(column: $table.meaning, builder: (column) => column);

  GeneratedColumn<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get example =>
      $composableBuilder(column: $table.example, builder: (column) => column);

  GeneratedColumn<String> get exampleTranslation => $composableBuilder(
    column: $table.exampleTranslation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  $$DecksTableAnnotationComposer get deckId {
    final $$DecksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableAnnotationComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> cardsRefs<T extends Object>(
    Expression<T> Function($$CardsTableAnnotationComposer a) f,
  ) {
    final $$CardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.noteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableAnnotationComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NotesTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $NotesTable,
          Note,
          $$NotesTableFilterComposer,
          $$NotesTableOrderingComposer,
          $$NotesTableAnnotationComposer,
          $$NotesTableCreateCompanionBuilder,
          $$NotesTableUpdateCompanionBuilder,
          (Note, $$NotesTableReferences),
          Note,
          PrefetchHooks Function({bool deckId, bool cardsRefs})
        > {
  $$NotesTableTableManager(_$AppDb db, $NotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> modifiedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<String> deckId = const Value.absent(),
                Value<String> term = const Value.absent(),
                Value<String> pronunciation = const Value.absent(),
                Value<String> meaning = const Value.absent(),
                Value<String> explanation = const Value.absent(),
                Value<String> example = const Value.absent(),
                Value<String> exampleTranslation = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotesCompanion(
                id: id,
                modifiedAt: modifiedAt,
                deleted: deleted,
                dirty: dirty,
                deckId: deckId,
                term: term,
                pronunciation: pronunciation,
                meaning: meaning,
                explanation: explanation,
                example: example,
                exampleTranslation: exampleTranslation,
                tags: tags,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> modifiedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                required String deckId,
                required String term,
                Value<String> pronunciation = const Value.absent(),
                Value<String> meaning = const Value.absent(),
                Value<String> explanation = const Value.absent(),
                Value<String> example = const Value.absent(),
                Value<String> exampleTranslation = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotesCompanion.insert(
                id: id,
                modifiedAt: modifiedAt,
                deleted: deleted,
                dirty: dirty,
                deckId: deckId,
                term: term,
                pronunciation: pronunciation,
                meaning: meaning,
                explanation: explanation,
                example: example,
                exampleTranslation: exampleTranslation,
                tags: tags,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NotesTable, Note>(table),
                  $$NotesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({deckId = false, cardsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (cardsRefs) db.cards],
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
                    if (deckId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.deckId,
                        referencedTable: $$NotesTableReferences._deckIdTable(
                          db,
                        ),
                        referencedColumn: $$NotesTableReferences
                            ._deckIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (cardsRefs)
                    await $_getPrefetchedData<Note, $NotesTable, Card>(
                      currentTable: table,
                      referencedTable: $$NotesTableReferences._cardsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$NotesTableReferences(db, table, p0).cardsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.noteId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$NotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $NotesTable,
      Note,
      $$NotesTableFilterComposer,
      $$NotesTableOrderingComposer,
      $$NotesTableAnnotationComposer,
      $$NotesTableCreateCompanionBuilder,
      $$NotesTableUpdateCompanionBuilder,
      (Note, $$NotesTableReferences),
      Note,
      PrefetchHooks Function({bool deckId, bool cardsRefs})
    >;
typedef $$CardsTableCreateCompanionBuilder = CardsCompanion Function({
  Value<String> id,
  Value<int> modifiedAt,
  Value<bool> deleted,
  Value<bool> dirty,
  required String noteId,
  Value<String> direction,
  Value<DateTime> due,
  Value<int> state,
  Value<int?> step,
  Value<double?> stability,
  Value<double?> difficulty,
  Value<int> reps,
  Value<int> lapses,
  Value<DateTime?> lastReview,
  Value<int> rowid,
});
typedef $$CardsTableUpdateCompanionBuilder = CardsCompanion Function({
  Value<String> id,
  Value<int> modifiedAt,
  Value<bool> deleted,
  Value<bool> dirty,
  Value<String> noteId,
  Value<String> direction,
  Value<DateTime> due,
  Value<int> state,
  Value<int?> step,
  Value<double?> stability,
  Value<double?> difficulty,
  Value<int> reps,
  Value<int> lapses,
  Value<DateTime?> lastReview,
  Value<int> rowid,
});

final class $$CardsTableReferences
    extends BaseReferences<_$AppDb, $CardsTable, Card> {
  $$CardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $NotesTable _noteIdTable(_$AppDb db) =>
      db.notes.createAlias('cards__note_id__notes__id');

  $$NotesTableProcessedTableManager get noteId {
    final $_column = $_itemColumn<String>('note_id')!;

    final manager = $$NotesTableTableManager(
      $_db,
      $_db.notes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_noteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ReviewLogsTable, List<ReviewLog>>
  _reviewLogsRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.reviewLogs,
    aliasName: 'cards__id__review_logs__card_id',
  );

  $$ReviewLogsTableProcessedTableManager get reviewLogsRefs {
    final manager = $$ReviewLogsTableTableManager(
      $_db,
      $_db.reviewLogs,
    ).filter((f) => f.cardId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_reviewLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CardsTableFilterComposer extends Composer<_$AppDb, $CardsTable> {
  $$CardsTableFilterComposer({
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

  ColumnFilters<int> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get due => $composableBuilder(
    column: $table.due,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get step => $composableBuilder(
    column: $table.step,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stability => $composableBuilder(
    column: $table.stability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lapses => $composableBuilder(
    column: $table.lapses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReview => $composableBuilder(
    column: $table.lastReview,
    builder: (column) => ColumnFilters(column),
  );

  $$NotesTableFilterComposer get noteId {
    final $$NotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableFilterComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> reviewLogsRefs(
    Expression<bool> Function($$ReviewLogsTableFilterComposer f) f,
  ) {
    final $$ReviewLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reviewLogs,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReviewLogsTableFilterComposer(
            $db: $db,
            $table: $db.reviewLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CardsTableOrderingComposer extends Composer<_$AppDb, $CardsTable> {
  $$CardsTableOrderingComposer({
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

  ColumnOrderings<int> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get due => $composableBuilder(
    column: $table.due,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get step => $composableBuilder(
    column: $table.step,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stability => $composableBuilder(
    column: $table.stability,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lapses => $composableBuilder(
    column: $table.lapses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReview => $composableBuilder(
    column: $table.lastReview,
    builder: (column) => ColumnOrderings(column),
  );

  $$NotesTableOrderingComposer get noteId {
    final $$NotesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableOrderingComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardsTableAnnotationComposer extends Composer<_$AppDb, $CardsTable> {
  $$CardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<DateTime> get due =>
      $composableBuilder(column: $table.due, builder: (column) => column);

  GeneratedColumn<int> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<int> get step =>
      $composableBuilder(column: $table.step, builder: (column) => column);

  GeneratedColumn<double> get stability =>
      $composableBuilder(column: $table.stability, builder: (column) => column);

  GeneratedColumn<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<int> get lapses =>
      $composableBuilder(column: $table.lapses, builder: (column) => column);

  GeneratedColumn<DateTime> get lastReview => $composableBuilder(
    column: $table.lastReview,
    builder: (column) => column,
  );

  $$NotesTableAnnotationComposer get noteId {
    final $$NotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableAnnotationComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> reviewLogsRefs<T extends Object>(
    Expression<T> Function($$ReviewLogsTableAnnotationComposer a) f,
  ) {
    final $$ReviewLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reviewLogs,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReviewLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.reviewLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CardsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $CardsTable,
          Card,
          $$CardsTableFilterComposer,
          $$CardsTableOrderingComposer,
          $$CardsTableAnnotationComposer,
          $$CardsTableCreateCompanionBuilder,
          $$CardsTableUpdateCompanionBuilder,
          (Card, $$CardsTableReferences),
          Card,
          PrefetchHooks Function({bool noteId, bool reviewLogsRefs})
        > {
  $$CardsTableTableManager(_$AppDb db, $CardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> modifiedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<String> noteId = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<DateTime> due = const Value.absent(),
                Value<int> state = const Value.absent(),
                Value<int?> step = const Value.absent(),
                Value<double?> stability = const Value.absent(),
                Value<double?> difficulty = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<int> lapses = const Value.absent(),
                Value<DateTime?> lastReview = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardsCompanion(
                id: id,
                modifiedAt: modifiedAt,
                deleted: deleted,
                dirty: dirty,
                noteId: noteId,
                direction: direction,
                due: due,
                state: state,
                step: step,
                stability: stability,
                difficulty: difficulty,
                reps: reps,
                lapses: lapses,
                lastReview: lastReview,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> modifiedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                required String noteId,
                Value<String> direction = const Value.absent(),
                Value<DateTime> due = const Value.absent(),
                Value<int> state = const Value.absent(),
                Value<int?> step = const Value.absent(),
                Value<double?> stability = const Value.absent(),
                Value<double?> difficulty = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<int> lapses = const Value.absent(),
                Value<DateTime?> lastReview = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardsCompanion.insert(
                id: id,
                modifiedAt: modifiedAt,
                deleted: deleted,
                dirty: dirty,
                noteId: noteId,
                direction: direction,
                due: due,
                state: state,
                step: step,
                stability: stability,
                difficulty: difficulty,
                reps: reps,
                lapses: lapses,
                lastReview: lastReview,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CardsTable, Card>(table),
                  $$CardsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({noteId = false, reviewLogsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (reviewLogsRefs) db.reviewLogs],
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
                    if (noteId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.noteId,
                        referencedTable: $$CardsTableReferences._noteIdTable(
                          db,
                        ),
                        referencedColumn: $$CardsTableReferences
                            ._noteIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (reviewLogsRefs)
                    await $_getPrefetchedData<Card, $CardsTable, ReviewLog>(
                      currentTable: table,
                      referencedTable: $$CardsTableReferences
                          ._reviewLogsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CardsTableReferences(db, table, p0).reviewLogsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.cardId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $CardsTable,
      Card,
      $$CardsTableFilterComposer,
      $$CardsTableOrderingComposer,
      $$CardsTableAnnotationComposer,
      $$CardsTableCreateCompanionBuilder,
      $$CardsTableUpdateCompanionBuilder,
      (Card, $$CardsTableReferences),
      Card,
      PrefetchHooks Function({bool noteId, bool reviewLogsRefs})
    >;
typedef $$ReviewLogsTableCreateCompanionBuilder = ReviewLogsCompanion Function({
  Value<String> id,
  Value<int> modifiedAt,
  Value<bool> deleted,
  required String cardId,
  required int rating,
  required DateTime reviewedAt,
  required int durationMs,
  required bool wasNew,
  Value<int?> thinkMs,
  Value<bool> dirty,
  Value<int> rowid,
});
typedef $$ReviewLogsTableUpdateCompanionBuilder = ReviewLogsCompanion Function({
  Value<String> id,
  Value<int> modifiedAt,
  Value<bool> deleted,
  Value<String> cardId,
  Value<int> rating,
  Value<DateTime> reviewedAt,
  Value<int> durationMs,
  Value<bool> wasNew,
  Value<int?> thinkMs,
  Value<bool> dirty,
  Value<int> rowid,
});

final class $$ReviewLogsTableReferences
    extends BaseReferences<_$AppDb, $ReviewLogsTable, ReviewLog> {
  $$ReviewLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CardsTable _cardIdTable(_$AppDb db) =>
      db.cards.createAlias('review_logs__card_id__cards__id');

  $$CardsTableProcessedTableManager get cardId {
    final $_column = $_itemColumn<String>('card_id')!;

    final manager = $$CardsTableTableManager(
      $_db,
      $_db.cards,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReviewLogsTableFilterComposer
    extends Composer<_$AppDb, $ReviewLogsTable> {
  $$ReviewLogsTableFilterComposer({
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

  ColumnFilters<int> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get wasNew => $composableBuilder(
    column: $table.wasNew,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get thinkMs => $composableBuilder(
    column: $table.thinkMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  $$CardsTableFilterComposer get cardId {
    final $$CardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableFilterComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewLogsTableOrderingComposer
    extends Composer<_$AppDb, $ReviewLogsTable> {
  $$ReviewLogsTableOrderingComposer({
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

  ColumnOrderings<int> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get wasNew => $composableBuilder(
    column: $table.wasNew,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get thinkMs => $composableBuilder(
    column: $table.thinkMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  $$CardsTableOrderingComposer get cardId {
    final $$CardsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableOrderingComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewLogsTableAnnotationComposer
    extends Composer<_$AppDb, $ReviewLogsTable> {
  $$ReviewLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get wasNew =>
      $composableBuilder(column: $table.wasNew, builder: (column) => column);

  GeneratedColumn<int> get thinkMs =>
      $composableBuilder(column: $table.thinkMs, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  $$CardsTableAnnotationComposer get cardId {
    final $$CardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableAnnotationComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewLogsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $ReviewLogsTable,
          ReviewLog,
          $$ReviewLogsTableFilterComposer,
          $$ReviewLogsTableOrderingComposer,
          $$ReviewLogsTableAnnotationComposer,
          $$ReviewLogsTableCreateCompanionBuilder,
          $$ReviewLogsTableUpdateCompanionBuilder,
          (ReviewLog, $$ReviewLogsTableReferences),
          ReviewLog,
          PrefetchHooks Function({bool cardId})
        > {
  $$ReviewLogsTableTableManager(_$AppDb db, $ReviewLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReviewLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReviewLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReviewLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> modifiedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> cardId = const Value.absent(),
                Value<int> rating = const Value.absent(),
                Value<DateTime> reviewedAt = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<bool> wasNew = const Value.absent(),
                Value<int?> thinkMs = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReviewLogsCompanion(
                id: id,
                modifiedAt: modifiedAt,
                deleted: deleted,
                cardId: cardId,
                rating: rating,
                reviewedAt: reviewedAt,
                durationMs: durationMs,
                wasNew: wasNew,
                thinkMs: thinkMs,
                dirty: dirty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> modifiedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                required String cardId,
                required int rating,
                required DateTime reviewedAt,
                required int durationMs,
                required bool wasNew,
                Value<int?> thinkMs = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReviewLogsCompanion.insert(
                id: id,
                modifiedAt: modifiedAt,
                deleted: deleted,
                cardId: cardId,
                rating: rating,
                reviewedAt: reviewedAt,
                durationMs: durationMs,
                wasNew: wasNew,
                thinkMs: thinkMs,
                dirty: dirty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReviewLogsTable, ReviewLog>(table),
                  $$ReviewLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cardId = false}) {
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
                    if (cardId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.cardId,
                        referencedTable: $$ReviewLogsTableReferences
                            ._cardIdTable(db),
                        referencedColumn: $$ReviewLogsTableReferences
                            ._cardIdTable(db)
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

typedef $$ReviewLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $ReviewLogsTable,
      ReviewLog,
      $$ReviewLogsTableFilterComposer,
      $$ReviewLogsTableOrderingComposer,
      $$ReviewLogsTableAnnotationComposer,
      $$ReviewLogsTableCreateCompanionBuilder,
      $$ReviewLogsTableUpdateCompanionBuilder,
      (ReviewLog, $$ReviewLogsTableReferences),
      ReviewLog,
      PrefetchHooks Function({bool cardId})
    >;
typedef $$PrefsTableCreateCompanionBuilder = PrefsCompanion Function({
  Value<String> id,
  Value<int> modifiedAt,
  Value<bool> deleted,
  Value<bool> dirty,
  required String value,
  Value<int> rowid,
});
typedef $$PrefsTableUpdateCompanionBuilder = PrefsCompanion Function({
  Value<String> id,
  Value<int> modifiedAt,
  Value<bool> deleted,
  Value<bool> dirty,
  Value<String> value,
  Value<int> rowid,
});

class $$PrefsTableFilterComposer extends Composer<_$AppDb, $PrefsTable> {
  $$PrefsTableFilterComposer({
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

  ColumnFilters<int> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PrefsTableOrderingComposer extends Composer<_$AppDb, $PrefsTable> {
  $$PrefsTableOrderingComposer({
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

  ColumnOrderings<int> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PrefsTableAnnotationComposer extends Composer<_$AppDb, $PrefsTable> {
  $$PrefsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$PrefsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $PrefsTable,
          Pref,
          $$PrefsTableFilterComposer,
          $$PrefsTableOrderingComposer,
          $$PrefsTableAnnotationComposer,
          $$PrefsTableCreateCompanionBuilder,
          $$PrefsTableUpdateCompanionBuilder,
          (Pref, BaseReferences<_$AppDb, $PrefsTable, Pref>),
          Pref,
          PrefetchHooks Function()
        > {
  $$PrefsTableTableManager(_$AppDb db, $PrefsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrefsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrefsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PrefsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> modifiedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PrefsCompanion(
                id: id,
                modifiedAt: modifiedAt,
                deleted: deleted,
                dirty: dirty,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> modifiedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => PrefsCompanion.insert(
                id: id,
                modifiedAt: modifiedAt,
                deleted: deleted,
                dirty: dirty,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PrefsTable, Pref>(table),
                  BaseReferences<_$AppDb, $PrefsTable, Pref>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PrefsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $PrefsTable,
      Pref,
      $$PrefsTableFilterComposer,
      $$PrefsTableOrderingComposer,
      $$PrefsTableAnnotationComposer,
      $$PrefsTableCreateCompanionBuilder,
      $$PrefsTableUpdateCompanionBuilder,
      (Pref, BaseReferences<_$AppDb, $PrefsTable, Pref>),
      Pref,
      PrefetchHooks Function()
    >;

class $AppDbManager {
  final _$AppDb _db;
  $AppDbManager(this._db);
  $$DecksTableTableManager get decks =>
      $$DecksTableTableManager(_db, _db.decks);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
  $$CardsTableTableManager get cards =>
      $$CardsTableTableManager(_db, _db.cards);
  $$ReviewLogsTableTableManager get reviewLogs =>
      $$ReviewLogsTableTableManager(_db, _db.reviewLogs);
  $$PrefsTableTableManager get prefs =>
      $$PrefsTableTableManager(_db, _db.prefs);
}
