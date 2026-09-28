# Progress & handover

**Living status document.** Not a specification — the eight documents beside it are the
binding ones. This says where the work actually is, what is waiting on you, and how to pick
it up without rediscovering anything.

Last updated: **14 September 2026**, M8 release preparation done on `feat/m8-release`; the steps
only you can take are §3 rows 7–10 and `store/README.md`.

---

## ▶ Resume here (14 September 2026)

**Where it stands.** M0–M7 are merged. M8 — everything a Google Play release needs that does not
need your Play Console account — is built, tested (931 tests, goldens 6, perf 8, analyze clean)
and pushed to **`feat/m8-release`**, not yet merged. The app is now **Schwa Notes**
(`io.github.hongphuc_pham.schwanotes`). What M8 found and fixed is in §6.

**Done by you so far**
- ✅ Ko-fi page: `https://ko-fi.com/williamphucpham` — wired into Settings → About and the site.
- ✅ Upload key created (14 Sep) at `C:\Users\hongp\keys\schwanotes-upload.jks`, alias `upload`,
  `CN=Hong Phuc Pham, O=Schwa Notes`, valid to 2054; `app/android/key.properties` written
  (git-ignored — checked). A signed release bundle was built and carries this key. Upload-key
  certificate SHA-256:
  `E0:CD:C0:EA:E5:C1:7D:90:B4:A2:8D:82:0A:5D:0E:31:3B:BE:C7:14:81:65:6C:37:32:E3:2E:AF:AD:A2:70:C9`
  (Play Console shows the upload key's fingerprint under App signing; it should match).
- ✅ Play listing contact email chosen (your Gmail).

**Still to do, in this order**
1. **Back up the keystore and its password** somewhere other than this PC (password manager +
   a copy of the `.jks`). Clear the clipboard if the base64 is still on it
   (`Set-Clipboard -Value ' '`, and delete it from Win+V history).
2. **Rename the repository on GitHub** to `SchwaNotes` (Settings → General). Your local `origin`
   already points at `https://github.com/hongphuc-pham/SchwaNotes.git`, so **`git push` and
   `git pull` fail with "Repository not found" until the rename is done**. Until then, push with
   `git push https://github.com/hongphuc-pham/VocabNote.git feat/m8-release`, or undo with
   `git remote set-url origin https://github.com/hongphuc-pham/VocabNote.git`.
3. **Open and merge the M8 pull request** from `feat/m8-release` (after the rename, the address is
   `github.com/hongphuc-pham/SchwaNotes/pull/new/feat/m8-release`). CI must be green.
4. **Turn on GitHub Pages**: Settings → Pages → Source: *GitHub Actions*. After the merge to
   `main`, open `https://hongphuc-pham.github.io/SchwaNotes/privacy.html` in a private window.
5. **Add the four GitHub secrets** (Settings → Secrets and variables → Actions) — only needed for
   the tag-triggered Release workflow; a manual upload does not need them:
   `UPLOAD_KEYSTORE_BASE64` (from
   `[Convert]::ToBase64String([IO.File]::ReadAllBytes('C:\Users\hongp\keys\schwanotes-upload.jks')) | Set-Clipboard`),
   `UPLOAD_KEYSTORE_PASSWORD`, `UPLOAD_KEY_ALIAS` = `upload`, `UPLOAD_KEY_PASSWORD`.
6. **Google Play Console** — `store/README.md`, top to bottom: create the app, the *App content*
   declarations (`store/data-safety.md`, `store/content-rating.md`), the listing
   (`store/listing.md`, `store/graphics/`, `store/screenshots/`), then a **closed test**: upload
   the bundle, accept Play App Signing, invite **15+ testers** (`store/testers.md`) and keep 12
   opted in for **14 days**. Then apply for production and roll out at 10% for 48 hours.

**The bundle to upload.** `cd app; flutter build appbundle --release` →
`app/build/app/outputs/bundle/release/app-release.aab` (version 1.0.0, build 1). With
`key.properties` present it is signed with your upload key. Every later upload needs a higher
build number in `app/pubspec.yaml` (`1.0.1+2`, …).

**Still unverified** (§5, §6): cold start on a real phone (F-092 not yet demonstrated), the backup
round trip on the renamed build, the launcher's themed icon, TalkBack's voice, any iPhone. The
closed test is the first chance to see them.

**Commands** are in §2 below; the local task notes, if you want the full discovery log, are in
`plans/active/m8-release/` (git-ignored, on this PC only).

---

## 1. Where we are

| Milestone | Status | Where |
|---|---|---|
| M0 — Foundations | ✅ done | PR #1 (`b81d056`) |
| M1 — Data layer | ✅ done | PR #1 |
| M2 — Word capture | ✅ done | PR #1 |
| M3 — Pronunciation & highlighting | ✅ done | PR #2 (`0b82fc7`) |
| M4 — Lists & notes | ✅ done | PR #3 (`b25f154`) |
| M5 — Practice framework + flashcards | ✅ done | PR #3 |
| M6 — Settings, guide, help, backup | ✅ done | PR #4 (`540b4f9`) |
| M7 — Polish & accessibility | ✅ done — F-092 cold start **not met** (§3 row 6) | PRs #5 (`9dce7bd`), #6 (`b787b8f`) |
| **M8 — Release** | 🔨 preparation done — Play Console, upload key and closed test are yours (§3) | `feat/m8-release` |

```
931 tests passing (8 perf + 6 golden run apart) · 2 integration tests on the emulator
flutter analyze clean · dart format clean · licences and migration safety clean
529 l10n strings · schema version 2 (M7 changes nothing in it)
```

---

## 2. Picking the work back up

### The environment (this is the part that is easy to lose)

Flutter was **not** installed on this machine and is **not** available via winget. It was
downloaded from the official archive:

- **Flutter 3.47.2 / Dart 3.13.2 (stable)** at `C:\src\flutter`
- `C:\src\flutter\bin` was added to the **user** PATH (persists across sessions)
- Web and all desktop targets are disabled (`flutter config --no-enable-web` etc.)
- Android SDK and JDK 17 were already present
- The GitHub CLI (`gh`) is installed (winget, 13 Sep) but **not logged in**; until
  `gh auth login` is run, pull requests are opened on github.com.

If `flutter --version` fails in a new shell, prepend the path:
`$env:PATH = "C:\src\flutter\bin;$env:PATH"`

### The commands that matter

```bash
cd app
flutter pub get
dart run build_runner build     # NOT --delete-conflicting-outputs; removed in build_runner 2.16
flutter gen-l10n
flutter run
```

Before pushing — CI runs exactly these, in this order:

```bash
dart format --output=none --set-exit-if-changed .
dart run build_runner build && flutter gen-l10n && git diff --exit-code --stat
                                             # generated code committed and current; any
                                             # edit to a @Riverpod class moves its hash
dart run tool/check_licences.dart            # permissive licences only
dart run tool/check_migration_safety.dart    # no destructive migration patterns
flutter test test/migration                  # blocking
flutter analyze --fatal-infos --fatal-warnings
flutter test --exclude-tags perf             # the suite
flutter test --tags perf -j 1                # the timings, alone, with nothing beside them
```

On the emulator (`Pixel_9_Pro` AVD, Android 17):

```bash
emulator -avd Pixel_9_Pro -gpu swiftshader_indirect -no-snapshot-load -no-audio
flutter test integration_test/backup_round_trip_test.dart -d emulator-5554
```

Run nothing heavy beside the emulator — it has crashed under a test run or a Gradle build.

### Releasing (from M8)

- **Upload key:** once, `powershell -ExecutionPolicy Bypass -File app/tool/make_upload_key.ps1`.
  It creates the keystore outside the repo, writes the git-ignored `app/android/key.properties`,
  and prints the four GitHub secrets. With the file present, `flutter build appbundle --release`
  is signed with the upload key; without it, with the debug key (installable on an emulator,
  refused by Play).
- **Signed bundle in CI:** push a tag matching the pubspec version (`git tag v1.0.0 && git push
  origin v1.0.0`). `.github/workflows/release.yml` builds the App Bundle from the secrets, fails
  if it is debug-signed, and leaves it as a workflow artifact. Nothing is uploaded to Play.
- **Site and privacy policy:** `site/`, deployed by `.github/workflows/pages.yml` on pushes to
  `main` that touch it (Settings → Pages → Source: GitHub Actions, once).
- **Store listing and Play Console steps:** `store/README.md`.
- **Icons and store graphics:** `flutter test tool/brand_assets_test.dart` redraws them; look at
  every PNG before committing.

Regenerating the offline pronunciation asset (rarely needed — it is committed):

```bash
dart run tool/build_ipa_fallback.dart
```

---

## 3. Waiting on you

Nothing blocks the code. M8 (release) needs things only you can provide — store accounts,
a signing key, the feedback address — and these deserve a decision when you have a moment.

| # | Decision | Why it is here |
|---|---|---|
| 1 | **Riverpod 3, not 2** | Your stack said Riverpod 2. It is not installable alongside Drift — `riverpod_generator` 2.x needs `source_gen ^2`, `drift_dev` needs `>=3` — and 2.6.1 is 22 months unmaintained. Proceeded with 3.4.3. Recorded in `ARCHITECTURE.md` §3.1. Reversible only by dropping Drift, which breaks ADR-001. |
| 2 | **`riverpod_lint` is absent** | Impossible to install: `custom_lint` caps at `analyzer ^8`, `drift_dev` needs `>=13`. The layer rule is enforced by `test/architecture/layer_boundaries_test.dart` instead, which fails the build the same way. Not re-checked at M6. |
| 3 | ~~**Index on `study_cards(box, lapses)`**~~ | ✅ Settled in M7: the index had existed since M5's v2 migration, and cannot serve this sort anyway. The real cost was the join reading every card column and discarding it; `useColumns: false` took the sort from ~100ms to ~62ms on 5,000 words, and its gate from 150ms to 100ms. No schema change. |
| 4 | ~~**The feedback address**~~ | ✅ Decided at M8 (14 Sep): **GitHub Issues only**. `FEEDBACK_EMAIL` is never set, *Send feedback* stays hidden, and the privacy note no longer lists the email point in a build without an address (DATA-SOURCES §7). |
| 7 | **Rename the repository to `SchwaNotes`** | Decided 14 Sep. Every link — in the app, the look-up's User-Agent, the site, the privacy policy and the store pack — already uses `hongphuc-pham/SchwaNotes`; GitHub redirects the old URLs. After renaming: `git remote set-url origin https://github.com/hongphuc-pham/SchwaNotes.git`. |
| 8 | ~~**A contact email for the Play listing**~~ | ✅ Your Gmail (14 Sep). Shown publicly on the listing, and named as the privacy contact on the site. |
| 9 | ~~**Your Ko-fi page**~~ | ✅ `https://ko-fi.com/williamphucpham`, wired into Settings → About and the site (14 Sep). The row is hidden in any build where `ProjectLinks.support` is null. Chosen at M8 over Buy Me a Coffee (5% fee, Stripe payouts in 44 countries) and GitHub Sponsors (supporters need a GitHub account): Ko-fi takes 0% of one-off tips, supporters pay by card, PayPal, Apple Pay or Google Pay without an account, and it pays out to PayPal or Stripe. Google Play treats a tip that unlocks nothing as a peer-to-peer payment, so no Play Billing (Payments policy, answer 10281818). |
| 10 | **The upload key and Pages** | ✅ Upload key created 14 Sep (see *Resume here*). Still to do: back it up off this PC, add the four GitHub secrets, and turn on *Settings → Pages → Source: GitHub Actions*. `store/README.md` walks the rest. |
| 5 | **Play Data safety, one reading to confirm** | A feedback email the user sends from their own mail app carries the app version and device model. Google's docs exempt user-initiated transfers the user expects, but do not name this case; `DATA-SOURCES.md` §7 records it as the reading relied on. Worth a look before the M8 store listing. |
| 6 | **Cold start: the app's own cost is fixed (M8); the 2s budget still needs a real phone** | *M8, 14 Sep:* `bootstrap` no longer waits for the version (`9c140ed`). Same-boot interleaved traces: first frame 2495 → 579ms, but first frame on screen 3.0 → 2.6s on the emulator's software GPU (§5). Run it on a phone before calling F-092 met. *Before M8:* | Measured and then instrumented at M7 (§5): of the 5162ms between framework init and the first frame, **`resolveAppVersion()` is 4872ms — 94%**. Opening and migrating the database is 26ms, so the migration theory first recorded here was wrong. Nothing before the first frame needs the app version (About and the feedback email want it), so the fix is to make it lazy or to start it unawaited like the 30-day purge already is. **Deliberately not fixed in M7** — you timeboxed this to instrumentation, and 4.9s for one channel call wants a real phone's number before anyone changes start-up. Recorded as **not met**. |

Two smaller ones, mentioned once and not worth blocking on:

- `.gitignore` excludes `.metadata` (under an "IDE" heading meant for Eclipse). Flutter's
  `.metadata` is normally committed and is used by `flutter migrate`.
- `flutter_tts` triggers a Kotlin Gradle Plugin deprecation warning that future Flutter
  versions will make fatal.

---

## 4. Decisions already made and written down

All of these are in the binding docs, not just here.

- **"All words" is a filter chip, not a seeded list** — `DATABASE.md` §2. A row would be
  renameable and deletable, which it must not be.
- **`validateDatabaseSchema()` cannot ship** — it lives in `drift_dev`, a dev dependency.
  Production does a cheap table-presence check; the real validation runs in
  `test/migration/`. Corrected in `DATABASE.md` §4.
- **Enums store documented strings, not Dart names** — `quick_test`, not `quickTest`. Rules
  out drift's `textEnum()`. Timestamps are epoch **milliseconds**, ruling out drift's
  `dateTime()` (which defaults to seconds). Both asserted by tests.
- **The DI seam** — `application/repositories.dart` declares providers against domain
  interfaces; `data/composition_root.dart` supplies implementations. `ARCHITECTURE.md` §3.3.
- **`dbus` is MPL-2.0** but reaches only Linux desktop, which Schwa Notes does not ship.
  Exempted by name in `tool/check_licences.dart`. `DATA-SOURCES.md` §6.
- **F-002 corrected** to 21 IPA symbols, matching `UI-UX.md` §4.2.
- **Verified API shape** — a miss is HTTP 200 with `entries: []`, the accent lives in
  `pronunciations[].tags`, and `text` arrives with slashes. `DATA-SOURCES.md` §1.
- **The backup file (M6)** — a `.vnb` is a ZIP of `manifest.json` and `data.json`, rows keyed
  by SQL column name. Merge matches on id, then headword; newer wins; it never deletes.
  Replace keeps a safety copy first. `DATABASE.md` §5.
- **Onboarding is decided before `runApp` (M6)**, never by a router redirect, and is not
  shown to someone upgrading who already has words. `FEATURES.md` F-077.
- **No Cambridge line on the licences screen (M6)** — the plan had one, but it would put
  the name outside its link, which `DATA-SOURCES.md` §3 forbids.

---

## 5. Known gaps and loose ends

**Verified on a device.** The Pixel_9_Pro emulator (Android 17) has been driven at every
milestone since M3. At M6, on 11 September: onboarding on a fresh install, export through
the real share sheet, import through the real file picker (merge and replace), *Delete all
data*, and the licences pages — and `integration_test/backup_round_trip_test.dart`
(export → wipe → import, every table deep-equal) passes there. Two privacy defects were
found doing it, both fixed — see §8.

At M7, on 13 September, an accessibility pass on the same emulator: dark theme, reduce motion
(all three animation scales at 0) and the platform accessibility tree, read with
`uiautomator dump`. Onboarding announces "Page 1 of 3" and advances with animation off; the
IPA symbol row reaches a screen reader as learner names — *Insert short a as in cat*, *Insert
uh as in about* — and not as raw glyphs, which is what F-093 and `UI-UX.md` §6 ask for. The
semantics were switched on with Android's Accessibility Menu rather than TalkBack, because
TalkBack's touch exploration changes what a scripted tap does; **so the labels are verified,
but how TalkBack actually pronounces them has still not been heard by anyone.** That, like
the iPhone, waits for M8.

**Measured on the emulator at M7 (13 September) — and F-092 is not met.** Every figure below
is from `Pixel_9_Pro` on a software GPU, with nothing else running; a real phone at M8 is
what settles them (§3). Read them with that in mind, but not as an excuse: the *split* is
what matters, and the split does not point at the machine.

| What | Figure | How |
|---|---|---|
| Cold start, release APK | median **4560ms** (5 runs, all `LaunchState: COLD`) | `am start -S -W` |
| → engine + framework init | 1.82s | `--trace-startup`, profile |
| → **after framework init** | **5.70s** | same |
| → first frame / rasterized | 7.52s / 9.47s | same |
| Scrolling 5,000 words | build median **4.3ms**, raster median **14.2ms**, worst build 252.9ms | `flutter drive --profile`, 204 frames |

Three things this says, in order of how much they matter:

1. **Cold start fails F-092's 2s budget, and the cost is ours.** Roughly three quarters of
   the 7.52s to first frame falls *after* framework init — `bootstrap` plus the first build,
   not engine start-up. The software GPU shows up in the 7.52s → 9.47s raster step and comes
   nowhere near explaining it, so a faster phone scales the number down without changing
   which part is heavy. **Instrumented on 13 September, and it is one call:**

   | `bootstrap` step | cumulative | own cost |
   |---|---|---|
   | binding, error log, licences, error handlers | 8ms | 8ms |
   | database opened **and migrated** | 34ms | **26ms** |
   | `resolveAppVersion()` | 4906ms | **4872ms** |
   | onboarding flag | 4935ms | 29ms |
   | first frame | 5162ms | 227ms (the first build) |

   `resolveAppVersion()` — a `package_info_plus` platform-channel call — is **94%** of the
   window; the same run's `timeAfterFrameworkInit` was 5162ms, matching the last mark exactly,
   so nothing is hidden between the marks. Opening and migrating the database costs 26ms, so
   the migration was never the problem. Nothing before the first frame needs the app version:
   it is wanted by the About screen and the feedback email. **Not fixed in M7** — measure it
   on a phone first (§3).
2. **The 4560ms figure is a lower bound, not the answer.** `am start -W` stops timing at the
   activity's first window draw, which is `LaunchTheme`'s launch background
   (`AndroidManifest.xml:17`), and Flutter never calls `reportFullyDrawn()`. "Starts in 4.5s"
   would be flattering it.
3. **Scrolling is fine.** Both medians fit inside a 60Hz frame even on this emulator. One
   252.9ms build frame (~15 dropped) is a start-up frame, recorded and not chased.

**M8, 14 September: the fix, measured.** `--trace-startup` on profile builds of `ce13187`
(before) and the fixed tree, both prebuilt and installed, runs **interleaved on one emulator
boot** so the emulator's drift lands on both; only the emulator was using the host's CPU.
Milliseconds, after framework init / first frame / first frame rasterised:

| Pair | Before | After |
|---|---|---|
| 1 | 2182 / 2598 / 4043 | 129 / 647 / 2709 |
| 2 | 1948 / 2564 / 3113 | 206 / 510 / 2347 |
| 3 | 1802 / 2161 / 2622 | 95 / 443 / 2649 |
| 4 | 2118 / 2426 / 2963 | 909 / 1288 / 2557 |
| **median** | **2033 / 2495 / 3038** | **168 / 579 / 2603** |

The app's own work before the first frame is gone. What a user sees moved less: the first frame
reaches the screen at 2.6s instead of 3.0s, because on this software GPU painting that first
frame takes about two seconds — work that was simply queued behind Dart before. **F-092 is not
demonstrated on the emulator**, and the remaining cost is the emulator's rasteriser, which a
phone's GPU does in a fraction of the time. This boot's "before" (2.0s after init) is also
quicker than M7's 5.2s: boots differ, which is why only same-boot pairs are compared. Two traps
on the way, both mine: an `am start` A/B whose numbers climbed run on run (discarded), and a
script parse error that made the first trace run measure nothing.

Caveats stated so the numbers are not over-read: profile mode carries VM-service and
`ProfileInstaller` overhead and is slower than the release build it describes, and ART was
JIT-compiling framework code cold.

**Never verified, and cannot be from Windows:**

- **iOS on a device.** An unsigned iOS build passes in CI (it did on PR #3), but the app has
  never been run on an iPhone or a simulator.
- **A physical phone.** Everything so far is the emulator, on a software GPU.

**Deliberately deferred, by milestone:**

- ~~Word detail screen is still a placeholder~~ — built in M3.
- ~~The word editor screen has no widget test~~ — made testable in M4 (`b30491d`).
- ~~*Export my data* on the recovery screen is disabled~~ — built in M6: it reads the file
  raw and read-only, so it works exactly when Drift refuses it.
- Look-up has not been driven end-to-end through the UI in a test (as of M3; not re-checked).
- `WordSort.leastKnown` has a query and a perf test but no correctness test (as of M3).
- F-078 (empty states) was not re-audited as a whole at M6; the words list's empty state
  gained *See how it works*.

---

## 6. What M8 turned out to be

Release **preparation** for Google Play. Everything that does not need your Play Console account
is done; what does is in §3 rows 7–10 and walked step by step in `store/README.md`. iOS is not
being released (no Apple account); its unsigned CI build stays.

**Three things were found rather than built:**

1. **The release build could not reach the internet.** `aapt dump permissions` on the release
   APK showed no `INTERNET`: Flutter's template declares it only in the debug and profile
   manifests. So *Look up* had failed in every release build since M2, looking exactly like
   being offline — debug runs, widget tests and M7's release-APK device pass (which never looked
   a word up) all hid it. Fixed, and guarded by `test/architecture/android_manifest_test.dart`,
   which reads the manifest because no widget test can see this. **Verified on the emulator with
   the renamed release APK:** *Look up* on "cough" returned UK /kɒf/, US /kɔːf/ and /kɔf/, the
   parts of speech, definitions, examples and the Wiktionary attribution — the first look-up
   ever driven end to end in a release build (§5 had flagged it as never driven through the UI).
2. **The name was taken.** "VocabNote" is a live iOS vocabulary app, and "Vocab Note" exists on
   Android and Windows. The app is now **Schwa Notes**, with the permanent ID
   `io.github.hongphuc_pham.schwanotes` (iOS: `io.github.hongphuc-pham.schwanotes`, which cannot
   contain `_`). The Dart package, the database file and the `.vnb` extension keep the old name
   on purpose. Guarded by `test/architecture/product_name_test.dart`. (Web search, not a legal
   clearance.)
3. **The privacy note described a feature the release does not have.** Its email-feedback point
   showed in every build, but v1.0 has no feedback address. It now shows only when one is set,
   and DATA-SOURCES §7 says so.

**Three more were found by using the renamed release build on the emulator** (onboarding, look
up, four words, a highlight, a note, a full flashcard round, Settings) — none of them visible to
the 900-odd host tests:

4. **The Daily review count froze when it started watching.** It took "now" once, so a word added
   while the hub was open was never counted ("2 due" over a four-card round), and a card graded
   *Again* that came due ten minutes later left the hub saying nothing was due, with Daily review
   disabled, until a restart. The count now uses SQLite's own clock on every re-run, and the hub
   re-reads it when the app resumes.
5. **A note was dated with the UTC day.** Written at 01:51 in Adelaide, it said the day before. The
   notes section was the only place formatting a stored instant without `toLocal()`.
6. **A suggested part of speech outside the five chips lit nothing** — "preposition" for "about"
   was taken but not shown. It now gets a chip of its own.

Each has a test that passes on the fix and a mutation that fails on an assertion. Not re-run on
the renamed build: the backup round trip (only its file-name prefix changed, which unit tests
cover), and the launcher's themed icon (`adb` cannot switch themed icons on).

**F-092, cold start:** `bootstrap` no longer waits for the app version (`9c140ed`). Measured with
`--trace-startup` on profile builds of the commit before and after, interleaved on one emulator
boot — figures in §5. The work before the first frame is gone (median 2033 → 168ms after
framework init; first frame 2495 → 579ms), but on the emulator's software GPU the first frame
still reaches the screen at about **2.6s** (was 3.0s): painting it takes ~2s there. So F-092 is
**still not demonstrated** — a real phone decides it.

**Built:** upload-key signing (`app/tool/make_upload_key.ps1`, `release.yml` on a version tag),
the icon and store graphics (`tool/brand_assets_test.dart`, no new dependency), the website and
privacy policy (`site/`, `pages.yml`), the store pack (`store/`), and a gentle *Buy me a coffee*
row that stays hidden until your Ko-fi page exists.

## 7. What M7 turned out to be

Features **F-090–F-097**: states, motion, contrast, semantics, 200% text, goldens, and the
performance budgets. Built in eight slices over two PRs, each fix mutation-checked. **F-092
(cold start) is not met** and goes to M8 with its cause measured (§5).

**Seven things were found rather than built:**

1. **Quiet text failed contrast.** `outline`, used as the app's quiet text colour, measured
   3.45:1 on its containers, and the amber IPA underline 2.39:1. Both pinned in the theme;
   `theme_contrast_test.dart` now checks every colour pair the app uses, not ten of them.
2. **Five buttons a screen reader could reach but not press** — IPA symbol chips, colour
   swatches, legend lines, the UK/US play buttons and `VnTapTarget` carried a button label and
   no tap action, so every stock guideline skipped them. Fixed, and
   `pressableButtonsGuideline` now fails any enabled button without one.
3. **The IPA symbol keys read as raw glyphs.** Each key now says its learner name (*Insert
   short a as in cat*), and so does `IpaText` — confirmed in the emulator's accessibility tree.
4. **A list card's action button was 40dp**, and the flashcard's swipe detector added an
   unlabelled node to the tree.
5. **The practice hub read a failed word count as an empty library**, telling someone with
   words to add their first; **a practice run span for ever** if starting it threw. Both now
   say what happened and offer *Try again*.
6. **The least-known sort was reading every card column and discarding it.** ~100ms → ~62ms
   on 5,000 words, no schema change (§3 row 3).
7. **F-094's iOS floor was wrong** — 15.0, Flutter 3.47's own, not 13.

**Goldens:** six, generated on Windows and compared byte for byte on Linux CI. Two more were
written and deleted after looking at them, and why is the rule for any new one: `ipa_text`
showed no highlight at all (CI goldens obscure text, and highlights are text decoration), and
`button_row` differed across platforms by 0.31% (its layout is decided by measuring text, and
font metrics differ). **A golden is worth keeping only if what it shows survives both —
shape, spacing, surface colour, fixed layout.**

**Carried to M8:** the F-092 fix, a physical phone, an iPhone, and hearing TalkBack.

## 8. What M6 turned out to be

Features **F-070–F-077 and F-079**: the settings screen, the *How to use* guide, Help &
feedback, backup export and import, data sources & licences, the privacy note, first-run
onboarding and a small on-device error log. Built in eight slices on one branch, each
mutation-checked.

**Four things were found rather than built:**

1. **Delete all data left the words readable in the database file.** FTS5 keeps a deleted
   row's tokens in its index segments until they merge; a copy pulled off the emulator held
   the headword four times. Now the index is rebuilt and the file `VACUUM`ed afterwards, and
   a host test checks the file's bytes.
2. **The OS plugins kept copies of a backup in the app's cache** — the share sheet's copy of
   the last export, and the picker's copy of a chosen file. Both now go with *Delete all
   data*, and the picker's as soon as it has been read.
3. **Two layouts broke at 200% text on 320dp**: a licences row whose button took the whole
   width, and the typed confirmation with the keyboard up. Found by
   `test/widget/m6_large_text_test.dart`, which walks every M6 screen, sheet and dialog.
4. **From research before the slices:** the confirmation words were all capitals, which a
   screen reader may spell out letter by letter (now lower case); and the error hook lacked
   `PlatformDispatcher.onError`, which catches what escapes the zone (added).

**Deviations from the plan, all deliberate:**

- Privacy is a sheet and a section of *Data sources & licences*, not a route of its own.
- A *Dictionary look-up* switch was added under *Your data* (`UI-UX.md` §4.9).
- Merging takes the backup's settings only when this phone is still on the defaults.

## 9. What M3 turned out to be

Features **F-020–F-025**, all met. Two screens (word detail, IPA highlight editor), six
controllers, one device-speech adapter behind a domain interface.

**Four things were found rather than built**, and each is worth knowing about:

1. **`WordEditorScreen` was never wired into the router.** Written in M2, it resolved to
   `PlaceholderScreen`, so *Add word* opened a placeholder and the app had no way to add a
   word through its own UI. Fixed. The new screens are tested through the real router so this
   class of gap fails a test.
2. **Two Android `<queries>` entries were missing.** Without one for `TTS_SERVICE`, package
   visibility hides the speech engine on Android 11+ and `speak()` is a **no-op with no
   error** — M3 would have looked finished and been silent on every real device. `url_launcher`
   needed the same for the Cambridge link and the mailto feedback address.
3. **A soft-deleted word rendered as a live one**, editable and speakable, because
   `watchById` deliberately still returns those rows for Undo.
4. **Autoplay lost a race with its own setting**, deciding on the first frame from the
   defaults and — since it runs once — never revisiting it.

**Deviations from the spec, both deliberate:**

- No UK/US *toggle*. `UI-UX.md` §4.3 draws two rows each with a play button, which is
  strictly better: both transcriptions stay visible for comparison. `ttsLocale` now only
  decides which accent autoplays.
- Selection in the editor is tap → tap-again → optional drag. `UI-UX.md` §4.4 specifies
  tap-and-drag, but §1 forbids hiding an action behind a gesture and a screen-reader user
  cannot pan, so the drag is the fast path over the same state rather than the only route.
  Slow replay is likewise a `CustomSemanticsAction` as well as a long-press.

**Two bugs found by actually running it**, neither catchable by the existing tests:

1. **The IPA symbol row (F-002) never appeared.** Its `FocusNode`s had no listeners, so
   `hasFocus` changing never rebuilt anything and the row that `bottomNavigationBar` selects
   was never shown. Manual IPA entry - a 🔴 hard rule (RULES §3) - was therefore impossible
   on a real phone, because no phone keyboard has ɒ. Shipped in M2, unnoticed for two
   milestones.
2. **Tapping a symbol stole focus from the field.** The code carried a comment saying "keep
   the field focused" that nothing implemented; the `InkWell` took focus, which (once bug 1
   was fixed) dismissed the row mid-word and sent the next keystroke nowhere. Fixed with
   `canRequestFocus: false` and covered by `test/widget/ipa_keyboard_row_test.dart`.

## 10. Issue tracking

`bd` (beads) is installed on this machine but **not initialised in this repository** — there
is no database and no issues. It was left that way on purpose: initialising a tracker is a
repo-structure decision, and this file plus the milestone list in `PLAN.md` has been enough
so far.

If you want it, `bd init` in the repo root, and §3 and §5 of this file are the natural first
issues to import.
