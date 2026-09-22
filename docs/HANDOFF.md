# Handoff

For the next developer. Written 20 September 2026 at v0.9.0; brought up to date 21 September 2026 at v0.13.0.

Read this once, then work from `CLAUDE.md` (how this repo is built) and `docs/ROADMAP.md` (what is left). This page says where things stand, what is waiting on a person rather than on code, and the traps that cost time.

## What the app is

Scan any QR code or barcode and see exactly where it leads before anything opens, then create clean codes that are checked to scan. Android only; iOS is deferred. Package `com.oasisforge.qrscanner`, published by Oasis Forge.

Two rules shape most decisions, and every feature keeps them:

- **No ad in the working area.** Never on the camera, a scan result, a generator form or a created code. Banner ads appear only at the bottom of History, Settings and the Create list, and since v0.13.0 one full-screen ad may follow a code that has been saved or shared — after its confirmation, never instead of it, once per run of the app (ADS-9). All of it only after the user's first successful scan or created code.
- **Nothing opens before the user has seen where it leads.** A link is checked on the device and shown in full, with the site's name large, before anything hands it to a browser.

The behaviour is written down, rule by rule with stable IDs, in `docs/PRODUCT_RULES.md`. Code, tests and pull requests cite those IDs (`SCAN-4`, `ADS-1`, `PRO-7`). If a feature has no rule yet, write the rule first — the `/spec` skill does that.

## Where things stand

- **Everything planned for the closed test is built:** the scanner and permissions, result screens and payload parsers, on-device link safety, History with an undoable delete, the generator with save and share, ads with consent, Pro, and Settings.
- **v0.9.0 replaced the Material look with the app's own design** (see *The design*, below).
- 3,319 tests pass; the analyzer and the format check are clean.
- Twenty-six pull requests are merged. Each was a release until 21 September 2026, when that stopped being automatic: **a release is cut when the maintainer asks for one**, and everything merged in between waits under **Unreleased** in `CHANGELOG.md`. **Nothing is tagged**, either. Every tag was deleted on 2026-09-21, and the record of a version is now its `CHANGELOG.md` entry and the commit that raised it.
- **v0.10.0 gave the app its launcher icon and cold-start window** (see *The design*, below), so the last code blocker is cleared.
- **v0.11.0 gave the app twenty languages,** each listed under its own name. Greek is translated but held back on a font bug (*Known bugs* in `docs/ROADMAP.md`).
- **v0.12.2 drew the whole Play listing from the app itself** — text in twenty languages, six captioned screenshots and a feature graphic per language — and v0.12.4 added release notes in twenty languages to every release (`docs/RELEASING.md`).
- **The app is on Google Play, on the internal test track** (v0.12.3, uploaded 21 September 2026). The Play Console entries, the listing in twenty languages, the app-content declarations and the testers are all done, and a real test purchase of Pro was driven end to end on the emulator. What stands between here and the closed test now is the calendar, two spikes on real phones, and a Firebase project for crash reports.

## Getting it running

1. **Flutter 3.47.4 / Dart 3.13.3**, pinned in `CLAUDE.md`, `ci.yml` and `release.yml`. Another version may pass locally and fail CI.
2. `flutter pub get`, then `flutter test` (about 12 minutes) and `flutter analyze`.
3. An Android emulator or a phone: `flutter run`. The project was driven on an emulator named `Medium_Phone` (API 37, Play Store image, virtual-scene camera).
4. `adb` is not on the PATH on the machine this was built on: use `$LOCALAPPDATA/Android/Sdk/platform-tools/adb.exe`.

On that machine the checkout is on `D:`, outside the OneDrive root at `C:\Users\hassa\OneDrive` (checked 2026-09-20), so a broken native build is not OneDrive's doing. What does break there is the release build: Kotlin 2.4.0 cannot compute a path from the pub cache on `C:` to the project on `D:`, and all nine Kotlin plugin modules fail at once. Set `$env:GRADLE_OPTS = "-Dorg.gradle.project.kotlin.incremental=false"` before building; `docs/STACK_NOTES.md` has the detail.

## How the code is arranged

Data flows one way: screen → state → storage or service. A write lands first, then state changes; on failure it rolls back and the screen says so.

- `lib/core/` — reusable across the portfolio's apps, so it imports nothing from the folders below: the database contract, the key-value store, the theme, and the services other apps will share (clipboard, share, ads, consent, billing, link opener).
- `lib/models/` — immutable records, pure Dart.
- `lib/db/` — ordered migration steps and the DAOs. **A merged migration step is never edited**; add another.
- `lib/services/` — device capabilities this app adds (camera, image decoder, permissions, system intents), each behind an interface with a no-op fake. `app_services.dart` holds one of each, and **only `main.dart` builds the real ones**.
- `lib/state/` — the `ChangeNotifier`s: settings, success counts, scanner, history, generator, Pro.
- `lib/screens/` — presentational only.
- `test/` mirrors `lib/`, plus `test/helpers/` and the accessibility and text-size harnesses.

147 Dart files under `lib/`, the generated localisations included, and 72 test files. `tool/` sits outside both: the icon painter and the renderer that writes `assets/icon/`, the two tools that edit the ARB files across all twenty languages at once, and the builders for the store captions and a release's notes. The format check covers it. `integration_test/` is not run by `flutter test` either: it renders the Play listing's graphics on a device from the real screens.

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

v0.10.0 added the app's mark (ICON-1–ICON-7): the concentric square of a QR code's finder pattern, signal on chassis, painted in `tool/app_icon_painter.dart` so the launcher icon, its adaptive and themed layers and the cold-start window all come from one source. One number matters more than it looks: the mark is drawn at **44 dp of the 108 dp canvas**, not the 66 dp safe zone. 66 dp is the widest a mark may be before a mask clips it, and a square that wide has its corners at 46.7 dp — outside the 36 dp a launcher actually shows — so round masks cut the ring and the chassis is squeezed out until the icon reads as a plain signal-coloured tile. Tests hold both ends of that: the corners stay inside the safe circle, and the mark stays between 45% and 70% of the visible circle.

## Working rules

- **One branch per theme, one PR to `main`.** Never stack on an unmerged branch.
- **A release is the maintainer's call, and most PRs are not one.** The change goes under `## [Unreleased]` in `CHANGELOG.md` and the version stands still; CI passes a branch that does not move it, and checks one that does. **Nothing is tagged and nothing is published from anywhere** (2026-09-21): the bundle Play receives is built on this machine and uploaded by hand, and a release carries its notes in all twenty languages.
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

1. **Crash reports** (PRIV-3): the Settings row is hidden behind `crashReportsAvailable` in `lib/screens/settings/privacy_section.dart` until a Firebase `google-services.json` exists. Spike S14 first: no Firebase traffic before the switch is on.
2. **Open questions** for the product owner: Create forms show "This field is required." on an untouched blank form; the link result could show its checks as a short inspection report (needs a rule first); SCAN-7's "up to 2×" auto-zoom cap cannot be enforced with Flutter alone.
3. **Phase 2b**, during the closed test: more scan entry points, the remaining result types, extended link safety, History organisation, the rest of the generator, then export and backup. `docs/ROADMAP.md` has the order and the reasons.

### Waiting on a person, not on code

- **What the interstitial's ad unit left behind.** The unit was created on 22 September 2026 and `interstitialAdUnitId` in `lib/main.dart` carries it, so ADS-9 is live in a release build. Two things follow from that: one sentence of the store listing is now untrue in twenty languages (the English source is corrected; the nineteen translations and the CSV need rebuilding), and the test account still owns Pro, so cancel that order in Play Console — a Pro owner never sees an ad to check the interstitial with (ADS-7).
- **Play Console, from here on:** every later upload is by hand as well, and each one carries its release notes in twenty languages (`store/play/release-notes/`).
- **Re-uploading the listing** once the interstitial sentence is retranslated. **Tablet screenshots (7-inch and 10-inch) are still not rendered**, and the app has no large-screen layout to render — no navigation rail, no content width cap — so Play will flag large screens until both are done.
- **Testers:** assigned to the internal track. The count still has to hold — at least 12 opted in for 14 continuous days.
- **Real phones** for spike S5 (joining a Wi-Fi network) and S6 (cold start to first scan). The emulator's scene is too soft to confirm a live read inside the target.

### Already done, so don't redo it

- The privacy policy is written and published at `https://oasis-forge.github.io/qr-scanner-generator/privacy-policy/`, and Settings opens it. It describes only what ships today; each deferred feature returns to the page in the PR that ships it.
- AdMob is set up: the app ID is in the manifest, the banner unit is `bannerAdUnitId` in `lib/main.dart` (release builds only; debug uses Google's test unit), the consent messages are published, and `app-ads.txt` is live at the Oasis Forge site root.
- Release signing, the app's launcher name in English and Arabic, and the permission allow-list are all in place.
- **`main` is protected** (21 September 2026): a pull request is required, both CI checks must pass, force pushes and deletion are blocked, and there is no bypass list — the rules apply to the owner too. To fix `main` in a hurry, turn the ruleset off in Settings → Rules, push, and turn it back on.
- **Pro works against a real test order** (21 September 2026, on the emulator): `remove_ads` at US$1.99 bought with a license-test card, banners gone from all three screens at once, Pro surviving a force-stop, ownership re-found from Play after the app data was wiped, and Restore purchase confirming "Purchase restored." The test account owns Pro from then on, which by ADS-7 means no ad of any kind appears on that device until the order is cancelled.
- **The upload key exists.** `android/key.properties` points at it and a release build is signed with it — checked on the 0.12.3 bundle, `CN=hassan kalash, OU=oasis forge`, not the debug key Play refuses. It never leaves this machine, so the GitHub keystore secrets are not needed.
- **The store listing is written and rendered** in all twenty languages, and so are a release's notes: text, six captioned screenshots and a feature graphic per language, and the 512 px icon. It all sits in `store/play/`, which is gitignored because the repository is public; `store/play/README.txt` says what is where and how to rebuild it.
