# Releasing

Every PR merged to `main` is a release. The app version is the source of truth: `x.y.z` follows [Semantic Versioning](https://semver.org) (major for breaking changes, minor for new features, patch for fixes and everything else). Mobile stores also need a build number `N` (`x.y.z+N`) that grows by one with every release. `bash scripts/version.sh name` and `build` read them.

1. **Before merging**, bump the version on the branch with `/release [major|minor|patch]`, or by hand: edit the version and add a `## [x.y.z] - YYYY-MM-DD` entry to `CHANGELOG.md`. CI fails if the version isn't above the latest `vX.Y.Z` tag or has no changelog entry. Dependabot PRs are exempt and ship with the next release.
2. **On merge**, `release.yml` builds the release artifacts, tags the merge commit `vX.Y.Z`, and attaches them to a **draft** GitHub Release with the changelog entry as notes. A merge whose version is already tagged releases nothing.

Tags pushed by CI don't start other workflows, so any other platform's release workflow is run by hand from the Actions tab, or with `gh workflow run <workflow>.yml --ref vX.Y.Z`. Each checks that the tag matches the version.

## GitHub secrets and variables

Add them in GitHub → Settings → Secrets and variables → Actions, or with `gh secret set NAME` (it prompts for the value).

| Name | Kind | Used by | Value |
|---|---|---|---|
| `CLAUDE_CODE_OAUTH_TOKEN` | secret | `claude.yml` | Output of `claude setup-token` |
| `ANDROID_KEYSTORE_BASE64` | secret | `release.yml` | Base64 of `upload-keystore.jks` |
| `ANDROID_KEYSTORE_PASSWORD` | secret | `release.yml` | Keystore password |
| `ANDROID_KEY_ALIAS` | secret | `release.yml` | Key alias, e.g. `upload` |
| `ANDROID_KEY_PASSWORD` | secret | `release.yml` | Key password |
| `PLAY_SERVICE_ACCOUNT_JSON` | secret | `release.yml` | Google Cloud service-account JSON key with Play Console release access |

## Protect `main`

Settings → Rules → Rulesets → New branch ruleset, target `main`:
- Require a pull request before merging.
- Require status checks to pass: the CI job names. Run CI on one PR first so the names show up in the picker.
- Block force pushes and deletion.
- Bypass list: Repository admin.

## Public repository

- **Secrets stay safe:** GitHub masks secret values in logs, and the workflows never print them. CI uses `pull_request`, not `pull_request_target`, so PRs from forks run without secrets. `claude.yml` runs only for `thepromptkitchen-alt`.
- **Releases are drafts**, so nobody can download an artifact until you publish it.
- **Fork PRs:** Settings → Actions → General → "Approval for running fork pull request workflows" → "Require approval for all external contributors".
- **Commit emails are public.** Use the noreply address from GitHub → Settings → Emails: `git config user.email "<id>+thepromptkitchen-alt@users.noreply.github.com"`.
- **License:** with no `LICENSE` file the code is "all rights reserved".
- A public repo gets free GitHub-hosted runners, so every PR runs the checks and an Android build.

## Privacy policy

Google Play requires a public privacy policy URL.
1. Settings → Pages → Deploy from a branch → `main` / `/docs`.
2. The policy is then live at `https://oasis-forge.github.io/qr-scanner-generator/privacy-policy`. Its contact is the GitHub Issues page, so no email address is published.

Every file in `docs/` gets published.

## One-time setup: Android

1. Create the upload keystore and back it up with its passwords. Losing it means asking Google for an upload-key reset.
   ```bash
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Base64 it into the clipboard for `ANDROID_KEYSTORE_BASE64` (PowerShell):
   ```powershell
   [Convert]::ToBase64String([IO.File]::ReadAllBytes("upload-keystore.jks")) | Set-Clipboard
   ```
3. Optional, for signed local builds: keep the keystore and a `key.properties` in the Android project, both gitignored.
4. In Play Console, create the app with package `com.oasisforge.qrscanner` and keep Play App Signing enabled.
5. **Upload the first AAB by hand** in Play Console → Testing → Internal testing. The API can't create an app's first release.
6. In Google Cloud, create a service account and a JSON key. In Play Console → Users and permissions, invite it with release permissions for this app. Save the JSON as `PLAY_SERVICE_ACCOUNT_JSON`.
7. New personal developer accounts need a closed test with at least 12 testers for 14 days before production access. Confirm the current rule and start early.

Without the signing secrets, CI signs each APK with a throwaway debug key, which can't update an installed copy: back up in the app, uninstall, install, restore.

## One-time setup: ads, consent, Pro, crash reports

Where ads may appear, how often, and what Pro unlocks are rules in `docs/PRODUCT_RULES.md`. This section is only the account setup.

1. **AdMob:** add the Android app (package `com.oasisforge.qrscanner`) and create one ad unit per placement the rules allow. The AdMob app ID goes in `android/app/src/main/AndroidManifest.xml`; ad unit IDs aren't secrets. Debug builds always use Google's test ad units, and your own phones are registered as AdMob test devices.
2. **Consent:** in AdMob → Privacy & messaging, publish the European regulations message (EEA, UK, Switzerland) and the US state regulations message, both linking the privacy policy URL. The app requests consent through `google_mobile_ads`' UMP API before it loads any ad.
3. **app-ads.txt:** AdMob verifies apps through an `app-ads.txt` file at the root of the developer website on the Play listing. The Pages URL above is a sub-path, so confirm where the root file can live (for example an `Oasis-Forge/oasis-forge.github.io` repo) before the listing goes live.
4. **Pro:** Play Console → Monetize → Products → In-app products: create one managed, one-time product for Pro. It can only be created after an AAB with the billing permission is uploaded. Add testers under Settings → License testing so closed-test purchases aren't charged.
5. **Crash reports:** create a Firebase project with the Android app; `flutterfire configure` writes `google-services.json` and Gradle config, no Kotlin. Set `firebase_crashlytics_collection_enabled` to `false` in the manifest; collection starts only when the user turns on "Send crash reports" in Settings (PRIV-3, spike S14).
6. **Data safety form** (Play Console → App content): declare what the ads SDK and Crashlytics collect and share. Keep it matched to `docs/privacy-policy.md` and the release manifest's permissions (RUN-2).

## One-time setup: Claude GitHub Action

Run `/install-github-app` from a `claude` terminal, or install the Claude GitHub app on the repo and add `CLAUDE_CODE_OAUTH_TOKEN`. Then comment `@claude <request>` on an issue or PR. Only `thepromptkitchen-alt` can trigger it, and each run is capped at 15 turns.

## App icon and splash screen

Draw them from one committed source, generate the platform files with the stack's tools, and commit the results. The commands are in `docs/STACK_NOTES.md`.
