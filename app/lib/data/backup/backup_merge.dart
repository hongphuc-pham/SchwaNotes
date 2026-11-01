import 'package:vocabnote/data/backup/backup_codec.dart';
import 'package:vocabnote/data/backup/backup_rows.dart';
import 'package:vocabnote/data/backup/backup_sql.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/repositories/mappers.dart';
import 'package:vocabnote/domain/entities/app_settings.dart';
import 'package:vocabnote/domain/entities/backup.dart';

/// One merge of a checked backup into the library (F-074, the default).
///
/// **Only adds and updates.** It never deletes or hides a word the user has;
/// where both sides hold the same thing, the newer one wins. The table this
/// follows is in `docs/DATABASE.md` §5. Run inside the caller's transaction.
class BackupMerge {
  /// Prepares a merge of [_backup] into [_db].
  new(this._db, this._backup);

  final AppDatabase _db;
  final CheckedBackup _backup;

  /// Backup word id → the id it has on this phone.
  final Map<String, String> _wordIds = <String, String>{};

  /// Words the backup holds, by the backup's id.
  final Map<String, BackupRow> _backupWords = <String, BackupRow>{};

  /// Backup words deleted in the backup. What hangs off them is skipped
  /// quietly - it is not broken, it belongs to something the user removed.
  final Set<String> _deletedInBackup = <String>{};

  /// Backup list id → the id it has on this phone.
  final Map<String, String> _listIds = <String, String>{};

  late int _rejected = _backup.rejected;
  int _wordsAdded = 0;
  int _wordsUpdated = 0;
  int _wordsSkipped = 0;
  int _notesAdded = 0;
  int _highlightsAdded = 0;
  int _listsAdded = 0;

  /// Runs the merge, table by table, parents first.
  Future<ImportReport> run() async {
    await _words();
    await _notes();
    await _highlights();
    await _lists();
    await _listItems();
    await _cards();
    await _practice();
    await _settings();
    return ImportReport(
      wordsAdded: _wordsAdded,
      wordsUpdated: _wordsUpdated,
      wordsSkipped: _wordsSkipped,
      notesAdded: _notesAdded,
      highlightsAdded: _highlightsAdded,
      listsAdded: _listsAdded,
      rejected: _rejected,
    );
  }

  /// This phone's id for a backup word, or null. A row pointing at a word
  /// the backup does not hold at all is counted as unusable.
  String? _wordFor(Object? backupId) {
    final id = _wordIds[backupId];
    if (id == null && !_deletedInBackup.contains(backupId)) _rejected++;
    return id;
  }

  Future<void> _words() async {
    final local = <String, BackupRow>{
      for (final row in await _db.selectRows(
        'SELECT id, headword_normalized, updated_at, deleted_at FROM words',
      ))
        row['id']! as String: row,
    };
    final liveByHeadword = <String, String>{
      for (final row in local.values)
        if (row['deleted_at'] == null)
          row['headword_normalized']! as String: row['id']! as String,
    };

    for (final row in _backup.rows('words')) {
      final id = row['id']! as String;
      if (_backupWords.containsKey(id)) {
        _rejected++;
        continue;
      }
      _backupWords[id] = row;
      final headword = row['headword_normalized']! as String;
      // Same id first; then the same live word typed on another phone.
      final match = local.containsKey(id) ? id : liveByHeadword[headword];

      if (row['deleted_at'] != null) {
        // A merge never deletes: this phone's copy, if any, stays as it is.
        if (match == null) _deletedInBackup.add(id);
        if (match != null) _wordIds[id] = match;
        _wordsSkipped++;
        continue;
      }
      if (match == null) {
        await _db.insertRow('words', row);
        _wordIds[id] = id;
        local[id] = row;
        liveByHeadword[headword] = id;
        _wordsAdded++;
        continue;
      }

      _wordIds[id] = match;
      if ((row['updated_at']! as int) > (local[match]!['updated_at']! as int)) {
        await _db.updateRow(
          'words',
          <String, Object?>{...row, 'deleted_at': null}
            ..remove('id')
            ..remove('created_at'),
          keyColumn: 'id',
          key: match,
        );
        _wordsUpdated++;
      } else {
        _wordsSkipped++;
      }
    }
  }

  Future<void> _notes() async {
    final local = <String, int>{
      for (final row in await _db.selectRows(
        'SELECT id, updated_at FROM word_notes',
      ))
        row['id']! as String: row['updated_at']! as int,
    };
    for (final row in _backup.rows('word_notes')) {
      final wordId = _wordFor(row['word_id']);
      if (wordId == null) continue;
      final id = row['id']! as String;
      final note = <String, Object?>{...row, 'word_id': wordId};
      final localUpdated = local[id];
      if (localUpdated == null) {
        await _db.insertRow('word_notes', note);
        local[id] = row['updated_at']! as int;
        _notesAdded++;
      } else if ((row['updated_at']! as int) > localUpdated) {
        await _db.updateRow(
          'word_notes',
          note..remove('id'),
          keyColumn: 'id',
          key: id,
        );
      }
    }
  }

  Future<void> _highlights() async {
    final local = <Object?>{
      for (final row in await _db.selectRows('SELECT id FROM ipa_highlights'))
        row['id'],
    };
    for (final row in _backup.rows('ipa_highlights')) {
      final wordId = _wordFor(row['word_id']);
      if (wordId == null || local.contains(row['id'])) continue;
      final target = row['target'];
      if (target != 'ipa_uk' && target != 'ipa_us') {
        _rejected++;
        continue;
      }
      // Only onto the transcription it was drawn on: if this phone's word
      // now reads differently, the range would mark the wrong sounds.
      final drawnOn = _backupWords[row['word_id']]?[target];
      final current = (await _db.selectRows(
        'SELECT $target AS ipa FROM words WHERE id = ?',
        <Object?>[wordId],
      )).single['ipa'];
      if (drawnOn == null || current != drawnOn) continue;
      if (!highlightFits(row, current! as String)) {
        _rejected++;
        continue;
      }
      await _db.insertRow('ipa_highlights', <String, Object?>{
        ...row,
        'word_id': wordId,
      });
      local.add(row['id']);
      _highlightsAdded++;
    }
  }

  Future<void> _lists() async {
    // By kind as well as name: a list "Verbs" and a tag "verbs" are two
    // things. A backup from before tags has no kind, and only lists.
    String key(BackupRow row) =>
        '${row['kind'] ?? 'list'}|'
        '${(row['name']! as String).trim().toLowerCase()}';

    final local = await _db.selectRows(
      'SELECT id, name, kind, updated_at FROM word_lists',
    );
    final byId = <String, BackupRow>{
      for (final row in local) row['id']! as String: row,
    };
    final byName = <String, String>{
      for (final row in local) key(row): row['id']! as String,
    };
    final highest = (await _db.selectRows(
      'SELECT max(sort_order) AS top FROM word_lists',
    )).single['top'];
    var nextOrder = highest is int ? highest + 1 : 0;

    // In the backup's own order, appended after this phone's lists.
    final incoming = [..._backup.rows('word_lists')]
      ..sort((a, b) => (a['sort_order']! as int) - (b['sort_order']! as int));
    for (final row in incoming) {
      final id = row['id']! as String;
      final match = byId.containsKey(id) ? id : byName[key(row)];
      if (match == null) {
        await _db.insertRow('word_lists', <String, Object?>{
          ...row,
          'sort_order': nextOrder++,
        });
        _listIds[id] = id;
        byId[id] = row;
        byName[key(row)] = id;
        _listsAdded++;
        continue;
      }
      _listIds[id] = match;
      if ((row['updated_at']! as int) > (byId[match]!['updated_at']! as int)) {
        await _db.updateRow(
          'word_lists',
          <String, Object?>{
            for (final column in <String>[
              'name',
              'kind',
              'color_token',
              'icon_key',
              'updated_at',
            ])
              if (row.containsKey(column)) column: row[column],
          },
          keyColumn: 'id',
          key: match,
        );
      }
    }
  }

  Future<void> _listItems() async {
    final local = <String>{
      for (final row in await _db.selectRows(
        'SELECT list_id, word_id FROM word_list_items',
      ))
        '${row['list_id']}|${row['word_id']}',
    };
    for (final row in _backup.rows('word_list_items')) {
      final listId = _listIds[row['list_id']];
      if (listId == null) {
        _rejected++;
        continue;
      }
      final wordId = _wordFor(row['word_id']);
      if (wordId == null || !local.add('$listId|$wordId')) continue;
      await _db.insertRow('word_list_items', <String, Object?>{
        ...row,
        'list_id': listId,
        'word_id': wordId,
      });
    }
  }

  Future<void> _cards() async {
    final local = <String, int>{
      for (final row in await _db.selectRows(
        'SELECT word_id, last_reviewed_at FROM study_cards',
      ))
        row['word_id']! as String: (row['last_reviewed_at'] as int?) ?? -1,
    };
    for (final row in _backup.rows('study_cards')) {
      final wordId = _wordFor(row['word_id']);
      if (wordId == null) continue;
      if (!cardBoxValid(row)) {
        _rejected++;
        continue;
      }
      final card = <String, Object?>{...row, 'word_id': wordId};
      final reviewed = (row['last_reviewed_at'] as int?) ?? -1;
      final localReviewed = local[wordId];
      if (localReviewed == null) {
        await _db.insertRow('study_cards', card);
        local[wordId] = reviewed;
      } else if (reviewed > localReviewed) {
        // The card reviewed most recently knows best where the word is.
        await _db.updateRow(
          'study_cards',
          card..remove('word_id'),
          keyColumn: 'word_id',
          key: wordId,
        );
        local[wordId] = reviewed;
      }
    }
  }

  Future<void> _practice() async {
    final sessions = <Object?>{
      for (final row in await _db.selectRows(
        'SELECT id FROM practice_sessions',
      ))
        row['id'],
    };
    for (final row in _backup.rows('practice_sessions')) {
      if (!sessions.add(row['id'])) continue;
      await _db.insertRow('practice_sessions', <String, Object?>{
        ...row,
        // A session practised from a list follows that list to this phone.
        if (_listIds.containsKey(row['source_id']))
          'source_id': _listIds[row['source_id']],
      });
    }

    final answers = <Object?>{
      for (final row in await _db.selectRows('SELECT id FROM practice_answers'))
        row['id'],
    };
    for (final row in _backup.rows('practice_answers')) {
      if (answers.contains(row['id'])) continue;
      if (!sessions.contains(row['session_id'])) {
        _rejected++;
        continue;
      }
      final wordId = _wordFor(row['word_id']);
      if (wordId == null) continue;
      await _db.insertRow('practice_answers', <String, Object?>{
        ...row,
        'word_id': wordId,
      });
      answers.add(row['id']);
    }
  }

  /// A merge brings words, not another phone's preferences - unless this
  /// phone has none of its own yet. A new phone, still on the defaults, takes
  /// the backup's; the reminder stays off, because it needs this phone's
  /// permission and only its switch may ask (F-066).
  Future<void> _settings() async {
    final incoming = _backup.rows('settings').firstOrNull;
    if (incoming == null) return;
    final current = (await _db.settingsDao.getSettings()).toEntity();
    if (current != AppSettings.defaults) return;
    await _db.updateRow(
      'settings',
      <String, Object?>{...incoming, 'reminder_enabled': 0}..remove('id'),
      keyColumn: 'id',
      key: 1,
    );
  }
}
