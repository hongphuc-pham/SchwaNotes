import 'package:drift/drift.dart';
import 'package:vocabnote/data/db/converters/converters.dart';
import 'package:vocabnote/domain/entities/word_list.dart';

/// `word_lists` - the decks a user groups words into (F-042).
///
/// There is deliberately no seeded "All words" row: **All** is a filter chip
/// (`docs/UI-UX.md` §4.1), not a list. A row would be renameable, reorderable
/// and deletable, none of which is true of "all your words".
@DataClassName('WordListRow')
class WordLists extends Table {
  /// UUID v4.
  TextColumn get id => text()();

  /// What the user called it.
  TextColumn get name => text()();

  /// Card colour, by token name - the same palette the highlights use.
  TextColumn get colorToken =>
      text().named('color_token').map(ipaColorTokenConverter)();

  /// Optional icon identifier, for a later release.
  TextColumn get iconKey => text().named('icon_key').nullable()();

  /// Position in the grid; lower sorts first.
  IntColumn get sortOrder => integer().named('sort_order')();

  /// Epoch milliseconds UTC.
  IntColumn get createdAt =>
      integer().named('created_at').map(epochMillisConverter)();

  /// Epoch milliseconds UTC.
  IntColumn get updatedAt =>
      integer().named('updated_at').map(epochMillisConverter)();

  /// `list` or `tag`. Added at v4; every row from before then is a list.
  TextColumn get kind =>
      textEnum<ListKind>().withDefault(const Constant('list'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
