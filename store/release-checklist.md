# RULES §7 release checklist — v1.0.0 (build 1), Android

Walked item by item at M8 (14 September 2026). Each is **done**, **not applicable** with the
reason, or **left to the owner** with where the material is. Update this file for every
release; the next one starts from a clean copy of the table.

| # | RULES §7 item | Status | Evidence / where |
|---|---|---|---|
| 1 | Migration tested from the *previously published* version's schema, on a real device with real data — not just in CI | **Not applicable to v1.0** | Nothing has been published, so there is no previous schema a user could be on. Schema v1 → v2 is covered by the blocking migration tests (`app/test/migration`, 9 tests, green in CI) and was adopted in place on the emulator at M5–M7. **From v1.1 this item applies in full:** install v1.0 from Play on a phone, add real words, update, check nothing is lost. |
| 2 | Backup export/import round trip verified on both platforms | **Android: done at M6; to re-run on the renamed M8 build (pending).** iOS: **not applicable** — v1.0 ships on Google Play only (owner, 14 Sep). | `app/integration_test/backup_round_trip_test.dart` (export → wipe → import, every table deep-equal) on the emulator. |
| 3 | Licence and attribution screens re-verified against `DATA-SOURCES.md` | **Done** | `licences_screen_test.dart` holds every source to being named, licensed and linked, and the privacy sentence to F-076 word for word. The renamed strings ("neither endorses Schwa Notes") were changed in the ARB, FEATURES and the test together. |
| 4 | Store privacy declarations match `DATA-SOURCES.md` §7 word for word | **Drafted; the owner submits** | `store/data-safety.md` (every answer traced to §7 and to Google's definitions); `site/privacy.html` carries §7's points verbatim. §7 was corrected at M8 so the email point applies only to a build with a feedback address, which v1.0 is not. |
| 5 | Version and build number bumped; release notes written in plain language | **Done** | First release: `version: 1.0.0+1` in `app/pubspec.yaml` is the right starting point (no bump from nothing). Release notes in `store/listing.md` (176 of 500 characters). Every later upload needs a higher build number: `1.0.1+2`, … |
| 6 | Rollback plan: staged rollout at 10% for 48 hours before going wide | **Planned; the owner executes** | `store/README.md` step 5: production release at 10%, watch Android vitals and reviews for 48 hours, **Halt rollout** if needed, fix, bump, roll out again. A closed test of 12+ testers for 14+ days comes first anyway (new personal account). |

## Also checked for this release (not in RULES §7, found or decided at M8)

| Check | Result |
|---|---|
| The release APK can reach the internet | **Was broken in every release build until M8**: no `INTERNET` permission (`aapt dump permissions`). Fixed and guarded by `test/architecture/android_manifest_test.dart`. |
| Signing | Upload key via `key.properties` (owner-generated, git-ignored) or the Release workflow's secrets; verified with a throwaway key that the bundle carries it. Without a key the build falls back to the debug key, which Play refuses. |
| Target API level | 36 (Flutter 3.47.2's default) — meets Play's requirement for new apps from 31 Aug 2026. |
| App ID | `io.github.hongphuc_pham.schwanotes` — permanent after the first upload. |
| Name | "Schwa Notes"; "VocabNote" was already used by a live vocabulary app. Web search only, not a legal clearance. |
