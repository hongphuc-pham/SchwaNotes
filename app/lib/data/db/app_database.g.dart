// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class WordsFts extends Table
    with TableInfo<WordsFts, WordsFt>, VirtualTableInfo<WordsFts, WordsFt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  WordsFts(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  late final GeneratedColumn<String> wordId = GeneratedColumn<String>(
    'word_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  static const VerificationMeta _headwordMeta = const VerificationMeta(
    'headword',
  );
  late final GeneratedColumn<String> headword = GeneratedColumn<String>(
    'headword',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  static const VerificationMeta _definitionMeta = const VerificationMeta(
    'definition',
  );
  late final GeneratedColumn<String> definition = GeneratedColumn<String>(
    'definition',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  static const VerificationMeta _exampleMeta = const VerificationMeta(
    'example',
  );
  late final GeneratedColumn<String> example = GeneratedColumn<String>(
    'example',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    wordId,
    headword,
    definition,
    example,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'words_fts';
  @override
  VerificationContext validateIntegrity(
    Insertable<WordsFt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('word_id')) {
      context.handle(
        _wordIdMeta,
        wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_wordIdMeta);
    }
    if (data.containsKey('headword')) {
      context.handle(
        _headwordMeta,
        headword.isAcceptableOrUnknown(data['headword']!, _headwordMeta),
      );
    } else if (isInserting) {
      context.missing(_headwordMeta);
    }
    if (data.containsKey('definition')) {
      context.handle(
        _definitionMeta,
        definition.isAcceptableOrUnknown(data['definition']!, _definitionMeta),
      );
    } else if (isInserting) {
      context.missing(_definitionMeta);
    }
    if (data.containsKey('example')) {
      context.handle(
        _exampleMeta,
        example.isAcceptableOrUnknown(data['example']!, _exampleMeta),
      );
    } else if (isInserting) {
      context.missing(_exampleMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    } else if (isInserting) {
      context.missing(_notesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  WordsFt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WordsFt(
      wordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}word_id'],
      )!,
      headword: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}headword'],
      )!,
      definition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}definition'],
      )!,
      example: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}example'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
    );
  }

  @override
  WordsFts createAlias(String alias) {
    return WordsFts(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
  @override
  String get moduleAndArgs =>
      'fts5(word_id UNINDEXED, headword, definition, example, notes, tokenize = \'unicode61 remove_diacritics 2\')';
}

class WordsFt extends DataClass implements Insertable<WordsFt> {
  final String wordId;
  final String headword;
  final String definition;
  final String example;
  final String notes;
  const WordsFt({
    required this.wordId,
    required this.headword,
    required this.definition,
    required this.example,
    required this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['word_id'] = Variable<String>(wordId);
    map['headword'] = Variable<String>(headword);
    map['definition'] = Variable<String>(definition);
    map['example'] = Variable<String>(example);
    map['notes'] = Variable<String>(notes);
    return map;
  }

  WordsFtsCompanion toCompanion(bool nullToAbsent) {
    return WordsFtsCompanion(
      wordId: Value(wordId),
      headword: Value(headword),
      definition: Value(definition),
      example: Value(example),
      notes: Value(notes),
    );
  }

  factory WordsFt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WordsFt(
      wordId: serializer.fromJson<String>(json['word_id']),
      headword: serializer.fromJson<String>(json['headword']),
      definition: serializer.fromJson<String>(json['definition']),
      example: serializer.fromJson<String>(json['example']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'word_id': serializer.toJson<String>(wordId),
      'headword': serializer.toJson<String>(headword),
      'definition': serializer.toJson<String>(definition),
      'example': serializer.toJson<String>(example),
      'notes': serializer.toJson<String>(notes),
    };
  }

  WordsFt copyWith({
    String? wordId,
    String? headword,
    String? definition,
    String? example,
    String? notes,
  }) => WordsFt(
    wordId: wordId ?? this.wordId,
    headword: headword ?? this.headword,
    definition: definition ?? this.definition,
    example: example ?? this.example,
    notes: notes ?? this.notes,
  );
  WordsFt copyWithCompanion(WordsFtsCompanion data) {
    return WordsFt(
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      headword: data.headword.present ? data.headword.value : this.headword,
      definition: data.definition.present
          ? data.definition.value
          : this.definition,
      example: data.example.present ? data.example.value : this.example,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WordsFt(')
          ..write('wordId: $wordId, ')
          ..write('headword: $headword, ')
          ..write('definition: $definition, ')
          ..write('example: $example, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(wordId, headword, definition, example, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordsFt &&
          other.wordId == this.wordId &&
          other.headword == this.headword &&
          other.definition == this.definition &&
          other.example == this.example &&
          other.notes == this.notes);
}

class WordsFtsCompanion extends UpdateCompanion<WordsFt> {
  final Value<String> wordId;
  final Value<String> headword;
  final Value<String> definition;
  final Value<String> example;
  final Value<String> notes;
  final Value<int> rowid;
  const WordsFtsCompanion({
    this.wordId = const Value.absent(),
    this.headword = const Value.absent(),
    this.definition = const Value.absent(),
    this.example = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WordsFtsCompanion.insert({
    required String wordId,
    required String headword,
    required String definition,
    required String example,
    required String notes,
    this.rowid = const Value.absent(),
  }) : wordId = Value(wordId),
       headword = Value(headword),
       definition = Value(definition),
       example = Value(example),
       notes = Value(notes);
  static Insertable<WordsFt> custom({
    Expression<String>? wordId,
    Expression<String>? headword,
    Expression<String>? definition,
    Expression<String>? example,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (wordId != null) 'word_id': wordId,
      if (headword != null) 'headword': headword,
      if (definition != null) 'definition': definition,
      if (example != null) 'example': example,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WordsFtsCompanion copyWith({
    Value<String>? wordId,
    Value<String>? headword,
    Value<String>? definition,
    Value<String>? example,
    Value<String>? notes,
    Value<int>? rowid,
  }) {
    return WordsFtsCompanion(
      wordId: wordId ?? this.wordId,
      headword: headword ?? this.headword,
      definition: definition ?? this.definition,
      example: example ?? this.example,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (wordId.present) {
      map['word_id'] = Variable<String>(wordId.value);
    }
    if (headword.present) {
      map['headword'] = Variable<String>(headword.value);
    }
    if (definition.present) {
      map['definition'] = Variable<String>(definition.value);
    }
    if (example.present) {
      map['example'] = Variable<String>(example.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordsFtsCompanion(')
          ..write('wordId: $wordId, ')
          ..write('headword: $headword, ')
          ..write('definition: $definition, ')
          ..write('example: $example, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WordsTable extends Words with TableInfo<$WordsTable, WordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _headwordMeta = const VerificationMeta(
    'headword',
  );
  @override
  late final GeneratedColumn<String> headword = GeneratedColumn<String>(
    'headword',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _headwordNormalizedMeta =
      const VerificationMeta('headwordNormalized');
  @override
  late final GeneratedColumn<String> headwordNormalized =
      GeneratedColumn<String>(
        'headword_normalized',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _partOfSpeechMeta = const VerificationMeta(
    'partOfSpeech',
  );
  @override
  late final GeneratedColumn<String> partOfSpeech = GeneratedColumn<String>(
    'part_of_speech',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ipaUkMeta = const VerificationMeta('ipaUk');
  @override
  late final GeneratedColumn<String> ipaUk = GeneratedColumn<String>(
    'ipa_uk',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ipaUsMeta = const VerificationMeta('ipaUs');
  @override
  late final GeneratedColumn<String> ipaUs = GeneratedColumn<String>(
    'ipa_us',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _definitionMeta = const VerificationMeta(
    'definition',
  );
  @override
  late final GeneratedColumn<String> definition = GeneratedColumn<String>(
    'definition',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exampleMeta = const VerificationMeta(
    'example',
  );
  @override
  late final GeneratedColumn<String> example = GeneratedColumn<String>(
    'example',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<WordSource, String> source =
      GeneratedColumn<String>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('manual'),
      ).withConverter<WordSource>($WordsTable.$convertersource);
  static const VerificationMeta _sourceAttributionMeta = const VerificationMeta(
    'sourceAttribution',
  );
  @override
  late final GeneratedColumn<String> sourceAttribution =
      GeneratedColumn<String>(
        'source_attribution',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isFavouriteMeta = const VerificationMeta(
    'isFavourite',
  );
  @override
  late final GeneratedColumn<bool> isFavourite = GeneratedColumn<bool>(
    'is_favourite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favourite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($WordsTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($WordsTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> deletedAt =
      GeneratedColumn<int>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($WordsTable.$converterdeletedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    headword,
    headwordNormalized,
    partOfSpeech,
    ipaUk,
    ipaUs,
    definition,
    example,
    source,
    sourceAttribution,
    isFavourite,
    isArchived,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'words';
  @override
  VerificationContext validateIntegrity(
    Insertable<WordRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('headword')) {
      context.handle(
        _headwordMeta,
        headword.isAcceptableOrUnknown(data['headword']!, _headwordMeta),
      );
    } else if (isInserting) {
      context.missing(_headwordMeta);
    }
    if (data.containsKey('headword_normalized')) {
      context.handle(
        _headwordNormalizedMeta,
        headwordNormalized.isAcceptableOrUnknown(
          data['headword_normalized']!,
          _headwordNormalizedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_headwordNormalizedMeta);
    }
    if (data.containsKey('part_of_speech')) {
      context.handle(
        _partOfSpeechMeta,
        partOfSpeech.isAcceptableOrUnknown(
          data['part_of_speech']!,
          _partOfSpeechMeta,
        ),
      );
    }
    if (data.containsKey('ipa_uk')) {
      context.handle(
        _ipaUkMeta,
        ipaUk.isAcceptableOrUnknown(data['ipa_uk']!, _ipaUkMeta),
      );
    }
    if (data.containsKey('ipa_us')) {
      context.handle(
        _ipaUsMeta,
        ipaUs.isAcceptableOrUnknown(data['ipa_us']!, _ipaUsMeta),
      );
    }
    if (data.containsKey('definition')) {
      context.handle(
        _definitionMeta,
        definition.isAcceptableOrUnknown(data['definition']!, _definitionMeta),
      );
    }
    if (data.containsKey('example')) {
      context.handle(
        _exampleMeta,
        example.isAcceptableOrUnknown(data['example']!, _exampleMeta),
      );
    }
    if (data.containsKey('source_attribution')) {
      context.handle(
        _sourceAttributionMeta,
        sourceAttribution.isAcceptableOrUnknown(
          data['source_attribution']!,
          _sourceAttributionMeta,
        ),
      );
    }
    if (data.containsKey('is_favourite')) {
      context.handle(
        _isFavouriteMeta,
        isFavourite.isAcceptableOrUnknown(
          data['is_favourite']!,
          _isFavouriteMeta,
        ),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WordRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      headword: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}headword'],
      )!,
      headwordNormalized: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}headword_normalized'],
      )!,
      partOfSpeech: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}part_of_speech'],
      ),
      ipaUk: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ipa_uk'],
      ),
      ipaUs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ipa_us'],
      ),
      definition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}definition'],
      ),
      example: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}example'],
      ),
      source: $WordsTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source'],
        )!,
      ),
      sourceAttribution: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_attribution'],
      ),
      isFavourite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favourite'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      createdAt: $WordsTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $WordsTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      deletedAt: $WordsTable.$converterdeletedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}deleted_at'],
        ),
      ),
    );
  }

  @override
  $WordsTable createAlias(String alias) {
    return $WordsTable(attachedDatabase, alias);
  }

  static TypeConverter<WordSource, String> $convertersource =
      wordSourceConverter;
  static TypeConverter<DateTime, int> $convertercreatedAt =
      epochMillisConverter;
  static TypeConverter<DateTime, int> $converterupdatedAt =
      epochMillisConverter;
  static TypeConverter<DateTime?, int?> $converterdeletedAt =
      nullableEpochMillisConverter;
}

class WordRow extends DataClass implements Insertable<WordRow> {
  /// UUID v4, so two devices' exports can be merged without collisions.
  final String id;

  /// Exactly as the user typed it.
  final String headword;

  /// Lowercased and whitespace-collapsed, for dedupe (F-001) and search.
  final String headwordNormalized;

  /// Free text: noun, verb, or whatever the user prefers.
  final String? partOfSpeech;

  /// British transcription, without slashes.
  final String? ipaUk;

  /// American transcription, without slashes.
  final String? ipaUs;

  /// What the word means.
  final String? definition;

  /// A sentence using it.
  final String? example;

  /// `manual` | `api` | `offline` | `mixed`.
  final WordSource source;

  /// The credit line and source URL, when one is owed (RULES §16).
  final String? sourceAttribution;

  /// Starred by the user (F-044).
  final bool isFavourite;

  /// Hidden from lists but kept in stats (F-045).
  final bool isArchived;

  /// Epoch milliseconds UTC.
  final DateTime createdAt;

  /// Epoch milliseconds UTC. Import merge resolves conflicts on this.
  final DateTime updatedAt;

  /// Set on soft delete; purged 30 days later.
  final DateTime? deletedAt;
  const WordRow({
    required this.id,
    required this.headword,
    required this.headwordNormalized,
    this.partOfSpeech,
    this.ipaUk,
    this.ipaUs,
    this.definition,
    this.example,
    required this.source,
    this.sourceAttribution,
    required this.isFavourite,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['headword'] = Variable<String>(headword);
    map['headword_normalized'] = Variable<String>(headwordNormalized);
    if (!nullToAbsent || partOfSpeech != null) {
      map['part_of_speech'] = Variable<String>(partOfSpeech);
    }
    if (!nullToAbsent || ipaUk != null) {
      map['ipa_uk'] = Variable<String>(ipaUk);
    }
    if (!nullToAbsent || ipaUs != null) {
      map['ipa_us'] = Variable<String>(ipaUs);
    }
    if (!nullToAbsent || definition != null) {
      map['definition'] = Variable<String>(definition);
    }
    if (!nullToAbsent || example != null) {
      map['example'] = Variable<String>(example);
    }
    {
      map['source'] = Variable<String>(
        $WordsTable.$convertersource.toSql(source),
      );
    }
    if (!nullToAbsent || sourceAttribution != null) {
      map['source_attribution'] = Variable<String>(sourceAttribution);
    }
    map['is_favourite'] = Variable<bool>(isFavourite);
    map['is_archived'] = Variable<bool>(isArchived);
    {
      map['created_at'] = Variable<int>(
        $WordsTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<int>(
        $WordsTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(
        $WordsTable.$converterdeletedAt.toSql(deletedAt),
      );
    }
    return map;
  }

  WordsCompanion toCompanion(bool nullToAbsent) {
    return WordsCompanion(
      id: Value(id),
      headword: Value(headword),
      headwordNormalized: Value(headwordNormalized),
      partOfSpeech: partOfSpeech == null && nullToAbsent
          ? const Value.absent()
          : Value(partOfSpeech),
      ipaUk: ipaUk == null && nullToAbsent
          ? const Value.absent()
          : Value(ipaUk),
      ipaUs: ipaUs == null && nullToAbsent
          ? const Value.absent()
          : Value(ipaUs),
      definition: definition == null && nullToAbsent
          ? const Value.absent()
          : Value(definition),
      example: example == null && nullToAbsent
          ? const Value.absent()
          : Value(example),
      source: Value(source),
      sourceAttribution: sourceAttribution == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceAttribution),
      isFavourite: Value(isFavourite),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory WordRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WordRow(
      id: serializer.fromJson<String>(json['id']),
      headword: serializer.fromJson<String>(json['headword']),
      headwordNormalized: serializer.fromJson<String>(
        json['headwordNormalized'],
      ),
      partOfSpeech: serializer.fromJson<String?>(json['partOfSpeech']),
      ipaUk: serializer.fromJson<String?>(json['ipaUk']),
      ipaUs: serializer.fromJson<String?>(json['ipaUs']),
      definition: serializer.fromJson<String?>(json['definition']),
      example: serializer.fromJson<String?>(json['example']),
      source: serializer.fromJson<WordSource>(json['source']),
      sourceAttribution: serializer.fromJson<String?>(
        json['sourceAttribution'],
      ),
      isFavourite: serializer.fromJson<bool>(json['isFavourite']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'headword': serializer.toJson<String>(headword),
      'headwordNormalized': serializer.toJson<String>(headwordNormalized),
      'partOfSpeech': serializer.toJson<String?>(partOfSpeech),
      'ipaUk': serializer.toJson<String?>(ipaUk),
      'ipaUs': serializer.toJson<String?>(ipaUs),
      'definition': serializer.toJson<String?>(definition),
      'example': serializer.toJson<String?>(example),
      'source': serializer.toJson<WordSource>(source),
      'sourceAttribution': serializer.toJson<String?>(sourceAttribution),
      'isFavourite': serializer.toJson<bool>(isFavourite),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  WordRow copyWith({
    String? id,
    String? headword,
    String? headwordNormalized,
    Value<String?> partOfSpeech = const Value.absent(),
    Value<String?> ipaUk = const Value.absent(),
    Value<String?> ipaUs = const Value.absent(),
    Value<String?> definition = const Value.absent(),
    Value<String?> example = const Value.absent(),
    WordSource? source,
    Value<String?> sourceAttribution = const Value.absent(),
    bool? isFavourite,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => WordRow(
    id: id ?? this.id,
    headword: headword ?? this.headword,
    headwordNormalized: headwordNormalized ?? this.headwordNormalized,
    partOfSpeech: partOfSpeech.present ? partOfSpeech.value : this.partOfSpeech,
    ipaUk: ipaUk.present ? ipaUk.value : this.ipaUk,
    ipaUs: ipaUs.present ? ipaUs.value : this.ipaUs,
    definition: definition.present ? definition.value : this.definition,
    example: example.present ? example.value : this.example,
    source: source ?? this.source,
    sourceAttribution: sourceAttribution.present
        ? sourceAttribution.value
        : this.sourceAttribution,
    isFavourite: isFavourite ?? this.isFavourite,
    isArchived: isArchived ?? this.isArchived,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  WordRow copyWithCompanion(WordsCompanion data) {
    return WordRow(
      id: data.id.present ? data.id.value : this.id,
      headword: data.headword.present ? data.headword.value : this.headword,
      headwordNormalized: data.headwordNormalized.present
          ? data.headwordNormalized.value
          : this.headwordNormalized,
      partOfSpeech: data.partOfSpeech.present
          ? data.partOfSpeech.value
          : this.partOfSpeech,
      ipaUk: data.ipaUk.present ? data.ipaUk.value : this.ipaUk,
      ipaUs: data.ipaUs.present ? data.ipaUs.value : this.ipaUs,
      definition: data.definition.present
          ? data.definition.value
          : this.definition,
      example: data.example.present ? data.example.value : this.example,
      source: data.source.present ? data.source.value : this.source,
      sourceAttribution: data.sourceAttribution.present
          ? data.sourceAttribution.value
          : this.sourceAttribution,
      isFavourite: data.isFavourite.present
          ? data.isFavourite.value
          : this.isFavourite,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WordRow(')
          ..write('id: $id, ')
          ..write('headword: $headword, ')
          ..write('headwordNormalized: $headwordNormalized, ')
          ..write('partOfSpeech: $partOfSpeech, ')
          ..write('ipaUk: $ipaUk, ')
          ..write('ipaUs: $ipaUs, ')
          ..write('definition: $definition, ')
          ..write('example: $example, ')
          ..write('source: $source, ')
          ..write('sourceAttribution: $sourceAttribution, ')
          ..write('isFavourite: $isFavourite, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    headword,
    headwordNormalized,
    partOfSpeech,
    ipaUk,
    ipaUs,
    definition,
    example,
    source,
    sourceAttribution,
    isFavourite,
    isArchived,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordRow &&
          other.id == this.id &&
          other.headword == this.headword &&
          other.headwordNormalized == this.headwordNormalized &&
          other.partOfSpeech == this.partOfSpeech &&
          other.ipaUk == this.ipaUk &&
          other.ipaUs == this.ipaUs &&
          other.definition == this.definition &&
          other.example == this.example &&
          other.source == this.source &&
          other.sourceAttribution == this.sourceAttribution &&
          other.isFavourite == this.isFavourite &&
          other.isArchived == this.isArchived &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class WordsCompanion extends UpdateCompanion<WordRow> {
  final Value<String> id;
  final Value<String> headword;
  final Value<String> headwordNormalized;
  final Value<String?> partOfSpeech;
  final Value<String?> ipaUk;
  final Value<String?> ipaUs;
  final Value<String?> definition;
  final Value<String?> example;
  final Value<WordSource> source;
  final Value<String?> sourceAttribution;
  final Value<bool> isFavourite;
  final Value<bool> isArchived;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const WordsCompanion({
    this.id = const Value.absent(),
    this.headword = const Value.absent(),
    this.headwordNormalized = const Value.absent(),
    this.partOfSpeech = const Value.absent(),
    this.ipaUk = const Value.absent(),
    this.ipaUs = const Value.absent(),
    this.definition = const Value.absent(),
    this.example = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceAttribution = const Value.absent(),
    this.isFavourite = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WordsCompanion.insert({
    required String id,
    required String headword,
    required String headwordNormalized,
    this.partOfSpeech = const Value.absent(),
    this.ipaUk = const Value.absent(),
    this.ipaUs = const Value.absent(),
    this.definition = const Value.absent(),
    this.example = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceAttribution = const Value.absent(),
    this.isFavourite = const Value.absent(),
    this.isArchived = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       headword = Value(headword),
       headwordNormalized = Value(headwordNormalized),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<WordRow> custom({
    Expression<String>? id,
    Expression<String>? headword,
    Expression<String>? headwordNormalized,
    Expression<String>? partOfSpeech,
    Expression<String>? ipaUk,
    Expression<String>? ipaUs,
    Expression<String>? definition,
    Expression<String>? example,
    Expression<String>? source,
    Expression<String>? sourceAttribution,
    Expression<bool>? isFavourite,
    Expression<bool>? isArchived,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (headword != null) 'headword': headword,
      if (headwordNormalized != null) 'headword_normalized': headwordNormalized,
      if (partOfSpeech != null) 'part_of_speech': partOfSpeech,
      if (ipaUk != null) 'ipa_uk': ipaUk,
      if (ipaUs != null) 'ipa_us': ipaUs,
      if (definition != null) 'definition': definition,
      if (example != null) 'example': example,
      if (source != null) 'source': source,
      if (sourceAttribution != null) 'source_attribution': sourceAttribution,
      if (isFavourite != null) 'is_favourite': isFavourite,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WordsCompanion copyWith({
    Value<String>? id,
    Value<String>? headword,
    Value<String>? headwordNormalized,
    Value<String?>? partOfSpeech,
    Value<String?>? ipaUk,
    Value<String?>? ipaUs,
    Value<String?>? definition,
    Value<String?>? example,
    Value<WordSource>? source,
    Value<String?>? sourceAttribution,
    Value<bool>? isFavourite,
    Value<bool>? isArchived,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return WordsCompanion(
      id: id ?? this.id,
      headword: headword ?? this.headword,
      headwordNormalized: headwordNormalized ?? this.headwordNormalized,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      ipaUk: ipaUk ?? this.ipaUk,
      ipaUs: ipaUs ?? this.ipaUs,
      definition: definition ?? this.definition,
      example: example ?? this.example,
      source: source ?? this.source,
      sourceAttribution: sourceAttribution ?? this.sourceAttribution,
      isFavourite: isFavourite ?? this.isFavourite,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (headword.present) {
      map['headword'] = Variable<String>(headword.value);
    }
    if (headwordNormalized.present) {
      map['headword_normalized'] = Variable<String>(headwordNormalized.value);
    }
    if (partOfSpeech.present) {
      map['part_of_speech'] = Variable<String>(partOfSpeech.value);
    }
    if (ipaUk.present) {
      map['ipa_uk'] = Variable<String>(ipaUk.value);
    }
    if (ipaUs.present) {
      map['ipa_us'] = Variable<String>(ipaUs.value);
    }
    if (definition.present) {
      map['definition'] = Variable<String>(definition.value);
    }
    if (example.present) {
      map['example'] = Variable<String>(example.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(
        $WordsTable.$convertersource.toSql(source.value),
      );
    }
    if (sourceAttribution.present) {
      map['source_attribution'] = Variable<String>(sourceAttribution.value);
    }
    if (isFavourite.present) {
      map['is_favourite'] = Variable<bool>(isFavourite.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $WordsTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        $WordsTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(
        $WordsTable.$converterdeletedAt.toSql(deletedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordsCompanion(')
          ..write('id: $id, ')
          ..write('headword: $headword, ')
          ..write('headwordNormalized: $headwordNormalized, ')
          ..write('partOfSpeech: $partOfSpeech, ')
          ..write('ipaUk: $ipaUk, ')
          ..write('ipaUs: $ipaUs, ')
          ..write('definition: $definition, ')
          ..write('example: $example, ')
          ..write('source: $source, ')
          ..write('sourceAttribution: $sourceAttribution, ')
          ..write('isFavourite: $isFavourite, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WordNotesTable extends WordNotes
    with TableInfo<$WordNotesTable, WordNoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<String> wordId = GeneratedColumn<String>(
    'word_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES words (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($WordNotesTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($WordNotesTable.$converterupdatedAt);
  static const VerificationMeta _pinnedMeta = const VerificationMeta('pinned');
  @override
  late final GeneratedColumn<bool> pinned = GeneratedColumn<bool>(
    'pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    wordId,
    body,
    createdAt,
    updatedAt,
    pinned,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'word_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<WordNoteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('word_id')) {
      context.handle(
        _wordIdMeta,
        wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_wordIdMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('pinned')) {
      context.handle(
        _pinnedMeta,
        pinned.isAcceptableOrUnknown(data['pinned']!, _pinnedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WordNoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WordNoteRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      wordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}word_id'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      createdAt: $WordNotesTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $WordNotesTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      pinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pinned'],
      )!,
    );
  }

  @override
  $WordNotesTable createAlias(String alias) {
    return $WordNotesTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt =
      epochMillisConverter;
  static TypeConverter<DateTime, int> $converterupdatedAt =
      epochMillisConverter;
}

class WordNoteRow extends DataClass implements Insertable<WordNoteRow> {
  /// UUID v4.
  final String id;

  /// Owning word. Cascades, so purging a word takes its notes with it.
  final String wordId;

  /// What the user wrote.
  final String body;

  /// Epoch milliseconds UTC.
  final DateTime createdAt;

  /// Epoch milliseconds UTC.
  final DateTime updatedAt;

  /// Pinned notes sort above the rest.
  final bool pinned;
  const WordNoteRow({
    required this.id,
    required this.wordId,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    required this.pinned,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['word_id'] = Variable<String>(wordId);
    map['body'] = Variable<String>(body);
    {
      map['created_at'] = Variable<int>(
        $WordNotesTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<int>(
        $WordNotesTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    map['pinned'] = Variable<bool>(pinned);
    return map;
  }

  WordNotesCompanion toCompanion(bool nullToAbsent) {
    return WordNotesCompanion(
      id: Value(id),
      wordId: Value(wordId),
      body: Value(body),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      pinned: Value(pinned),
    );
  }

  factory WordNoteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WordNoteRow(
      id: serializer.fromJson<String>(json['id']),
      wordId: serializer.fromJson<String>(json['wordId']),
      body: serializer.fromJson<String>(json['body']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      pinned: serializer.fromJson<bool>(json['pinned']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'wordId': serializer.toJson<String>(wordId),
      'body': serializer.toJson<String>(body),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'pinned': serializer.toJson<bool>(pinned),
    };
  }

  WordNoteRow copyWith({
    String? id,
    String? wordId,
    String? body,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? pinned,
  }) => WordNoteRow(
    id: id ?? this.id,
    wordId: wordId ?? this.wordId,
    body: body ?? this.body,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    pinned: pinned ?? this.pinned,
  );
  WordNoteRow copyWithCompanion(WordNotesCompanion data) {
    return WordNoteRow(
      id: data.id.present ? data.id.value : this.id,
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      body: data.body.present ? data.body.value : this.body,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      pinned: data.pinned.present ? data.pinned.value : this.pinned,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WordNoteRow(')
          ..write('id: $id, ')
          ..write('wordId: $wordId, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('pinned: $pinned')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, wordId, body, createdAt, updatedAt, pinned);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordNoteRow &&
          other.id == this.id &&
          other.wordId == this.wordId &&
          other.body == this.body &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.pinned == this.pinned);
}

class WordNotesCompanion extends UpdateCompanion<WordNoteRow> {
  final Value<String> id;
  final Value<String> wordId;
  final Value<String> body;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> pinned;
  final Value<int> rowid;
  const WordNotesCompanion({
    this.id = const Value.absent(),
    this.wordId = const Value.absent(),
    this.body = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.pinned = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WordNotesCompanion.insert({
    required String id,
    required String wordId,
    required String body,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.pinned = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       wordId = Value(wordId),
       body = Value(body),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<WordNoteRow> custom({
    Expression<String>? id,
    Expression<String>? wordId,
    Expression<String>? body,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? pinned,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (wordId != null) 'word_id': wordId,
      if (body != null) 'body': body,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (pinned != null) 'pinned': pinned,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WordNotesCompanion copyWith({
    Value<String>? id,
    Value<String>? wordId,
    Value<String>? body,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? pinned,
    Value<int>? rowid,
  }) {
    return WordNotesCompanion(
      id: id ?? this.id,
      wordId: wordId ?? this.wordId,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      pinned: pinned ?? this.pinned,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (wordId.present) {
      map['word_id'] = Variable<String>(wordId.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $WordNotesTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        $WordNotesTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (pinned.present) {
      map['pinned'] = Variable<bool>(pinned.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordNotesCompanion(')
          ..write('id: $id, ')
          ..write('wordId: $wordId, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('pinned: $pinned, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IpaHighlightsTable extends IpaHighlights
    with TableInfo<$IpaHighlightsTable, IpaHighlightRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IpaHighlightsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<String> wordId = GeneratedColumn<String>(
    'word_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES words (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<HighlightTarget, String> target =
      GeneratedColumn<String>(
        'target',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<HighlightTarget>($IpaHighlightsTable.$convertertarget);
  static const VerificationMeta _startGraphemeMeta = const VerificationMeta(
    'startGrapheme',
  );
  @override
  late final GeneratedColumn<int> startGrapheme = GeneratedColumn<int>(
    'start_grapheme',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endGraphemeMeta = const VerificationMeta(
    'endGrapheme',
  );
  @override
  late final GeneratedColumn<int> endGrapheme = GeneratedColumn<int>(
    'end_grapheme',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<IpaColorToken, String>
  colorToken = GeneratedColumn<String>(
    'color_token',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<IpaColorToken>($IpaHighlightsTable.$convertercolorToken);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($IpaHighlightsTable.$convertercreatedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    wordId,
    target,
    startGrapheme,
    endGrapheme,
    colorToken,
    label,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ipa_highlights';
  @override
  VerificationContext validateIntegrity(
    Insertable<IpaHighlightRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('word_id')) {
      context.handle(
        _wordIdMeta,
        wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_wordIdMeta);
    }
    if (data.containsKey('start_grapheme')) {
      context.handle(
        _startGraphemeMeta,
        startGrapheme.isAcceptableOrUnknown(
          data['start_grapheme']!,
          _startGraphemeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startGraphemeMeta);
    }
    if (data.containsKey('end_grapheme')) {
      context.handle(
        _endGraphemeMeta,
        endGrapheme.isAcceptableOrUnknown(
          data['end_grapheme']!,
          _endGraphemeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_endGraphemeMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IpaHighlightRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IpaHighlightRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      wordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}word_id'],
      )!,
      target: $IpaHighlightsTable.$convertertarget.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}target'],
        )!,
      ),
      startGrapheme: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_grapheme'],
      )!,
      endGrapheme: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_grapheme'],
      )!,
      colorToken: $IpaHighlightsTable.$convertercolorToken.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}color_token'],
        )!,
      ),
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      createdAt: $IpaHighlightsTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
    );
  }

  @override
  $IpaHighlightsTable createAlias(String alias) {
    return $IpaHighlightsTable(attachedDatabase, alias);
  }

  static TypeConverter<HighlightTarget, String> $convertertarget =
      highlightTargetConverter;
  static TypeConverter<IpaColorToken, String> $convertercolorToken =
      ipaColorTokenConverter;
  static TypeConverter<DateTime, int> $convertercreatedAt =
      epochMillisConverter;
}

class IpaHighlightRow extends DataClass implements Insertable<IpaHighlightRow> {
  /// UUID v4.
  final String id;

  /// Owning word. Cascades.
  final String wordId;

  /// `ipa_uk` | `ipa_us` - which transcription this marks.
  final HighlightTarget target;

  /// First grapheme cluster, inclusive.
  final int startGrapheme;

  /// One past the last grapheme cluster, exclusive.
  final int endGrapheme;

  /// One of the five palette tokens, by name - never a hex value, so a theme
  /// change repaints existing highlights.
  final IpaColorToken colorToken;

  /// The user's label, e.g. "I say /s/ here". Up to 40 characters.
  final String? label;

  /// Epoch milliseconds UTC.
  final DateTime createdAt;
  const IpaHighlightRow({
    required this.id,
    required this.wordId,
    required this.target,
    required this.startGrapheme,
    required this.endGrapheme,
    required this.colorToken,
    this.label,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['word_id'] = Variable<String>(wordId);
    {
      map['target'] = Variable<String>(
        $IpaHighlightsTable.$convertertarget.toSql(target),
      );
    }
    map['start_grapheme'] = Variable<int>(startGrapheme);
    map['end_grapheme'] = Variable<int>(endGrapheme);
    {
      map['color_token'] = Variable<String>(
        $IpaHighlightsTable.$convertercolorToken.toSql(colorToken),
      );
    }
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    {
      map['created_at'] = Variable<int>(
        $IpaHighlightsTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    return map;
  }

  IpaHighlightsCompanion toCompanion(bool nullToAbsent) {
    return IpaHighlightsCompanion(
      id: Value(id),
      wordId: Value(wordId),
      target: Value(target),
      startGrapheme: Value(startGrapheme),
      endGrapheme: Value(endGrapheme),
      colorToken: Value(colorToken),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
      createdAt: Value(createdAt),
    );
  }

  factory IpaHighlightRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IpaHighlightRow(
      id: serializer.fromJson<String>(json['id']),
      wordId: serializer.fromJson<String>(json['wordId']),
      target: serializer.fromJson<HighlightTarget>(json['target']),
      startGrapheme: serializer.fromJson<int>(json['startGrapheme']),
      endGrapheme: serializer.fromJson<int>(json['endGrapheme']),
      colorToken: serializer.fromJson<IpaColorToken>(json['colorToken']),
      label: serializer.fromJson<String?>(json['label']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'wordId': serializer.toJson<String>(wordId),
      'target': serializer.toJson<HighlightTarget>(target),
      'startGrapheme': serializer.toJson<int>(startGrapheme),
      'endGrapheme': serializer.toJson<int>(endGrapheme),
      'colorToken': serializer.toJson<IpaColorToken>(colorToken),
      'label': serializer.toJson<String?>(label),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  IpaHighlightRow copyWith({
    String? id,
    String? wordId,
    HighlightTarget? target,
    int? startGrapheme,
    int? endGrapheme,
    IpaColorToken? colorToken,
    Value<String?> label = const Value.absent(),
    DateTime? createdAt,
  }) => IpaHighlightRow(
    id: id ?? this.id,
    wordId: wordId ?? this.wordId,
    target: target ?? this.target,
    startGrapheme: startGrapheme ?? this.startGrapheme,
    endGrapheme: endGrapheme ?? this.endGrapheme,
    colorToken: colorToken ?? this.colorToken,
    label: label.present ? label.value : this.label,
    createdAt: createdAt ?? this.createdAt,
  );
  IpaHighlightRow copyWithCompanion(IpaHighlightsCompanion data) {
    return IpaHighlightRow(
      id: data.id.present ? data.id.value : this.id,
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      target: data.target.present ? data.target.value : this.target,
      startGrapheme: data.startGrapheme.present
          ? data.startGrapheme.value
          : this.startGrapheme,
      endGrapheme: data.endGrapheme.present
          ? data.endGrapheme.value
          : this.endGrapheme,
      colorToken: data.colorToken.present
          ? data.colorToken.value
          : this.colorToken,
      label: data.label.present ? data.label.value : this.label,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IpaHighlightRow(')
          ..write('id: $id, ')
          ..write('wordId: $wordId, ')
          ..write('target: $target, ')
          ..write('startGrapheme: $startGrapheme, ')
          ..write('endGrapheme: $endGrapheme, ')
          ..write('colorToken: $colorToken, ')
          ..write('label: $label, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    wordId,
    target,
    startGrapheme,
    endGrapheme,
    colorToken,
    label,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IpaHighlightRow &&
          other.id == this.id &&
          other.wordId == this.wordId &&
          other.target == this.target &&
          other.startGrapheme == this.startGrapheme &&
          other.endGrapheme == this.endGrapheme &&
          other.colorToken == this.colorToken &&
          other.label == this.label &&
          other.createdAt == this.createdAt);
}

class IpaHighlightsCompanion extends UpdateCompanion<IpaHighlightRow> {
  final Value<String> id;
  final Value<String> wordId;
  final Value<HighlightTarget> target;
  final Value<int> startGrapheme;
  final Value<int> endGrapheme;
  final Value<IpaColorToken> colorToken;
  final Value<String?> label;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const IpaHighlightsCompanion({
    this.id = const Value.absent(),
    this.wordId = const Value.absent(),
    this.target = const Value.absent(),
    this.startGrapheme = const Value.absent(),
    this.endGrapheme = const Value.absent(),
    this.colorToken = const Value.absent(),
    this.label = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IpaHighlightsCompanion.insert({
    required String id,
    required String wordId,
    required HighlightTarget target,
    required int startGrapheme,
    required int endGrapheme,
    required IpaColorToken colorToken,
    this.label = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       wordId = Value(wordId),
       target = Value(target),
       startGrapheme = Value(startGrapheme),
       endGrapheme = Value(endGrapheme),
       colorToken = Value(colorToken),
       createdAt = Value(createdAt);
  static Insertable<IpaHighlightRow> custom({
    Expression<String>? id,
    Expression<String>? wordId,
    Expression<String>? target,
    Expression<int>? startGrapheme,
    Expression<int>? endGrapheme,
    Expression<String>? colorToken,
    Expression<String>? label,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (wordId != null) 'word_id': wordId,
      if (target != null) 'target': target,
      if (startGrapheme != null) 'start_grapheme': startGrapheme,
      if (endGrapheme != null) 'end_grapheme': endGrapheme,
      if (colorToken != null) 'color_token': colorToken,
      if (label != null) 'label': label,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IpaHighlightsCompanion copyWith({
    Value<String>? id,
    Value<String>? wordId,
    Value<HighlightTarget>? target,
    Value<int>? startGrapheme,
    Value<int>? endGrapheme,
    Value<IpaColorToken>? colorToken,
    Value<String?>? label,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return IpaHighlightsCompanion(
      id: id ?? this.id,
      wordId: wordId ?? this.wordId,
      target: target ?? this.target,
      startGrapheme: startGrapheme ?? this.startGrapheme,
      endGrapheme: endGrapheme ?? this.endGrapheme,
      colorToken: colorToken ?? this.colorToken,
      label: label ?? this.label,
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
    if (wordId.present) {
      map['word_id'] = Variable<String>(wordId.value);
    }
    if (target.present) {
      map['target'] = Variable<String>(
        $IpaHighlightsTable.$convertertarget.toSql(target.value),
      );
    }
    if (startGrapheme.present) {
      map['start_grapheme'] = Variable<int>(startGrapheme.value);
    }
    if (endGrapheme.present) {
      map['end_grapheme'] = Variable<int>(endGrapheme.value);
    }
    if (colorToken.present) {
      map['color_token'] = Variable<String>(
        $IpaHighlightsTable.$convertercolorToken.toSql(colorToken.value),
      );
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $IpaHighlightsTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IpaHighlightsCompanion(')
          ..write('id: $id, ')
          ..write('wordId: $wordId, ')
          ..write('target: $target, ')
          ..write('startGrapheme: $startGrapheme, ')
          ..write('endGrapheme: $endGrapheme, ')
          ..write('colorToken: $colorToken, ')
          ..write('label: $label, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WordListsTable extends WordLists
    with TableInfo<$WordListsTable, WordListRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordListsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  @override
  late final GeneratedColumnWithTypeConverter<IpaColorToken, String>
  colorToken = GeneratedColumn<String>(
    'color_token',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<IpaColorToken>($WordListsTable.$convertercolorToken);
  static const VerificationMeta _iconKeyMeta = const VerificationMeta(
    'iconKey',
  );
  @override
  late final GeneratedColumn<String> iconKey = GeneratedColumn<String>(
    'icon_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($WordListsTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($WordListsTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<ListKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('list'),
      ).withConverter<ListKind>($WordListsTable.$converterkind);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    colorToken,
    iconKey,
    sortOrder,
    createdAt,
    updatedAt,
    kind,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'word_lists';
  @override
  VerificationContext validateIntegrity(
    Insertable<WordListRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_key')) {
      context.handle(
        _iconKeyMeta,
        iconKey.isAcceptableOrUnknown(data['icon_key']!, _iconKeyMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WordListRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WordListRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      colorToken: $WordListsTable.$convertercolorToken.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}color_token'],
        )!,
      ),
      iconKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_key'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: $WordListsTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $WordListsTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      kind: $WordListsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
    );
  }

  @override
  $WordListsTable createAlias(String alias) {
    return $WordListsTable(attachedDatabase, alias);
  }

  static TypeConverter<IpaColorToken, String> $convertercolorToken =
      ipaColorTokenConverter;
  static TypeConverter<DateTime, int> $convertercreatedAt =
      epochMillisConverter;
  static TypeConverter<DateTime, int> $converterupdatedAt =
      epochMillisConverter;
  static JsonTypeConverter2<ListKind, String, String> $converterkind =
      const EnumNameConverter<ListKind>(ListKind.values);
}

class WordListRow extends DataClass implements Insertable<WordListRow> {
  /// UUID v4.
  final String id;

  /// What the user called it.
  final String name;

  /// Card colour, by token name - the same palette the highlights use.
  final IpaColorToken colorToken;

  /// Optional icon identifier, for a later release.
  final String? iconKey;

  /// Position in the grid; lower sorts first.
  final int sortOrder;

  /// Epoch milliseconds UTC.
  final DateTime createdAt;

  /// Epoch milliseconds UTC.
  final DateTime updatedAt;

  /// `list` or `tag`. Added at v4; every row from before then is a list.
  final ListKind kind;
  const WordListRow({
    required this.id,
    required this.name,
    required this.colorToken,
    this.iconKey,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    required this.kind,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    {
      map['color_token'] = Variable<String>(
        $WordListsTable.$convertercolorToken.toSql(colorToken),
      );
    }
    if (!nullToAbsent || iconKey != null) {
      map['icon_key'] = Variable<String>(iconKey);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    {
      map['created_at'] = Variable<int>(
        $WordListsTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<int>(
        $WordListsTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    {
      map['kind'] = Variable<String>(
        $WordListsTable.$converterkind.toSql(kind),
      );
    }
    return map;
  }

  WordListsCompanion toCompanion(bool nullToAbsent) {
    return WordListsCompanion(
      id: Value(id),
      name: Value(name),
      colorToken: Value(colorToken),
      iconKey: iconKey == null && nullToAbsent
          ? const Value.absent()
          : Value(iconKey),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      kind: Value(kind),
    );
  }

  factory WordListRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WordListRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      colorToken: serializer.fromJson<IpaColorToken>(json['colorToken']),
      iconKey: serializer.fromJson<String?>(json['iconKey']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      kind: $WordListsTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'colorToken': serializer.toJson<IpaColorToken>(colorToken),
      'iconKey': serializer.toJson<String?>(iconKey),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'kind': serializer.toJson<String>(
        $WordListsTable.$converterkind.toJson(kind),
      ),
    };
  }

  WordListRow copyWith({
    String? id,
    String? name,
    IpaColorToken? colorToken,
    Value<String?> iconKey = const Value.absent(),
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    ListKind? kind,
  }) => WordListRow(
    id: id ?? this.id,
    name: name ?? this.name,
    colorToken: colorToken ?? this.colorToken,
    iconKey: iconKey.present ? iconKey.value : this.iconKey,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    kind: kind ?? this.kind,
  );
  WordListRow copyWithCompanion(WordListsCompanion data) {
    return WordListRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      colorToken: data.colorToken.present
          ? data.colorToken.value
          : this.colorToken,
      iconKey: data.iconKey.present ? data.iconKey.value : this.iconKey,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      kind: data.kind.present ? data.kind.value : this.kind,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WordListRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorToken: $colorToken, ')
          ..write('iconKey: $iconKey, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('kind: $kind')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    colorToken,
    iconKey,
    sortOrder,
    createdAt,
    updatedAt,
    kind,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordListRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.colorToken == this.colorToken &&
          other.iconKey == this.iconKey &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.kind == this.kind);
}

class WordListsCompanion extends UpdateCompanion<WordListRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<IpaColorToken> colorToken;
  final Value<String?> iconKey;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<ListKind> kind;
  final Value<int> rowid;
  const WordListsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.colorToken = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.kind = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WordListsCompanion.insert({
    required String id,
    required String name,
    required IpaColorToken colorToken,
    this.iconKey = const Value.absent(),
    required int sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.kind = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       colorToken = Value(colorToken),
       sortOrder = Value(sortOrder),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<WordListRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? colorToken,
    Expression<String>? iconKey,
    Expression<int>? sortOrder,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? kind,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (colorToken != null) 'color_token': colorToken,
      if (iconKey != null) 'icon_key': iconKey,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (kind != null) 'kind': kind,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WordListsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<IpaColorToken>? colorToken,
    Value<String?>? iconKey,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<ListKind>? kind,
    Value<int>? rowid,
  }) {
    return WordListsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      colorToken: colorToken ?? this.colorToken,
      iconKey: iconKey ?? this.iconKey,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      kind: kind ?? this.kind,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (colorToken.present) {
      map['color_token'] = Variable<String>(
        $WordListsTable.$convertercolorToken.toSql(colorToken.value),
      );
    }
    if (iconKey.present) {
      map['icon_key'] = Variable<String>(iconKey.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $WordListsTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        $WordListsTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $WordListsTable.$converterkind.toSql(kind.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordListsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorToken: $colorToken, ')
          ..write('iconKey: $iconKey, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('kind: $kind, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WordListItemsTable extends WordListItems
    with TableInfo<$WordListItemsTable, WordListItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordListItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _listIdMeta = const VerificationMeta('listId');
  @override
  late final GeneratedColumn<String> listId = GeneratedColumn<String>(
    'list_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES word_lists (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<String> wordId = GeneratedColumn<String>(
    'word_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES words (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> addedAt =
      GeneratedColumn<int>(
        'added_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($WordListItemsTable.$converteraddedAt);
  @override
  List<GeneratedColumn> get $columns => [listId, wordId, addedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'word_list_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<WordListItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('list_id')) {
      context.handle(
        _listIdMeta,
        listId.isAcceptableOrUnknown(data['list_id']!, _listIdMeta),
      );
    } else if (isInserting) {
      context.missing(_listIdMeta);
    }
    if (data.containsKey('word_id')) {
      context.handle(
        _wordIdMeta,
        wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_wordIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {listId, wordId};
  @override
  WordListItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WordListItemRow(
      listId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}list_id'],
      )!,
      wordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}word_id'],
      )!,
      addedAt: $WordListItemsTable.$converteraddedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}added_at'],
        )!,
      ),
    );
  }

  @override
  $WordListItemsTable createAlias(String alias) {
    return $WordListItemsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $converteraddedAt = epochMillisConverter;
}

class WordListItemRow extends DataClass implements Insertable<WordListItemRow> {
  /// Owning list. Cascades.
  final String listId;

  /// Member word. Cascades.
  final String wordId;

  /// Epoch milliseconds UTC.
  final DateTime addedAt;
  const WordListItemRow({
    required this.listId,
    required this.wordId,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['list_id'] = Variable<String>(listId);
    map['word_id'] = Variable<String>(wordId);
    {
      map['added_at'] = Variable<int>(
        $WordListItemsTable.$converteraddedAt.toSql(addedAt),
      );
    }
    return map;
  }

  WordListItemsCompanion toCompanion(bool nullToAbsent) {
    return WordListItemsCompanion(
      listId: Value(listId),
      wordId: Value(wordId),
      addedAt: Value(addedAt),
    );
  }

  factory WordListItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WordListItemRow(
      listId: serializer.fromJson<String>(json['listId']),
      wordId: serializer.fromJson<String>(json['wordId']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'listId': serializer.toJson<String>(listId),
      'wordId': serializer.toJson<String>(wordId),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  WordListItemRow copyWith({
    String? listId,
    String? wordId,
    DateTime? addedAt,
  }) => WordListItemRow(
    listId: listId ?? this.listId,
    wordId: wordId ?? this.wordId,
    addedAt: addedAt ?? this.addedAt,
  );
  WordListItemRow copyWithCompanion(WordListItemsCompanion data) {
    return WordListItemRow(
      listId: data.listId.present ? data.listId.value : this.listId,
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WordListItemRow(')
          ..write('listId: $listId, ')
          ..write('wordId: $wordId, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(listId, wordId, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordListItemRow &&
          other.listId == this.listId &&
          other.wordId == this.wordId &&
          other.addedAt == this.addedAt);
}

class WordListItemsCompanion extends UpdateCompanion<WordListItemRow> {
  final Value<String> listId;
  final Value<String> wordId;
  final Value<DateTime> addedAt;
  final Value<int> rowid;
  const WordListItemsCompanion({
    this.listId = const Value.absent(),
    this.wordId = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WordListItemsCompanion.insert({
    required String listId,
    required String wordId,
    required DateTime addedAt,
    this.rowid = const Value.absent(),
  }) : listId = Value(listId),
       wordId = Value(wordId),
       addedAt = Value(addedAt);
  static Insertable<WordListItemRow> custom({
    Expression<String>? listId,
    Expression<String>? wordId,
    Expression<int>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (listId != null) 'list_id': listId,
      if (wordId != null) 'word_id': wordId,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WordListItemsCompanion copyWith({
    Value<String>? listId,
    Value<String>? wordId,
    Value<DateTime>? addedAt,
    Value<int>? rowid,
  }) {
    return WordListItemsCompanion(
      listId: listId ?? this.listId,
      wordId: wordId ?? this.wordId,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (listId.present) {
      map['list_id'] = Variable<String>(listId.value);
    }
    if (wordId.present) {
      map['word_id'] = Variable<String>(wordId.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<int>(
        $WordListItemsTable.$converteraddedAt.toSql(addedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordListItemsCompanion(')
          ..write('listId: $listId, ')
          ..write('wordId: $wordId, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StudyCardsTable extends StudyCards
    with TableInfo<$StudyCardsTable, StudyCardRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudyCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<String> wordId = GeneratedColumn<String>(
    'word_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES words (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _boxMeta = const VerificationMeta('box');
  @override
  late final GeneratedColumn<int> box = GeneratedColumn<int>(
    'box',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> dueAt =
      GeneratedColumn<int>(
        'due_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($StudyCardsTable.$converterdueAt);
  static const VerificationMeta _intervalDaysMeta = const VerificationMeta(
    'intervalDays',
  );
  @override
  late final GeneratedColumn<int> intervalDays = GeneratedColumn<int>(
    'interval_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _easeFactorMeta = const VerificationMeta(
    'easeFactor',
  );
  @override
  late final GeneratedColumn<double> easeFactor = GeneratedColumn<double>(
    'ease_factor',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(2.5),
  );
  static const VerificationMeta _repetitionsMeta = const VerificationMeta(
    'repetitions',
  );
  @override
  late final GeneratedColumn<int> repetitions = GeneratedColumn<int>(
    'repetitions',
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
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> lastReviewedAt =
      GeneratedColumn<int>(
        'last_reviewed_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($StudyCardsTable.$converterlastReviewedAt);
  @override
  late final GeneratedColumnWithTypeConverter<ReviewOutcome?, String>
  lastResult = GeneratedColumn<String>(
    'last_result',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<ReviewOutcome?>($StudyCardsTable.$converterlastResult);
  static const VerificationMeta _suspendedMeta = const VerificationMeta(
    'suspended',
  );
  @override
  late final GeneratedColumn<bool> suspended = GeneratedColumn<bool>(
    'suspended',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("suspended" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    wordId,
    box,
    dueAt,
    intervalDays,
    easeFactor,
    repetitions,
    lapses,
    lastReviewedAt,
    lastResult,
    suspended,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'study_cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<StudyCardRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('word_id')) {
      context.handle(
        _wordIdMeta,
        wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_wordIdMeta);
    }
    if (data.containsKey('box')) {
      context.handle(
        _boxMeta,
        box.isAcceptableOrUnknown(data['box']!, _boxMeta),
      );
    }
    if (data.containsKey('interval_days')) {
      context.handle(
        _intervalDaysMeta,
        intervalDays.isAcceptableOrUnknown(
          data['interval_days']!,
          _intervalDaysMeta,
        ),
      );
    }
    if (data.containsKey('ease_factor')) {
      context.handle(
        _easeFactorMeta,
        easeFactor.isAcceptableOrUnknown(data['ease_factor']!, _easeFactorMeta),
      );
    }
    if (data.containsKey('repetitions')) {
      context.handle(
        _repetitionsMeta,
        repetitions.isAcceptableOrUnknown(
          data['repetitions']!,
          _repetitionsMeta,
        ),
      );
    }
    if (data.containsKey('lapses')) {
      context.handle(
        _lapsesMeta,
        lapses.isAcceptableOrUnknown(data['lapses']!, _lapsesMeta),
      );
    }
    if (data.containsKey('suspended')) {
      context.handle(
        _suspendedMeta,
        suspended.isAcceptableOrUnknown(data['suspended']!, _suspendedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {wordId};
  @override
  StudyCardRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudyCardRow(
      wordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}word_id'],
      )!,
      box: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}box'],
      )!,
      dueAt: $StudyCardsTable.$converterdueAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}due_at'],
        )!,
      ),
      intervalDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_days'],
      )!,
      easeFactor: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ease_factor'],
      )!,
      repetitions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repetitions'],
      )!,
      lapses: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lapses'],
      )!,
      lastReviewedAt: $StudyCardsTable.$converterlastReviewedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}last_reviewed_at'],
        ),
      ),
      lastResult: $StudyCardsTable.$converterlastResult.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}last_result'],
        ),
      ),
      suspended: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}suspended'],
      )!,
    );
  }

  @override
  $StudyCardsTable createAlias(String alias) {
    return $StudyCardsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $converterdueAt = epochMillisConverter;
  static TypeConverter<DateTime?, int?> $converterlastReviewedAt =
      nullableEpochMillisConverter;
  static TypeConverter<ReviewOutcome?, String?> $converterlastResult =
      nullableReviewOutcomeConverter;
}

class StudyCardRow extends DataClass implements Insertable<StudyCardRow> {
  /// The word this card is for - also the primary key, so the one-card-per-word
  /// rule is structural rather than a convention someone can forget.
  final String wordId;

  /// Leitner box, 0-6 (`docs/GAMES.md` §5).
  final int box;

  /// When the card next comes up. Epoch milliseconds UTC.
  final DateTime dueAt;

  /// The interval that produced [dueAt], in days.
  final int intervalDays;

  /// SM-2 ease. Present, unused in v1.
  final double easeFactor;

  /// How many times the card has been reviewed.
  final int repetitions;

  /// How many times the user answered `again`.
  final int lapses;

  /// Epoch milliseconds UTC, or null if never reviewed.
  final DateTime? lastReviewedAt;

  /// `again` | `good` | `easy`, or null if never reviewed.
  final ReviewOutcome? lastResult;

  /// Suspended cards never appear in a due pool.
  final bool suspended;
  const StudyCardRow({
    required this.wordId,
    required this.box,
    required this.dueAt,
    required this.intervalDays,
    required this.easeFactor,
    required this.repetitions,
    required this.lapses,
    this.lastReviewedAt,
    this.lastResult,
    required this.suspended,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['word_id'] = Variable<String>(wordId);
    map['box'] = Variable<int>(box);
    {
      map['due_at'] = Variable<int>(
        $StudyCardsTable.$converterdueAt.toSql(dueAt),
      );
    }
    map['interval_days'] = Variable<int>(intervalDays);
    map['ease_factor'] = Variable<double>(easeFactor);
    map['repetitions'] = Variable<int>(repetitions);
    map['lapses'] = Variable<int>(lapses);
    if (!nullToAbsent || lastReviewedAt != null) {
      map['last_reviewed_at'] = Variable<int>(
        $StudyCardsTable.$converterlastReviewedAt.toSql(lastReviewedAt),
      );
    }
    if (!nullToAbsent || lastResult != null) {
      map['last_result'] = Variable<String>(
        $StudyCardsTable.$converterlastResult.toSql(lastResult),
      );
    }
    map['suspended'] = Variable<bool>(suspended);
    return map;
  }

  StudyCardsCompanion toCompanion(bool nullToAbsent) {
    return StudyCardsCompanion(
      wordId: Value(wordId),
      box: Value(box),
      dueAt: Value(dueAt),
      intervalDays: Value(intervalDays),
      easeFactor: Value(easeFactor),
      repetitions: Value(repetitions),
      lapses: Value(lapses),
      lastReviewedAt: lastReviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReviewedAt),
      lastResult: lastResult == null && nullToAbsent
          ? const Value.absent()
          : Value(lastResult),
      suspended: Value(suspended),
    );
  }

  factory StudyCardRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudyCardRow(
      wordId: serializer.fromJson<String>(json['wordId']),
      box: serializer.fromJson<int>(json['box']),
      dueAt: serializer.fromJson<DateTime>(json['dueAt']),
      intervalDays: serializer.fromJson<int>(json['intervalDays']),
      easeFactor: serializer.fromJson<double>(json['easeFactor']),
      repetitions: serializer.fromJson<int>(json['repetitions']),
      lapses: serializer.fromJson<int>(json['lapses']),
      lastReviewedAt: serializer.fromJson<DateTime?>(json['lastReviewedAt']),
      lastResult: serializer.fromJson<ReviewOutcome?>(json['lastResult']),
      suspended: serializer.fromJson<bool>(json['suspended']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'wordId': serializer.toJson<String>(wordId),
      'box': serializer.toJson<int>(box),
      'dueAt': serializer.toJson<DateTime>(dueAt),
      'intervalDays': serializer.toJson<int>(intervalDays),
      'easeFactor': serializer.toJson<double>(easeFactor),
      'repetitions': serializer.toJson<int>(repetitions),
      'lapses': serializer.toJson<int>(lapses),
      'lastReviewedAt': serializer.toJson<DateTime?>(lastReviewedAt),
      'lastResult': serializer.toJson<ReviewOutcome?>(lastResult),
      'suspended': serializer.toJson<bool>(suspended),
    };
  }

  StudyCardRow copyWith({
    String? wordId,
    int? box,
    DateTime? dueAt,
    int? intervalDays,
    double? easeFactor,
    int? repetitions,
    int? lapses,
    Value<DateTime?> lastReviewedAt = const Value.absent(),
    Value<ReviewOutcome?> lastResult = const Value.absent(),
    bool? suspended,
  }) => StudyCardRow(
    wordId: wordId ?? this.wordId,
    box: box ?? this.box,
    dueAt: dueAt ?? this.dueAt,
    intervalDays: intervalDays ?? this.intervalDays,
    easeFactor: easeFactor ?? this.easeFactor,
    repetitions: repetitions ?? this.repetitions,
    lapses: lapses ?? this.lapses,
    lastReviewedAt: lastReviewedAt.present
        ? lastReviewedAt.value
        : this.lastReviewedAt,
    lastResult: lastResult.present ? lastResult.value : this.lastResult,
    suspended: suspended ?? this.suspended,
  );
  StudyCardRow copyWithCompanion(StudyCardsCompanion data) {
    return StudyCardRow(
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      box: data.box.present ? data.box.value : this.box,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      intervalDays: data.intervalDays.present
          ? data.intervalDays.value
          : this.intervalDays,
      easeFactor: data.easeFactor.present
          ? data.easeFactor.value
          : this.easeFactor,
      repetitions: data.repetitions.present
          ? data.repetitions.value
          : this.repetitions,
      lapses: data.lapses.present ? data.lapses.value : this.lapses,
      lastReviewedAt: data.lastReviewedAt.present
          ? data.lastReviewedAt.value
          : this.lastReviewedAt,
      lastResult: data.lastResult.present
          ? data.lastResult.value
          : this.lastResult,
      suspended: data.suspended.present ? data.suspended.value : this.suspended,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudyCardRow(')
          ..write('wordId: $wordId, ')
          ..write('box: $box, ')
          ..write('dueAt: $dueAt, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('repetitions: $repetitions, ')
          ..write('lapses: $lapses, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('lastResult: $lastResult, ')
          ..write('suspended: $suspended')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    wordId,
    box,
    dueAt,
    intervalDays,
    easeFactor,
    repetitions,
    lapses,
    lastReviewedAt,
    lastResult,
    suspended,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudyCardRow &&
          other.wordId == this.wordId &&
          other.box == this.box &&
          other.dueAt == this.dueAt &&
          other.intervalDays == this.intervalDays &&
          other.easeFactor == this.easeFactor &&
          other.repetitions == this.repetitions &&
          other.lapses == this.lapses &&
          other.lastReviewedAt == this.lastReviewedAt &&
          other.lastResult == this.lastResult &&
          other.suspended == this.suspended);
}

class StudyCardsCompanion extends UpdateCompanion<StudyCardRow> {
  final Value<String> wordId;
  final Value<int> box;
  final Value<DateTime> dueAt;
  final Value<int> intervalDays;
  final Value<double> easeFactor;
  final Value<int> repetitions;
  final Value<int> lapses;
  final Value<DateTime?> lastReviewedAt;
  final Value<ReviewOutcome?> lastResult;
  final Value<bool> suspended;
  final Value<int> rowid;
  const StudyCardsCompanion({
    this.wordId = const Value.absent(),
    this.box = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.easeFactor = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.lapses = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.lastResult = const Value.absent(),
    this.suspended = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudyCardsCompanion.insert({
    required String wordId,
    this.box = const Value.absent(),
    required DateTime dueAt,
    this.intervalDays = const Value.absent(),
    this.easeFactor = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.lapses = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.lastResult = const Value.absent(),
    this.suspended = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : wordId = Value(wordId),
       dueAt = Value(dueAt);
  static Insertable<StudyCardRow> custom({
    Expression<String>? wordId,
    Expression<int>? box,
    Expression<int>? dueAt,
    Expression<int>? intervalDays,
    Expression<double>? easeFactor,
    Expression<int>? repetitions,
    Expression<int>? lapses,
    Expression<int>? lastReviewedAt,
    Expression<String>? lastResult,
    Expression<bool>? suspended,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (wordId != null) 'word_id': wordId,
      if (box != null) 'box': box,
      if (dueAt != null) 'due_at': dueAt,
      if (intervalDays != null) 'interval_days': intervalDays,
      if (easeFactor != null) 'ease_factor': easeFactor,
      if (repetitions != null) 'repetitions': repetitions,
      if (lapses != null) 'lapses': lapses,
      if (lastReviewedAt != null) 'last_reviewed_at': lastReviewedAt,
      if (lastResult != null) 'last_result': lastResult,
      if (suspended != null) 'suspended': suspended,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudyCardsCompanion copyWith({
    Value<String>? wordId,
    Value<int>? box,
    Value<DateTime>? dueAt,
    Value<int>? intervalDays,
    Value<double>? easeFactor,
    Value<int>? repetitions,
    Value<int>? lapses,
    Value<DateTime?>? lastReviewedAt,
    Value<ReviewOutcome?>? lastResult,
    Value<bool>? suspended,
    Value<int>? rowid,
  }) {
    return StudyCardsCompanion(
      wordId: wordId ?? this.wordId,
      box: box ?? this.box,
      dueAt: dueAt ?? this.dueAt,
      intervalDays: intervalDays ?? this.intervalDays,
      easeFactor: easeFactor ?? this.easeFactor,
      repetitions: repetitions ?? this.repetitions,
      lapses: lapses ?? this.lapses,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      lastResult: lastResult ?? this.lastResult,
      suspended: suspended ?? this.suspended,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (wordId.present) {
      map['word_id'] = Variable<String>(wordId.value);
    }
    if (box.present) {
      map['box'] = Variable<int>(box.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<int>(
        $StudyCardsTable.$converterdueAt.toSql(dueAt.value),
      );
    }
    if (intervalDays.present) {
      map['interval_days'] = Variable<int>(intervalDays.value);
    }
    if (easeFactor.present) {
      map['ease_factor'] = Variable<double>(easeFactor.value);
    }
    if (repetitions.present) {
      map['repetitions'] = Variable<int>(repetitions.value);
    }
    if (lapses.present) {
      map['lapses'] = Variable<int>(lapses.value);
    }
    if (lastReviewedAt.present) {
      map['last_reviewed_at'] = Variable<int>(
        $StudyCardsTable.$converterlastReviewedAt.toSql(lastReviewedAt.value),
      );
    }
    if (lastResult.present) {
      map['last_result'] = Variable<String>(
        $StudyCardsTable.$converterlastResult.toSql(lastResult.value),
      );
    }
    if (suspended.present) {
      map['suspended'] = Variable<bool>(suspended.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudyCardsCompanion(')
          ..write('wordId: $wordId, ')
          ..write('box: $box, ')
          ..write('dueAt: $dueAt, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('repetitions: $repetitions, ')
          ..write('lapses: $lapses, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('lastResult: $lastResult, ')
          ..write('suspended: $suspended, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PracticeSessionsTable extends PracticeSessions
    with TableInfo<$PracticeSessionsTable, PracticeSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PracticeSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PracticeMode, String> mode =
      GeneratedColumn<String>(
        'mode',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PracticeMode>($PracticeSessionsTable.$convertermode);
  @override
  late final GeneratedColumnWithTypeConverter<CardSourceKind, String>
  sourceKind = GeneratedColumn<String>(
    'source_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<CardSourceKind>($PracticeSessionsTable.$convertersourceKind);
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _configJsonMeta = const VerificationMeta(
    'configJson',
  );
  @override
  late final GeneratedColumn<String> configJson = GeneratedColumn<String>(
    'config_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> startedAt =
      GeneratedColumn<int>(
        'started_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($PracticeSessionsTable.$converterstartedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> endedAt =
      GeneratedColumn<int>(
        'ended_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($PracticeSessionsTable.$converterendedAt);
  static const VerificationMeta _totalRoundsMeta = const VerificationMeta(
    'totalRounds',
  );
  @override
  late final GeneratedColumn<int> totalRounds = GeneratedColumn<int>(
    'total_rounds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _correctRoundsMeta = const VerificationMeta(
    'correctRounds',
  );
  @override
  late final GeneratedColumn<int> correctRounds = GeneratedColumn<int>(
    'correct_rounds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _affectsSchedulingMeta = const VerificationMeta(
    'affectsScheduling',
  );
  @override
  late final GeneratedColumn<bool> affectsScheduling = GeneratedColumn<bool>(
    'affects_scheduling',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("affects_scheduling" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gameId,
    mode,
    sourceKind,
    sourceId,
    configJson,
    startedAt,
    endedAt,
    totalRounds,
    correctRounds,
    affectsScheduling,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'practice_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<PracticeSessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    }
    if (data.containsKey('config_json')) {
      context.handle(
        _configJsonMeta,
        configJson.isAcceptableOrUnknown(data['config_json']!, _configJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_configJsonMeta);
    }
    if (data.containsKey('total_rounds')) {
      context.handle(
        _totalRoundsMeta,
        totalRounds.isAcceptableOrUnknown(
          data['total_rounds']!,
          _totalRoundsMeta,
        ),
      );
    }
    if (data.containsKey('correct_rounds')) {
      context.handle(
        _correctRoundsMeta,
        correctRounds.isAcceptableOrUnknown(
          data['correct_rounds']!,
          _correctRoundsMeta,
        ),
      );
    }
    if (data.containsKey('affects_scheduling')) {
      context.handle(
        _affectsSchedulingMeta,
        affectsScheduling.isAcceptableOrUnknown(
          data['affects_scheduling']!,
          _affectsSchedulingMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_affectsSchedulingMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PracticeSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PracticeSessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_id'],
      )!,
      mode: $PracticeSessionsTable.$convertermode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}mode'],
        )!,
      ),
      sourceKind: $PracticeSessionsTable.$convertersourceKind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source_kind'],
        )!,
      ),
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      ),
      configJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}config_json'],
      )!,
      startedAt: $PracticeSessionsTable.$converterstartedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}started_at'],
        )!,
      ),
      endedAt: $PracticeSessionsTable.$converterendedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}ended_at'],
        ),
      ),
      totalRounds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_rounds'],
      )!,
      correctRounds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct_rounds'],
      )!,
      affectsScheduling: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}affects_scheduling'],
      )!,
    );
  }

  @override
  $PracticeSessionsTable createAlias(String alias) {
    return $PracticeSessionsTable(attachedDatabase, alias);
  }

  static TypeConverter<PracticeMode, String> $convertermode =
      practiceModeConverter;
  static TypeConverter<CardSourceKind, String> $convertersourceKind =
      cardSourceKindConverter;
  static TypeConverter<DateTime, int> $converterstartedAt =
      epochMillisConverter;
  static TypeConverter<DateTime?, int?> $converterendedAt =
      nullableEpochMillisConverter;
}

class PracticeSessionRow extends DataClass
    implements Insertable<PracticeSessionRow> {
  /// UUID v4.
  final String id;

  /// Which game ran, e.g. `flashcard`. Stable across releases, so a session
  /// recorded by an older build stays attributable.
  final String gameId;

  /// `daily` or `quick_test`.
  final PracticeMode mode;

  /// `all`, `list` or `favourites`.
  final CardSourceKind sourceKind;

  /// The list id when [sourceKind] is `list`.
  ///
  /// Deliberately **not** a foreign key: deleting a list must not erase the
  /// history of having practised it. A dangling id here is expected, and is
  /// handled when the summary is rendered.
  final String? sourceId;

  /// The full `GameConfig` as JSON. Readers tolerate unknown keys, so a
  /// session written by a newer build stays readable (`docs/GAMES.md` section
  /// 2).
  final String configJson;

  /// Epoch milliseconds UTC.
  final DateTime startedAt;

  /// Null while the session is running, or if the user abandoned it.
  final DateTime? endedAt;

  /// How many rounds were played.
  final int totalRounds;

  /// How many were answered `good` or `easy`.
  final int correctRounds;

  /// Whether this session applied the review schedule.
  final bool affectsScheduling;
  const PracticeSessionRow({
    required this.id,
    required this.gameId,
    required this.mode,
    required this.sourceKind,
    this.sourceId,
    required this.configJson,
    required this.startedAt,
    this.endedAt,
    required this.totalRounds,
    required this.correctRounds,
    required this.affectsScheduling,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['game_id'] = Variable<String>(gameId);
    {
      map['mode'] = Variable<String>(
        $PracticeSessionsTable.$convertermode.toSql(mode),
      );
    }
    {
      map['source_kind'] = Variable<String>(
        $PracticeSessionsTable.$convertersourceKind.toSql(sourceKind),
      );
    }
    if (!nullToAbsent || sourceId != null) {
      map['source_id'] = Variable<String>(sourceId);
    }
    map['config_json'] = Variable<String>(configJson);
    {
      map['started_at'] = Variable<int>(
        $PracticeSessionsTable.$converterstartedAt.toSql(startedAt),
      );
    }
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<int>(
        $PracticeSessionsTable.$converterendedAt.toSql(endedAt),
      );
    }
    map['total_rounds'] = Variable<int>(totalRounds);
    map['correct_rounds'] = Variable<int>(correctRounds);
    map['affects_scheduling'] = Variable<bool>(affectsScheduling);
    return map;
  }

  PracticeSessionsCompanion toCompanion(bool nullToAbsent) {
    return PracticeSessionsCompanion(
      id: Value(id),
      gameId: Value(gameId),
      mode: Value(mode),
      sourceKind: Value(sourceKind),
      sourceId: sourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceId),
      configJson: Value(configJson),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      totalRounds: Value(totalRounds),
      correctRounds: Value(correctRounds),
      affectsScheduling: Value(affectsScheduling),
    );
  }

  factory PracticeSessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PracticeSessionRow(
      id: serializer.fromJson<String>(json['id']),
      gameId: serializer.fromJson<String>(json['gameId']),
      mode: serializer.fromJson<PracticeMode>(json['mode']),
      sourceKind: serializer.fromJson<CardSourceKind>(json['sourceKind']),
      sourceId: serializer.fromJson<String?>(json['sourceId']),
      configJson: serializer.fromJson<String>(json['configJson']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      totalRounds: serializer.fromJson<int>(json['totalRounds']),
      correctRounds: serializer.fromJson<int>(json['correctRounds']),
      affectsScheduling: serializer.fromJson<bool>(json['affectsScheduling']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'gameId': serializer.toJson<String>(gameId),
      'mode': serializer.toJson<PracticeMode>(mode),
      'sourceKind': serializer.toJson<CardSourceKind>(sourceKind),
      'sourceId': serializer.toJson<String?>(sourceId),
      'configJson': serializer.toJson<String>(configJson),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'totalRounds': serializer.toJson<int>(totalRounds),
      'correctRounds': serializer.toJson<int>(correctRounds),
      'affectsScheduling': serializer.toJson<bool>(affectsScheduling),
    };
  }

  PracticeSessionRow copyWith({
    String? id,
    String? gameId,
    PracticeMode? mode,
    CardSourceKind? sourceKind,
    Value<String?> sourceId = const Value.absent(),
    String? configJson,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    int? totalRounds,
    int? correctRounds,
    bool? affectsScheduling,
  }) => PracticeSessionRow(
    id: id ?? this.id,
    gameId: gameId ?? this.gameId,
    mode: mode ?? this.mode,
    sourceKind: sourceKind ?? this.sourceKind,
    sourceId: sourceId.present ? sourceId.value : this.sourceId,
    configJson: configJson ?? this.configJson,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    totalRounds: totalRounds ?? this.totalRounds,
    correctRounds: correctRounds ?? this.correctRounds,
    affectsScheduling: affectsScheduling ?? this.affectsScheduling,
  );
  PracticeSessionRow copyWithCompanion(PracticeSessionsCompanion data) {
    return PracticeSessionRow(
      id: data.id.present ? data.id.value : this.id,
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      mode: data.mode.present ? data.mode.value : this.mode,
      sourceKind: data.sourceKind.present
          ? data.sourceKind.value
          : this.sourceKind,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      configJson: data.configJson.present
          ? data.configJson.value
          : this.configJson,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      totalRounds: data.totalRounds.present
          ? data.totalRounds.value
          : this.totalRounds,
      correctRounds: data.correctRounds.present
          ? data.correctRounds.value
          : this.correctRounds,
      affectsScheduling: data.affectsScheduling.present
          ? data.affectsScheduling.value
          : this.affectsScheduling,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PracticeSessionRow(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('mode: $mode, ')
          ..write('sourceKind: $sourceKind, ')
          ..write('sourceId: $sourceId, ')
          ..write('configJson: $configJson, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('totalRounds: $totalRounds, ')
          ..write('correctRounds: $correctRounds, ')
          ..write('affectsScheduling: $affectsScheduling')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    gameId,
    mode,
    sourceKind,
    sourceId,
    configJson,
    startedAt,
    endedAt,
    totalRounds,
    correctRounds,
    affectsScheduling,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PracticeSessionRow &&
          other.id == this.id &&
          other.gameId == this.gameId &&
          other.mode == this.mode &&
          other.sourceKind == this.sourceKind &&
          other.sourceId == this.sourceId &&
          other.configJson == this.configJson &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.totalRounds == this.totalRounds &&
          other.correctRounds == this.correctRounds &&
          other.affectsScheduling == this.affectsScheduling);
}

class PracticeSessionsCompanion extends UpdateCompanion<PracticeSessionRow> {
  final Value<String> id;
  final Value<String> gameId;
  final Value<PracticeMode> mode;
  final Value<CardSourceKind> sourceKind;
  final Value<String?> sourceId;
  final Value<String> configJson;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<int> totalRounds;
  final Value<int> correctRounds;
  final Value<bool> affectsScheduling;
  final Value<int> rowid;
  const PracticeSessionsCompanion({
    this.id = const Value.absent(),
    this.gameId = const Value.absent(),
    this.mode = const Value.absent(),
    this.sourceKind = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.configJson = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.totalRounds = const Value.absent(),
    this.correctRounds = const Value.absent(),
    this.affectsScheduling = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PracticeSessionsCompanion.insert({
    required String id,
    required String gameId,
    required PracticeMode mode,
    required CardSourceKind sourceKind,
    this.sourceId = const Value.absent(),
    required String configJson,
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.totalRounds = const Value.absent(),
    this.correctRounds = const Value.absent(),
    required bool affectsScheduling,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       gameId = Value(gameId),
       mode = Value(mode),
       sourceKind = Value(sourceKind),
       configJson = Value(configJson),
       startedAt = Value(startedAt),
       affectsScheduling = Value(affectsScheduling);
  static Insertable<PracticeSessionRow> custom({
    Expression<String>? id,
    Expression<String>? gameId,
    Expression<String>? mode,
    Expression<String>? sourceKind,
    Expression<String>? sourceId,
    Expression<String>? configJson,
    Expression<int>? startedAt,
    Expression<int>? endedAt,
    Expression<int>? totalRounds,
    Expression<int>? correctRounds,
    Expression<bool>? affectsScheduling,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gameId != null) 'game_id': gameId,
      if (mode != null) 'mode': mode,
      if (sourceKind != null) 'source_kind': sourceKind,
      if (sourceId != null) 'source_id': sourceId,
      if (configJson != null) 'config_json': configJson,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (totalRounds != null) 'total_rounds': totalRounds,
      if (correctRounds != null) 'correct_rounds': correctRounds,
      if (affectsScheduling != null) 'affects_scheduling': affectsScheduling,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PracticeSessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? gameId,
    Value<PracticeMode>? mode,
    Value<CardSourceKind>? sourceKind,
    Value<String?>? sourceId,
    Value<String>? configJson,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<int>? totalRounds,
    Value<int>? correctRounds,
    Value<bool>? affectsScheduling,
    Value<int>? rowid,
  }) {
    return PracticeSessionsCompanion(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      mode: mode ?? this.mode,
      sourceKind: sourceKind ?? this.sourceKind,
      sourceId: sourceId ?? this.sourceId,
      configJson: configJson ?? this.configJson,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      totalRounds: totalRounds ?? this.totalRounds,
      correctRounds: correctRounds ?? this.correctRounds,
      affectsScheduling: affectsScheduling ?? this.affectsScheduling,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(
        $PracticeSessionsTable.$convertermode.toSql(mode.value),
      );
    }
    if (sourceKind.present) {
      map['source_kind'] = Variable<String>(
        $PracticeSessionsTable.$convertersourceKind.toSql(sourceKind.value),
      );
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (configJson.present) {
      map['config_json'] = Variable<String>(configJson.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(
        $PracticeSessionsTable.$converterstartedAt.toSql(startedAt.value),
      );
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<int>(
        $PracticeSessionsTable.$converterendedAt.toSql(endedAt.value),
      );
    }
    if (totalRounds.present) {
      map['total_rounds'] = Variable<int>(totalRounds.value);
    }
    if (correctRounds.present) {
      map['correct_rounds'] = Variable<int>(correctRounds.value);
    }
    if (affectsScheduling.present) {
      map['affects_scheduling'] = Variable<bool>(affectsScheduling.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PracticeSessionsCompanion(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('mode: $mode, ')
          ..write('sourceKind: $sourceKind, ')
          ..write('sourceId: $sourceId, ')
          ..write('configJson: $configJson, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('totalRounds: $totalRounds, ')
          ..write('correctRounds: $correctRounds, ')
          ..write('affectsScheduling: $affectsScheduling, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PracticeAnswersTable extends PracticeAnswers
    with TableInfo<$PracticeAnswersTable, PracticeAnswerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PracticeAnswersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES practice_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<String> wordId = GeneratedColumn<String>(
    'word_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES words (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _roundIndexMeta = const VerificationMeta(
    'roundIndex',
  );
  @override
  late final GeneratedColumn<int> roundIndex = GeneratedColumn<int>(
    'round_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ReviewOutcome, String> result =
      GeneratedColumn<String>(
        'result',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ReviewOutcome>($PracticeAnswersTable.$converterresult);
  static const VerificationMeta _responseMsMeta = const VerificationMeta(
    'responseMs',
  );
  @override
  late final GeneratedColumn<int> responseMs = GeneratedColumn<int>(
    'response_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> answeredAt =
      GeneratedColumn<int>(
        'answered_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($PracticeAnswersTable.$converteransweredAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    wordId,
    roundIndex,
    result,
    responseMs,
    answeredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'practice_answers';
  @override
  VerificationContext validateIntegrity(
    Insertable<PracticeAnswerRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('word_id')) {
      context.handle(
        _wordIdMeta,
        wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_wordIdMeta);
    }
    if (data.containsKey('round_index')) {
      context.handle(
        _roundIndexMeta,
        roundIndex.isAcceptableOrUnknown(data['round_index']!, _roundIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_roundIndexMeta);
    }
    if (data.containsKey('response_ms')) {
      context.handle(
        _responseMsMeta,
        responseMs.isAcceptableOrUnknown(data['response_ms']!, _responseMsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PracticeAnswerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PracticeAnswerRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      wordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}word_id'],
      )!,
      roundIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}round_index'],
      )!,
      result: $PracticeAnswersTable.$converterresult.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}result'],
        )!,
      ),
      responseMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}response_ms'],
      ),
      answeredAt: $PracticeAnswersTable.$converteransweredAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}answered_at'],
        )!,
      ),
    );
  }

  @override
  $PracticeAnswersTable createAlias(String alias) {
    return $PracticeAnswersTable(attachedDatabase, alias);
  }

  static TypeConverter<ReviewOutcome, String> $converterresult =
      reviewOutcomeConverter;
  static TypeConverter<DateTime, int> $converteransweredAt =
      epochMillisConverter;
}

class PracticeAnswerRow extends DataClass
    implements Insertable<PracticeAnswerRow> {
  /// UUID v4.
  final String id;

  /// Owning session. Cascades.
  final String sessionId;

  /// The word that was asked. Cascades.
  final String wordId;

  /// Zero-based position within the session.
  final int roundIndex;

  /// `again`, `good`, `easy` or `skipped`.
  final ReviewOutcome result;

  /// How long the user took, in milliseconds.
  final int? responseMs;

  /// Epoch milliseconds UTC.
  final DateTime answeredAt;
  const PracticeAnswerRow({
    required this.id,
    required this.sessionId,
    required this.wordId,
    required this.roundIndex,
    required this.result,
    this.responseMs,
    required this.answeredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['word_id'] = Variable<String>(wordId);
    map['round_index'] = Variable<int>(roundIndex);
    {
      map['result'] = Variable<String>(
        $PracticeAnswersTable.$converterresult.toSql(result),
      );
    }
    if (!nullToAbsent || responseMs != null) {
      map['response_ms'] = Variable<int>(responseMs);
    }
    {
      map['answered_at'] = Variable<int>(
        $PracticeAnswersTable.$converteransweredAt.toSql(answeredAt),
      );
    }
    return map;
  }

  PracticeAnswersCompanion toCompanion(bool nullToAbsent) {
    return PracticeAnswersCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      wordId: Value(wordId),
      roundIndex: Value(roundIndex),
      result: Value(result),
      responseMs: responseMs == null && nullToAbsent
          ? const Value.absent()
          : Value(responseMs),
      answeredAt: Value(answeredAt),
    );
  }

  factory PracticeAnswerRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PracticeAnswerRow(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      wordId: serializer.fromJson<String>(json['wordId']),
      roundIndex: serializer.fromJson<int>(json['roundIndex']),
      result: serializer.fromJson<ReviewOutcome>(json['result']),
      responseMs: serializer.fromJson<int?>(json['responseMs']),
      answeredAt: serializer.fromJson<DateTime>(json['answeredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'wordId': serializer.toJson<String>(wordId),
      'roundIndex': serializer.toJson<int>(roundIndex),
      'result': serializer.toJson<ReviewOutcome>(result),
      'responseMs': serializer.toJson<int?>(responseMs),
      'answeredAt': serializer.toJson<DateTime>(answeredAt),
    };
  }

  PracticeAnswerRow copyWith({
    String? id,
    String? sessionId,
    String? wordId,
    int? roundIndex,
    ReviewOutcome? result,
    Value<int?> responseMs = const Value.absent(),
    DateTime? answeredAt,
  }) => PracticeAnswerRow(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    wordId: wordId ?? this.wordId,
    roundIndex: roundIndex ?? this.roundIndex,
    result: result ?? this.result,
    responseMs: responseMs.present ? responseMs.value : this.responseMs,
    answeredAt: answeredAt ?? this.answeredAt,
  );
  PracticeAnswerRow copyWithCompanion(PracticeAnswersCompanion data) {
    return PracticeAnswerRow(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      roundIndex: data.roundIndex.present
          ? data.roundIndex.value
          : this.roundIndex,
      result: data.result.present ? data.result.value : this.result,
      responseMs: data.responseMs.present
          ? data.responseMs.value
          : this.responseMs,
      answeredAt: data.answeredAt.present
          ? data.answeredAt.value
          : this.answeredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PracticeAnswerRow(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('wordId: $wordId, ')
          ..write('roundIndex: $roundIndex, ')
          ..write('result: $result, ')
          ..write('responseMs: $responseMs, ')
          ..write('answeredAt: $answeredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    wordId,
    roundIndex,
    result,
    responseMs,
    answeredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PracticeAnswerRow &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.wordId == this.wordId &&
          other.roundIndex == this.roundIndex &&
          other.result == this.result &&
          other.responseMs == this.responseMs &&
          other.answeredAt == this.answeredAt);
}

class PracticeAnswersCompanion extends UpdateCompanion<PracticeAnswerRow> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> wordId;
  final Value<int> roundIndex;
  final Value<ReviewOutcome> result;
  final Value<int?> responseMs;
  final Value<DateTime> answeredAt;
  final Value<int> rowid;
  const PracticeAnswersCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.wordId = const Value.absent(),
    this.roundIndex = const Value.absent(),
    this.result = const Value.absent(),
    this.responseMs = const Value.absent(),
    this.answeredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PracticeAnswersCompanion.insert({
    required String id,
    required String sessionId,
    required String wordId,
    required int roundIndex,
    required ReviewOutcome result,
    this.responseMs = const Value.absent(),
    required DateTime answeredAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       wordId = Value(wordId),
       roundIndex = Value(roundIndex),
       result = Value(result),
       answeredAt = Value(answeredAt);
  static Insertable<PracticeAnswerRow> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? wordId,
    Expression<int>? roundIndex,
    Expression<String>? result,
    Expression<int>? responseMs,
    Expression<int>? answeredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (wordId != null) 'word_id': wordId,
      if (roundIndex != null) 'round_index': roundIndex,
      if (result != null) 'result': result,
      if (responseMs != null) 'response_ms': responseMs,
      if (answeredAt != null) 'answered_at': answeredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PracticeAnswersCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? wordId,
    Value<int>? roundIndex,
    Value<ReviewOutcome>? result,
    Value<int?>? responseMs,
    Value<DateTime>? answeredAt,
    Value<int>? rowid,
  }) {
    return PracticeAnswersCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      wordId: wordId ?? this.wordId,
      roundIndex: roundIndex ?? this.roundIndex,
      result: result ?? this.result,
      responseMs: responseMs ?? this.responseMs,
      answeredAt: answeredAt ?? this.answeredAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (wordId.present) {
      map['word_id'] = Variable<String>(wordId.value);
    }
    if (roundIndex.present) {
      map['round_index'] = Variable<int>(roundIndex.value);
    }
    if (result.present) {
      map['result'] = Variable<String>(
        $PracticeAnswersTable.$converterresult.toSql(result.value),
      );
    }
    if (responseMs.present) {
      map['response_ms'] = Variable<int>(responseMs.value);
    }
    if (answeredAt.present) {
      map['answered_at'] = Variable<int>(
        $PracticeAnswersTable.$converteransweredAt.toSql(answeredAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PracticeAnswersCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('wordId: $wordId, ')
          ..write('roundIndex: $roundIndex, ')
          ..write('result: $result, ')
          ..write('responseMs: $responseMs, ')
          ..write('answeredAt: $answeredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppMetaTable extends AppMeta with TableInfo<$AppMetaTable, AppMetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppMetaTable(this.attachedDatabase, [this._alias]);
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppMetaRow> instance, {
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
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppMetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppMetaRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      ),
    );
  }

  @override
  $AppMetaTable createAlias(String alias) {
    return $AppMetaTable(attachedDatabase, alias);
  }
}

class AppMetaRow extends DataClass implements Insertable<AppMetaRow> {
  /// The key.
  final String key;

  /// The value, always a string. Callers parse.
  final String? value;
  const AppMetaRow({required this.key, this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    return map;
  }

  AppMetaCompanion toCompanion(bool nullToAbsent) {
    return AppMetaCompanion(
      key: Value(key),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
    );
  }

  factory AppMetaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppMetaRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String?>(value),
    };
  }

  AppMetaRow copyWith({
    String? key,
    Value<String?> value = const Value.absent(),
  }) => AppMetaRow(
    key: key ?? this.key,
    value: value.present ? value.value : this.value,
  );
  AppMetaRow copyWithCompanion(AppMetaCompanion data) {
    return AppMetaRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaRow(')
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
      (other is AppMetaRow &&
          other.key == this.key &&
          other.value == this.value);
}

class AppMetaCompanion extends UpdateCompanion<AppMetaRow> {
  final Value<String> key;
  final Value<String?> value;
  final Value<int> rowid;
  const AppMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppMetaCompanion.insert({
    required String key,
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<AppMetaRow> custom({
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

  AppMetaCompanion copyWith({
    Value<String>? key,
    Value<String?>? value,
    Value<int>? rowid,
  }) {
    return AppMetaCompanion(
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
    return (StringBuffer('AppMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, SettingsRow> {
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
    defaultValue: const Constant(1),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ThemePreference, String>
  themeMode = GeneratedColumn<String>(
    'theme_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  ).withConverter<ThemePreference>($SettingsTable.$converterthemeMode);
  @override
  late final GeneratedColumnWithTypeConverter<TtsLocale, String> ttsLocale =
      GeneratedColumn<String>(
        'tts_locale',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('en-GB'),
      ).withConverter<TtsLocale>($SettingsTable.$converterttsLocale);
  static const VerificationMeta _ttsRateMeta = const VerificationMeta(
    'ttsRate',
  );
  @override
  late final GeneratedColumn<double> ttsRate = GeneratedColumn<double>(
    'tts_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.5),
  );
  static const VerificationMeta _ttsPitchMeta = const VerificationMeta(
    'ttsPitch',
  );
  @override
  late final GeneratedColumn<double> ttsPitch = GeneratedColumn<double>(
    'tts_pitch',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _autoplayOnOpenMeta = const VerificationMeta(
    'autoplayOnOpen',
  );
  @override
  late final GeneratedColumn<bool> autoplayOnOpen = GeneratedColumn<bool>(
    'autoplay_on_open',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("autoplay_on_open" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dailyGoalMeta = const VerificationMeta(
    'dailyGoal',
  );
  @override
  late final GeneratedColumn<int> dailyGoal = GeneratedColumn<int>(
    'daily_goal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(20),
  );
  static const VerificationMeta _reminderEnabledMeta = const VerificationMeta(
    'reminderEnabled',
  );
  @override
  late final GeneratedColumn<bool> reminderEnabled = GeneratedColumn<bool>(
    'reminder_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reminder_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _reminderTimeMinutesMeta =
      const VerificationMeta('reminderTimeMinutes');
  @override
  late final GeneratedColumn<int> reminderTimeMinutes = GeneratedColumn<int>(
    'reminder_time_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PromptSide, String> promptSide =
      GeneratedColumn<String>(
        'prompt_side',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('word_first'),
      ).withConverter<PromptSide>($SettingsTable.$converterpromptSide);
  static const VerificationMeta _lookupEnabledMeta = const VerificationMeta(
    'lookupEnabled',
  );
  @override
  late final GeneratedColumn<bool> lookupEnabled = GeneratedColumn<bool>(
    'lookup_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("lookup_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _reviewScheduleMeta = const VerificationMeta(
    'reviewSchedule',
  );
  @override
  late final GeneratedColumn<String> reviewSchedule = GeneratedColumn<String>(
    'review_schedule',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[0,1,2,4,7,15,30]'),
  );
  static const VerificationMeta _againRepeatsMeta = const VerificationMeta(
    'againRepeats',
  );
  @override
  late final GeneratedColumn<int> againRepeats = GeneratedColumn<int>(
    'again_repeats',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _mixSidesMeta = const VerificationMeta(
    'mixSides',
  );
  @override
  late final GeneratedColumn<String> mixSides = GeneratedColumn<String>(
    'mix_sides',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('word_first,meaning_first'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<MixOrder, String> mixOrder =
      GeneratedColumn<String>(
        'mix_order',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('random'),
      ).withConverter<MixOrder>($SettingsTable.$convertermixOrder);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    themeMode,
    ttsLocale,
    ttsRate,
    ttsPitch,
    autoplayOnOpen,
    dailyGoal,
    reminderEnabled,
    reminderTimeMinutes,
    promptSide,
    lookupEnabled,
    reviewSchedule,
    againRepeats,
    mixSides,
    mixOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tts_rate')) {
      context.handle(
        _ttsRateMeta,
        ttsRate.isAcceptableOrUnknown(data['tts_rate']!, _ttsRateMeta),
      );
    }
    if (data.containsKey('tts_pitch')) {
      context.handle(
        _ttsPitchMeta,
        ttsPitch.isAcceptableOrUnknown(data['tts_pitch']!, _ttsPitchMeta),
      );
    }
    if (data.containsKey('autoplay_on_open')) {
      context.handle(
        _autoplayOnOpenMeta,
        autoplayOnOpen.isAcceptableOrUnknown(
          data['autoplay_on_open']!,
          _autoplayOnOpenMeta,
        ),
      );
    }
    if (data.containsKey('daily_goal')) {
      context.handle(
        _dailyGoalMeta,
        dailyGoal.isAcceptableOrUnknown(data['daily_goal']!, _dailyGoalMeta),
      );
    }
    if (data.containsKey('reminder_enabled')) {
      context.handle(
        _reminderEnabledMeta,
        reminderEnabled.isAcceptableOrUnknown(
          data['reminder_enabled']!,
          _reminderEnabledMeta,
        ),
      );
    }
    if (data.containsKey('reminder_time_minutes')) {
      context.handle(
        _reminderTimeMinutesMeta,
        reminderTimeMinutes.isAcceptableOrUnknown(
          data['reminder_time_minutes']!,
          _reminderTimeMinutesMeta,
        ),
      );
    }
    if (data.containsKey('lookup_enabled')) {
      context.handle(
        _lookupEnabledMeta,
        lookupEnabled.isAcceptableOrUnknown(
          data['lookup_enabled']!,
          _lookupEnabledMeta,
        ),
      );
    }
    if (data.containsKey('review_schedule')) {
      context.handle(
        _reviewScheduleMeta,
        reviewSchedule.isAcceptableOrUnknown(
          data['review_schedule']!,
          _reviewScheduleMeta,
        ),
      );
    }
    if (data.containsKey('again_repeats')) {
      context.handle(
        _againRepeatsMeta,
        againRepeats.isAcceptableOrUnknown(
          data['again_repeats']!,
          _againRepeatsMeta,
        ),
      );
    }
    if (data.containsKey('mix_sides')) {
      context.handle(
        _mixSidesMeta,
        mixSides.isAcceptableOrUnknown(data['mix_sides']!, _mixSidesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      themeMode: $SettingsTable.$converterthemeMode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}theme_mode'],
        )!,
      ),
      ttsLocale: $SettingsTable.$converterttsLocale.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tts_locale'],
        )!,
      ),
      ttsRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tts_rate'],
      )!,
      ttsPitch: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tts_pitch'],
      )!,
      autoplayOnOpen: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}autoplay_on_open'],
      )!,
      dailyGoal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_goal'],
      )!,
      reminderEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reminder_enabled'],
      )!,
      reminderTimeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_time_minutes'],
      ),
      promptSide: $SettingsTable.$converterpromptSide.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}prompt_side'],
        )!,
      ),
      lookupEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}lookup_enabled'],
      )!,
      reviewSchedule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review_schedule'],
      )!,
      againRepeats: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}again_repeats'],
      )!,
      mixSides: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mix_sides'],
      )!,
      mixOrder: $SettingsTable.$convertermixOrder.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}mix_order'],
        )!,
      ),
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }

  static TypeConverter<ThemePreference, String> $converterthemeMode =
      themePreferenceConverter;
  static TypeConverter<TtsLocale, String> $converterttsLocale =
      ttsLocaleConverter;
  static TypeConverter<PromptSide, String> $converterpromptSide =
      promptSideConverter;
  static TypeConverter<MixOrder, String> $convertermixOrder = mixOrderConverter;
}

class SettingsRow extends DataClass implements Insertable<SettingsRow> {
  /// Always 1. See the CHECK constraint below.
  final int id;

  /// `system`, `light` or `dark`.
  final ThemePreference themeMode;

  /// `en-GB` or `en-US`.
  final TtsLocale ttsLocale;

  /// Speech rate, 0.0-1.0 as flutter_tts defines it.
  final double ttsRate;

  /// Speech pitch, 0.5-2.0.
  final double ttsPitch;

  /// Speak the word when its detail screen opens.
  final bool autoplayOnOpen;

  /// Cards to aim for each day; caps the daily review pool.
  final int dailyGoal;

  /// Off by default. Permission is requested only when the user turns it on
  /// (F-066, `docs/RULES.md` section 6).
  final bool reminderEnabled;

  /// Minutes after local midnight, or null when never set.
  final int? reminderTimeMinutes;

  /// `word_first`, `ipa_first`, `meaning_first` or `mix` (v3).
  final PromptSide promptSide;

  /// Whether the *Look up* button is offered on the word form.
  ///
  /// Turning it off makes the app entirely offline by choice, not merely by
  /// circumstance.
  final bool lookupEnabled;

  /// The interval each Leitner box waits, as a JSON array of seven integers.
  ///
  /// The default **is** the `docs/GAMES.md` §5 table, so a user who never
  /// opens Settings gets exactly the documented behaviour. Stored as JSON
  /// rather than seven columns because it is one setting the user edits as a
  /// unit, and because a `Sm2Scheduler` in phase 2 would want a different
  /// shape entirely (ADR-005).
  final String reviewSchedule;

  /// How many extra times a card graded *again* may return in the same session.
  ///
  /// Session-local: it changes what one sitting feels like and touches no
  /// scheduling column. 0 disables it.
  final int againRepeats;

  /// The faces a `mix` prompt draws from: storage values joined by commas
  /// (v3). Read through `PromptSide.decodeMix`, which falls back rather than
  /// trusting the string.
  final String mixSides;

  /// `random` or `rotate` - how a `mix` prompt picks each card's face (v3).
  final MixOrder mixOrder;
  const SettingsRow({
    required this.id,
    required this.themeMode,
    required this.ttsLocale,
    required this.ttsRate,
    required this.ttsPitch,
    required this.autoplayOnOpen,
    required this.dailyGoal,
    required this.reminderEnabled,
    this.reminderTimeMinutes,
    required this.promptSide,
    required this.lookupEnabled,
    required this.reviewSchedule,
    required this.againRepeats,
    required this.mixSides,
    required this.mixOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['theme_mode'] = Variable<String>(
        $SettingsTable.$converterthemeMode.toSql(themeMode),
      );
    }
    {
      map['tts_locale'] = Variable<String>(
        $SettingsTable.$converterttsLocale.toSql(ttsLocale),
      );
    }
    map['tts_rate'] = Variable<double>(ttsRate);
    map['tts_pitch'] = Variable<double>(ttsPitch);
    map['autoplay_on_open'] = Variable<bool>(autoplayOnOpen);
    map['daily_goal'] = Variable<int>(dailyGoal);
    map['reminder_enabled'] = Variable<bool>(reminderEnabled);
    if (!nullToAbsent || reminderTimeMinutes != null) {
      map['reminder_time_minutes'] = Variable<int>(reminderTimeMinutes);
    }
    {
      map['prompt_side'] = Variable<String>(
        $SettingsTable.$converterpromptSide.toSql(promptSide),
      );
    }
    map['lookup_enabled'] = Variable<bool>(lookupEnabled);
    map['review_schedule'] = Variable<String>(reviewSchedule);
    map['again_repeats'] = Variable<int>(againRepeats);
    map['mix_sides'] = Variable<String>(mixSides);
    {
      map['mix_order'] = Variable<String>(
        $SettingsTable.$convertermixOrder.toSql(mixOrder),
      );
    }
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      id: Value(id),
      themeMode: Value(themeMode),
      ttsLocale: Value(ttsLocale),
      ttsRate: Value(ttsRate),
      ttsPitch: Value(ttsPitch),
      autoplayOnOpen: Value(autoplayOnOpen),
      dailyGoal: Value(dailyGoal),
      reminderEnabled: Value(reminderEnabled),
      reminderTimeMinutes: reminderTimeMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderTimeMinutes),
      promptSide: Value(promptSide),
      lookupEnabled: Value(lookupEnabled),
      reviewSchedule: Value(reviewSchedule),
      againRepeats: Value(againRepeats),
      mixSides: Value(mixSides),
      mixOrder: Value(mixOrder),
    );
  }

  factory SettingsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingsRow(
      id: serializer.fromJson<int>(json['id']),
      themeMode: serializer.fromJson<ThemePreference>(json['themeMode']),
      ttsLocale: serializer.fromJson<TtsLocale>(json['ttsLocale']),
      ttsRate: serializer.fromJson<double>(json['ttsRate']),
      ttsPitch: serializer.fromJson<double>(json['ttsPitch']),
      autoplayOnOpen: serializer.fromJson<bool>(json['autoplayOnOpen']),
      dailyGoal: serializer.fromJson<int>(json['dailyGoal']),
      reminderEnabled: serializer.fromJson<bool>(json['reminderEnabled']),
      reminderTimeMinutes: serializer.fromJson<int?>(
        json['reminderTimeMinutes'],
      ),
      promptSide: serializer.fromJson<PromptSide>(json['promptSide']),
      lookupEnabled: serializer.fromJson<bool>(json['lookupEnabled']),
      reviewSchedule: serializer.fromJson<String>(json['reviewSchedule']),
      againRepeats: serializer.fromJson<int>(json['againRepeats']),
      mixSides: serializer.fromJson<String>(json['mixSides']),
      mixOrder: serializer.fromJson<MixOrder>(json['mixOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'themeMode': serializer.toJson<ThemePreference>(themeMode),
      'ttsLocale': serializer.toJson<TtsLocale>(ttsLocale),
      'ttsRate': serializer.toJson<double>(ttsRate),
      'ttsPitch': serializer.toJson<double>(ttsPitch),
      'autoplayOnOpen': serializer.toJson<bool>(autoplayOnOpen),
      'dailyGoal': serializer.toJson<int>(dailyGoal),
      'reminderEnabled': serializer.toJson<bool>(reminderEnabled),
      'reminderTimeMinutes': serializer.toJson<int?>(reminderTimeMinutes),
      'promptSide': serializer.toJson<PromptSide>(promptSide),
      'lookupEnabled': serializer.toJson<bool>(lookupEnabled),
      'reviewSchedule': serializer.toJson<String>(reviewSchedule),
      'againRepeats': serializer.toJson<int>(againRepeats),
      'mixSides': serializer.toJson<String>(mixSides),
      'mixOrder': serializer.toJson<MixOrder>(mixOrder),
    };
  }

  SettingsRow copyWith({
    int? id,
    ThemePreference? themeMode,
    TtsLocale? ttsLocale,
    double? ttsRate,
    double? ttsPitch,
    bool? autoplayOnOpen,
    int? dailyGoal,
    bool? reminderEnabled,
    Value<int?> reminderTimeMinutes = const Value.absent(),
    PromptSide? promptSide,
    bool? lookupEnabled,
    String? reviewSchedule,
    int? againRepeats,
    String? mixSides,
    MixOrder? mixOrder,
  }) => SettingsRow(
    id: id ?? this.id,
    themeMode: themeMode ?? this.themeMode,
    ttsLocale: ttsLocale ?? this.ttsLocale,
    ttsRate: ttsRate ?? this.ttsRate,
    ttsPitch: ttsPitch ?? this.ttsPitch,
    autoplayOnOpen: autoplayOnOpen ?? this.autoplayOnOpen,
    dailyGoal: dailyGoal ?? this.dailyGoal,
    reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    reminderTimeMinutes: reminderTimeMinutes.present
        ? reminderTimeMinutes.value
        : this.reminderTimeMinutes,
    promptSide: promptSide ?? this.promptSide,
    lookupEnabled: lookupEnabled ?? this.lookupEnabled,
    reviewSchedule: reviewSchedule ?? this.reviewSchedule,
    againRepeats: againRepeats ?? this.againRepeats,
    mixSides: mixSides ?? this.mixSides,
    mixOrder: mixOrder ?? this.mixOrder,
  );
  SettingsRow copyWithCompanion(SettingsCompanion data) {
    return SettingsRow(
      id: data.id.present ? data.id.value : this.id,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      ttsLocale: data.ttsLocale.present ? data.ttsLocale.value : this.ttsLocale,
      ttsRate: data.ttsRate.present ? data.ttsRate.value : this.ttsRate,
      ttsPitch: data.ttsPitch.present ? data.ttsPitch.value : this.ttsPitch,
      autoplayOnOpen: data.autoplayOnOpen.present
          ? data.autoplayOnOpen.value
          : this.autoplayOnOpen,
      dailyGoal: data.dailyGoal.present ? data.dailyGoal.value : this.dailyGoal,
      reminderEnabled: data.reminderEnabled.present
          ? data.reminderEnabled.value
          : this.reminderEnabled,
      reminderTimeMinutes: data.reminderTimeMinutes.present
          ? data.reminderTimeMinutes.value
          : this.reminderTimeMinutes,
      promptSide: data.promptSide.present
          ? data.promptSide.value
          : this.promptSide,
      lookupEnabled: data.lookupEnabled.present
          ? data.lookupEnabled.value
          : this.lookupEnabled,
      reviewSchedule: data.reviewSchedule.present
          ? data.reviewSchedule.value
          : this.reviewSchedule,
      againRepeats: data.againRepeats.present
          ? data.againRepeats.value
          : this.againRepeats,
      mixSides: data.mixSides.present ? data.mixSides.value : this.mixSides,
      mixOrder: data.mixOrder.present ? data.mixOrder.value : this.mixOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingsRow(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode, ')
          ..write('ttsLocale: $ttsLocale, ')
          ..write('ttsRate: $ttsRate, ')
          ..write('ttsPitch: $ttsPitch, ')
          ..write('autoplayOnOpen: $autoplayOnOpen, ')
          ..write('dailyGoal: $dailyGoal, ')
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('reminderTimeMinutes: $reminderTimeMinutes, ')
          ..write('promptSide: $promptSide, ')
          ..write('lookupEnabled: $lookupEnabled, ')
          ..write('reviewSchedule: $reviewSchedule, ')
          ..write('againRepeats: $againRepeats, ')
          ..write('mixSides: $mixSides, ')
          ..write('mixOrder: $mixOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    themeMode,
    ttsLocale,
    ttsRate,
    ttsPitch,
    autoplayOnOpen,
    dailyGoal,
    reminderEnabled,
    reminderTimeMinutes,
    promptSide,
    lookupEnabled,
    reviewSchedule,
    againRepeats,
    mixSides,
    mixOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingsRow &&
          other.id == this.id &&
          other.themeMode == this.themeMode &&
          other.ttsLocale == this.ttsLocale &&
          other.ttsRate == this.ttsRate &&
          other.ttsPitch == this.ttsPitch &&
          other.autoplayOnOpen == this.autoplayOnOpen &&
          other.dailyGoal == this.dailyGoal &&
          other.reminderEnabled == this.reminderEnabled &&
          other.reminderTimeMinutes == this.reminderTimeMinutes &&
          other.promptSide == this.promptSide &&
          other.lookupEnabled == this.lookupEnabled &&
          other.reviewSchedule == this.reviewSchedule &&
          other.againRepeats == this.againRepeats &&
          other.mixSides == this.mixSides &&
          other.mixOrder == this.mixOrder);
}

class SettingsCompanion extends UpdateCompanion<SettingsRow> {
  final Value<int> id;
  final Value<ThemePreference> themeMode;
  final Value<TtsLocale> ttsLocale;
  final Value<double> ttsRate;
  final Value<double> ttsPitch;
  final Value<bool> autoplayOnOpen;
  final Value<int> dailyGoal;
  final Value<bool> reminderEnabled;
  final Value<int?> reminderTimeMinutes;
  final Value<PromptSide> promptSide;
  final Value<bool> lookupEnabled;
  final Value<String> reviewSchedule;
  final Value<int> againRepeats;
  final Value<String> mixSides;
  final Value<MixOrder> mixOrder;
  const SettingsCompanion({
    this.id = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.ttsLocale = const Value.absent(),
    this.ttsRate = const Value.absent(),
    this.ttsPitch = const Value.absent(),
    this.autoplayOnOpen = const Value.absent(),
    this.dailyGoal = const Value.absent(),
    this.reminderEnabled = const Value.absent(),
    this.reminderTimeMinutes = const Value.absent(),
    this.promptSide = const Value.absent(),
    this.lookupEnabled = const Value.absent(),
    this.reviewSchedule = const Value.absent(),
    this.againRepeats = const Value.absent(),
    this.mixSides = const Value.absent(),
    this.mixOrder = const Value.absent(),
  });
  SettingsCompanion.insert({
    this.id = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.ttsLocale = const Value.absent(),
    this.ttsRate = const Value.absent(),
    this.ttsPitch = const Value.absent(),
    this.autoplayOnOpen = const Value.absent(),
    this.dailyGoal = const Value.absent(),
    this.reminderEnabled = const Value.absent(),
    this.reminderTimeMinutes = const Value.absent(),
    this.promptSide = const Value.absent(),
    this.lookupEnabled = const Value.absent(),
    this.reviewSchedule = const Value.absent(),
    this.againRepeats = const Value.absent(),
    this.mixSides = const Value.absent(),
    this.mixOrder = const Value.absent(),
  });
  static Insertable<SettingsRow> custom({
    Expression<int>? id,
    Expression<String>? themeMode,
    Expression<String>? ttsLocale,
    Expression<double>? ttsRate,
    Expression<double>? ttsPitch,
    Expression<bool>? autoplayOnOpen,
    Expression<int>? dailyGoal,
    Expression<bool>? reminderEnabled,
    Expression<int>? reminderTimeMinutes,
    Expression<String>? promptSide,
    Expression<bool>? lookupEnabled,
    Expression<String>? reviewSchedule,
    Expression<int>? againRepeats,
    Expression<String>? mixSides,
    Expression<String>? mixOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (themeMode != null) 'theme_mode': themeMode,
      if (ttsLocale != null) 'tts_locale': ttsLocale,
      if (ttsRate != null) 'tts_rate': ttsRate,
      if (ttsPitch != null) 'tts_pitch': ttsPitch,
      if (autoplayOnOpen != null) 'autoplay_on_open': autoplayOnOpen,
      if (dailyGoal != null) 'daily_goal': dailyGoal,
      if (reminderEnabled != null) 'reminder_enabled': reminderEnabled,
      if (reminderTimeMinutes != null)
        'reminder_time_minutes': reminderTimeMinutes,
      if (promptSide != null) 'prompt_side': promptSide,
      if (lookupEnabled != null) 'lookup_enabled': lookupEnabled,
      if (reviewSchedule != null) 'review_schedule': reviewSchedule,
      if (againRepeats != null) 'again_repeats': againRepeats,
      if (mixSides != null) 'mix_sides': mixSides,
      if (mixOrder != null) 'mix_order': mixOrder,
    });
  }

  SettingsCompanion copyWith({
    Value<int>? id,
    Value<ThemePreference>? themeMode,
    Value<TtsLocale>? ttsLocale,
    Value<double>? ttsRate,
    Value<double>? ttsPitch,
    Value<bool>? autoplayOnOpen,
    Value<int>? dailyGoal,
    Value<bool>? reminderEnabled,
    Value<int?>? reminderTimeMinutes,
    Value<PromptSide>? promptSide,
    Value<bool>? lookupEnabled,
    Value<String>? reviewSchedule,
    Value<int>? againRepeats,
    Value<String>? mixSides,
    Value<MixOrder>? mixOrder,
  }) {
    return SettingsCompanion(
      id: id ?? this.id,
      themeMode: themeMode ?? this.themeMode,
      ttsLocale: ttsLocale ?? this.ttsLocale,
      ttsRate: ttsRate ?? this.ttsRate,
      ttsPitch: ttsPitch ?? this.ttsPitch,
      autoplayOnOpen: autoplayOnOpen ?? this.autoplayOnOpen,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTimeMinutes: reminderTimeMinutes ?? this.reminderTimeMinutes,
      promptSide: promptSide ?? this.promptSide,
      lookupEnabled: lookupEnabled ?? this.lookupEnabled,
      reviewSchedule: reviewSchedule ?? this.reviewSchedule,
      againRepeats: againRepeats ?? this.againRepeats,
      mixSides: mixSides ?? this.mixSides,
      mixOrder: mixOrder ?? this.mixOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(
        $SettingsTable.$converterthemeMode.toSql(themeMode.value),
      );
    }
    if (ttsLocale.present) {
      map['tts_locale'] = Variable<String>(
        $SettingsTable.$converterttsLocale.toSql(ttsLocale.value),
      );
    }
    if (ttsRate.present) {
      map['tts_rate'] = Variable<double>(ttsRate.value);
    }
    if (ttsPitch.present) {
      map['tts_pitch'] = Variable<double>(ttsPitch.value);
    }
    if (autoplayOnOpen.present) {
      map['autoplay_on_open'] = Variable<bool>(autoplayOnOpen.value);
    }
    if (dailyGoal.present) {
      map['daily_goal'] = Variable<int>(dailyGoal.value);
    }
    if (reminderEnabled.present) {
      map['reminder_enabled'] = Variable<bool>(reminderEnabled.value);
    }
    if (reminderTimeMinutes.present) {
      map['reminder_time_minutes'] = Variable<int>(reminderTimeMinutes.value);
    }
    if (promptSide.present) {
      map['prompt_side'] = Variable<String>(
        $SettingsTable.$converterpromptSide.toSql(promptSide.value),
      );
    }
    if (lookupEnabled.present) {
      map['lookup_enabled'] = Variable<bool>(lookupEnabled.value);
    }
    if (reviewSchedule.present) {
      map['review_schedule'] = Variable<String>(reviewSchedule.value);
    }
    if (againRepeats.present) {
      map['again_repeats'] = Variable<int>(againRepeats.value);
    }
    if (mixSides.present) {
      map['mix_sides'] = Variable<String>(mixSides.value);
    }
    if (mixOrder.present) {
      map['mix_order'] = Variable<String>(
        $SettingsTable.$convertermixOrder.toSql(mixOrder.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode, ')
          ..write('ttsLocale: $ttsLocale, ')
          ..write('ttsRate: $ttsRate, ')
          ..write('ttsPitch: $ttsPitch, ')
          ..write('autoplayOnOpen: $autoplayOnOpen, ')
          ..write('dailyGoal: $dailyGoal, ')
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('reminderTimeMinutes: $reminderTimeMinutes, ')
          ..write('promptSide: $promptSide, ')
          ..write('lookupEnabled: $lookupEnabled, ')
          ..write('reviewSchedule: $reviewSchedule, ')
          ..write('againRepeats: $againRepeats, ')
          ..write('mixSides: $mixSides, ')
          ..write('mixOrder: $mixOrder')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final WordsFts wordsFts = WordsFts(this);
  late final $WordsTable words = $WordsTable(this);
  late final Trigger wordsFtsAfterInsert = Trigger(
    'CREATE TRIGGER words_fts_after_insert AFTER INSERT ON words BEGIN INSERT INTO words_fts (word_id, headword, definition, example, notes) VALUES (new.id, new.headword, coalesce(new.definition, \'\'), coalesce(new.example, \'\'), \'\');END',
    'words_fts_after_insert',
  );
  late final Trigger wordsFtsAfterUpdate = Trigger(
    'CREATE TRIGGER words_fts_after_update AFTER UPDATE ON words BEGIN UPDATE words_fts SET headword = new.headword, definition = coalesce(new.definition, \'\'), example = coalesce(new.example, \'\') WHERE word_id = new.id;END',
    'words_fts_after_update',
  );
  late final Trigger wordsFtsAfterDelete = Trigger(
    'CREATE TRIGGER words_fts_after_delete AFTER DELETE ON words BEGIN DELETE FROM words_fts WHERE word_id = old.id;END',
    'words_fts_after_delete',
  );
  late final $WordNotesTable wordNotes = $WordNotesTable(this);
  late final Trigger notesFtsAfterInsert = Trigger(
    'CREATE TRIGGER notes_fts_after_insert AFTER INSERT ON word_notes BEGIN UPDATE words_fts SET notes = coalesce((SELECT group_concat(body, \' \') FROM word_notes WHERE word_id = new.word_id), \'\') WHERE word_id = new.word_id;END',
    'notes_fts_after_insert',
  );
  late final Trigger notesFtsAfterUpdate = Trigger(
    'CREATE TRIGGER notes_fts_after_update AFTER UPDATE ON word_notes BEGIN UPDATE words_fts SET notes = coalesce((SELECT group_concat(body, \' \') FROM word_notes WHERE word_id = new.word_id), \'\') WHERE word_id = new.word_id;END',
    'notes_fts_after_update',
  );
  late final Trigger notesFtsAfterDelete = Trigger(
    'CREATE TRIGGER notes_fts_after_delete AFTER DELETE ON word_notes BEGIN UPDATE words_fts SET notes = coalesce((SELECT group_concat(body, \' \') FROM word_notes WHERE word_id = old.word_id), \'\') WHERE word_id = old.word_id;END',
    'notes_fts_after_delete',
  );
  late final Index idxNotesWord = Index(
    'idx_notes_word',
    'CREATE INDEX idx_notes_word ON word_notes (word_id)',
  );
  late final Index idxWordsNormalized = Index(
    'idx_words_normalized',
    'CREATE INDEX idx_words_normalized ON words (headword_normalized)',
  );
  late final Index idxWordsUpdated = Index(
    'idx_words_updated',
    'CREATE INDEX idx_words_updated ON words (updated_at DESC)',
  );
  late final $IpaHighlightsTable ipaHighlights = $IpaHighlightsTable(this);
  late final $WordListsTable wordLists = $WordListsTable(this);
  late final $WordListItemsTable wordListItems = $WordListItemsTable(this);
  late final $StudyCardsTable studyCards = $StudyCardsTable(this);
  late final $PracticeSessionsTable practiceSessions = $PracticeSessionsTable(
    this,
  );
  late final $PracticeAnswersTable practiceAnswers = $PracticeAnswersTable(
    this,
  );
  late final $AppMetaTable appMeta = $AppMetaTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final Index idxHighlightsWord = Index(
    'idx_highlights_word',
    'CREATE INDEX idx_highlights_word ON ipa_highlights (word_id, target)',
  );
  late final Index idxCardsDue = Index(
    'idx_cards_due',
    'CREATE INDEX idx_cards_due ON study_cards (due_at, suspended)',
  );
  late final Index idxCardsBoxLapses = Index(
    'idx_cards_box_lapses',
    'CREATE INDEX idx_cards_box_lapses ON study_cards (box, lapses)',
  );
  late final WordsDao wordsDao = WordsDao(this as AppDatabase);
  late final NotesDao notesDao = NotesDao(this as AppDatabase);
  late final HighlightsDao highlightsDao = HighlightsDao(this as AppDatabase);
  late final ListsDao listsDao = ListsDao(this as AppDatabase);
  late final PracticeDao practiceDao = PracticeDao(this as AppDatabase);
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  late final MetaDao metaDao = MetaDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    wordsFts,
    words,
    wordsFtsAfterInsert,
    wordsFtsAfterUpdate,
    wordsFtsAfterDelete,
    wordNotes,
    notesFtsAfterInsert,
    notesFtsAfterUpdate,
    notesFtsAfterDelete,
    idxNotesWord,
    idxWordsNormalized,
    idxWordsUpdated,
    ipaHighlights,
    wordLists,
    wordListItems,
    studyCards,
    practiceSessions,
    practiceAnswers,
    appMeta,
    settings,
    idxHighlightsWord,
    idxCardsDue,
    idxCardsBoxLapses,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'words',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [TableUpdate('words_fts', kind: UpdateKind.insert)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'words',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('words_fts', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'words',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('words_fts', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'words',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('word_notes', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'word_notes',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [TableUpdate('words_fts', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'word_notes',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('words_fts', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'word_notes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('words_fts', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'words',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('ipa_highlights', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'word_lists',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('word_list_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'words',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('word_list_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'words',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('study_cards', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'practice_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('practice_answers', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'words',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('practice_answers', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $WordsFtsCreateCompanionBuilder = WordsFtsCompanion Function({
  required String wordId,
  required String headword,
  required String definition,
  required String example,
  required String notes,
  Value<int> rowid,
});
typedef $WordsFtsUpdateCompanionBuilder = WordsFtsCompanion Function({
  Value<String> wordId,
  Value<String> headword,
  Value<String> definition,
  Value<String> example,
  Value<String> notes,
  Value<int> rowid,
});

class $WordsFtsFilterComposer extends Composer<_$AppDatabase, WordsFts> {
  $WordsFtsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get wordId => $composableBuilder(
    column: $table.wordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get headword => $composableBuilder(
    column: $table.headword,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get example => $composableBuilder(
    column: $table.example,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $WordsFtsOrderingComposer extends Composer<_$AppDatabase, WordsFts> {
  $WordsFtsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get wordId => $composableBuilder(
    column: $table.wordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get headword => $composableBuilder(
    column: $table.headword,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get example => $composableBuilder(
    column: $table.example,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $WordsFtsAnnotationComposer extends Composer<_$AppDatabase, WordsFts> {
  $WordsFtsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get wordId =>
      $composableBuilder(column: $table.wordId, builder: (column) => column);

  GeneratedColumn<String> get headword =>
      $composableBuilder(column: $table.headword, builder: (column) => column);

  GeneratedColumn<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => column,
  );

  GeneratedColumn<String> get example =>
      $composableBuilder(column: $table.example, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $WordsFtsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          WordsFts,
          WordsFt,
          $WordsFtsFilterComposer,
          $WordsFtsOrderingComposer,
          $WordsFtsAnnotationComposer,
          $WordsFtsCreateCompanionBuilder,
          $WordsFtsUpdateCompanionBuilder,
          (WordsFt, BaseReferences<_$AppDatabase, WordsFts, WordsFt>),
          WordsFt,
          PrefetchHooks Function()
        > {
  $WordsFtsTableManager(_$AppDatabase db, WordsFts table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $WordsFtsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $WordsFtsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $WordsFtsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> wordId = const Value.absent(),
                Value<String> headword = const Value.absent(),
                Value<String> definition = const Value.absent(),
                Value<String> example = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WordsFtsCompanion(
                wordId: wordId,
                headword: headword,
                definition: definition,
                example: example,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String wordId,
                required String headword,
                required String definition,
                required String example,
                required String notes,
                Value<int> rowid = const Value.absent(),
              }) => WordsFtsCompanion.insert(
                wordId: wordId,
                headword: headword,
                definition: definition,
                example: example,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<WordsFts, WordsFt>(table),
                  BaseReferences<_$AppDatabase, WordsFts, WordsFt>(
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

typedef $WordsFtsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      WordsFts,
      WordsFt,
      $WordsFtsFilterComposer,
      $WordsFtsOrderingComposer,
      $WordsFtsAnnotationComposer,
      $WordsFtsCreateCompanionBuilder,
      $WordsFtsUpdateCompanionBuilder,
      (WordsFt, BaseReferences<_$AppDatabase, WordsFts, WordsFt>),
      WordsFt,
      PrefetchHooks Function()
    >;
typedef $$WordsTableCreateCompanionBuilder = WordsCompanion Function({
  required String id,
  required String headword,
  required String headwordNormalized,
  Value<String?> partOfSpeech,
  Value<String?> ipaUk,
  Value<String?> ipaUs,
  Value<String?> definition,
  Value<String?> example,
  Value<WordSource> source,
  Value<String?> sourceAttribution,
  Value<bool> isFavourite,
  Value<bool> isArchived,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$WordsTableUpdateCompanionBuilder = WordsCompanion Function({
  Value<String> id,
  Value<String> headword,
  Value<String> headwordNormalized,
  Value<String?> partOfSpeech,
  Value<String?> ipaUk,
  Value<String?> ipaUs,
  Value<String?> definition,
  Value<String?> example,
  Value<WordSource> source,
  Value<String?> sourceAttribution,
  Value<bool> isFavourite,
  Value<bool> isArchived,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

final class $$WordsTableReferences
    extends BaseReferences<_$AppDatabase, $WordsTable, WordRow> {
  $$WordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WordNotesTable, List<WordNoteRow>>
  _wordNotesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.wordNotes,
    aliasName: 'words__id__word_notes__word_id',
  );

  $$WordNotesTableProcessedTableManager get wordNotesRefs {
    final manager = $$WordNotesTableTableManager(
      $_db,
      $_db.wordNotes,
    ).filter((f) => f.wordId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_wordNotesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$IpaHighlightsTable, List<IpaHighlightRow>>
  _ipaHighlightsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.ipaHighlights,
    aliasName: 'words__id__ipa_highlights__word_id',
  );

  $$IpaHighlightsTableProcessedTableManager get ipaHighlightsRefs {
    final manager = $$IpaHighlightsTableTableManager(
      $_db,
      $_db.ipaHighlights,
    ).filter((f) => f.wordId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_ipaHighlightsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WordListItemsTable, List<WordListItemRow>>
  _wordListItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.wordListItems,
    aliasName: 'words__id__word_list_items__word_id',
  );

  $$WordListItemsTableProcessedTableManager get wordListItemsRefs {
    final manager = $$WordListItemsTableTableManager(
      $_db,
      $_db.wordListItems,
    ).filter((f) => f.wordId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_wordListItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$StudyCardsTable, List<StudyCardRow>>
  _studyCardsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.studyCards,
    aliasName: 'words__id__study_cards__word_id',
  );

  $$StudyCardsTableProcessedTableManager get studyCardsRefs {
    final manager = $$StudyCardsTableTableManager(
      $_db,
      $_db.studyCards,
    ).filter((f) => f.wordId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_studyCardsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PracticeAnswersTable, List<PracticeAnswerRow>>
  _practiceAnswersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.practiceAnswers,
    aliasName: 'words__id__practice_answers__word_id',
  );

  $$PracticeAnswersTableProcessedTableManager get practiceAnswersRefs {
    final manager = $$PracticeAnswersTableTableManager(
      $_db,
      $_db.practiceAnswers,
    ).filter((f) => f.wordId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _practiceAnswersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WordsTableFilterComposer extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableFilterComposer({
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

  ColumnFilters<String> get headword => $composableBuilder(
    column: $table.headword,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get headwordNormalized => $composableBuilder(
    column: $table.headwordNormalized,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partOfSpeech => $composableBuilder(
    column: $table.partOfSpeech,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ipaUk => $composableBuilder(
    column: $table.ipaUk,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ipaUs => $composableBuilder(
    column: $table.ipaUs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get example => $composableBuilder(
    column: $table.example,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<WordSource, WordSource, String> get source =>
      $composableBuilder(
        column: $table.source,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get sourceAttribution => $composableBuilder(
    column: $table.sourceAttribution,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavourite => $composableBuilder(
    column: $table.isFavourite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get deletedAt =>
      $composableBuilder(
        column: $table.deletedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  Expression<bool> wordNotesRefs(
    Expression<bool> Function($$WordNotesTableFilterComposer f) f,
  ) {
    final $$WordNotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordNotes,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordNotesTableFilterComposer(
            $db: $db,
            $table: $db.wordNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> ipaHighlightsRefs(
    Expression<bool> Function($$IpaHighlightsTableFilterComposer f) f,
  ) {
    final $$IpaHighlightsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ipaHighlights,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IpaHighlightsTableFilterComposer(
            $db: $db,
            $table: $db.ipaHighlights,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> wordListItemsRefs(
    Expression<bool> Function($$WordListItemsTableFilterComposer f) f,
  ) {
    final $$WordListItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordListItems,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordListItemsTableFilterComposer(
            $db: $db,
            $table: $db.wordListItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> studyCardsRefs(
    Expression<bool> Function($$StudyCardsTableFilterComposer f) f,
  ) {
    final $$StudyCardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.studyCards,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudyCardsTableFilterComposer(
            $db: $db,
            $table: $db.studyCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> practiceAnswersRefs(
    Expression<bool> Function($$PracticeAnswersTableFilterComposer f) f,
  ) {
    final $$PracticeAnswersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.practiceAnswers,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeAnswersTableFilterComposer(
            $db: $db,
            $table: $db.practiceAnswers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WordsTableOrderingComposer
    extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableOrderingComposer({
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

  ColumnOrderings<String> get headword => $composableBuilder(
    column: $table.headword,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get headwordNormalized => $composableBuilder(
    column: $table.headwordNormalized,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partOfSpeech => $composableBuilder(
    column: $table.partOfSpeech,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ipaUk => $composableBuilder(
    column: $table.ipaUk,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ipaUs => $composableBuilder(
    column: $table.ipaUs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get example => $composableBuilder(
    column: $table.example,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceAttribution => $composableBuilder(
    column: $table.sourceAttribution,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavourite => $composableBuilder(
    column: $table.isFavourite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get headword =>
      $composableBuilder(column: $table.headword, builder: (column) => column);

  GeneratedColumn<String> get headwordNormalized => $composableBuilder(
    column: $table.headwordNormalized,
    builder: (column) => column,
  );

  GeneratedColumn<String> get partOfSpeech => $composableBuilder(
    column: $table.partOfSpeech,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ipaUk =>
      $composableBuilder(column: $table.ipaUk, builder: (column) => column);

  GeneratedColumn<String> get ipaUs =>
      $composableBuilder(column: $table.ipaUs, builder: (column) => column);

  GeneratedColumn<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => column,
  );

  GeneratedColumn<String> get example =>
      $composableBuilder(column: $table.example, builder: (column) => column);

  GeneratedColumnWithTypeConverter<WordSource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get sourceAttribution => $composableBuilder(
    column: $table.sourceAttribution,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFavourite => $composableBuilder(
    column: $table.isFavourite,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> wordNotesRefs<T extends Object>(
    Expression<T> Function($$WordNotesTableAnnotationComposer a) f,
  ) {
    final $$WordNotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordNotes,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordNotesTableAnnotationComposer(
            $db: $db,
            $table: $db.wordNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> ipaHighlightsRefs<T extends Object>(
    Expression<T> Function($$IpaHighlightsTableAnnotationComposer a) f,
  ) {
    final $$IpaHighlightsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ipaHighlights,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IpaHighlightsTableAnnotationComposer(
            $db: $db,
            $table: $db.ipaHighlights,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> wordListItemsRefs<T extends Object>(
    Expression<T> Function($$WordListItemsTableAnnotationComposer a) f,
  ) {
    final $$WordListItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordListItems,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordListItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.wordListItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> studyCardsRefs<T extends Object>(
    Expression<T> Function($$StudyCardsTableAnnotationComposer a) f,
  ) {
    final $$StudyCardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.studyCards,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudyCardsTableAnnotationComposer(
            $db: $db,
            $table: $db.studyCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> practiceAnswersRefs<T extends Object>(
    Expression<T> Function($$PracticeAnswersTableAnnotationComposer a) f,
  ) {
    final $$PracticeAnswersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.practiceAnswers,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeAnswersTableAnnotationComposer(
            $db: $db,
            $table: $db.practiceAnswers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WordsTable,
          WordRow,
          $$WordsTableFilterComposer,
          $$WordsTableOrderingComposer,
          $$WordsTableAnnotationComposer,
          $$WordsTableCreateCompanionBuilder,
          $$WordsTableUpdateCompanionBuilder,
          (WordRow, $$WordsTableReferences),
          WordRow,
          PrefetchHooks Function({
            bool wordNotesRefs,
            bool ipaHighlightsRefs,
            bool wordListItemsRefs,
            bool studyCardsRefs,
            bool practiceAnswersRefs,
          })
        > {
  $$WordsTableTableManager(_$AppDatabase db, $WordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> headword = const Value.absent(),
                Value<String> headwordNormalized = const Value.absent(),
                Value<String?> partOfSpeech = const Value.absent(),
                Value<String?> ipaUk = const Value.absent(),
                Value<String?> ipaUs = const Value.absent(),
                Value<String?> definition = const Value.absent(),
                Value<String?> example = const Value.absent(),
                Value<WordSource> source = const Value.absent(),
                Value<String?> sourceAttribution = const Value.absent(),
                Value<bool> isFavourite = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WordsCompanion(
                id: id,
                headword: headword,
                headwordNormalized: headwordNormalized,
                partOfSpeech: partOfSpeech,
                ipaUk: ipaUk,
                ipaUs: ipaUs,
                definition: definition,
                example: example,
                source: source,
                sourceAttribution: sourceAttribution,
                isFavourite: isFavourite,
                isArchived: isArchived,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String headword,
                required String headwordNormalized,
                Value<String?> partOfSpeech = const Value.absent(),
                Value<String?> ipaUk = const Value.absent(),
                Value<String?> ipaUs = const Value.absent(),
                Value<String?> definition = const Value.absent(),
                Value<String?> example = const Value.absent(),
                Value<WordSource> source = const Value.absent(),
                Value<String?> sourceAttribution = const Value.absent(),
                Value<bool> isFavourite = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WordsCompanion.insert(
                id: id,
                headword: headword,
                headwordNormalized: headwordNormalized,
                partOfSpeech: partOfSpeech,
                ipaUk: ipaUk,
                ipaUs: ipaUs,
                definition: definition,
                example: example,
                source: source,
                sourceAttribution: sourceAttribution,
                isFavourite: isFavourite,
                isArchived: isArchived,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WordsTable, WordRow>(table),
                  $$WordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                wordNotesRefs = false,
                ipaHighlightsRefs = false,
                wordListItemsRefs = false,
                studyCardsRefs = false,
                practiceAnswersRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (wordNotesRefs) db.wordNotes,
                    if (ipaHighlightsRefs) db.ipaHighlights,
                    if (wordListItemsRefs) db.wordListItems,
                    if (studyCardsRefs) db.studyCards,
                    if (practiceAnswersRefs) db.practiceAnswers,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (wordNotesRefs)
                        await $_getPrefetchedData<
                          WordRow,
                          $WordsTable,
                          WordNoteRow
                        >(
                          currentTable: table,
                          referencedTable: $$WordsTableReferences
                              ._wordNotesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WordsTableReferences(
                                db,
                                table,
                                p0,
                              ).wordNotesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.wordId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (ipaHighlightsRefs)
                        await $_getPrefetchedData<
                          WordRow,
                          $WordsTable,
                          IpaHighlightRow
                        >(
                          currentTable: table,
                          referencedTable: $$WordsTableReferences
                              ._ipaHighlightsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WordsTableReferences(
                                db,
                                table,
                                p0,
                              ).ipaHighlightsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.wordId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (wordListItemsRefs)
                        await $_getPrefetchedData<
                          WordRow,
                          $WordsTable,
                          WordListItemRow
                        >(
                          currentTable: table,
                          referencedTable: $$WordsTableReferences
                              ._wordListItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WordsTableReferences(
                                db,
                                table,
                                p0,
                              ).wordListItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.wordId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (studyCardsRefs)
                        await $_getPrefetchedData<
                          WordRow,
                          $WordsTable,
                          StudyCardRow
                        >(
                          currentTable: table,
                          referencedTable: $$WordsTableReferences
                              ._studyCardsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WordsTableReferences(
                                db,
                                table,
                                p0,
                              ).studyCardsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.wordId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (practiceAnswersRefs)
                        await $_getPrefetchedData<
                          WordRow,
                          $WordsTable,
                          PracticeAnswerRow
                        >(
                          currentTable: table,
                          referencedTable: $$WordsTableReferences
                              ._practiceAnswersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WordsTableReferences(
                                db,
                                table,
                                p0,
                              ).practiceAnswersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.wordId == item.id,
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

typedef $$WordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WordsTable,
      WordRow,
      $$WordsTableFilterComposer,
      $$WordsTableOrderingComposer,
      $$WordsTableAnnotationComposer,
      $$WordsTableCreateCompanionBuilder,
      $$WordsTableUpdateCompanionBuilder,
      (WordRow, $$WordsTableReferences),
      WordRow,
      PrefetchHooks Function({
        bool wordNotesRefs,
        bool ipaHighlightsRefs,
        bool wordListItemsRefs,
        bool studyCardsRefs,
        bool practiceAnswersRefs,
      })
    >;
typedef $$WordNotesTableCreateCompanionBuilder = WordNotesCompanion Function({
  required String id,
  required String wordId,
  required String body,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> pinned,
  Value<int> rowid,
});
typedef $$WordNotesTableUpdateCompanionBuilder = WordNotesCompanion Function({
  Value<String> id,
  Value<String> wordId,
  Value<String> body,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> pinned,
  Value<int> rowid,
});

final class $$WordNotesTableReferences
    extends BaseReferences<_$AppDatabase, $WordNotesTable, WordNoteRow> {
  $$WordNotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WordsTable _wordIdTable(_$AppDatabase db) =>
      db.words.createAlias('word_notes__word_id__words__id');

  $$WordsTableProcessedTableManager get wordId {
    final $_column = $_itemColumn<String>('word_id')!;

    final manager = $$WordsTableTableManager(
      $_db,
      $_db.words,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WordNotesTableFilterComposer
    extends Composer<_$AppDatabase, $WordNotesTable> {
  $$WordNotesTableFilterComposer({
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

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnFilters(column),
  );

  $$WordsTableFilterComposer get wordId {
    final $$WordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableFilterComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordNotesTableOrderingComposer
    extends Composer<_$AppDatabase, $WordNotesTable> {
  $$WordNotesTableOrderingComposer({
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

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnOrderings(column),
  );

  $$WordsTableOrderingComposer get wordId {
    final $$WordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableOrderingComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordNotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordNotesTable> {
  $$WordNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get pinned =>
      $composableBuilder(column: $table.pinned, builder: (column) => column);

  $$WordsTableAnnotationComposer get wordId {
    final $$WordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableAnnotationComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordNotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WordNotesTable,
          WordNoteRow,
          $$WordNotesTableFilterComposer,
          $$WordNotesTableOrderingComposer,
          $$WordNotesTableAnnotationComposer,
          $$WordNotesTableCreateCompanionBuilder,
          $$WordNotesTableUpdateCompanionBuilder,
          (WordNoteRow, $$WordNotesTableReferences),
          WordNoteRow,
          PrefetchHooks Function({bool wordId})
        > {
  $$WordNotesTableTableManager(_$AppDatabase db, $WordNotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> wordId = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WordNotesCompanion(
                id: id,
                wordId: wordId,
                body: body,
                createdAt: createdAt,
                updatedAt: updatedAt,
                pinned: pinned,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String wordId,
                required String body,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<bool> pinned = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WordNotesCompanion.insert(
                id: id,
                wordId: wordId,
                body: body,
                createdAt: createdAt,
                updatedAt: updatedAt,
                pinned: pinned,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WordNotesTable, WordNoteRow>(table),
                  $$WordNotesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({wordId = false}) {
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
                    if (wordId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.wordId,
                        referencedTable: $$WordNotesTableReferences
                            ._wordIdTable(db),
                        referencedColumn: $$WordNotesTableReferences
                            ._wordIdTable(db)
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

typedef $$WordNotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WordNotesTable,
      WordNoteRow,
      $$WordNotesTableFilterComposer,
      $$WordNotesTableOrderingComposer,
      $$WordNotesTableAnnotationComposer,
      $$WordNotesTableCreateCompanionBuilder,
      $$WordNotesTableUpdateCompanionBuilder,
      (WordNoteRow, $$WordNotesTableReferences),
      WordNoteRow,
      PrefetchHooks Function({bool wordId})
    >;
typedef $$IpaHighlightsTableCreateCompanionBuilder =
    IpaHighlightsCompanion Function({
      required String id,
      required String wordId,
      required HighlightTarget target,
      required int startGrapheme,
      required int endGrapheme,
      required IpaColorToken colorToken,
      Value<String?> label,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$IpaHighlightsTableUpdateCompanionBuilder =
    IpaHighlightsCompanion Function({
      Value<String> id,
      Value<String> wordId,
      Value<HighlightTarget> target,
      Value<int> startGrapheme,
      Value<int> endGrapheme,
      Value<IpaColorToken> colorToken,
      Value<String?> label,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$IpaHighlightsTableReferences
    extends
        BaseReferences<_$AppDatabase, $IpaHighlightsTable, IpaHighlightRow> {
  $$IpaHighlightsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WordsTable _wordIdTable(_$AppDatabase db) =>
      db.words.createAlias('ipa_highlights__word_id__words__id');

  $$WordsTableProcessedTableManager get wordId {
    final $_column = $_itemColumn<String>('word_id')!;

    final manager = $$WordsTableTableManager(
      $_db,
      $_db.words,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$IpaHighlightsTableFilterComposer
    extends Composer<_$AppDatabase, $IpaHighlightsTable> {
  $$IpaHighlightsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<HighlightTarget, HighlightTarget, String>
  get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get startGrapheme => $composableBuilder(
    column: $table.startGrapheme,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endGrapheme => $composableBuilder(
    column: $table.endGrapheme,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<IpaColorToken, IpaColorToken, String>
  get colorToken => $composableBuilder(
    column: $table.colorToken,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$WordsTableFilterComposer get wordId {
    final $$WordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableFilterComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IpaHighlightsTableOrderingComposer
    extends Composer<_$AppDatabase, $IpaHighlightsTable> {
  $$IpaHighlightsTableOrderingComposer({
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

  ColumnOrderings<String> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startGrapheme => $composableBuilder(
    column: $table.startGrapheme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endGrapheme => $composableBuilder(
    column: $table.endGrapheme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorToken => $composableBuilder(
    column: $table.colorToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WordsTableOrderingComposer get wordId {
    final $$WordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableOrderingComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IpaHighlightsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IpaHighlightsTable> {
  $$IpaHighlightsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<HighlightTarget, String> get target =>
      $composableBuilder(column: $table.target, builder: (column) => column);

  GeneratedColumn<int> get startGrapheme => $composableBuilder(
    column: $table.startGrapheme,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endGrapheme => $composableBuilder(
    column: $table.endGrapheme,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<IpaColorToken, String> get colorToken =>
      $composableBuilder(
        column: $table.colorToken,
        builder: (column) => column,
      );

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$WordsTableAnnotationComposer get wordId {
    final $$WordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableAnnotationComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IpaHighlightsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IpaHighlightsTable,
          IpaHighlightRow,
          $$IpaHighlightsTableFilterComposer,
          $$IpaHighlightsTableOrderingComposer,
          $$IpaHighlightsTableAnnotationComposer,
          $$IpaHighlightsTableCreateCompanionBuilder,
          $$IpaHighlightsTableUpdateCompanionBuilder,
          (IpaHighlightRow, $$IpaHighlightsTableReferences),
          IpaHighlightRow,
          PrefetchHooks Function({bool wordId})
        > {
  $$IpaHighlightsTableTableManager(_$AppDatabase db, $IpaHighlightsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IpaHighlightsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IpaHighlightsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IpaHighlightsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> wordId = const Value.absent(),
                Value<HighlightTarget> target = const Value.absent(),
                Value<int> startGrapheme = const Value.absent(),
                Value<int> endGrapheme = const Value.absent(),
                Value<IpaColorToken> colorToken = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IpaHighlightsCompanion(
                id: id,
                wordId: wordId,
                target: target,
                startGrapheme: startGrapheme,
                endGrapheme: endGrapheme,
                colorToken: colorToken,
                label: label,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String wordId,
                required HighlightTarget target,
                required int startGrapheme,
                required int endGrapheme,
                required IpaColorToken colorToken,
                Value<String?> label = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => IpaHighlightsCompanion.insert(
                id: id,
                wordId: wordId,
                target: target,
                startGrapheme: startGrapheme,
                endGrapheme: endGrapheme,
                colorToken: colorToken,
                label: label,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$IpaHighlightsTable, IpaHighlightRow>(table),
                  $$IpaHighlightsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({wordId = false}) {
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
                    if (wordId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.wordId,
                        referencedTable: $$IpaHighlightsTableReferences
                            ._wordIdTable(db),
                        referencedColumn: $$IpaHighlightsTableReferences
                            ._wordIdTable(db)
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

typedef $$IpaHighlightsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IpaHighlightsTable,
      IpaHighlightRow,
      $$IpaHighlightsTableFilterComposer,
      $$IpaHighlightsTableOrderingComposer,
      $$IpaHighlightsTableAnnotationComposer,
      $$IpaHighlightsTableCreateCompanionBuilder,
      $$IpaHighlightsTableUpdateCompanionBuilder,
      (IpaHighlightRow, $$IpaHighlightsTableReferences),
      IpaHighlightRow,
      PrefetchHooks Function({bool wordId})
    >;
typedef $$WordListsTableCreateCompanionBuilder = WordListsCompanion Function({
  required String id,
  required String name,
  required IpaColorToken colorToken,
  Value<String?> iconKey,
  required int sortOrder,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<ListKind> kind,
  Value<int> rowid,
});
typedef $$WordListsTableUpdateCompanionBuilder = WordListsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<IpaColorToken> colorToken,
  Value<String?> iconKey,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<ListKind> kind,
  Value<int> rowid,
});

final class $$WordListsTableReferences
    extends BaseReferences<_$AppDatabase, $WordListsTable, WordListRow> {
  $$WordListsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WordListItemsTable, List<WordListItemRow>>
  _wordListItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.wordListItems,
    aliasName: 'word_lists__id__word_list_items__list_id',
  );

  $$WordListItemsTableProcessedTableManager get wordListItemsRefs {
    final manager = $$WordListItemsTableTableManager(
      $_db,
      $_db.wordListItems,
    ).filter((f) => f.listId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_wordListItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WordListsTableFilterComposer
    extends Composer<_$AppDatabase, $WordListsTable> {
  $$WordListsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<IpaColorToken, IpaColorToken, String>
  get colorToken => $composableBuilder(
    column: $table.colorToken,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<ListKind, ListKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  Expression<bool> wordListItemsRefs(
    Expression<bool> Function($$WordListItemsTableFilterComposer f) f,
  ) {
    final $$WordListItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordListItems,
      getReferencedColumn: (t) => t.listId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordListItemsTableFilterComposer(
            $db: $db,
            $table: $db.wordListItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WordListsTableOrderingComposer
    extends Composer<_$AppDatabase, $WordListsTable> {
  $$WordListsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorToken => $composableBuilder(
    column: $table.colorToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WordListsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordListsTable> {
  $$WordListsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<IpaColorToken, String> get colorToken =>
      $composableBuilder(
        column: $table.colorToken,
        builder: (column) => column,
      );

  GeneratedColumn<String> get iconKey =>
      $composableBuilder(column: $table.iconKey, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ListKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  Expression<T> wordListItemsRefs<T extends Object>(
    Expression<T> Function($$WordListItemsTableAnnotationComposer a) f,
  ) {
    final $$WordListItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordListItems,
      getReferencedColumn: (t) => t.listId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordListItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.wordListItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WordListsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WordListsTable,
          WordListRow,
          $$WordListsTableFilterComposer,
          $$WordListsTableOrderingComposer,
          $$WordListsTableAnnotationComposer,
          $$WordListsTableCreateCompanionBuilder,
          $$WordListsTableUpdateCompanionBuilder,
          (WordListRow, $$WordListsTableReferences),
          WordListRow,
          PrefetchHooks Function({bool wordListItemsRefs})
        > {
  $$WordListsTableTableManager(_$AppDatabase db, $WordListsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordListsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordListsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordListsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<IpaColorToken> colorToken = const Value.absent(),
                Value<String?> iconKey = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<ListKind> kind = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WordListsCompanion(
                id: id,
                name: name,
                colorToken: colorToken,
                iconKey: iconKey,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                kind: kind,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required IpaColorToken colorToken,
                Value<String?> iconKey = const Value.absent(),
                required int sortOrder,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<ListKind> kind = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WordListsCompanion.insert(
                id: id,
                name: name,
                colorToken: colorToken,
                iconKey: iconKey,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                kind: kind,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WordListsTable, WordListRow>(table),
                  $$WordListsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({wordListItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (wordListItemsRefs) db.wordListItems,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (wordListItemsRefs)
                    await $_getPrefetchedData<
                      WordListRow,
                      $WordListsTable,
                      WordListItemRow
                    >(
                      currentTable: table,
                      referencedTable: $$WordListsTableReferences
                          ._wordListItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$WordListsTableReferences(
                            db,
                            table,
                            p0,
                          ).wordListItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.listId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$WordListsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WordListsTable,
      WordListRow,
      $$WordListsTableFilterComposer,
      $$WordListsTableOrderingComposer,
      $$WordListsTableAnnotationComposer,
      $$WordListsTableCreateCompanionBuilder,
      $$WordListsTableUpdateCompanionBuilder,
      (WordListRow, $$WordListsTableReferences),
      WordListRow,
      PrefetchHooks Function({bool wordListItemsRefs})
    >;
typedef $$WordListItemsTableCreateCompanionBuilder =
    WordListItemsCompanion Function({
      required String listId,
      required String wordId,
      required DateTime addedAt,
      Value<int> rowid,
    });
typedef $$WordListItemsTableUpdateCompanionBuilder =
    WordListItemsCompanion Function({
      Value<String> listId,
      Value<String> wordId,
      Value<DateTime> addedAt,
      Value<int> rowid,
    });

final class $$WordListItemsTableReferences
    extends
        BaseReferences<_$AppDatabase, $WordListItemsTable, WordListItemRow> {
  $$WordListItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WordListsTable _listIdTable(_$AppDatabase db) =>
      db.wordLists.createAlias('word_list_items__list_id__word_lists__id');

  $$WordListsTableProcessedTableManager get listId {
    final $_column = $_itemColumn<String>('list_id')!;

    final manager = $$WordListsTableTableManager(
      $_db,
      $_db.wordLists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_listIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WordsTable _wordIdTable(_$AppDatabase db) =>
      db.words.createAlias('word_list_items__word_id__words__id');

  $$WordsTableProcessedTableManager get wordId {
    final $_column = $_itemColumn<String>('word_id')!;

    final manager = $$WordsTableTableManager(
      $_db,
      $_db.words,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WordListItemsTableFilterComposer
    extends Composer<_$AppDatabase, $WordListItemsTable> {
  $$WordListItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get addedAt =>
      $composableBuilder(
        column: $table.addedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$WordListsTableFilterComposer get listId {
    final $$WordListsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.wordLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordListsTableFilterComposer(
            $db: $db,
            $table: $db.wordLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordsTableFilterComposer get wordId {
    final $$WordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableFilterComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordListItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $WordListItemsTable> {
  $$WordListItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WordListsTableOrderingComposer get listId {
    final $$WordListsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.wordLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordListsTableOrderingComposer(
            $db: $db,
            $table: $db.wordLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordsTableOrderingComposer get wordId {
    final $$WordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableOrderingComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordListItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordListItemsTable> {
  $$WordListItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<DateTime, int> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  $$WordListsTableAnnotationComposer get listId {
    final $$WordListsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.wordLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordListsTableAnnotationComposer(
            $db: $db,
            $table: $db.wordLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordsTableAnnotationComposer get wordId {
    final $$WordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableAnnotationComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordListItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WordListItemsTable,
          WordListItemRow,
          $$WordListItemsTableFilterComposer,
          $$WordListItemsTableOrderingComposer,
          $$WordListItemsTableAnnotationComposer,
          $$WordListItemsTableCreateCompanionBuilder,
          $$WordListItemsTableUpdateCompanionBuilder,
          (WordListItemRow, $$WordListItemsTableReferences),
          WordListItemRow,
          PrefetchHooks Function({bool listId, bool wordId})
        > {
  $$WordListItemsTableTableManager(_$AppDatabase db, $WordListItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordListItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordListItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordListItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> listId = const Value.absent(),
                Value<String> wordId = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WordListItemsCompanion(
                listId: listId,
                wordId: wordId,
                addedAt: addedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String listId,
                required String wordId,
                required DateTime addedAt,
                Value<int> rowid = const Value.absent(),
              }) => WordListItemsCompanion.insert(
                listId: listId,
                wordId: wordId,
                addedAt: addedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WordListItemsTable, WordListItemRow>(table),
                  $$WordListItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({listId = false, wordId = false}) {
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
                    if (listId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.listId,
                        referencedTable: $$WordListItemsTableReferences
                            ._listIdTable(db),
                        referencedColumn: $$WordListItemsTableReferences
                            ._listIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (wordId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.wordId,
                        referencedTable: $$WordListItemsTableReferences
                            ._wordIdTable(db),
                        referencedColumn: $$WordListItemsTableReferences
                            ._wordIdTable(db)
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

typedef $$WordListItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WordListItemsTable,
      WordListItemRow,
      $$WordListItemsTableFilterComposer,
      $$WordListItemsTableOrderingComposer,
      $$WordListItemsTableAnnotationComposer,
      $$WordListItemsTableCreateCompanionBuilder,
      $$WordListItemsTableUpdateCompanionBuilder,
      (WordListItemRow, $$WordListItemsTableReferences),
      WordListItemRow,
      PrefetchHooks Function({bool listId, bool wordId})
    >;
typedef $$StudyCardsTableCreateCompanionBuilder = StudyCardsCompanion Function({
  required String wordId,
  Value<int> box,
  required DateTime dueAt,
  Value<int> intervalDays,
  Value<double> easeFactor,
  Value<int> repetitions,
  Value<int> lapses,
  Value<DateTime?> lastReviewedAt,
  Value<ReviewOutcome?> lastResult,
  Value<bool> suspended,
  Value<int> rowid,
});
typedef $$StudyCardsTableUpdateCompanionBuilder = StudyCardsCompanion Function({
  Value<String> wordId,
  Value<int> box,
  Value<DateTime> dueAt,
  Value<int> intervalDays,
  Value<double> easeFactor,
  Value<int> repetitions,
  Value<int> lapses,
  Value<DateTime?> lastReviewedAt,
  Value<ReviewOutcome?> lastResult,
  Value<bool> suspended,
  Value<int> rowid,
});

final class $$StudyCardsTableReferences
    extends BaseReferences<_$AppDatabase, $StudyCardsTable, StudyCardRow> {
  $$StudyCardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WordsTable _wordIdTable(_$AppDatabase db) =>
      db.words.createAlias('study_cards__word_id__words__id');

  $$WordsTableProcessedTableManager get wordId {
    final $_column = $_itemColumn<String>('word_id')!;

    final manager = $$WordsTableTableManager(
      $_db,
      $_db.words,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StudyCardsTableFilterComposer
    extends Composer<_$AppDatabase, $StudyCardsTable> {
  $$StudyCardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get box => $composableBuilder(
    column: $table.box,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get dueAt =>
      $composableBuilder(
        column: $table.dueAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lapses => $composableBuilder(
    column: $table.lapses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get lastReviewedAt =>
      $composableBuilder(
        column: $table.lastReviewedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<ReviewOutcome?, ReviewOutcome, String>
  get lastResult => $composableBuilder(
    column: $table.lastResult,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get suspended => $composableBuilder(
    column: $table.suspended,
    builder: (column) => ColumnFilters(column),
  );

  $$WordsTableFilterComposer get wordId {
    final $$WordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableFilterComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StudyCardsTableOrderingComposer
    extends Composer<_$AppDatabase, $StudyCardsTable> {
  $$StudyCardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get box => $composableBuilder(
    column: $table.box,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lapses => $composableBuilder(
    column: $table.lapses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastResult => $composableBuilder(
    column: $table.lastResult,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get suspended => $composableBuilder(
    column: $table.suspended,
    builder: (column) => ColumnOrderings(column),
  );

  $$WordsTableOrderingComposer get wordId {
    final $$WordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableOrderingComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StudyCardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudyCardsTable> {
  $$StudyCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get box =>
      $composableBuilder(column: $table.box, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => column,
  );

  GeneratedColumn<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lapses =>
      $composableBuilder(column: $table.lapses, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get lastReviewedAt =>
      $composableBuilder(
        column: $table.lastReviewedAt,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<ReviewOutcome?, String> get lastResult =>
      $composableBuilder(
        column: $table.lastResult,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get suspended =>
      $composableBuilder(column: $table.suspended, builder: (column) => column);

  $$WordsTableAnnotationComposer get wordId {
    final $$WordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableAnnotationComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StudyCardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StudyCardsTable,
          StudyCardRow,
          $$StudyCardsTableFilterComposer,
          $$StudyCardsTableOrderingComposer,
          $$StudyCardsTableAnnotationComposer,
          $$StudyCardsTableCreateCompanionBuilder,
          $$StudyCardsTableUpdateCompanionBuilder,
          (StudyCardRow, $$StudyCardsTableReferences),
          StudyCardRow,
          PrefetchHooks Function({bool wordId})
        > {
  $$StudyCardsTableTableManager(_$AppDatabase db, $StudyCardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudyCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudyCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudyCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> wordId = const Value.absent(),
                Value<int> box = const Value.absent(),
                Value<DateTime> dueAt = const Value.absent(),
                Value<int> intervalDays = const Value.absent(),
                Value<double> easeFactor = const Value.absent(),
                Value<int> repetitions = const Value.absent(),
                Value<int> lapses = const Value.absent(),
                Value<DateTime?> lastReviewedAt = const Value.absent(),
                Value<ReviewOutcome?> lastResult = const Value.absent(),
                Value<bool> suspended = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudyCardsCompanion(
                wordId: wordId,
                box: box,
                dueAt: dueAt,
                intervalDays: intervalDays,
                easeFactor: easeFactor,
                repetitions: repetitions,
                lapses: lapses,
                lastReviewedAt: lastReviewedAt,
                lastResult: lastResult,
                suspended: suspended,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String wordId,
                Value<int> box = const Value.absent(),
                required DateTime dueAt,
                Value<int> intervalDays = const Value.absent(),
                Value<double> easeFactor = const Value.absent(),
                Value<int> repetitions = const Value.absent(),
                Value<int> lapses = const Value.absent(),
                Value<DateTime?> lastReviewedAt = const Value.absent(),
                Value<ReviewOutcome?> lastResult = const Value.absent(),
                Value<bool> suspended = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudyCardsCompanion.insert(
                wordId: wordId,
                box: box,
                dueAt: dueAt,
                intervalDays: intervalDays,
                easeFactor: easeFactor,
                repetitions: repetitions,
                lapses: lapses,
                lastReviewedAt: lastReviewedAt,
                lastResult: lastResult,
                suspended: suspended,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StudyCardsTable, StudyCardRow>(table),
                  $$StudyCardsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({wordId = false}) {
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
                    if (wordId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.wordId,
                        referencedTable: $$StudyCardsTableReferences
                            ._wordIdTable(db),
                        referencedColumn: $$StudyCardsTableReferences
                            ._wordIdTable(db)
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

typedef $$StudyCardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StudyCardsTable,
      StudyCardRow,
      $$StudyCardsTableFilterComposer,
      $$StudyCardsTableOrderingComposer,
      $$StudyCardsTableAnnotationComposer,
      $$StudyCardsTableCreateCompanionBuilder,
      $$StudyCardsTableUpdateCompanionBuilder,
      (StudyCardRow, $$StudyCardsTableReferences),
      StudyCardRow,
      PrefetchHooks Function({bool wordId})
    >;
typedef $$PracticeSessionsTableCreateCompanionBuilder =
    PracticeSessionsCompanion Function({
      required String id,
      required String gameId,
      required PracticeMode mode,
      required CardSourceKind sourceKind,
      Value<String?> sourceId,
      required String configJson,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      Value<int> totalRounds,
      Value<int> correctRounds,
      required bool affectsScheduling,
      Value<int> rowid,
    });
typedef $$PracticeSessionsTableUpdateCompanionBuilder =
    PracticeSessionsCompanion Function({
      Value<String> id,
      Value<String> gameId,
      Value<PracticeMode> mode,
      Value<CardSourceKind> sourceKind,
      Value<String?> sourceId,
      Value<String> configJson,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<int> totalRounds,
      Value<int> correctRounds,
      Value<bool> affectsScheduling,
      Value<int> rowid,
    });

final class $$PracticeSessionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PracticeSessionsTable,
          PracticeSessionRow
        > {
  $$PracticeSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$PracticeAnswersTable, List<PracticeAnswerRow>>
  _practiceAnswersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.practiceAnswers,
    aliasName: 'practice_sessions__id__practice_answers__session_id',
  );

  $$PracticeAnswersTableProcessedTableManager get practiceAnswersRefs {
    final manager = $$PracticeAnswersTableTableManager(
      $_db,
      $_db.practiceAnswers,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _practiceAnswersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PracticeSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $PracticeSessionsTable> {
  $$PracticeSessionsTableFilterComposer({
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

  ColumnFilters<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PracticeMode, PracticeMode, String> get mode =>
      $composableBuilder(
        column: $table.mode,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<CardSourceKind, CardSourceKind, String>
  get sourceKind => $composableBuilder(
    column: $table.sourceKind,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get startedAt =>
      $composableBuilder(
        column: $table.startedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get endedAt =>
      $composableBuilder(
        column: $table.endedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get totalRounds => $composableBuilder(
    column: $table.totalRounds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correctRounds => $composableBuilder(
    column: $table.correctRounds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get affectsScheduling => $composableBuilder(
    column: $table.affectsScheduling,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> practiceAnswersRefs(
    Expression<bool> Function($$PracticeAnswersTableFilterComposer f) f,
  ) {
    final $$PracticeAnswersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.practiceAnswers,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeAnswersTableFilterComposer(
            $db: $db,
            $table: $db.practiceAnswers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PracticeSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PracticeSessionsTable> {
  $$PracticeSessionsTableOrderingComposer({
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

  ColumnOrderings<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceKind => $composableBuilder(
    column: $table.sourceKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalRounds => $composableBuilder(
    column: $table.totalRounds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correctRounds => $composableBuilder(
    column: $table.correctRounds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get affectsScheduling => $composableBuilder(
    column: $table.affectsScheduling,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PracticeSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PracticeSessionsTable> {
  $$PracticeSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get gameId =>
      $composableBuilder(column: $table.gameId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PracticeMode, String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CardSourceKind, String> get sourceKind =>
      $composableBuilder(
        column: $table.sourceKind,
        builder: (column) => column,
      );

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get totalRounds => $composableBuilder(
    column: $table.totalRounds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get correctRounds => $composableBuilder(
    column: $table.correctRounds,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get affectsScheduling => $composableBuilder(
    column: $table.affectsScheduling,
    builder: (column) => column,
  );

  Expression<T> practiceAnswersRefs<T extends Object>(
    Expression<T> Function($$PracticeAnswersTableAnnotationComposer a) f,
  ) {
    final $$PracticeAnswersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.practiceAnswers,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeAnswersTableAnnotationComposer(
            $db: $db,
            $table: $db.practiceAnswers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PracticeSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PracticeSessionsTable,
          PracticeSessionRow,
          $$PracticeSessionsTableFilterComposer,
          $$PracticeSessionsTableOrderingComposer,
          $$PracticeSessionsTableAnnotationComposer,
          $$PracticeSessionsTableCreateCompanionBuilder,
          $$PracticeSessionsTableUpdateCompanionBuilder,
          (PracticeSessionRow, $$PracticeSessionsTableReferences),
          PracticeSessionRow,
          PrefetchHooks Function({bool practiceAnswersRefs})
        > {
  $$PracticeSessionsTableTableManager(
    _$AppDatabase db,
    $PracticeSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PracticeSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PracticeSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PracticeSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> gameId = const Value.absent(),
                Value<PracticeMode> mode = const Value.absent(),
                Value<CardSourceKind> sourceKind = const Value.absent(),
                Value<String?> sourceId = const Value.absent(),
                Value<String> configJson = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> totalRounds = const Value.absent(),
                Value<int> correctRounds = const Value.absent(),
                Value<bool> affectsScheduling = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PracticeSessionsCompanion(
                id: id,
                gameId: gameId,
                mode: mode,
                sourceKind: sourceKind,
                sourceId: sourceId,
                configJson: configJson,
                startedAt: startedAt,
                endedAt: endedAt,
                totalRounds: totalRounds,
                correctRounds: correctRounds,
                affectsScheduling: affectsScheduling,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String gameId,
                required PracticeMode mode,
                required CardSourceKind sourceKind,
                Value<String?> sourceId = const Value.absent(),
                required String configJson,
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> totalRounds = const Value.absent(),
                Value<int> correctRounds = const Value.absent(),
                required bool affectsScheduling,
                Value<int> rowid = const Value.absent(),
              }) => PracticeSessionsCompanion.insert(
                id: id,
                gameId: gameId,
                mode: mode,
                sourceKind: sourceKind,
                sourceId: sourceId,
                configJson: configJson,
                startedAt: startedAt,
                endedAt: endedAt,
                totalRounds: totalRounds,
                correctRounds: correctRounds,
                affectsScheduling: affectsScheduling,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PracticeSessionsTable, PracticeSessionRow>(
                    table,
                  ),
                  $$PracticeSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({practiceAnswersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (practiceAnswersRefs) db.practiceAnswers,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (practiceAnswersRefs)
                    await $_getPrefetchedData<
                      PracticeSessionRow,
                      $PracticeSessionsTable,
                      PracticeAnswerRow
                    >(
                      currentTable: table,
                      referencedTable: $$PracticeSessionsTableReferences
                          ._practiceAnswersRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PracticeSessionsTableReferences(
                            db,
                            table,
                            p0,
                          ).practiceAnswersRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sessionId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PracticeSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PracticeSessionsTable,
      PracticeSessionRow,
      $$PracticeSessionsTableFilterComposer,
      $$PracticeSessionsTableOrderingComposer,
      $$PracticeSessionsTableAnnotationComposer,
      $$PracticeSessionsTableCreateCompanionBuilder,
      $$PracticeSessionsTableUpdateCompanionBuilder,
      (PracticeSessionRow, $$PracticeSessionsTableReferences),
      PracticeSessionRow,
      PrefetchHooks Function({bool practiceAnswersRefs})
    >;
typedef $$PracticeAnswersTableCreateCompanionBuilder =
    PracticeAnswersCompanion Function({
      required String id,
      required String sessionId,
      required String wordId,
      required int roundIndex,
      required ReviewOutcome result,
      Value<int?> responseMs,
      required DateTime answeredAt,
      Value<int> rowid,
    });
typedef $$PracticeAnswersTableUpdateCompanionBuilder =
    PracticeAnswersCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<String> wordId,
      Value<int> roundIndex,
      Value<ReviewOutcome> result,
      Value<int?> responseMs,
      Value<DateTime> answeredAt,
      Value<int> rowid,
    });

final class $$PracticeAnswersTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PracticeAnswersTable,
          PracticeAnswerRow
        > {
  $$PracticeAnswersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PracticeSessionsTable _sessionIdTable(_$AppDatabase db) => db
      .practiceSessions
      .createAlias('practice_answers__session_id__practice_sessions__id');

  $$PracticeSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$PracticeSessionsTableTableManager(
      $_db,
      $_db.practiceSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WordsTable _wordIdTable(_$AppDatabase db) =>
      db.words.createAlias('practice_answers__word_id__words__id');

  $$WordsTableProcessedTableManager get wordId {
    final $_column = $_itemColumn<String>('word_id')!;

    final manager = $$WordsTableTableManager(
      $_db,
      $_db.words,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PracticeAnswersTableFilterComposer
    extends Composer<_$AppDatabase, $PracticeAnswersTable> {
  $$PracticeAnswersTableFilterComposer({
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

  ColumnFilters<int> get roundIndex => $composableBuilder(
    column: $table.roundIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ReviewOutcome, ReviewOutcome, String>
  get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get responseMs => $composableBuilder(
    column: $table.responseMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get answeredAt =>
      $composableBuilder(
        column: $table.answeredAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$PracticeSessionsTableFilterComposer get sessionId {
    final $$PracticeSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableFilterComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordsTableFilterComposer get wordId {
    final $$WordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableFilterComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PracticeAnswersTableOrderingComposer
    extends Composer<_$AppDatabase, $PracticeAnswersTable> {
  $$PracticeAnswersTableOrderingComposer({
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

  ColumnOrderings<int> get roundIndex => $composableBuilder(
    column: $table.roundIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get responseMs => $composableBuilder(
    column: $table.responseMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PracticeSessionsTableOrderingComposer get sessionId {
    final $$PracticeSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordsTableOrderingComposer get wordId {
    final $$WordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableOrderingComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PracticeAnswersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PracticeAnswersTable> {
  $$PracticeAnswersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get roundIndex => $composableBuilder(
    column: $table.roundIndex,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ReviewOutcome, String> get result =>
      $composableBuilder(column: $table.result, builder: (column) => column);

  GeneratedColumn<int> get responseMs => $composableBuilder(
    column: $table.responseMs,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, int> get answeredAt =>
      $composableBuilder(
        column: $table.answeredAt,
        builder: (column) => column,
      );

  $$PracticeSessionsTableAnnotationComposer get sessionId {
    final $$PracticeSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordsTableAnnotationComposer get wordId {
    final $$WordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableAnnotationComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PracticeAnswersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PracticeAnswersTable,
          PracticeAnswerRow,
          $$PracticeAnswersTableFilterComposer,
          $$PracticeAnswersTableOrderingComposer,
          $$PracticeAnswersTableAnnotationComposer,
          $$PracticeAnswersTableCreateCompanionBuilder,
          $$PracticeAnswersTableUpdateCompanionBuilder,
          (PracticeAnswerRow, $$PracticeAnswersTableReferences),
          PracticeAnswerRow,
          PrefetchHooks Function({bool sessionId, bool wordId})
        > {
  $$PracticeAnswersTableTableManager(
    _$AppDatabase db,
    $PracticeAnswersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PracticeAnswersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PracticeAnswersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PracticeAnswersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> wordId = const Value.absent(),
                Value<int> roundIndex = const Value.absent(),
                Value<ReviewOutcome> result = const Value.absent(),
                Value<int?> responseMs = const Value.absent(),
                Value<DateTime> answeredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PracticeAnswersCompanion(
                id: id,
                sessionId: sessionId,
                wordId: wordId,
                roundIndex: roundIndex,
                result: result,
                responseMs: responseMs,
                answeredAt: answeredAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required String wordId,
                required int roundIndex,
                required ReviewOutcome result,
                Value<int?> responseMs = const Value.absent(),
                required DateTime answeredAt,
                Value<int> rowid = const Value.absent(),
              }) => PracticeAnswersCompanion.insert(
                id: id,
                sessionId: sessionId,
                wordId: wordId,
                roundIndex: roundIndex,
                result: result,
                responseMs: responseMs,
                answeredAt: answeredAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PracticeAnswersTable, PracticeAnswerRow>(table),
                  $$PracticeAnswersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false, wordId = false}) {
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
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$PracticeAnswersTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$PracticeAnswersTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (wordId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.wordId,
                        referencedTable: $$PracticeAnswersTableReferences
                            ._wordIdTable(db),
                        referencedColumn: $$PracticeAnswersTableReferences
                            ._wordIdTable(db)
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

typedef $$PracticeAnswersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PracticeAnswersTable,
      PracticeAnswerRow,
      $$PracticeAnswersTableFilterComposer,
      $$PracticeAnswersTableOrderingComposer,
      $$PracticeAnswersTableAnnotationComposer,
      $$PracticeAnswersTableCreateCompanionBuilder,
      $$PracticeAnswersTableUpdateCompanionBuilder,
      (PracticeAnswerRow, $$PracticeAnswersTableReferences),
      PracticeAnswerRow,
      PrefetchHooks Function({bool sessionId, bool wordId})
    >;
typedef $$AppMetaTableCreateCompanionBuilder = AppMetaCompanion Function({
  required String key,
  Value<String?> value,
  Value<int> rowid,
});
typedef $$AppMetaTableUpdateCompanionBuilder = AppMetaCompanion Function({
  Value<String> key,
  Value<String?> value,
  Value<int> rowid,
});

class $$AppMetaTableFilterComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableFilterComposer({
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

class $$AppMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableOrderingComposer({
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

class $$AppMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableAnnotationComposer({
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

class $$AppMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppMetaTable,
          AppMetaRow,
          $$AppMetaTableFilterComposer,
          $$AppMetaTableOrderingComposer,
          $$AppMetaTableAnnotationComposer,
          $$AppMetaTableCreateCompanionBuilder,
          $$AppMetaTableUpdateCompanionBuilder,
          (
            AppMetaRow,
            BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaRow>,
          ),
          AppMetaRow,
          PrefetchHooks Function()
        > {
  $$AppMetaTableTableManager(_$AppDatabase db, $AppMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String?> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppMetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            Value<String?> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppMetaCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppMetaTable, AppMetaRow>(table),
                  BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaRow>(
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

typedef $$AppMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppMetaTable,
      AppMetaRow,
      $$AppMetaTableFilterComposer,
      $$AppMetaTableOrderingComposer,
      $$AppMetaTableAnnotationComposer,
      $$AppMetaTableCreateCompanionBuilder,
      $$AppMetaTableUpdateCompanionBuilder,
      (AppMetaRow, BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaRow>),
      AppMetaRow,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  Value<int> id,
  Value<ThemePreference> themeMode,
  Value<TtsLocale> ttsLocale,
  Value<double> ttsRate,
  Value<double> ttsPitch,
  Value<bool> autoplayOnOpen,
  Value<int> dailyGoal,
  Value<bool> reminderEnabled,
  Value<int?> reminderTimeMinutes,
  Value<PromptSide> promptSide,
  Value<bool> lookupEnabled,
  Value<String> reviewSchedule,
  Value<int> againRepeats,
  Value<String> mixSides,
  Value<MixOrder> mixOrder,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<int> id,
  Value<ThemePreference> themeMode,
  Value<TtsLocale> ttsLocale,
  Value<double> ttsRate,
  Value<double> ttsPitch,
  Value<bool> autoplayOnOpen,
  Value<int> dailyGoal,
  Value<bool> reminderEnabled,
  Value<int?> reminderTimeMinutes,
  Value<PromptSide> promptSide,
  Value<bool> lookupEnabled,
  Value<String> reviewSchedule,
  Value<int> againRepeats,
  Value<String> mixSides,
  Value<MixOrder> mixOrder,
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

  ColumnWithTypeConverterFilters<ThemePreference, ThemePreference, String>
  get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<TtsLocale, TtsLocale, String> get ttsLocale =>
      $composableBuilder(
        column: $table.ttsLocale,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get ttsRate => $composableBuilder(
    column: $table.ttsRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ttsPitch => $composableBuilder(
    column: $table.ttsPitch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get autoplayOnOpen => $composableBuilder(
    column: $table.autoplayOnOpen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyGoal => $composableBuilder(
    column: $table.dailyGoal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderTimeMinutes => $composableBuilder(
    column: $table.reminderTimeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PromptSide, PromptSide, String>
  get promptSide => $composableBuilder(
    column: $table.promptSide,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get lookupEnabled => $composableBuilder(
    column: $table.lookupEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewSchedule => $composableBuilder(
    column: $table.reviewSchedule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get againRepeats => $composableBuilder(
    column: $table.againRepeats,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mixSides => $composableBuilder(
    column: $table.mixSides,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MixOrder, MixOrder, String> get mixOrder =>
      $composableBuilder(
        column: $table.mixOrder,
        builder: (column) => ColumnWithTypeConverterFilters(column),
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

  ColumnOrderings<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ttsLocale => $composableBuilder(
    column: $table.ttsLocale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ttsRate => $composableBuilder(
    column: $table.ttsRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ttsPitch => $composableBuilder(
    column: $table.ttsPitch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoplayOnOpen => $composableBuilder(
    column: $table.autoplayOnOpen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyGoal => $composableBuilder(
    column: $table.dailyGoal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderTimeMinutes => $composableBuilder(
    column: $table.reminderTimeMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get promptSide => $composableBuilder(
    column: $table.promptSide,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get lookupEnabled => $composableBuilder(
    column: $table.lookupEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewSchedule => $composableBuilder(
    column: $table.reviewSchedule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get againRepeats => $composableBuilder(
    column: $table.againRepeats,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mixSides => $composableBuilder(
    column: $table.mixSides,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mixOrder => $composableBuilder(
    column: $table.mixOrder,
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

  GeneratedColumnWithTypeConverter<ThemePreference, String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TtsLocale, String> get ttsLocale =>
      $composableBuilder(column: $table.ttsLocale, builder: (column) => column);

  GeneratedColumn<double> get ttsRate =>
      $composableBuilder(column: $table.ttsRate, builder: (column) => column);

  GeneratedColumn<double> get ttsPitch =>
      $composableBuilder(column: $table.ttsPitch, builder: (column) => column);

  GeneratedColumn<bool> get autoplayOnOpen => $composableBuilder(
    column: $table.autoplayOnOpen,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dailyGoal =>
      $composableBuilder(column: $table.dailyGoal, builder: (column) => column);

  GeneratedColumn<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderTimeMinutes => $composableBuilder(
    column: $table.reminderTimeMinutes,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<PromptSide, String> get promptSide =>
      $composableBuilder(
        column: $table.promptSide,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get lookupEnabled => $composableBuilder(
    column: $table.lookupEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reviewSchedule => $composableBuilder(
    column: $table.reviewSchedule,
    builder: (column) => column,
  );

  GeneratedColumn<int> get againRepeats => $composableBuilder(
    column: $table.againRepeats,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mixSides =>
      $composableBuilder(column: $table.mixSides, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MixOrder, String> get mixOrder =>
      $composableBuilder(column: $table.mixOrder, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          SettingsRow,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (
            SettingsRow,
            BaseReferences<_$AppDatabase, $SettingsTable, SettingsRow>,
          ),
          SettingsRow,
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
                Value<ThemePreference> themeMode = const Value.absent(),
                Value<TtsLocale> ttsLocale = const Value.absent(),
                Value<double> ttsRate = const Value.absent(),
                Value<double> ttsPitch = const Value.absent(),
                Value<bool> autoplayOnOpen = const Value.absent(),
                Value<int> dailyGoal = const Value.absent(),
                Value<bool> reminderEnabled = const Value.absent(),
                Value<int?> reminderTimeMinutes = const Value.absent(),
                Value<PromptSide> promptSide = const Value.absent(),
                Value<bool> lookupEnabled = const Value.absent(),
                Value<String> reviewSchedule = const Value.absent(),
                Value<int> againRepeats = const Value.absent(),
                Value<String> mixSides = const Value.absent(),
                Value<MixOrder> mixOrder = const Value.absent(),
              }) => SettingsCompanion(
                id: id,
                themeMode: themeMode,
                ttsLocale: ttsLocale,
                ttsRate: ttsRate,
                ttsPitch: ttsPitch,
                autoplayOnOpen: autoplayOnOpen,
                dailyGoal: dailyGoal,
                reminderEnabled: reminderEnabled,
                reminderTimeMinutes: reminderTimeMinutes,
                promptSide: promptSide,
                lookupEnabled: lookupEnabled,
                reviewSchedule: reviewSchedule,
                againRepeats: againRepeats,
                mixSides: mixSides,
                mixOrder: mixOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<ThemePreference> themeMode = const Value.absent(),
                Value<TtsLocale> ttsLocale = const Value.absent(),
                Value<double> ttsRate = const Value.absent(),
                Value<double> ttsPitch = const Value.absent(),
                Value<bool> autoplayOnOpen = const Value.absent(),
                Value<int> dailyGoal = const Value.absent(),
                Value<bool> reminderEnabled = const Value.absent(),
                Value<int?> reminderTimeMinutes = const Value.absent(),
                Value<PromptSide> promptSide = const Value.absent(),
                Value<bool> lookupEnabled = const Value.absent(),
                Value<String> reviewSchedule = const Value.absent(),
                Value<int> againRepeats = const Value.absent(),
                Value<String> mixSides = const Value.absent(),
                Value<MixOrder> mixOrder = const Value.absent(),
              }) => SettingsCompanion.insert(
                id: id,
                themeMode: themeMode,
                ttsLocale: ttsLocale,
                ttsRate: ttsRate,
                ttsPitch: ttsPitch,
                autoplayOnOpen: autoplayOnOpen,
                dailyGoal: dailyGoal,
                reminderEnabled: reminderEnabled,
                reminderTimeMinutes: reminderTimeMinutes,
                promptSide: promptSide,
                lookupEnabled: lookupEnabled,
                reviewSchedule: reviewSchedule,
                againRepeats: againRepeats,
                mixSides: mixSides,
                mixOrder: mixOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, SettingsRow>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, SettingsRow>(
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

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      SettingsRow,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (SettingsRow, BaseReferences<_$AppDatabase, $SettingsTable, SettingsRow>),
      SettingsRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $WordsFtsTableManager get wordsFts =>
      $WordsFtsTableManager(_db, _db.wordsFts);
  $$WordsTableTableManager get words =>
      $$WordsTableTableManager(_db, _db.words);
  $$WordNotesTableTableManager get wordNotes =>
      $$WordNotesTableTableManager(_db, _db.wordNotes);
  $$IpaHighlightsTableTableManager get ipaHighlights =>
      $$IpaHighlightsTableTableManager(_db, _db.ipaHighlights);
  $$WordListsTableTableManager get wordLists =>
      $$WordListsTableTableManager(_db, _db.wordLists);
  $$WordListItemsTableTableManager get wordListItems =>
      $$WordListItemsTableTableManager(_db, _db.wordListItems);
  $$StudyCardsTableTableManager get studyCards =>
      $$StudyCardsTableTableManager(_db, _db.studyCards);
  $$PracticeSessionsTableTableManager get practiceSessions =>
      $$PracticeSessionsTableTableManager(_db, _db.practiceSessions);
  $$PracticeAnswersTableTableManager get practiceAnswers =>
      $$PracticeAnswersTableTableManager(_db, _db.practiceAnswers);
  $$AppMetaTableTableManager get appMeta =>
      $$AppMetaTableTableManager(_db, _db.appMeta);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
