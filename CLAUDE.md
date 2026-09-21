# QR Scanner + Generator

Scan any QR code or barcode and see exactly where it leads before anything opens, then create clean, styled codes that are checked to scan, without ads covering the camera or the result. Built with Flutter 3.47.4 / Dart 3.13.3. Targets Android (iOS is deferred).

## Commands (use the quiet forms)
- `flutter pub get > $null`
- `flutter analyze`
- `flutter test test/<file>_test.dart` while iterating; `flutter test -r failures-only` once at the end
- `dart format lib test tool`: rarely needed if the format hook runs on every edit
- `flutter build apk --release` builds the release artifact; `flutter run` runs the app
- `/verify` runs format check + analyze + tests and reports failures only
- `bash scripts/version.sh name|build|check|notes` reads the version, runs CI's bump check, prints the changelog entry

## Architecture
Decided 2026-09-17: `provider` + `ChangeNotifier`, `sqflite` with ordered migration steps, one app at the repo root.

Data flows one way: screen → state → storage/service. A write lands first, then state changes; on failure it rolls back and the screen shows an error.

- `lib/core/`: reusable across the portfolio's apps, so it imports nothing from the folders below. `db/` (migration contract and runner, database open), `store/` (key-value store for settings, consent, Pro, success counts), `theme/`, `services/` (clipboard, share, crash reports, ads, consent, billing, link opener).
- `lib/models/`: immutable records with `toMap`/`fromMap` and `copyWith` (sentinel for clearable nullables); pure Dart, no Flutter imports.
- `lib/db/`: `migrations/step_NNN_*.dart` in an ordered list, plus the DAOs. A merged step is never edited.
- `lib/services/`: device capabilities this app adds (camera scanner, image decoder, permissions, Wi-Fi, system intents), each an interface with a `Noop` fake; `app_services.dart` holds one of each, and only `main.dart` builds real ones.
- `lib/state/`: `ChangeNotifier`s (settings, success counts, later history and the generator).
- `lib/l10n/`: one `app_<code>.arb` per language (20, LANG-7), `languages.dart` naming each in its own language, and the generated `app_localizations.dart`, all committed; CI regenerates and fails on a diff. Never hand-edit the ARB files across languages: `tool/add_messages.dart` changes a message in every file at once, and `tool/new_language.dart` adds a language from the English one.
- `lib/screens/`: presentational only, reading state with `context.read/watch`.
- `test/`: mirrors `lib/`, plus `test/helpers/` (in-memory database, fakes, pump helpers) and the accessibility and text-scale harnesses.

## Conventions
- Product principles: no ad in the working area (viewfinder, scan result, generator editor), and the largest button is always the real action; nothing opens before the user has seen where it leads; the free app does the whole core job, and Pro is a one-time purchase that removes ads, never a subscription; no account, and scans, codes and history leave the device only when the user shares or exports them; ads and crash reports run only as far as the user's consent allows. Every feature keeps them.
- Flutter only: no hand-written Kotlin or Java. The only allowed files are the generated, untouched `MainActivity.kt` and `GeneratedPluginRegistrant.java`; every native capability comes from a plugin (manifest XML and Gradle config are fine). CI's Flutter-only guard enforces it, so a plugin that generates Kotlin into the repo is out.
- Out of scope until the user reopens them (decided 2026-09-14): home-screen widgets, a backend (dynamic QR codes, server-side link reputation), iOS.
- Behavior is defined in `docs/PRODUCT_RULES.md` with stable rule IDs (`SCAN-3`). Code comments, tests, PRs, and roadmap items cite them. No rule yet? `/spec <area>` before coding.
- State lives in the state layer; screens stay presentational. Don't add a second state library.
- Schema change = append a migration step and test the upgrade; never edit a merged step.
- Device services (camera scanner, ads, consent, purchases, clipboard, files, crash reports) sit behind an interface. Tests get a no-op fake by default; only the app's entry point builds the real one.
- Every model/state change gets a test. Tests assert what the user sees (text on screen, contents of a file), never just that output exists.
- Feature order: model → migration → state → screen → test → analyze.
- One branch per theme, PR to `main`; CI (`.github/workflows/ci.yml`) must pass.
- Every merged PR is a release: `/release [major|minor|patch]` on the branch (SemVer + `CHANGELOG.md` entry; CI checks it). The merge tags `vX.Y.Z` and drafts a GitHub Release. The local build goes to `dist/qr-scanner-generator-X.Y.Z.*` (gitignored); rebuild it after any app change on the branch.
- Before a branch is merged: `/ship` (coverage of changed files, missing tests, drive it by hand, release, PR).

## Workflow
- Start of an item: `git switch main`, `git pull --ff-only`, then branch from it. Never stack on an unmerged branch.
- Bundle related roadmap items into one PR by theme, and tick their boxes in that PR.
- Pass PR/issue bodies and commit messages through files (`gh pr create --body-file`, `git commit -F`): PowerShell 5.1 splits double quotes in here-strings.
- Before `gh workflow run --ref <branch>`, check `git ls-remote origin refs/heads/<branch>` matches `HEAD`.
- Anything that shows on screen gets driven by hand before the PR, and the PR says what was driven and what was only compiled. Put back any test data or setting changed on a device.
- A green open PR waits for the user; don't merge it.
- Competitors are for learning: observed behavior → what to learn → our better rule. Never copy their rules, text, or assets.
- End of session: `/handoff`. On "resume": read the handoff memory, `gh pr list`, `git log --oneline -3`.

## Token rules
- Don't open generated or platform folders unless the task is platform-specific (list in `docs/STACK_NOTES.md`).
- Grep with a `path`, then read line ranges. Never read lockfiles or generated project files whole; grep them.
- Don't spawn subagents for tasks touching fewer than ~5 files. Use the `build-doctor` agent for long build logs.
- Subagents and workflows run on Sonnet (the user's rule).
- Don't summarize diffs back; state the result in 1–3 lines.

## Read on demand only
- `docs/ROADMAP.md`: phased plan and known bugs. Read when planning or picking up work.
- `docs/PRODUCT_RULES.md`: behavior rules with IDs. Read the relevant section before implementing or testing a feature.
- `docs/research/competitor-analysis.md`: what the competitor does. Read before `/spec`.
- `docs/research/technical-constraints.md`: Flutter-only package plan, Play policy, spikes. Read before `/spec` and before adding a plugin.
- `docs/HANDOFF.md`: where the project stands, what is waiting on a person, and the traps. Read when picking the project up.
- `docs/RELEASING.md`: signing, secrets, store release steps.
- `docs/STACK_NOTES.md`: stack commands, architecture that worked, traps, device drill.

## Gotchas
- If the repo is public: never commit secrets or personal data, and never print secrets in workflows.
- Store IDs are permanent after the first upload and carry no personal names: `com.oasisforge.qrscanner`.
- Quote paths in shell commands; project paths may contain spaces. The repo is on `D:`, outside the OneDrive root at `C:\Users\hassa\OneDrive` (checked 2026-09-20), so a broken native build is not OneDrive's doing. A release build needs `$env:GRADLE_OPTS = "-Dorg.gradle.project.kotlin.incremental=false"` first, or all nine Kotlin plugin modules fail (`docs/STACK_NOTES.md`).
- The bare `flutter` on PATH is 3.44.8 and too old for this repo. Use `D:\Desktop\projects\flutter_sdk\flutter\bin\flutter` (`docs/STACK_NOTES.md`).
- `adb` isn't on PATH: use `$LOCALAPPDATA/Android/Sdk/platform-tools/adb.exe`. The emulator is `Medium_Phone` (API 37, Play Store image, virtual-scene back camera) at `emulator-5554`; the competitor app is installed there for research.
