# Data safety form — draft answers, with the reasoning

Play Console → **Policy and programs → App content → Data safety**.

**This is the owner's legal declaration.** These answers are drafted from what the code does
(`docs/DATA-SOURCES.md` §7, checked at M7 against every dependency) and from Google's own
definitions, quoted below. Read them before submitting; if anything in the app changes, the form
changes in the same release (RULES §7).

Google's definitions (https://support.google.com/googleplay/android-developer/answer/10787469,
fetched 14 Sep 2026):

- **Collection** — "Transmitting data from your app off a user's device."
- **Sharing** — "Transferring user data collected from your app to a third party."
- Exemptions include data processed **only on the device**, **ephemeral processing**, and, for
  *sharing* only, transfers **the user initiates and reasonably expects**.
- Apps that collect nothing still complete the form and link a privacy policy.

---

## The one judgement call: Look up

When the user taps **Look up**, the app sends the typed word to FreeDictionaryAPI.com over HTTPS.
That is data leaving the device, so it meets the definition of *collection* even though the
developer never receives it. The user-initiated exemption covers *sharing*, not collection, and
the developer cannot promise how a third-party server processes or logs a request, so
"ephemeral" is not ours to claim.

**Recommended: declare it** — conservatively, and it costs nothing in trust because the answers
are all mild: optional, not shared, encrypted, for app functionality only.

The alternative ("no data collected") is defensible — a dictionary word is arguably not *user
data* at all — but if a reviewer disagrees, the listing is out of line with the app. Declaring it
cannot be wrong.

## Answers

**Does your app collect or share any of the required user data types?** → **Yes**

**Is all of the user data collected by your app encrypted in transit?** → **Yes** (HTTPS only;
`FreeDictionaryClient` base URL is `https://`)

**Do you provide a way for users to request that their data is deleted?** → **No**. Nothing is
held by the developer; everything on the phone is removed by *Settings → Delete all data* or by
uninstalling. If the form requires an explanation, use that sentence.

### Data types

| Category → type | Collected | Shared | Processed ephemerally | Required or optional | Purpose |
|---|---|---|---|---|---|
| App activity → **In-app search history** (the looked-up word) | Yes | **No** | No (third party's server; not ours to promise) | **Optional** — users can switch Look up off, and never need it | **App functionality** |

**Everything else: not collected.** In particular:

- **Location, personal info, financial info, health, messages, photos/videos, audio, files and
  docs, calendar, contacts** — not collected.
- **App info and performance (crash logs, diagnostics)** — not collected. The error log stays on
  the phone (F-079) and is never transmitted.
- **Device or other IDs** — not collected. No advertising ID; no analytics or ads SDK (F-097).
- **Backups** — created on the device and handed to the share menu by the user; the app uploads
  nothing. On-device processing, exempt.
- **Feedback** — this release has no email feedback (GitHub Issues link only, opened in the
  browser by the user). Nothing is transmitted by the app.
- **IP address** — seen by FreeDictionaryAPI.com as by any web server during a look-up; it is not
  a data type the app collects or reads. The privacy policy says so plainly.

## Also in App content (same page)

| Declaration | Answer |
|---|---|
| Privacy policy | `https://hongphuc-pham.github.io/SchwaNotes/privacy.html` |
| Ads | **No, my app does not contain ads** |
| App access | **All functionality is available without special access** (no login) |
| Content rating | see `content-rating.md` |
| Target audience and content | see `content-rating.md` |
| News app | No |
| Government app | No |
| Financial features | None |
| Health | None |
| COVID-19 contact tracing / status | No |
| Data safety | this file |
