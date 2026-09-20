# Handoff

For the next developer. Written 20 September 2026, at v0.9.0.

Read this once, then work from `CLAUDE.md` (how this repo is built) and `docs/ROADMAP.md` (what is left). This page says where things stand, what is waiting on a person rather than on code, and the traps that cost time.

## What the app is

Scan any QR code or barcode and see exactly where it leads before anything opens, then create clean codes that are checked to scan. Android only; iOS is deferred. Package `com.oasisforge.qrscanner`, published by Oasis Forge.

Two rules shape most decisions, and every feature keeps them:

- **No ad in the working area.** Never on the camera, a scan result, a generator form or a created code. Ads appear only at the bottom of History, Settings and the Create list, and only after the user's first successful scan or created code.
- **Nothing opens before the user has seen where it leads.** A link is checked on the device and shown in full, with the site's name large, before anything hands it to a browser.

The behaviour is written down, rule by rule with stable IDs, in `docs/PRODUCT_RULES.md`. Code, tests and pull requests cite those IDs (`SCAN-4`, `ADS-1`, `PRO-7`). If a feature has no rule yet, write the rule first — the `/spec` skill does that.

## Where things stand

- **Everything planned for the closed test is built:** the scanner and permissions, result screens and payload parsers, on-device link safety, History with an undoable delete, the generator with save and share, ads with consent, Pro, and Settings.
- **v0.9.0 replaced the Material look with the app's own design** (see *The design*, below).
- 1,411 tests pass; the analyzer and the format check are clean.
- Thirteen pull requests are merged; each one was a release. `v0.9.0`'s release run was still finishing when this was written — check that its tag and draft release exist.
- **The app has never been uploaded to Google Play.** That, and the launcher icon, are what stand between here and a closed test.

## Getting it running

1. **Flutter 3.47.4 / Dart 3.13.3**, pinned in `CLAUDE.md`, `ci.yml` and `release.yml`. Another version may pass locally and fail CI.
2. `flutter pub get`, then `flutter test` (about 12 minutes) and `flutter analyze`.
3. An Android emulator or a phone: `flutter run`. The project was driven on an emulator named `Medium_Phone` (API 37, Play Store image, virtual-scene camera).
4. `adb` is not on the PATH on the machine this was built on: use `$LOCALAPPDATA/Android/Sdk/platform-tools/adb.exe`.

The repository sits under OneDrive on that machine. If a native build ever breaks there, move the checkout out of OneDrive rather than patching the build.

## How the code is arranged

Data flows one way: screen → state → storage or service. A write lands first, then state changes; on failure it rolls back and the screen says so.

- `lib/core/` — reusable across the portfolio's apps, so it imports nothing from the folders below: the database contract, the key-value store, the theme, and the services other apps will share (clipboard, share, ads, consent, billing, link opener).
- `lib/models/` — immutable records, pure Dart.
- `lib/db/` — ordered migration steps and the DAOs. **A merged migration step is never edited**; add another.
- `lib/services/` — device capabilities this app adds (camera, image decoder, permissions, system intents), each behind an interface with a no-op fake. `app_services.dart` holds one of each, and **only `main.dart` builds the real ones**.
- `lib/state/` — the `ChangeNotifier`s: settings, success counts, scanner, history, generator, Pro.
- `lib/screens/` — presentational only.
- `test/` mirrors `lib/`, plus `test/helpers/` and the accessibility and text-size harnesses.

128 Dart files under `lib/`, 71 test files.

## The design

v0.9.0 gave the app a look of its own: an instrument rather than another rounded-card app.

- A warm near-black chassis, with paper only where a code's content is shown.
- One signal colour, `#C9F24D`, that marks what the app is doing and never decorates.
- Space Grotesk names things; IBM Plex Mono says what the machine read — codes, sizes, times, states — in small capitals. Both are bundled under the SIL Open Font Licence, and their licences appear on the app's licence page.
- Hairlines and square corners; no cards, no shadows.

Everything is in `lib/core/theme/app_theme.dart`: the palette lives in an `AppColors` theme extension, and `AppTheme.mono()` is the monospaced voice. **Screens read colours from the theme; they do not spell out their own.**

Two decisions worth knowing before you change them:

- **The app keeps its own palette** in both light and dark (SET-1). Dynamic colour was removed, because the phone's wallpaper palette recoloured the signal and the paper.
- **The chassis is the default,** even on a phone set to light. Light and System default remain in Settings.

The design was drawn on a canvas before it was built; the screens there are the reference for anything new.

## Working rules

- **One branch per theme, one PR to `main`.** Never stack on an unmerged branch.
- **Every merged PR is a release.** Bump the version and add a `CHANGELOG.md` entry on the branch (the `/release` skill does it); CI fails without it. The merge tags `vX.Y.Z` and drafts a GitHub release.
- **Drive it by hand before the PR.** Anything that shows on screen gets run on a device, and the PR says what was driven and what was only tested. `/ship` walks through the gate.
- **Tests assert what the user sees** — text on screen, the contents of a file — never just that something exists. Every model or state change gets a test.
- **Flutter only.** No hand-written Kotlin or Java; CI enforces it. Manifest XML and Gradle config are fine.
- A green open PR waits for the repository owner to merge it.

## Traps that cost time here

`docs/STACK_NOTES.md` holds the full list. The ones that bite hardest:

- **Widget tests can't touch the real database, real rendering or real files.** Under the fake clock they never complete and the suite hangs. Use `test/helpers/memory_record_dao.dart`, and the renderer and scratch-file seams on `GeneratorState`.
- **ARB messages escape apostrophes by doubling them** (`can''t`). `flutter gen-l10n` reports "Unmatched single quotes" and buries it among harmless notices.
- **Plugins add permissions quietly.** Check the release APK with `aapt2 dump permissions`; `release.yml` fails the build on anything outside its allowed list, and the privacy policy has to match (PRIV-6).
- **The ads SDK pulls in an old WorkManager** whose database the release shrinker strips: a release build crashed at launch while debug builds and CI were green. `android/app/build.gradle.kts` pins `androidx.work` 2.11.2. **Launch every release build once before opening a PR that adds a native SDK.**
- **Consent gates everything about ads.** If Google's consent tool can't resolve (for example, no consent message published for the AdMob app), the app shows no ads at all — by rule, not by accident.
- **Emulators are AdMob test devices automatically.** Real phones are not: register them under AdMob → Settings → Test devices before installing a release build, or your own taps count as invalid traffic.
- `scripts/version.sh check` used to leave a full clone shallow; fixed, but if `main` ever looks diverged for no reason, run `git fetch --unshallow origin`.

## What is left

### Code

1. **Launcher icon and splash screen.** Both are still Flutter's defaults, and this is the last code blocker for a Play upload. Draw them from one committed source and generate the platform files (`docs/STACK_NOTES.md`).
2. **Crash reports** (PRIV-3): the Settings row is hidden behind `crashReportsAvailable` in `lib/screens/settings/privacy_section.dart` until a Firebase `google-services.json` exists. Spike S14 first: no Firebase traffic before the switch is on.
3. **Open questions** for the product owner: Create forms show "This field is required." on an untouched blank form; the link result could show its checks as a short inspection report (needs a rule first); SCAN-7's "up to 2×" auto-zoom cap cannot be enforced with Flutter alone.
4. **Phase 2b**, during the closed test: eight more languages, more scan entry points, the remaining result types, extended link safety, History organisation, the rest of the generator, then export and backup. `docs/ROADMAP.md` has the order and the reasons.

### Waiting on a person, not on code

- **The upload key.** Create it, back it up, and set `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS` and `ANDROID_KEY_PASSWORD` in GitHub (`docs/RELEASING.md`). Until then release builds are signed with a debug key, which Play refuses. The Gradle side is already wired.
- **Play Console:** create the app, upload the first bundle by hand (the API cannot create an app's first release), then create the `remove_ads` product at US$1.99 and add license testers so a real purchase can be driven.
- **Play app content:** data safety (declare AdMob and the consent tool, Play Billing, and ML Kit's usage statistics), ads declaration, content rating, target audience 13+, app access with no login.
- **Store listing** in English and Arabic: title, descriptions, a 512 px icon, a 1024×500 feature graphic, screenshots.
- **Testers:** a group of 20+ so at least 12 are opted in for 14 continuous days.
- **`main` branch protection** is still off.
- **Real phones** for spike S5 (joining a Wi-Fi network) and S6 (cold start to first scan). The emulator's scene is too soft to confirm a live read inside the target.

### Already done, so don't redo it

- The privacy policy is written and published at `https://oasis-forge.github.io/qr-scanner-generator/privacy-policy/`, and Settings opens it. It describes only what ships today; each deferred feature returns to the page in the PR that ships it.
- AdMob is set up: the app ID is in the manifest, the banner unit is `bannerAdUnitId` in `lib/main.dart` (release builds only; debug uses Google's test unit), the consent messages are published, and `app-ads.txt` is live at the Oasis Forge site root.
- Release signing, the app's launcher name in English and Arabic, and the permission allow-list are all in place.
