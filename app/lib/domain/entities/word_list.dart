import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vocabnote/domain/value_objects/ipa_color_token.dart';

part 'word_list.freezed.dart';

/// What a row of `word_lists` is to the user.
///
/// One table for both, because a tag does everything a list does: it holds
/// words, opens the same screen and can be practised. Only where it shows
/// differs, and a tag never appears in the Lists tab.
enum ListKind {
  /// A deck: the word's category, a card on the Lists tab.
  list,

  /// A label on a word. A word usually has several.
  tag,
}

/// A deck the user groups words into - "IELTS speaking", "work vocabulary"
/// (F-042).
///
/// A word can belong to many lists, and **deleting a list never deletes
/// words**: the cascade runs from `word_lists` to `word_list_items` only, and
/// there is a test that says so.
///
/// "All words" is deliberately *not* one of these. It is a filter chip
/// (`UI-UX.md` §4.1), not a row - otherwise it would be renameable, reorderable
/// and deletable, which it must not be.
@freezed
abstract class WordList with _$WordList {
  /// Creates a list.
  const factory({
    /// UUID v4.
    required String id,

    /// What the user called it.
    required String name,

    /// Card colour. Reuses the IPA palette tokens so the app has one set of
    /// colours, stored by name so a theme change recolours existing lists.
    required IpaColorToken color,

    /// Position in the grid; lower sorts first. Long-press to reorder.
    required int sortOrder,

    /// When it was created.
    required DateTime createdAt,

    /// When it was last renamed, recoloured or reordered.
    required DateTime updatedAt,

    /// Optional icon identifier, for a later release.
    String? iconKey,

    /// A list or a tag.
    @Default(ListKind.list) ListKind kind,
  }) = _WordList;

  const new _();
}

/// A list plus the counts the grid shows on its card (`UI-UX.md` §4.5).
///
/// Kept separate from [WordList] because the counts are a query result, not
/// part of the list itself - storing them would mean keeping two sources of
/// truth in sync.
@freezed
abstract class WordListSummary with _$WordListSummary {
  /// Creates a summary.
  const factory({
    /// The list itself.
    required WordList list,

    /// How many words are in it, excluding soft-deleted ones.
    required int wordCount,

    /// How many of those have a study card due now - the due-today badge.
    required int dueCount,
  }) = _WordListSummary;

  const new _();

  /// Whether the badge should be shown at all.
  bool get hasDue => dueCount > 0;
}
