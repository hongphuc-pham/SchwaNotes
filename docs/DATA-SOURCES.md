# Data sources, licences and compliance

Rule: **nothing ships in this app unless we can name its licence and satisfy it.**
Everything below was checked in September 2026; re-verify before each public release
(`docs/RULES.md` §7 release checklist).

---

## 1. Online dictionary look-up — **FreeDictionaryAPI.com**

| | |
|---|---|
| Endpoint | `GET https://freedictionaryapi.com/api/v1/entries/en/{word}` |
| Auth | none, no API key |
| Rate limit | 1,000 requests / hour / IP, resets hourly UTC; `429` when exceeded |
| Underlying data | **Wiktionary**, extracted with `wiktextract` |
| Licence | **CC BY-SA 4.0** |
| Provides | definitions, part of speech, pronunciations (IPA), examples, source page links |

### What CC BY-SA 4.0 obliges us to do
1. **Attribute.** A visible credit wherever the content is shown, plus a fuller credit in
   *Settings → Data sources & licences*, and on the store listing / landing page.
2. **Link back.** The API returns the source Wiktionary page URL — store it on the word
   (`words.source_attribution`) and expose it as a *View source* link on the word detail.
3. **Name the licence** and link to `https://creativecommons.org/licenses/by-sa/4.0/`.
4. **ShareAlike.** Applies to the *dictionary text*, not to our Dart code. We do not relicense
   or claim ownership of the text; the user's own notes and highlights remain the user's.
5. **No implied endorsement.** Do not suggest Wiktionary or FreeDictionaryAPI endorses the app.

### Implementation requirements
- Store `source = 'api'` and `source_attribution = 'Wiktionary via FreeDictionaryAPI.com — CC BY-SA 4.0'`
  plus the source URL on every field accepted from the API.
- Show a small "Wiktionary · CC BY-SA 4.0" line under any API-derived definition.
- Respect the rate limit: debounce the search box, one request per explicit *Look up* tap,
  in-memory + on-disk cache per word (24h), exponential back-off on `429`.
- Send a descriptive `User-Agent` (`SchwaNotes/<version> (github.com/<repo>)`) — courteous and
  expected by community APIs.
- Content the user typed themselves is `source = 'manual'` and carries **no** attribution,
  because it is theirs.

### Response shape, verified against the live API *(checked at M2)*

```
{ word, entries: [ { language:{code,name}, partOfSpeech,
                     pronunciations:[{type,text,tags[]}],
                     senses:[{definition,examples[],tags[]}] } ],
  source: { url, license:{name,url} } }
```

Three things worth knowing, all of which change how the client behaves:

1. **A miss is HTTP 200 with `entries: []`**, not a 404. The offline fallback is
   therefore triggered by an empty list, not by a status code.
2. **The accent lives in `pronunciations[].tags`** — `Received Pronunciation`
   for UK, `General American` for US. There is no accent field. An *untagged*
   transcription is offered for the US field only, never presented as UK.
3. **`text` arrives with slashes** (`/kɒf/`). They are stripped before storage,
   because `words.ipa_uk` holds bare symbols and the UI adds the slashes back.

Real captured responses are committed under
`app/test/fixtures/dictionary/` and the parser is tested against them, so a
change in the API's shape fails a test rather than a user's form.

### Rejected alternative — `dictionaryapi.dev`
Popular and convenient, but its data provenance traces back to scraped **Google Dictionary**
content (Oxford-licensed) and the site publishes no licence or terms. That is exactly the risk
we were asked to avoid, so it is **not** used. Recorded here so nobody "helpfully" swaps it in.

---

## 2. Offline IPA fallback — **CMUdict**

| | |
|---|---|
| Source | `github.com/cmusphinx/cmudict` (Carnegie Mellon University, 1993–2014) |
| Licence | Unrestricted for research **and commercial** use; asks that the origin be acknowledged |
| Coverage | ~134k North-American English entries, ARPAbet phonemes |

- A build script (`app/tool/build_ipa_fallback.dart`) converts ARPAbet → IPA and emits
  `assets/data/ipa_fallback.json.gz`. The script, the mapping table
  (`app/tool/arpabet_to_ipa.dart`) and the source revision are committed so the asset is
  reproducible — anyone re-running it gets the same file.
- **Pinned revision** `0f8072f814306c5ee4fbf992ed853601b12c01f9` (2024-12-17). A commit SHA,
  never `master`: a moving branch would mean two people generating different assets.
- Generated at M2: **126,037 entries, 854 KB gzipped** (3.1 MB raw JSON). Only the primary
  pronunciation of each word is kept; CMUdict's `(2)`/`(3)` variants are dropped, because a
  fallback offered to someone with no network wants one confident answer, not three.
- Loaded **lazily and off the main thread**, never at startup: the parsed map is ~15 MB and
  eagerly loading it would blow the 2s cold-start budget (F-092).
- Words filled from it get `source = 'offline'` and `source_attribution = 'CMU Pronouncing Dictionary (CMU)'`.
- Acknowledge CMU in *Settings → Data sources & licences*.
- Caveat surfaced in the UI: this is **US** pronunciation only, and it is a broad transcription
  — the UK field stays empty and the user can type it.

---

## 3. Cambridge Dictionary — **link only**

Cambridge publishes no free public API, and scraping their pages breaches their terms, breaks
whenever their markup changes, and risks store removal. So:

- **Allowed:** `url_launcher` opening `https://dictionary.cambridge.org/dictionary/english/<word>`
  in the user's external browser, labelled "Open in Cambridge Dictionary".
- **Forbidden, in code review terms — reject any PR that:** fetches a `dictionary.cambridge.org`
  URL programmatically; parses their HTML; caches or stores their definitions, examples or
  audio; embeds their site in an in-app WebView styled to look like part of Schwa Notes; or uses
  their name, logo or wordmark as branding. The word "Cambridge" may appear only as the plain
  text of the link, and nothing about the app may suggest affiliation.
- *Applied at M6:* *Data sources & licences* does not mention Cambridge at all — not even a
  "not affiliated" line, which would put the name somewhere other than its link. Nothing of
  theirs is shown in the app, so there is nothing to attribute.

---

## 4. Audio — device text-to-speech (`flutter_tts`)

- Uses the OS speech engine (Google TTS / Samsung TTS on Android, AVSpeechSynthesizer on iOS).
  No content is bundled, so **no licence obligation**, no storage cost, and it works offline.
- Voice selection is limited to what the user's device has installed. If no `en-GB` voice
  exists, fall back to `en-US` and say so once, with a link to the OS voice settings. The
  fallback order is `en-GB → en-US → device default`, resolved once and cached
  (`SpeechService.resolveVoice`); having no English voice at all is not an error, because a
  rough synthesised approximation is more use than silence.
- 🔴 **`AndroidManifest.xml` must declare `android.intent.action.TTS_SERVICE` under
  `<queries>`.** From Android 11 (API 30) package visibility hides the speech engine otherwise,
  and the symptom is silence, not an error. The same applies to `url_launcher`: `VIEW`/`https`
  for the Cambridge link (F-025) and `SENDTO`/`mailto` for feedback (F-072). `canLaunchUrl`
  can still return false where `launchUrl` would work, so the Cambridge button launches and
  handles failure rather than gating itself on a probe.

**Known limitation, stated honestly in the app.** TTS is a synthesised reference, not a native
speaker. It is a good model for stress, rhythm and vowel targets, and it is reliable for every
word including names and rare terms — but it can miss the natural connected speech of a human
recording. The *How to use* guide says this in one plain sentence rather than overselling it.

Phase 2 (`F-028`) may add real recordings from **Wikimedia Commons** (CC BY-SA / CC0 depending
on the file — each file's licence must be read and stored per-file, not assumed). Both sit
behind `SpeechService`, so no screen changes.

---

## 5. Fonts

| Font | Use | Licence |
|---|---|---|
| **Inter** | all UI text | SIL Open Font License 1.1 |
| **Charis SIL** | IPA rendering | SIL Open Font License 1.1 |

Both are bundled as assets rather than fetched from Google Fonts, so the app works offline and
the licence position is unambiguous. OFL requires the licence text to be distributed with the
fonts — ship `assets/fonts/OFL.txt` for each and surface it in the licences screen.

Charis SIL is used specifically because generic system fonts render IPA symbols and combining
diacritics inconsistently across Android OEMs — and IPA fidelity is the point of this app.

---

## 6. Dart/Flutter packages

Permissive licences only: **MIT, BSD-2/3, Apache-2.0, OFL**. No GPL/AGPL/LGPL, no
source-available or "free for non-commercial" licences.

- `app/tool/check_licences.dart` reads `pubspec.lock`, inspects every resolved package's
  licence file and fails the build on anything non-permissive. CI runs it on every push;
  run it locally with `dart run tool/check_licences.dart`.
- The in-app licences screen uses Flutter's `showLicensePage()` (which aggregates package
  licences automatically) **plus** our own section for the data sources above, which
  `showLicensePage` does not know about.

### Known exemption — `dbus` (MPL-2.0) *(recorded at M0)*

A licence audit of the full tree turns up exactly one non-permissive package: `dbus`, which
is **MPL-2.0**. It arrives transitively through `file_picker_linux` and
`flutter_local_notifications_linux` — the Linux desktop implementations of two federated
plugins.

Schwa Notes ships **Android and iOS only**, so Flutter never compiles those implementation
packages and no MPL code reaches a released artefact. The exemption is recorded by name in
`check_licences.dart`, never by wildcard, so a genuinely new copyleft dependency cannot hide
behind it. Re-verify at each release: if a desktop target is ever added, this stops being
exempt and the plugin must be replaced.

---

## 7. Privacy statement (what the app actually does)

- No account, no sign-in, no server owned by us.
- No analytics, no ads, no tracking SDKs, no advertising ID.
- The only outbound requests: (a) a word you explicitly look up, sent to
  `freedictionaryapi.com`; (b) URLs you explicitly tap open in your browser.
- Feedback, **only in a build that sets a feedback address** (`--dart-define=FEEDBACK_EMAIL`), is
  composed in the user's own mail app; the pre-filled diagnostics (app version, OS version,
  device model) are visible to the user before they press send, and nothing else is attached —
  unless the user ticks *Include the error log*, in which case the log's newest entries appear in
  the same preview before anything opens. **v1.0 sets no address** (owner, 14 Sep 2026): feedback
  is a GitHub Issues link the user opens in their browser, which the point above already covers,
  and the in-app privacy note shows this point only when an address is set.

*Recorded at M6, for the M8 store declarations:* Google Play's Data safety form treats a
transfer the user initiates, and would reasonably expect, as exempt from "data sharing"
(https://support.google.com/googleplay/android-developer/answer/10787469). The feedback email
is exactly that — composed and sent by the user from their own mail app after a preview — but
the help page does not name this case in so many words. This is the reading we rely on, not a
certainty; re-check it when the declarations are written.
- Everything else — words, IPA, highlights, notes, practice history — stays in the app's
  private database on the device and leaves only when the user exports a backup.

*Checked at M7 against the dependency list (F-097):* the app's runtime dependencies hold no
analytics, ads or attribution SDK. The only HTTP client is `dio`, used by the dictionary
client for a look-up the user asks for; `device_info_plus` and `package_info_plus` read the
device model and app version locally, for the feedback preview the user sees before sending;
`flutter_tts` speaks through the device's own engine. Re-run the eye over
`app/pubspec.yaml` whenever a dependency is added — `check_licences.dart` guards licences,
not behaviour.

This is the text that must match both the store privacy declarations (Play Data Safety, Apple
App Privacy) and `F-076` in the app. If one changes, all three change in the same PR.

*In the app, since M6* (`presentation/settings/privacy_note.dart`, strings `privacyNote` and
`privacyPoint1`–`5`): F-076's sentence word for word, then each point above in the second
person, in the same order. A widget test holds the sentence to F-076 exactly.

---

## 8. Sources checked

- Free Dictionary API (Wiktionary/wiktextract, CC BY-SA 4.0, 1,000 req/h): https://freedictionaryapi.com/
- dictionaryapi.dev (no published licence; Google Dictionary provenance): https://dictionaryapi.dev/
- CMUdict licence: https://github.com/cmusphinx/cmudict
- CC BY-SA 4.0: https://creativecommons.org/licenses/by-sa/4.0/
- SIL Open Font License 1.1: https://openfontlicense.org/
