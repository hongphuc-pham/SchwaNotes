# Features

Priority: **M** must-have for v1 · **S** should-have for v1 · **C** could-have (cut first) ·
**P2** deferred to phase 2. Every M/S item needs the listed acceptance criteria to be green
before the milestone is closed.

---

## F-0xx · Word capture

| ID | Pri | Feature | Acceptance criteria |
|---|---|---|---|
| F-001 | M | Add a word by typing | Headword required, trimmed; duplicate `headword_normalized` warns but does not block ("You already have *cough* — open it?"); saves in ≤2 taps from the FAB. |
| F-002 | M | Manual IPA entry | A dedicated IPA field with a **symbol keyboard row** (ˈ ˌ ː ə ɜ æ ɑ ɒ ʌ ʊ ɪ i u ʃ ʒ tʃ dʒ θ ð ŋ ɹ — 21 symbols). Typing IPA by hand is a supported first-class path. *Corrected at M2: this row previously omitted `i` and `u`, which `UI-UX.md` §4.2 lists. §4.2 is the source of truth.* |
| F-003 | M | Manual definition, example, part of speech, notes | All optional, all free text. |
| F-004 | M | Dictionary look-up (opt-in per word) | Tapping *Look up* queries FreeDictionaryAPI.com and shows results as **suggestion chips per field**; nothing is written until the user taps a suggestion. Never auto-overwrites text the user has typed. |
| F-005 | M | Offline IPA fallback | With no network (or API miss), the bundled CMUdict-derived asset supplies US IPA. Result is labelled *offline* in the source field. |
| F-006 | M | Look-up failure is graceful | Timeout 6s, one retry; on failure a quiet inline message "Couldn't reach the dictionary — you can still type it in" and the form stays fully usable. |
| F-007 | S | Edit any field later | Editing IPA re-validates highlights (F-023). |
| F-008 | M | Delete a word | Soft delete + 5-second Undo snackbar; purged after 30 days. |
| F-009 | C | Quick-add from share sheet | Sharing selected text from any app opens the add screen pre-filled. |
| F-010 | P2 | Bulk import from CSV | |

## F-02x · Pronunciation & IPA

| ID | Pri | Feature | Acceptance criteria |
|---|---|---|---|
| F-020 | M | Listen to the word (TTS) | Big play button on word detail. UK / US toggle. Uses device TTS; works offline. Speed slider persisted in settings. |
| F-021 | M | Slow replay | Long-press play → 0.6× rate for imitation practice. |
| F-022 | M | **IPA highlighting** | Tap-and-drag across IPA symbols to select a run; pick one of 5 colours; optionally add a short label. Selection snaps to grapheme clusters — never splits a symbol or a combining mark. |
| F-023 | M | Highlights survive edits | If the IPA string changes, ranges that still fit are kept; ranges that don't are listed in a confirm dialog before being dropped. |
| F-024 | S | Highlight legend | Word detail shows the labels beneath the IPA, tappable to jump to the range. |
| F-025 | S | Open in Cambridge Dictionary | Button on word detail launches `https://dictionary.cambridge.org/dictionary/english/<word>` in the external browser. No scraping, no embedded webview of their content. |
| F-026 | C | Copy IPA to clipboard | |
| F-027 | P2 | Record yourself and compare | Deliberately deferred. `SpeechService` is already an interface so this drops in without touching screens. |
| F-028 | P2 | Native-speaker audio | Wiktionary/Commons mp3 with cache + attribution, behind the same interface. |

## F-04x · Organising

| ID | Pri | Feature | Acceptance criteria |
|---|---|---|---|
| F-040 | M | My Words list | Sort by recent / A–Z / least known. Shows headword, IPA preview with highlight colours, note count. |
| F-041 | M | Search | Instant, ≤100ms on 5,000 words, matches headword, definition, example and note bodies (FTS5). |
| F-042 | M | Lists (decks) | Create, rename, recolour, reorder, delete (deleting a list never deletes words). A word can be in many lists. |
| F-043 | S | Filter chips | All · Favourites · Due today · **No IPA yet** · by list. *Corrected at M4: this row said "Not practised", which disagreed with `UI-UX.md` §4.1 and with the shipped code. They are different filters over different data — one is about transcription, the other about study history. §4.1 is the source of truth, and "No IPA yet" serves the app's core job of getting a transcription onto every word.* |
| F-044 | S | Favourite a word | Star toggle from list and detail. |
| F-045 | C | Archive a word | Hidden from lists, kept in stats. |

## F-06x · Practice (see `docs/GAMES.md`)

| ID | Pri | Feature | Acceptance criteria |
|---|---|---|---|
| F-060 | M | Practice hub | Cards for each registered game, each showing availability and a one-line description. Empty state when fewer than 4 words exist, with a link to add words. |
| F-061 | M | Flashcards — **Daily review** | Pool = cards with `due_at <= now`, ordered by due then random, capped at the daily goal (default 20). Grading updates the Leitner schedule. |
| F-062 | M | Flashcards — **Quick test** | User chooses source (All / a list / Favourites) and size (5 / 10 / 20 / All), **hard-capped at 30**. Random selection with a stored seed. Does **not** change the review schedule; it records stats only. |
| F-063 | M | Card interaction | Front shows the prompt side (word, IPA, or meaning — configurable); tap or swipe up to flip; then *Again* / *Good* / *Easy*. Optional TTS autoplay on reveal. |
| F-064 | M | Session summary | Score, time, list of missed words with a one-tap "add all to a list". |
| F-065 | S | Streak & daily goal | Days practised in a row; goal ring on the hub. Non-punitive copy — no guilt language. *Built at M5: the goal counts different words practised today in any mode; the streak runs back from yesterday until today has practice, and zero is never announced — see `UI-UX.md` §4.6.* |
| F-066 | S | Optional daily reminder | Local notification at a user-chosen time; off by default; asks permission only when enabled. *Built at M5: Settings → Practice → Daily reminder, 19:00 until a time is chosen. Scheduled inexactly (no exact-alarm permission) and repeating on UTC, because the device's zone name needs a package RULES has not approved (`flutter_timezone`); it is scheduled again from local time at every launch, so a daylight saving change shifts it by an hour at most until the app next opens.* |
| F-067 | M | Game framework | Adding a second game requires exactly: one `PracticeGame` class, one round widget, one registry line. No changes to the hub, config sheet, session storage or stats. Proven by a throwaway `DummyGame` in tests. |
| F-068 | P2 | Listen-and-choose game | Hear TTS, pick the right word. |
| F-069 | P2 | IPA match game | Match word ↔ IPA. |
| F-06A | P2 | Spell-from-audio game | |

## F-07x · Settings, help, trust

| ID | Pri | Feature | Acceptance criteria |
|---|---|---|---|
| F-070 | M | Settings screen | Appearance (system/light/dark), pronunciation (voice, speed, pitch, autoplay), practice (daily goal, prompt side, reminder, review pace and interval per box, repeats of missed cards), data (backup, restore, storage used), about. *Extended at M5: the repetition schedule became the user's choice — see `GAMES.md` §5.* |
| F-071 | M | **How to use — guide** | Always present in Settings. 6 short illustrated cards: add a word · fill from the dictionary · type your own IPA · highlight the sound you struggle with · leave a note · practise daily. Re-openable any time; also shown once at onboarding. |
| F-072 | M | **Help & feedback** | Always present in Settings: searchable FAQ, "Send feedback" (opens mail with app version, OS version and device model pre-filled — nothing else, and it is shown to the user before sending), and a GitHub Issues link. No data is transmitted without an explicit tap. |
| F-073 | M | Export backup | Produces `.vnb` ZIP, shared via the OS share sheet. |
| F-074 | M | Import backup | Merge (default) or Replace (confirm + auto-backup first). Reports added/updated/skipped. *Built at M6: a merge never deletes or hides a word; a phone still on its default settings takes the backup's; neither mode switches the reminder on. The full rules are in `DATABASE.md` §5.* |
| F-075 | M | Data sources & licences | Lists FreeDictionaryAPI.com / Wiktionary (CC BY-SA 4.0) with a link back to each source page, CMUdict, the OFL fonts, and package licences via `showLicensePage()`. *Built at M6: each source is named, its licence named, and linked (Wiktionary, FreeDictionaryAPI.com, the CC BY-SA 4.0 deed, CMUdict), with "neither endorses Schwa Notes". Both fonts' `OFL.txt` are viewable in full and registered with `LicenseRegistry`, so `showLicensePage()` lists them too. Cambridge is deliberately not mentioned: DATA-SOURCES §3 allows its name only as the text of its link.* |
| F-076 | M | Privacy note | Plain-English: "Schwa Notes has no account and no analytics. Your words never leave your phone unless you export them. Looking up a word sends only that word to freedictionaryapi.com." *Built at M6: that sentence word for word, then DATA-SOURCES §7's points in the second person; one widget, shown at the top of Data sources & licences and as a sheet from Settings → About → Privacy.* |
| F-077 | S | Onboarding | 3 slides + the guide; skippable; never shown again after completion. *Built at M6: shown only to an install that has never finished it **and** has no words — an upgrading user, whose pre-M6 install was seeded "not finished", is marked done silently. Decided in `bootstrap` before the first frame, so the words tab never flashes up first. Skip on every slide; Next and Skip are buttons, so nothing needs a swipe; the position is read as "Page 2 of 3"; with reduce-motion on, pages jump. Leaving by Skip, Done or a guide card's Try it all count as finished.* |
| F-078 | S | Empty states | Every list has a friendly empty state with the primary action. |
| F-079 | C | Local error log | Rolling log of uncaught errors, viewable and attachable from feedback. |

## F-09x · Non-functional

| ID | Pri | Requirement |
|---|---|---|
| F-090 | M | **Upgrading the app never loses data** — see `docs/DATABASE.md` §3. Blocking migration tests. |
| F-091 | M | Every core action works with no network. |
| F-092 | M | Cold start to interactive ≤ 2s on a mid-range Android device. *M8: the app no longer waits for its version before the first frame (first frame 2495 → 579ms, same-boot traces). On the emulator the first frame still reaches the screen at ~2.6s, mostly software-GPU painting; unverified on a phone, so not yet claimed as met (`PROGRESS.md` §5).* |
| F-093 | M | Accessibility: WCAG AA contrast, ≥48dp targets, semantic labels on all icon buttons, supports 200% text scale without clipping, respects reduce-motion. |
| F-094 | M | Android 8+ (API 26) and iOS 15+. *Checked at M7 against the build:* Android `minSdk` is 24 (Android 7.1), so the promise holds with room to spare; iOS is **15.0**, which is Flutter 3.47's own floor — iOS 13 was never buildable on this toolchain, and the line said 13 until M7. Running on an iPhone is still unverified (`PROGRESS.md` §5). |
| F-095 | S | Full light + dark themes; no hard-coded colours anywhere. |
| F-096 | S | English UI with l10n scaffolding in place (Vietnamese as the first candidate second locale). |
| F-097 | M | No analytics, no ads, no third-party SDK that phones home. |
