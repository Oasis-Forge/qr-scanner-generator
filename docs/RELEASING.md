# Releasing

A release is cut when the user asks for one, not on every merge (decided 2026-09-21). The app version is the source of truth: `x.y.z` follows [Semantic Versioning](https://semver.org) (major for breaking changes, minor for new features, patch for fixes and everything else). Mobile stores also need a build number `N` (`x.y.z+N`) that grows by one with every release. `bash scripts/version.sh name` and `build` read them.

1. **Most branches are not releases.** Put the change under `## [Unreleased]` in `CHANGELOG.md` and leave the version alone. CI passes a branch whose version stands still, so nothing forces a release — the decision is the user's.
2. **When the user asks for one**, bump the version on the branch with `/release [major|minor|patch]`, or by hand: edit the version and move the Unreleased entries under a `## [x.y.z] - YYYY-MM-DD` heading. From there CI fails if the version is not above the one on `main`, or has no changelog entry, or reuses a build number.
3. **On merge**, `release.yml` builds the release artifacts as a check and runs the permission gate, whether or not this merge is a release. When the version did move, it runs the version gate a second time against the commit before the merge. It publishes nothing and tags nothing (see below).

Any other platform's release workflow is run by hand from the Actions tab, or with `gh workflow run <workflow>.yml --ref main`.

## How this app reaches Play (decided 2026-09-21)

**Nothing is published, from anywhere.** No GitHub Release, no CI artifact, no Play upload from CI. The bundle is built locally and uploaded to the Play Console by hand:

```powershell
$env:GRADLE_OPTS = "-Dorg.gradle.project.kotlin.incremental=false"
flutter build appbundle --release
```

It lands at `build/app/outputs/bundle/release/app-release.aab` and is copied to `dist/qr-scanner-generator-X.Y.Z.aab` (gitignored). The `GRADLE_OPTS` line is this machine's Kotlin trap, not a Play requirement (`docs/STACK_NOTES.md`).

What this changes:

- **`PLAY_SERVICE_ACCOUNT_JSON` is not needed** and no service account is created. The row stays in the table below only so nobody adds it by mistake.
- **The keystore secrets in GitHub are not needed either.** Signing happens locally from `android/key.properties`, so the upload key never leaves the machine.
- **`release.yml` leaves nothing behind:** no GitHub Release, no artifact, and no tag (all tags were deleted 2026-09-21). It still builds the APK and AAB, because that proves the release build compiles on a clean machine and it is where the RUN-2 permission check runs. Its build is a check, not a deliverable.
- **The version gate compares against main, not a tag.** `scripts/version.sh check` reads the version on `origin/main` and refuses a PR that doesn't rise above it. On main — the merge build — it compares against the commit before the merge, which keeps the safeguard tags used to provide: two PRs opened together both pass against the same main, and without that second look the one merged last ships as part of no release. The job checks out with `fetch-depth: 2` for it.
- **The record of a version is its `CHANGELOG.md` entry** and the commit that raised it.

Why publish nothing: a CI build is debug-signed unless the optional keystore secrets are set, so a downloadable CI artifact is something nobody can install over an existing copy and nobody can upload — while looking exactly like the build that shipped. One place produces the real bundle, and it is this machine.

**A bundle can only be uploaded if it is signed with the upload key.** Without `android/key.properties` the build silently falls back to the debug key and Play rejects it — see *Signing locally* below, which is now the main path rather than an optional extra.

## GitHub secrets and variables

Add them in GitHub → Settings → Secrets and variables → Actions, or with `gh secret set NAME` (it prompts for the value).

| Name | Kind | Used by | Value |
|---|---|---|---|
| `CLAUDE_CODE_OAUTH_TOKEN` | secret | `claude.yml` | Output of `claude setup-token` |
| `ANDROID_KEYSTORE_BASE64` | secret | `release.yml` | Base64 of `upload-keystore.jks`. Optional: only if a CI-built artifact has to be uploadable. Signing is local (2026-09-21). |
| `ANDROID_KEYSTORE_PASSWORD` | secret | `release.yml` | Keystore password |
| `ANDROID_KEY_ALIAS` | secret | `release.yml` | Key alias, e.g. `upload` |
| `ANDROID_KEY_PASSWORD` | secret | `release.yml` | Key password |
| ~~`PLAY_SERVICE_ACCOUNT_JSON`~~ | — | — | **Not used.** Nothing publishes to Play from GitHub (2026-09-21); the bundle is built locally and uploaded by hand. |

## Protect `main`

Settings → Rules → Rulesets → New branch ruleset, target `main`:
- Require a pull request before merging.
- Require status checks to pass: the CI job names. Run CI on one PR first so the names show up in the picker.
- Block force pushes and deletion.
- Bypass list: Repository admin.

## Public repository

- **Secrets stay safe:** GitHub masks secret values in logs, and the workflows never print them. CI uses `pull_request`, not `pull_request_target`, so PRs from forks run without secrets. `claude.yml` runs only for `thepromptkitchen-alt`.
- **Nothing downloadable is produced**, so a public repo exposes no build at all: `release.yml` creates no GitHub Release and uploads no artifact (2026-09-21).
- **Fork PRs:** Settings → Actions → General → "Approval for running fork pull request workflows" → "Require approval for all external contributors".
- **Commit emails are public.** Use the noreply address from GitHub → Settings → Emails: `git config user.email "<id>+thepromptkitchen-alt@users.noreply.github.com"`.
- **License:** with no `LICENSE` file the code is "all rights reserved".
- A public repo gets free GitHub-hosted runners, so every PR runs the checks and an Android build.

## Privacy policy

Google Play requires a public privacy policy URL.
1. Settings → Pages → Deploy from a branch → `main` / `/docs`.
2. The policy is then live at `https://oasis-forge.github.io/qr-scanner-generator/privacy-policy/`, the URL Settings opens (SET-6) and the one Play and AdMob need. Done 2026-09-20.

Every file in `docs/` gets published.

## One-time setup: Android

### Signing locally

This is the path this app uses. Both files are gitignored and neither ever leaves the machine.

1. Create the upload keystore and back it up with its passwords. Losing it means asking Google for an upload-key reset. Run this yourself — it asks for passwords, which belong only to you:
   ```bash
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Put the `.jks` somewhere outside the repo, or inside `android/` (it is gitignored either way), and write `android/key.properties` beside it:
   ```properties
   storeFile=C:/path/to/upload-keystore.jks
   storePassword=…
   keyAlias=upload
   keyPassword=…
   ```
   `android/app/build.gradle.kts` picks it up on its own; with no such file the build falls back to the debug key and Play rejects the bundle.
3. Check a build really is signed with it before every upload. `keytool` is not on PATH on the QR machine, so call it through `JAVA_HOME` — a bare `keytool` prints nothing and looks like a pass:
   ```bash
   "$JAVA_HOME/bin/keytool.exe" -printcert -jarfile dist/qr-scanner-generator-X.Y.Z.aab
   ```
   The owner must be your certificate. `Owner: C=US, O=Android, CN=Android Debug` means the build fell back to the debug key and Play will reject it (seen on v0.11.0, before the keystore existed).

### Play Console

4. Create the app with package `com.oasisforge.qrscanner` and keep Play App Signing enabled.
5. **Upload every AAB by hand** in Play Console → Testing → Internal testing. The API can't create an app's first release, and by the decision above it isn't used afterwards either.
6. New personal developer accounts need a closed test with at least 12 testers for 14 days before production access. Confirm the current rule and start early.

A debug-signed build can't update an installed copy: back up in the app, uninstall, install, restore.

## One-time setup: ads, consent, Pro, crash reports

Where ads may appear, how often, and what Pro unlocks are rules in `docs/PRODUCT_RULES.md`. This section is only the account setup.

1. **AdMob:** add the Android app (package `com.oasisforge.qrscanner`) and create one ad unit per placement the rules allow. Done 2026-09-19: the AdMob app ID is in `android/app/src/main/AndroidManifest.xml` and the banner unit is `bannerAdUnitId` in `lib/main.dart` (one unit serves all three slots). Neither is a secret. Release builds request the real unit; debug builds always use Google's test unit. Register your own phones as AdMob test devices (AdMob → Settings → Test devices) before installing a release build on them; emulators are test devices automatically.
2. **Consent:** in AdMob → Privacy & messaging, publish the European regulations message (EEA, UK, Switzerland) and the US state regulations message, both linking the privacy policy URL. The app requests consent through `google_mobile_ads`' UMP API before it loads any ad.
3. **app-ads.txt:** AdMob verifies apps through an `app-ads.txt` file at the root of the developer website on the Play listing. The Pages URL above is a sub-path, so the file lives at the site root instead: `https://oasis-forge.github.io/app-ads.txt`, served from the `Oasis-Forge/oasis-forge.github.io` repo. Live and checked 2026-09-21. The listing's developer website must be that root, not the sub-path, or AdMob won't find it.
4. **Pro:** Play Console → Monetize → Products → In-app products: create one managed, one-time product for Pro. It can only be created after an AAB with the billing permission is uploaded. Add testers under Settings → License testing so closed-test purchases aren't charged.
5. **Crash reports:** create a Firebase project with the Android app; `flutterfire configure` writes `google-services.json` and Gradle config, no Kotlin. Set `firebase_crashlytics_collection_enabled` to `false` in the manifest; collection starts only when the user turns on "Send crash reports" in Settings (PRIV-3, spike S14).
6. **Data safety form** (Play Console → App content): declare what the ads SDK and Crashlytics collect and share. Keep it matched to `docs/privacy-policy/index.html` and the release manifest's permissions (RUN-2).

## One-time setup: Claude GitHub Action

Run `/install-github-app` from a `claude` terminal, or install the Claude GitHub app on the repo and add `CLAUDE_CODE_OAUTH_TOKEN`. Then comment `@claude <request>` on an issue or PR. Only `thepromptkitchen-alt` can trigger it, and each run is capped at 15 turns.

## App icon and splash screen

Draw them from one committed source, generate the platform files with the stack's tools, and commit the results. The commands are in `docs/STACK_NOTES.md`.

## Store listing

Everything the listing needs lives in `store/`, which `.gitignore` keeps out of the public repository; `store/play/README.txt` says what is where. Only the captions and titles are committed, in `integration_test/store_captions.dart`, because the renderer needs them to compile and CI analyzes that folder.

### Text

`store/play/source/listing.txt` holds all twenty languages, one block each, and is the only file edited by hand. Build the rest from it:

```bash
dart store/play/source/build_listing.dart store/play/source/listing.txt store/play
```

That writes `store/play/store-listing-translations.csv` for **Main store listing → Manage translations → bulk import**, and `store/play/text/<code>.txt` to paste by hand if the import misreads a language. It refuses to write anything if a title is over 30 characters, a short description over 80, or a full description over 4000, and prints the count for each language either way — Play rejects an over-long field on import without saying which one. English is left out of the CSV: it is the default listing, typed on the main page.

Only claim what ships. The listing describes the app at v0.12.0, which has no search, no export or backup, no barcode *generation* and no styled codes; those are Phase 2b, and a listing that promises them is a listing Play can pull.

### Graphics

`integration_test/store_screenshots_test.dart` renders them on the emulator from the real screens with sample data: six captioned phone screenshots (1080×1920) and a feature graphic (1024×500) per language, plus the 512×512 store icon once. Android draws the text itself, so every script looks exactly as it does on a phone.

```bash
adb shell "rm -rf /sdcard/Download/store-screenshots"
flutter test integration_test/store_screenshots_test.dart -d emulator-5554
adb pull /sdcard/Download/store-screenshots/<code> store/play/graphics
```

- **Clear the whole folder first, not just one language.** The runner uninstalls the app when it finishes, and the next install cannot overwrite the files the old one wrote — the write fails with `Permission denied, errno = 13`. Leaving `icon-512.png` behind in the parent folder is enough to fail a run whose language folders were cleared.
- **Quote the device path** in every `adb shell` and `adb pull` from Git Bash, or wrap the whole command in quotes. Unquoted, Git Bash rewrites `/sdcard/...` into `C:/Program Files/Git/sdcard/...`: the pull says "No such file or directory", and the `rm` silently deletes nothing, which then looks like a permissions problem.
- `--dart-define=ONLY=en-US,ar` renders only those languages.
- The scanner shot needs `CameraPermissionState.granted`, or it renders the permission gate instead of the viewfinder, and a fake camera that paints a poster — the emulator's virtual scene is far too soft to photograph.
- The icon and both graphics use the launcher mark's own painter (`tool/app_icon_painter.dart`), so the store and the phone can't drift apart (ICON-1).

Play also needs the listing's developer website to be the **site root** (`https://oasis-forge.github.io/`), not the privacy policy's sub-path, or AdMob will not find `app-ads.txt`.

### Release notes

Every release carries its notes in all twenty languages (decided 2026-09-21): a tester reading the app in Urdu should read the note in Urdu too. The source is one block per language, the same shape as the listing's, and the only file edited by hand:

```bash
dart tool/build_release_notes.dart store/play/source/release-notes/X.Y.Z.txt store/play
```

That writes `store/play/release-notes/X.Y.Z.txt`: every language inside its own `<en-US>` … `</en-US>` tag, which is the entire contents of the release's **Release notes** field. Paste it once and Play splits it. The builder refuses to write if a language is over **500 characters**, missing, or not a listing language, and prints each count either way.

- **Write the English first and keep it short.** German and Russian run about a third longer, so English much over 380 characters produces translations Play rejects — and it rejects the whole paste, naming no language.
- **A release with nothing a user can see gets notes about the build, not an invented feature.** "Nothing users can see" is the right thing to write in `CHANGELOG.md` and the wrong thing to tell a tester.
- Translate with the same fan-out the listing used, grounded in `lib/l10n/app_<code>.arb`, so the note and the app use the same words for History, Create and Wi-Fi.
