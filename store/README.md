# Publishing Schwa Notes on Google Play — the checklist

Everything in this folder was prepared in M8 so that the only steps left need the owner's Play
Console account. Work top to bottom; each step says where its material is.

| File | What it is |
|---|---|
| `listing.md` | App name, short and full description, release notes, listing details |
| `data-safety.md` | Data safety answers, with Google's definitions and the reasoning |
| `content-rating.md` | IARC questionnaire and target-audience answers |
| `testers.md` | The 12-tester closed test: rules, invite message, what to log |
| `release-checklist.md` | RULES §7 walked item by item for v1.0 — done, not applicable, or yours |
| `graphics/` | 512 px icon, 1024 × 500 feature graphic |
| `screenshots/` | Phone screenshots from the release build |
| `check_listing.ps1` | Checks the listing text against Play's character limits |

---

## 1. Before opening Play Console

- [x] **Create the upload key** — done 14 Sep (`C:\Users\hongp\keys\schwanotes-upload.jks`,
      alias `upload`); still to back up off this PC. How it was made, from `app\tool`:
      `powershell -ExecutionPolicy Bypass -File .\make_upload_key.ps1`
      (Windows refuses `.\make_upload_key.ps1` on its own — scripts are disabled by default, and
      `-ExecutionPolicy Bypass` lifts that for this one run only, changing no setting). It asks
      for a password and writes `app/android/key.properties` and the keystore, both git-ignored. **Back up the keystore and password somewhere other than this PC.** With Play
      App Signing, losing the upload key is recoverable through Google support, but slow.
- [ ] **Build the signed bundle:** `cd app; flutter build appbundle --release` →
      `app/build/app/outputs/bundle/release/app-release.aab`. Or push a tag `v1.0.0`: the
      *Release* workflow builds it from GitHub secrets (see `docs/PROGRESS.md` §2).
- [ ] **GitHub Pages is live**: repo *Settings → Pages → Source: GitHub Actions*, then open
      `https://hongphuc-pham.github.io/SchwaNotes/privacy.html` in a private window.
- [x] **A contact email** for the listing: `william.phucpham@gmail.com` (shown publicly).
- [ ] **Rename the repository** to `SchwaNotes` (GitHub → Settings → General). Every link in the
      app, the site and this folder already uses that name; GitHub redirects the old URLs.
      **Only after the rename has happened on GitHub**, locally:
      `git remote set-url origin https://github.com/hongphuc-pham/SchwaNotes.git`.
      In the other order every push and pull fails with `Repository not found`, because the new
      address does not exist yet. To undo that:
      `git remote set-url origin https://github.com/hongphuc-pham/VocabNote.git`.

## 2. Create the app

Play Console → **Create app**

- [ ] App name: `Schwa Notes: IPA word notebook` · Default language: English (United Kingdom) or
      English (United States) · **App** · **Free**
- [ ] Declarations: Developer Program Policies ✓, US export laws ✓

## 3. Set up your app (Dashboard → "Set up your app")

- [ ] **Privacy policy** — the Pages URL above.
- [ ] **App access** — all functionality available without special access.
- [ ] **Ads** — no ads.
- [ ] **Content rating** — `content-rating.md`.
- [ ] **Target audience** — `content-rating.md`.
- [ ] **Data safety** — `data-safety.md`.
- [ ] **Government / financial / health / news** — none (`data-safety.md`, last table).
- [ ] **Store listing** — `listing.md`, `graphics/`, `screenshots/`.
- [ ] **App category and contact details** — `listing.md`, listing details table.

## 4. Closed test (required for new personal accounts)

- [ ] Testing → **Closed testing** → create track → Countries: all you want to test in.
- [ ] Upload `app-release.aab`. Accept **Play App Signing** when asked (Google holds the app
      signing key; your keystore is the *upload* key).
- [ ] Release name `1.0.0 (1)`, release notes from `listing.md`.
- [ ] Testers: create an email list of **15+** people; copy the opt-in link.
- [ ] Send the invite (`testers.md`). **14 days start when 12 testers have opted in.**
- [ ] During the test: log feedback in `testers.md`; fix what matters; new builds need a higher
      version code (`app/pubspec.yaml`: `1.0.1+2`, and so on).

## 5. Production

- [ ] Dashboard → **Apply for production** (appears after 14 days with 12+ testers). Answer from
      the `testers.md` log.
- [ ] After approval: Production → **Create new release** → promote the tested build.
- [ ] **Staged rollout at 10%**, then watch **Android vitals** (crashes, ANRs) and reviews for
      **48 hours** before going to 100% (RULES §7 release checklist). If something is wrong:
      **Halt rollout** — users who have it keep it, nobody new gets it — fix, bump the version,
      roll out again.

## 6. After it is live

- [ ] Replace "Coming soon to Google Play" on `site/index.html` with the store link.
- [x] Ko-fi page (`https://ko-fi.com/williamphucpham`) wired into Settings and the site (14 Sep).
- [ ] Record the release in `docs/PROGRESS.md` §1.
