# Google Play store listing — Schwa Notes

Paste each block into Play Console → **Grow users → Store presence → Main store listing**.
Limits are Play's (https://support.google.com/googleplay/android-developer/answer/9859152):
app name 30, short description 80, full description 4000 characters. Counts are checked by
`store/check_listing.ps1`; rerun it after any edit.

Every claim below is something the app does today. If a feature changes, change this file in
the same PR (RULES §38).

---

## App name (≤ 30)

```
Schwa Notes: IPA word notebook
```

## Short description (≤ 80)

```
Note English words, write the IPA, and mark the sounds you keep getting wrong.
```

## Full description (≤ 4000)

```
Schwa Notes is a small, free notebook for English pronunciation.

You save a word, write how it sounds in IPA, colour the exact symbol you keep getting wrong, leave yourself a note, and practise a few cards a day. Everything stays on your phone. There is no account, no ads and no subscription.

WHY "SCHWA"
ə, the schwa, is the most common vowel sound in English, and it is almost never spelled the way it sounds: the a in "about", the er in "teacher", the o in "lemon". It is the classic sound a learner hears wrong. This app is for exactly that.

WHAT YOU CAN DO
• Add a word in two taps, or tap Look up to fill in how it sounds, what it means and an example from a free, open dictionary. Nothing is filled in until you choose it, and every field stays editable.
• Write the IPA yourself. A row of every sound English needs sits above the keyboard, so you never hunt for ɒ or ʃ.
• Highlight the sounds you struggle with. Select any run of IPA symbols, pick a colour and add a label like "rounder lips here". Selection respects how symbols combine, so it never splits t͡ʃ or loses a length mark.
• Hear it in UK or US English with your phone's own voice. Hold play for a slower replay.
• Keep as many notes on a word as you like: where you heard it, what your mouth should do, what to listen for.
• Group words into lists, such as IELTS speaking or work vocabulary.
• Practise with flashcards. Daily review brings back the words that are due, and the ones you find hard come back sooner. A quick test lets you try a handful at any time without changing your schedule.
• Get a gentle daily reminder, if you want one.
• Back everything up to one file and bring it back on another phone.

MADE TO BE COMFORTABLE
• Works offline. Only Look up uses the internet, and it sends nothing but the word. You can switch it off.
• Light and dark themes.
• Built for screen readers: IPA is read aloud as sound names ("short a as in cat"), not as strange symbols.
• Works at large text sizes and with reduced motion.

YOUR WORDS ARE YOURS
No account, no sign-in, no analytics, no ads, no tracking. Your words, highlights, notes and practice history stay in the app's private storage and leave your phone only in a backup you choose to export. The privacy policy says exactly what happens and when.

FREE AND OPEN SOURCE
Schwa Notes is free, and there is nothing to unlock. The source code is public. If it helps you, there is an optional way to buy the developer a coffee in Settings. It changes nothing in the app.

Definitions and examples come from Wiktionary (CC BY-SA 4.0) through FreeDictionaryAPI.com. Offline pronunciations come from the CMU Pronouncing Dictionary. Neither endorses this app.
```

## Release notes — version 1.0.0 (≤ 500)

```
First release. Note English words with their IPA, highlight the sounds you keep getting wrong, add notes, and practise with daily flashcards. Works offline, no account, no ads.
```

---

## Listing details

| Field | Value |
|---|---|
| App category | Education |
| Tags (pick up to 5 in Console) | Language learning · Education · Dictionary · Flashcards · Reference |
| Contact email | `william.phucpham@gmail.com` — required, and shown publicly on the listing (owner's choice, 14 Sep) |
| Website | `https://hongphuc-pham.github.io/SchwaNotes/` (after the repo rename) |
| Privacy policy | `https://hongphuc-pham.github.io/SchwaNotes/privacy.html` |
| App icon | `store/graphics/icon-512.png` (512 × 512, 32-bit PNG) |
| Feature graphic | `store/graphics/feature-graphic.png` (1024 × 500, 24-bit PNG, no alpha) |
| Phone screenshots | `store/screenshots/phone-1…4-*.png`: My words, a word with its highlight, the highlight editor, a flashcard. Taken from the release build on the emulator, then padded at the sides to exactly 1428 × 2856 and saved as 24-bit PNG, because Play refuses alpha and a long side more than twice the short one (the raw 1280 × 2856 captures are 2.23:1). Play recommends four or more, at 1080 px or wider. |
| Price | **Free.** Note: a free app can never later be changed to paid. |
