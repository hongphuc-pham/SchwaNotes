# Schwa Notes

*Formerly VocabNote — renamed at M8, because another vocabulary app already uses that name.*

A free, offline-first mobile app for **noting English words and mastering their pronunciation**.

You type a word, get (or write) its IPA, highlight the exact sounds you keep getting wrong,
leave yourself notes, listen to it, and practise it as flashcards. No account. No server.
No subscription. Your words live on your phone and stay yours.

> **Status: M0–M7 built; M8 (release preparation) in progress.** You can add words by hand
> or from the dictionary, search them instantly, hear them in UK or US English, colour the
> exact IPA symbols you keep getting wrong, keep lists and notes, practise with flashcards on
> a spaced schedule, and back everything up to one file you can bring back on another phone.
> Settings, a *How to use* guide and *Help & feedback* are in, and M7 checked every screen
> for contrast, tap targets, screen-reader labels, reduced motion and 200% text.
>
> 931 tests passing (timed and golden checks run apart) · `flutter analyze --fatal-infos
> --fatal-warnings` clean · backup round trip and a 5,000-word scroll measured on the Android
> emulator · cold start's own cost removed at M8 (first frame ~0.6s), but the 2-second budget is
> **not yet shown on a real phone** — see
> [`docs/PROGRESS.md`](docs/PROGRESS.md) §5 for that and for what is still unverified
> (iOS, a real phone).

---

## 1. Product principles

| # | Principle | What it means in practice |
|---|-----------|---------------------------|
| P1 | **The user's data is the user's** | 100% local SQLite database. No backend, no account, no telemetry. Export/import is user-driven. |
| P2 | **Never lose a word** | Upgrading the app must *never* reset the database. Migrations are additive-only, tested, and take an automatic backup first. |
| P3 | **Typing is learning** | Auto-fill from a dictionary is a convenience, never a requirement. Every field stays hand-editable, and manual entry is a first-class path. |
| P4 | **Pronunciation first** | The word screen is built around IPA and audio, not around definitions. |
| P5 | **Simple beats clever** | Two taps to add a word. Three tabs. No hidden gestures. Every screen has an obvious primary action. |
| P6 | **Works on a plane** | Every core action works offline. Network only enriches. |
| P7 | **Licence-clean** | Only openly licensed data ships in the app, and it is attributed in-app. See [`docs/DATA-SOURCES.md`](docs/DATA-SOURCES.md). |
| P8 | **Always reachable** | Settings always contains *How to use* and *Help & feedback*. |

## 2. What it does (v1)

- **My Words** — a searchable, filterable list of everything you are studying.
- **Add a word** — type it yourself, or tap *Look up* to pre-fill IPA, definition, examples
  and part of speech from a free open dictionary. Every field remains editable.
- **Word detail** — big headword, UK and US rows each with a play button (hold for a 0.6×
  slow replay), IPA in your highlight colours, definition with attribution, and your notes.
- **IPA highlighting** — select any run of IPA symbols and colour it, with an optional label
  such as `I say /s/ here` or `stress`. This is the signature feature.
  Selection snaps to **grapheme clusters**, so a run can never split `t͡ʃ` or orphan a length
  mark; you can tap, tap-again to extend, or drag; overlaps are allowed; undo covers the whole
  session and nothing is written until you press *Done*. If you later edit the transcription,
  highlights that still fit are kept and the rest are listed for confirmation before they go.
- **Notes (comments)** — as many timestamped notes per word as you like.
- **Lists** — group words into decks (e.g. *IELTS speaking*, *work vocabulary*).
- **Practice** — a pluggable game framework. v1 ships **Flashcards** in two modes:
  - *Daily review* — Leitner-scheduled cards that are due today.
  - *Quick test* — a random set you size yourself (5 / 10 / 20 / All, capped at 30).
- **Cambridge** — an *Open in Cambridge Dictionary* button that launches the official page
  in the browser. We link; we never scrape or copy their content.
- **Settings** — theme, TTS voice/speed, daily reminder, backup & restore,
  **How to use** guide, **Help & feedback**, and data-source attributions.

Full, numbered list with acceptance criteria: [`docs/FEATURES.md`](docs/FEATURES.md).

## 3. Tech stack

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Flutter 3.x / Dart 3 | One codebase, Android + iOS |
| State | Riverpod 3 (+ codegen) | Testable, compile-safe, no BuildContext coupling. v2 is unmaintained and cannot resolve alongside Drift — see `ARCHITECTURE.md` §3.1 |
| Navigation | go_router | Declarative, deep-link ready |
| Database | Drift over SQLite | Typed SQL, **first-class versioned migrations**, FTS5 search |
| Audio | flutter_tts | Offline, free, no licensing burden, UK/US voices |
| Networking | dio | Look-up only (FreeDictionaryAPI.com); retries, timeouts, 429 back-off |
| Models | freezed + json_serializable | Immutable, exhaustive, safe JSON |
| Local files | path_provider, share_plus, file_picker | Backup export/import |
| Notifications | flutter_local_notifications | Optional daily practice reminder |
| Links | url_launcher | Cambridge, feedback email, GitHub issues |

## 4. Repository layout

```
SchwaNotes/
├─ README.md                 <- you are here
├─ docs/
│  ├─ PROGRESS.md            <- where the work is, what's waiting on you, how to resume
│  ├─ PLAN.md                <- milestones, scope per release, phase-2 backlog
│  ├─ FEATURES.md            <- numbered features + acceptance criteria
│  ├─ ARCHITECTURE.md        <- layers, folder tree, packages, infra, CI
│  ├─ DATABASE.md            <- schema + the upgrade-safety migration policy
│  ├─ GAMES.md               <- the pluggable practice-game framework
│  ├─ UI-UX.md               <- design tokens, screens, flows, copy, a11y
│  ├─ DATA-SOURCES.md        <- dictionary/audio sources and licence compliance
│  └─ RULES.md               <- engineering + product rules, definition of done
├─ Makefile / make.ps1       <- the same task list, for make and for PowerShell
├─ drift_schemas/            <- exported schema snapshots, one per version
└─ app/                      <- the Flutter project
   ├─ lib/
   │  ├─ core/               <- theme, l10n, router, grapheme indexing, Result
   │  ├─ domain/             <- entities, value objects, repository interfaces
   │  ├─ data/               <- Drift, dictionary client, TTS, composition root
   │  ├─ application/        <- Riverpod controllers; the DI seam
   │  └─ presentation/       <- screens and widgets
   ├─ test/                  <- unit, widget, migration and architecture tests
   └─ tool/                  <- licence, migration-safety and asset scripts
```

The dependency rule is `presentation → application → domain ← data`, and it is enforced by a
test rather than by convention.

## 5. Getting started

Built and verified against **Flutter 3.47.2 / Dart 3.13.2** (stable). CI pins the same
version; anything from 3.24 up should work, but that is the one that is actually tested.

```bash
flutter --version
cd app
flutter pub get
dart run build_runner build          # riverpod, freezed, json, drift
                                     # NOT --delete-conflicting-outputs: removed in 2.16
flutter gen-l10n                     # regenerates lib/core/l10n/gen/
flutter run
```

Before pushing, run the whole gate in one command — the same six steps CI runs, in the same
order, stopping at the first failure:

```bash
make ci                # or, with no `make` installed:  .\make.ps1 ci
```

`make` is not on Windows by default. Either `winget install ezwinports.make`, or use
`make.ps1`, which is the same task list and needs nothing installed. `make help` /
`.\make.ps1 help` lists everything; the ones you will reach for most:

| Task | What it does |
|---|---|
| `ci` | Format check, licences, migration safety, migration tests, analyze, all tests |
| `test` · `test-unit` · `test-widget` | The whole suite, or just one layer of it |
| `test-migration` | The blocking upgrade-safety tests (RULES §29) |
| `test-arch` | The layer-direction and grapheme rules (RULES §20, §21) |
| `setup` · `gen` · `l10n` | Packages, code generation, localisations |
| `emulator` · `run` · `run-emulator` | Boot the AVD, run on it, or both |

Or the individual commands, if you prefer:

```bash
dart format --output=none --set-exit-if-changed .
dart run tool/check_licences.dart            # permissive licences only
dart run tool/check_migration_safety.dart    # no destructive migration patterns
flutter test test/migration                  # blocking (RULES §29)
flutter analyze --fatal-infos --fatal-warnings
flutter test
```

The architecture test (`test/architecture/layer_boundaries_test.dart`) enforces the layer
direction and the grapheme rule in place of `riverpod_lint`, which cannot be installed
alongside Drift — see `docs/ARCHITECTURE.md` §3.1.

From M1, after any schema change:

```bash
dart run drift_dev schema dump lib/data/db/app_database.dart drift_schemas/
dart run drift_dev schema steps drift_schemas/ lib/data/db/schema_versions.dart
dart run drift_dev schema generate drift_schemas/ test/migration/generated/
```

## 6. Data, licences and privacy

- Dictionary lookups use **FreeDictionaryAPI.com**, whose content is extracted from
  **Wiktionary** and licensed **CC BY-SA 4.0** — attributed in-app, with a link back to the
  source page. (`dictionaryapi.dev` is deliberately *not* used: no published licence and
  Google Dictionary provenance.)
- The offline IPA fallback ships **CMUdict** (CMU; unrestricted for research and commercial
  use, acknowledgement requested), converted to IPA by a committed build script.
- Bundled fonts **Inter** and **Charis SIL** are both SIL OFL 1.1.
- **No Cambridge content is bundled, cached or scraped.** We only open their public URL.
- The app collects **no analytics and no personal data**. Nothing leaves the device except
  the word you explicitly look up, and feedback you explicitly choose to send.

Details and the exact obligations: [`docs/DATA-SOURCES.md`](docs/DATA-SOURCES.md).

## 7. Feedback

There is no backend, so feedback is routed through the user's own mail client or GitHub
Issues from **Settings → Help & feedback**. See `F-072` in [`docs/FEATURES.md`](docs/FEATURES.md).

## 8. Licence

**MIT** — see [`LICENSE`](LICENSE). Use it, change it, ship it; just keep the copyright notice.

This is separate from the *data* licences in section 6, which bind regardless of the code
licence. In particular, dictionary content pulled from Wiktionary is **CC BY-SA 4.0** and
must stay attributed, and the bundled fonts are under the SIL OFL — none of that is relaxed
by the MIT licence on the code.
