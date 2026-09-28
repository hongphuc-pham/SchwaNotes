# UI / UX design

Brief: **simple, modern, friendly.** The user is studying, often tired, often on a bus.
Every screen answers one question and offers one obvious next action.

## 1. Design principles

1. **One primary action per screen**, always reachable with a thumb.
2. **The word is the hero.** Headword and IPA get the largest type on the detail screen;
   chrome recedes.
3. **Friendly, never gamified-aggressive.** Encourage, never shame. No red "you failed",
   no streak-loss guilt, no forced notifications.
4. **Show, don't explain.** Empty states teach the feature; the guide is a backup, not a
   prerequisite.
5. **Nothing hidden behind a gesture alone.** Every swipe has a visible equivalent.
6. **Colour is meaning, never decoration.** The five highlight colours are the only saturated
   colours on a word screen.

## 2. Design tokens

### Colour — "Phonetic Naturalist" (Material 3, one tonal palette per brand hue)

An olive-and-terracotta field notebook, not a gamified quiz app.

| Token | Light | Dark | Use |
|---|---|---|---|
| `primary` seed | `#4E6E34` | same seed | actions, selected states |
| `secondary` seed | `#D9653B` | same seed | playback, streaks, encouragement accents |
| `tertiary` seed | `#16A38C` | same seed | "known" / success |
| `surface` | `#FBFAFF` | `#121318` | page background |
| `surfaceContainer` | `#F1F0F7` | `#1D1E24` | cards, sheets |
| `outlineVariant` | `#DDDCE5` | `#3A3B42` | hairlines |
| `outline` | `#62665C` | `#9B9E93` | quiet text, captions, field outlines |

**The three brand values are seeds, not role values.** Each one generates its own Material
tonal palette, and a role is always taken together with its `on-` partner from the *same*
palette — so `colorScheme.secondary` is that terracotta hue at tone 40 (light) / 80 (dark),
not the literal `#D9653B`. Writing a brand hex straight into a role instead leaves its `on-`
partner generated from a different palette, which is not readable: that shipped from M0 to M3
as white on `#FF8A5B` at 2.32:1, and as a *purple* `onTertiary` on teal.

The surfaces are the exception and stay pinned. They are near-neutral, so they carry no hue
to disagree with. So is `outline`, because the app reads it as **text** (quiet lines,
captions, the IPA slashes), not only as a border: Material's tone is meant for 3:1
boundaries and measured 3.45:1 as text on the quietest surface (M7). The pinned value is the
nearest lightness on the same hue that reads at 4.5:1 everywhere, and stays quieter than
`onSurfaceVariant`.

**Contrast is asserted, not assumed.** `test/unit/core/theme_contrast_test.dart` holds, in
both brightnesses and to WCAG AA (unrounded): every colour used for text — `onSurface`,
`onSurfaceVariant`, `outline`, `primary`, `error` — at 4.5:1 on every surface it sits on
(`surface`, `surfaceContainer`, `surfaceContainerHighest`); every `on-` role at 4.5:1 on its
fill or container, and snackbar text; `outline`, `primary` and `secondary` at 3:1 as edges
and icons; and each IPA highlight — text at 4.5:1 on its tint, the underline at 3:1 on the
surface and on the tint. Decoration (`outlineVariant`, the inactive onboarding dots) and
disabled controls are exempt by name. Flutter's `textContrastGuideline` is a second net
only: it guesses a background from rendered pixels and is known to pass subtle failures.

**No dynamic colour.** Material You replaced the primary seed outright, so on Android 12+
most users would never have seen the app's own identity. The platform channel that read
`android.R.color.system_accent1_500` was removed in the M3 restyle; the app always ships its
brand. See `ARCHITECTURE.md` §3.1.

**IPA highlight palette** — five tokens, distinguishable for the common colour-vision
deficiencies, and never used for anything else:

| Token | Light fill / line | Dark fill / line |
|---|---|---|
| `amber` | `#F2B70529` / `#A37400` | `#F2B7053D` / `#F2C55C` |
| `coral` | `#F2664B29` / `#C4402A` | `#F2664B3D` / `#FF9377` |
| `violet` | `#8A6BF229` / `#5B41C4` | `#8A6BF23D` / `#B8A2FF` |
| `teal` | `#16A38C29` / `#0C7565` | `#16A38C3D` / `#5DD6C0` |
| `blue` | `#3E8BF229` / `#1E63C4` | `#3E8BF23D` / `#84B8FF` |

Rendering rule: a highlight is a **tinted background plus a 2px underline**, never coloured
glyphs. Text keeps the normal on-surface colour, so contrast stays AA in both themes and a
colourblind user still sees the underline.

### Type — Inter for UI, Charis SIL for IPA

| Role | Size / weight | Notes |
|---|---|---|
| `displayWord` | 40 / 600 | headword on detail and flashcard front |
| `ipaLarge` | 30 / 400 Charis SIL | detail screen IPA, letter-spacing 0.5 |
| `ipaInline` | 16 / 400 Charis SIL | list rows |
| `titleL` | 22 / 600 | app bars, section titles |
| `body` | 16 / 400 | definitions, notes |
| `label` | 13 / 500 | chips, captions, attribution |

All sizes scale with the OS text-size setting; layouts are tested at 200%.

**Charis SIL is a deliberate deviation from the design system**, which specifies Noto Serif
for phonetic display. Both fonts cover IPA Extensions, Spacing Modifier Letters and the
combining diacritics, so coverage is not the question. Charis SIL is the phonetics-specific
one — 3,900+ glyphs, ligated sequences for transcription, a correct single-storey ɡ by
default — it is already bundled and verified rendering on device, and it is a serif, so it
satisfies the design's stated intent. Switching would bundle a second font to lose all that.

### Shape, space, motion

- Radius: 12 chips · 16 cards · 28 sheets and dialogs · full pills for filters
- Spacing scale: 4 · 8 · 12 · 16 · 24 · 32 (nothing else)
- Elevation: tonal surfaces only; no drop shadows except the FAB
- Motion: 200ms `easeOutCubic` for enter, 150ms for exit; card flip 320ms `easeInOutCubic`;
  **all animation stops when `MediaQuery.disableAnimations` is true** — the app's own
  durations go to zero through `AppMotion.durationFor`, and Flutter cuts the transitions it
  owns (screens, sheets, dialogs, the implicit `Animated…` widgets) to 5% of their length,
  a frame or two. Nothing in `presentation/` may opt out of that or name a duration of its
  own: `no_unmanaged_motion_test.dart` and `reduce_motion_test.dart` hold both.
  Durations where nothing moves — the Undo window, the legend emphasis — are `AppTiming`.

## 3. Navigation

Three bottom tabs, plus settings in the app bar. Flat and obvious — no drawer, no nested tabs.

```
[ Words ]   [ Practice ]   [ Lists ]                     ⚙ (app bar)
```

Routes: `/words`, `/words/:id`, `/words/:id/edit`, `/words/:id/ipa`, `/lists`, `/lists/:id`,
`/practice`, `/practice/:gameId/run`, `/practice/summary/:sessionId`, `/settings`,
`/settings/guide`, `/settings/help`, `/settings/backup`, `/settings/licences`, `/onboarding`.

## 4. Screens

### 4.1 Words (home)
- App bar: title *My words*, search icon (expands to an inline field), settings icon.
- Filter chips row: `All · Favourites · Due today · No IPA yet · <list names>`. **All** and
  each list chip carry a count badge. *Favourites*, *Due today* and *No IPA yet* do not —
  their counts are not streamed today, and three extra queries is feature work, not styling.
- Cards, one per word: headword (titleL) with its part of speech as a quiet badge · the
  transcription **labelled with the accent it is** (`preferredIpa` silently falls back to US,
  so an unlabelled one is ambiguous), rendered with the user's highlights · a note-count.
  Tonal `surfaceContainer`, 16dp radius, whole card tappable.
  - Was a flat 72dp row until the Phonetic Naturalist restyle. On a phonetics app the IPA is
    the content rather than a subtitle, and a card gives it room.
  - The design also draws a per-row play button and a waveform. Neither is built: playback
    from the list is not in `FEATURES.md`, and there is no recording feature to visualise.
  - The box-level dot this section used to promise was never built. It belongs with M5's
    practice work, which is where the box level comes from.
- FAB: `+ Add word`.
- Empty state: friendly illustration, "Your first word goes here", one-line explanation,
  **Add a word** button and a secondary **See how it works** link into the guide.

### 4.2 Add / edit word
Single scrolling form, save in the app bar (enabled once the headword is non-empty).

1. **Word** — autofocus. Under it, a quiet button: **Look up** *(optional — typing it yourself
   helps you remember)*.
2. **Look-up results** appear as a dismissible card with **per-field suggestion chips**
   (IPA UK · IPA US · part of speech · definition · example). Tapping a chip fills that field
   and nothing else. A chip never overwrites text the user has already typed without a confirm.
   The card footer carries the attribution line and a *View source* link.
3. **IPA (UK)** and **IPA (US)** — each with the IPA symbol keyboard row docked above the
   keyboard: `ˈ ˌ ː ə ɜ æ ɑ ɒ ʌ ʊ ɪ i u ʃ ʒ tʃ dʒ θ ð ŋ ɹ`. Slashes are shown as fixed affixes,
   not typed.
4. **Part of speech** (chips: noun/verb/adj/adv/other) · **Definition** · **Example**
5. **Note** — one box for a first note; more can be added from detail.
6. **Add to lists** — multi-select chips.

### 4.3 Word detail
```
┌──────────────────────────────────────┐
│  ← cough                    ★  ⋯     │
│                                      │
│   cough                              │   displayWord
│   verb                               │
│                                      │
│   UK  /kɒf/     [▶]                  │   ipaLarge, highlights rendered
│   US  /kɔːf/    [▶]                  │   long-press ▶ = 0.6× slow
│   ── amber: I say /f/ too softly ─── │   highlight legend, tappable
│                                      │
│   [ Edit IPA highlights ]            │
│                                      │
│   Definition                         │
│   To expel air from the lungs…       │
│   Wiktionary · CC BY-SA 4.0 · source │
│                                      │
│   Example                            │
│   "She coughed all night."           │
│                                      │
│   My notes                    + Add  │
│   • 3 Sep — mouth more open          │
│                                      │
│   [ Open in Cambridge Dictionary ↗ ] │
└──────────────────────────────────────┘
```

### 4.4 IPA highlight editor (the signature screen)
- The IPA string is rendered as large, individually hit-testable **grapheme chips** with
  generous spacing so a fingertip can land on one symbol.
- Tap a symbol to select it; drag to extend the run; the selection is announced for
  screen readers as "selected ʃ ɜː".
- A bottom sheet holds the five colour swatches, an optional label field (40 chars) and
  **Delete highlight**.
- Overlapping highlights are allowed; the newest wins visually and both appear in the legend.
- Undo is available for the whole session; nothing is written until *Done*.

### 4.5 Lists
Grid of coloured cards: name, word count, a due-today badge. Long-press to reorder.
Detail = a filtered Words screen with **Practise this list** in the app bar.

### 4.6 Practice hub
- A goal ring at the top: *12 of 20 today*, with encouraging copy, never a warning.
  *Built at M5:* the count is different words practised today in any mode — a quick test
  is practice, and a word asked twice is one word. Beneath it, the days practised in a row,
  counted back from yesterday until today has practice (a day is not missed until it is
  over). A streak of zero is never mentioned; the line reads *Any card you practise today
  counts*. A screen reader hears the ring as one sentence.
- One card per registered game. The flashcard card shows two buttons:
  **Daily review (7 due)** and **Quick test**.
- Games below `minCards` render greyed with "Add 4 words to unlock".
- If the library cannot be counted, the hub says so and offers **Try again** — *Built at M7*:
  the count was read as "0 on failure", so a failed read told someone with a full library to
  add their first word.
- Quick-test config is a **bottom sheet**: source (All / list / Favourites), size
  (5 · 10 · 20 · All — the *All* chip shows "max 30"), prompt side, autoplay toggle, **Start**.

### 4.7 Flashcard run
- Slim progress bar; `3/10` and a close button (confirms before abandoning a daily session).
- A session that cannot start says so and offers **Try again** — *Built at M7*: the start is
  fire-and-forget, so a failure left the screen spinning with nothing to read and nothing to
  do. Nothing due, or a pool with no cards, keeps its own empty state.
- Front: the prompt side, centred, with the play button. "Tap to reveal" hint on round 1 only.
- Back: word · IPA with highlights · definition · first note.
- Grading: three wide buttons — **Again** (outline), **Good** (filled), **Easy** (tonal) —
  each showing its next interval ("2d") so the schedule is never mysterious.
- Swipe left = Again, right = Good, as an alternative to tapping, never the only way.

### 4.8 Summary
Score ring, time, words to review again, **Add missed words to a list**, **Practise again**,
**Done**. Copy is warm: "Nice work — 8 of 10." Missed words are "worth another look", not wrong.

### 4.9 Settings
```
Appearance      Theme · Text size hint
Pronunciation   Voice (UK/US) · Speed · Pitch · Autoplay on open · Test voice ▶
Practice        Daily goal · Prompt side · Daily reminder (off by default)
                Review pace (gentle · standard · intensive) · Interval per box
                Repeat missed cards in the same session (default once)
Your data       Backup & restore ▸ (export · import) · Storage used
                Dictionary look-up (on by default) · Delete all data
Help            How to use  ▸        ← always present (F-071)
                Help & feedback ▸    ← always present (F-072)
About           Version · Data sources & licences · Privacy · Buy me a coffee ↗ (only with a page)
```

*Built at M6:*
- **Every choice is a row that opens a short list**, not a segmented control: three long
  labels in a segmented button do not survive 200% text on a 320dp phone (§6), and a list
  can say what each choice means (the paces carry a one-line hint).
- **Speed and pitch are sliders** shown as multiples of normal (`0.5×`–`1.5×` for speed,
  `0.5×`–`2.0×` for pitch). They save when the thumb is released, not on every step.
- **Review pace is derived, not stored.** It names the preset whose table the user has, and
  reads *Your own* once any box has been changed by hand. The interval editor is a sheet with
  one field per box; box 0 is fixed at "later the same day", and a table that would stop
  words coming back is refused with a sentence naming the box, before anything is written.
- **Dictionary look-up** is an addition to the original drawing. `settings.lookup_enabled`
  has existed since M1 with no control; switching it off makes the app offline by choice.
- **Export and import live one level down**, on *Backup & restore* (`/settings/backup`),
  with the last backup time and the import preview — four rows of data management in the
  main list would bury *Help* below the fold.
- **Privacy** opens a sheet; the same note is a section of *Data sources & licences*. No
  route of its own.
- **Buy me a coffee** *(M8)* is the last row of About and exists only when the build has a Ko-fi
  page (`ProjectLinks.support`). It opens the page in the browser, and its hint says a tip
  unlocks nothing — which must stay true: a tip that grants no content is what keeps it outside
  Google Play Billing. No icon, no badge, no prompt anywhere else in the app.
- **Import** (F-074) is the second button on *Backup & restore*. The picker offers any file —
  Android cannot filter by an extension it has never heard of — and a file that is not a
  backup is named as such in a snackbar ("Backups end in .vnb"), as is one too large or
  damaged. A real backup opens a sheet saying what it holds and when it was made, with
  **Add to my words** (merge) already chosen and **Replace everything** beside it. Replace
  then asks for `replace` to be typed (RULES §11) — lower case, with the keyboard's capitals left alone,
  because a screen reader may spell an all-caps word out letter by letter — and says that a copy of what is here is
  kept first. Nothing is written until then. The report that follows gives words added,
  updated and already here, the other things in one line, and a quiet line for anything
  that could not be read.
- **Delete all data** is the last row of *Your data*, its title in the error colour. Two
  steps, because there is no undo and no server to restore from: the first says what goes
  and offers **Make a backup first** (which opens *Backup & restore*) beside **Continue**;
  the second asks for `delete` to be typed. It removes every row and every copy of the
  library on disk (`DATABASE.md` §5), cancels the reminder, and lands on the words tab's
  empty state. Onboarding is not shown again: the person has used the app, and the empty
  state already teaches the first step. **Storage used** above it counts everything the
  library keeps on disk, copies included, so it drops to almost nothing afterwards.

### 4.10 How to use (guide)
Six cards, each an illustration + a sentence + a *Try it* button that deep-links to the real
screen: add a word · fill it from the dictionary · write the IPA yourself · highlight the sound
you struggle with · leave a note for yourself · practise daily. Card 3 carries the honest line
about text-to-speech being a synthesised reference.

*Built at M6:*
- **A scrolling column, not a pager.** It survives 200% text, and a guide opened a second
  time is scanned rather than paged through.
- **Illustrations are composed in code** from the app's own widgets — an IPA transcription
  with a real highlight, the symbol keys, suggestion chips, a note, the goal ring — so they
  follow light and dark and the text size, and need no asset. They are wrapped in
  `ExcludeSemantics`: read out, a mock-up sounds like buttons that are not there; the card's
  sentence is what a screen reader hears.
- ***Try it* is what teaches** (help met in context is remembered; a deck of cards read up
  front is not). It opens the real screen, and where a word exists it uses it: the
  highlight card opens the newest transcribed word's IPA editor, or the newest word's editor
  so it can be given IPA, or the add form; the note card opens the newest word. The practice
  card switches to the Practice tab rather than stacking a second hub on Settings. Each
  *Try it* is announced with its card's title, so six buttons are not six "Try it"s.
- Reachable from Settings → Help and from the empty words list's *See how it works*.

### 4.11 Help & feedback
Searchable FAQ (12 short answers), then:
- **Send feedback** → composes an email. The pre-filled body (app version, OS version, device
  model) is **shown in a preview dialog first**, with "nothing else is included".
- **Report a problem on GitHub** → opens Issues.
- **Rate the app** → store listing.

*Built at M6:*
- **The FAQ filters as the user types**, over questions and answers, with the number of
  matches in a live region ("3 answers") so a screen reader hears the search work. When
  nothing matches it says so with the term — "No answers mention “zebra”." — and offers
  **Clear search**. Each answer is an `ExpansionTile`, which announces expanded/collapsed.
- **Send feedback is shown only when the build has an address** (`--dart-define=
  FEEDBACK_EMAIL`, set at M8 — an address in the app is public, and it is the owner's to
  choose). The preview shows the email's exact body: app version, OS version, device
  **model** (never the device's name, which is the owner's own label) and, only if the user
  ticks it, the newest entries of the error log — trimmed so the whole `mailto:` link stays
  under ~1,900 characters, and shown as trimmed. Then "Nothing else is included." Nothing
  opens until **Open email**; if no mail app opens, a snackbar gives the address to write to.
- **View error log** (F-079) opens a sheet with the log, readable and clearable.
- **Rate the app** is not built: there is no store listing until M8.

## 5. Copy guidelines

- Second person, present tense, contractions. "You haven't added any words yet."
- No jargon in the UI: *sounds* not *phonemes*, *practice* not *SRS*, *backup* not *export dump*.
- Errors say what happened and what to do: "Couldn't reach the dictionary. You can still type
  the IPA yourself, or try again later."
- Never blame: "worth another look", not "incorrect".
- Buttons are verbs: **Add word**, **Start practice**, **Save highlight**.

## 6. Accessibility (blocking, not optional)

- Contrast ≥ 4.5:1 for text, ≥ 3:1 for UI edges, verified in both themes
  (`theme_contrast_test.dart`, from the theme itself — §2).
- Touch targets ≥ 48×48dp, including IPA symbol chips.
- Every icon-only button has a `Semantics` label; the flip card announces its state.
- **Checked on every screen, light and dark** (`accessibility_guidelines_test.dart`): each
  screen is walked top to bottom through the real router and, at every stop, Flutter's
  48dp tap-target, labelled-tap-target and text-contrast guidelines must pass. They only see
  what is built and on screen, which is why the walk. The sheets and dialogs get the same
  (`accessibility_sheets_test.dart`).
- **Every button a screen reader can reach, it can press.** A `Semantics(button: true)` over
  an `ExcludeSemantics` must carry the `onTap` it hides; Flutter's own guidelines skip a node
  with no tap action, so `pressableButtonsGuideline` checks it on every screen and sheet.
- The IPA is exposed to screen readers as spoken symbol names, not raw glyphs. Each sound is
  read by the name a learner knows it by, with an example word for vowels — /kɒf/ is
  "pronunciation: k, short o as in hot, f" (decided 11 Sep). Two-symbol sounds (`tʃ`, `eɪ`,
  `iː`) are one name; stress is said before its syllable; anything unrecognised is read as
  itself. The names are ARB strings (`ipaSound…`); `core/utils/ipa_sounds.dart` finds the
  sounds by longest match over graphemes. It applies to every transcription (`IpaText`), each
  chip in the highlight editor, its live "selected …" line, and each IPA keyboard key
  ("Insert ch") — whose label was the glyph itself until M7, with the name only a tooltip.
- Full keyboard/switch traversal order defined on every screen.
- Layout tested at 200% text scale and at 320dp width — no clipping, no overflow.
- `MediaQuery.disableAnimations` disables the flip and all transitions.
