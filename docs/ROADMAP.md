# Roadmap

Goal: build the v1 feature set and ship QR Scanner + Generator to Google Play. The closed test starts 16 October 2026, the production application goes in on 2 November, and the app is live by 13 November. Behavior is defined in `docs/PRODUCT_RULES.md`; items cite its rule IDs. Group related items into larger PRs by theme; CI must pass. Tick items in the same PR that completes them, and date every decision that adds, moves, or drops one.

## Schedule

| Dates (2026) | Phase | Exit |
|---|---|---|
| Sep 16–18 | 0 Tooling, spikes, accounts | CI green on a first PR; spikes S1, S2, S3, S8 answered; Play Console app created; tester recruiting started |
| Sep 21–25 | 1 Foundations | Schema, services behind interfaces, English + Arabic scaffolding, themes; tests green |
| Sep 28 – Oct 9 | 2a Closed-test build | The closed-test items driven by hand; an internal-testing upload by Oct 2 |
| Oct 1–9 | 3 Store readiness (overlaps 2a) | Listing, app content and privacy policy done; closed-test release submitted by Oct 9 |
| Oct 16 | Closed test starts | 12+ testers opted in (recruit 20+) |
| Oct 19–30 | 2b v1 during the test | v1 items shipped to the closed track; Oct 30 is day 14 |
| Nov 2 | Apply for production | |
| Nov 2–13 | 5 Release | Review, staged rollout, live Nov 13 (contingency Nov 20) |
| From Nov 16 | After v1 | v1.1 |

Suggested split:
- **Dev A:** camera, scanning, results, link safety, generator.
- **Dev B:** data, history, export, backup, ads, consent, Pro, settings, languages. Dev B starts Notes on Nov 2, so the release phase is Dev A's.

Decided 2026-09-16: the dates stay and the first build is trimmed; everything not in Phase 2a ships as updates during the closed test.

If Play's review of the closed-test release isn't done by Oct 16, day 14 of the test, the production application and the launch all move by the same number of days.

If Phase 0 or 1 runs long, the test harnesses and spikes S3, S11 and S13 can slip into the week of Sep 28. The schema, services, CI and signing can't, because the Oct 2 upload depends on them.

## Phase 0: Tooling (Sep 16–18)
Set up before the first feature, while it's cheap.
- [x] Kit applied: `CLAUDE.md`, `.claude/` settings, format hook, `/spec` `/verify` `/release` `/ship` `/handoff` skills, `build-doctor` agent; placeholders filled; Android-only CI with the Flutter-only guard (2026-09-15)
- [x] Competitor research (`docs/research/competitor-analysis.md`), technical constraints, product rules and privacy policy draft (2026-09-15/16)
- [x] Git history: fresh, starting at the kit commit; the old scaffold's history is gone (checked 2026-09-16)
- [x] Flutter pin: 3.47.4 / Dart 3.13.3, matched in the local SDK, `ci.yml`, `release.yml`, `claude.yml` and `CLAUDE.md` (decided 2026-09-16)
- [x] Finish `/kickoff`: Android scaffold as `com.oasisforge.qrscanner`, version `0.1.0+1`, merged `.gitignore`, strict lints, `/verify` green, kickoff skill deleted; repo `Oasis-Forge/qr-scanner-generator` (public) (2026-09-16)
- [x] GitHub repo, Dependabot, CI (checks, Flutter-only guard, Android build) green on a first PR (#1, 2026-09-16)
- [x] `main` ruleset, live 2026-09-21: pull request required, both CI checks required, no force pushes or deletion, merge and squash only, and no bypass — a direct push is refused for the owner as well (`docs/RELEASING.md`)
- [x] The release gate: the CI version check, then a build-as-a-check on merge. Tags and GitHub Releases were dropped on 2026-09-21 and the existing tags deleted; nothing is published from CI. Releasing on every merge went the same day: the user decides when a release is cut, and the check passes a branch whose version stands still (`docs/RELEASING.md`).
- [x] The release workflow runs once without secrets (unsigned artifacts, nothing published): it ran on the `v0.1.0` merge, 2026-09-16
- [x] Privacy policy served by GitHub Pages at `https://oasis-forge.github.io/qr-scanner-generator/privacy-policy/` (`docs/privacy-policy/index.html`), 2026-09-20
- [x] Re-check package versions on pub.dev and run the licence check (S7); each version is pinned when its feature adds it (`docs/research/technical-constraints.md` → Spike results, 2026-09-16)
- [x] Spikes S1 (virtual-scene scanning; answered 2026-09-17), S2 (`analyzeImage` on API 36/37), S3 (`flutter_zxing` from the OneDrive path) and S8 (camera permission states), plus the desk spikes S11 (Public Suffix List source) and S13 (barcode PNG rendering). Book real phones for S5 and S6 on Sep 28 – Oct 2. S2, S3, S8, S11 and S13 answered 2026-09-16 (`docs/research/technical-constraints.md` → Spike results).
- [ ] Accounts:
  - Play Console app `com.oasisforge.qrscanner` with Play App Signing and the upload keystore
  - the upload keystore created and backed up, with `android/key.properties` pointing at it locally (`docs/RELEASING.md`), so the bundle is signed with the upload key. GitHub secrets aren't needed: nothing publishes to Play from GitHub (decided 2026-09-21)
  - AdMob app, consent messages, and a Firebase project (`docs/RELEASING.md`)
  - a non-personal support email for the listing and feedback (SET-8)
- [ ] Testers: a Google Group, recruiting 20+ now so at least 12 are opted in on Oct 16 and stay for 14 days

## Phase 1: Foundations (Sep 21–25)
Groundwork every feature builds on. Settle everything that shapes stored data now, before testers have any.
- [x] Architecture (confirmed by the user 2026-09-17):
  - the kit's single app at the repo root: `provider` + `ChangeNotifier`, `sqflite` with ordered migrations (`docs/STACK_NOTES.md`)
  - code other apps will reuse (theme, ads and consent, Pro, database helpers) lives in `lib/core/` without app imports, so it can move to the shared core repo when Notes starts on Nov 2
- [x] Strict lints (unawaited futures, declared return types, single quotes, const where possible); `prefer_initializing_formals` is off, so public parameter names stay readable in front of private fields
- [x] Inject the storage layer and every device service into the state layer, so tests use an in-memory database and no-op fakes: camera scanner, image decoder, permissions, ads, consent, billing, crash reports, clipboard, file picker and share, Custom Tabs and intents, Wi-Fi (`lib/services/app_services.dart`; only `main.dart` builds real ones)
- [x] Migration scaffold: an ordered list of schema steps run on upgrade, with a test that upgrades the oldest schema
- [x] Reliable writes: write first, then change state; on failure roll back and show an error
- [x] Schema step 1 (REC-1–REC-4, DATA-1–DATA-8, DATE-1–DATE-3, DEL-1):
  - the records table with every field in "Roadmap impact" of `docs/PRODUCT_RULES.md`
  - the batch staging table
  - stores for settings, consent, Pro ownership and success counts
  - v1 fields included, so no migration touches testers' data
- [x] Localization scaffolding: English and Arabic message files, locale-formatted dates and numbers, and right-to-left layout from the start (LANG-1–LANG-3, LANG-5), with the CI message check and a test that both files carry the same keys and placeholders
- [x] Themes: system, light and dark, edge-to-edge insets, predictive back. Dynamic colour was dropped on 2026-09-20 when the app took its own identity (SET-1).
- [x] Test harnesses: icon labels (A11Y-1), touch targets (A11Y-2), every language at 2.0× text (A11Y-4, LANG-6) in `test/helpers/test_app.dart`. Contrast in both themes (A11Y-5) and no colour-only states (A11Y-6) go into every screen PR's checklist.
- [x] Tests: model round-trip, migration upgrade, duplicate matching (DATA-4), the sensitive-field flag (DATA-5)
- [x] Platform decision: Android only in v1; iOS deferred (2026-09-14)

## Phase 2a: Closed-test build (Sep 28 – Oct 9)
In dependency order, one theme per PR. Everything else in Phase 2 arrives during the test.
- [x] **Scanner and permissions:** RUN-1–RUN-7, SCAN-1–SCAN-7, SCAN-9, SCAN-11–SCAN-13, A11Y-3. SCAN-2 and SCAN-3's numbers stay provisional until S6. Done 2026-09-19 (v0.3.0). Still for a real phone: a live read with the code inside the target (the emulator's scene is too soft), and SCAN-2/SCAN-3 timings (S6). Open for the user: SCAN-7's 2x auto-zoom cap can't be enforced Flutter-only.
- [x] **Result screens and parsers:** RES-1–RES-4, RES-6, RES-7, RES-9, RES-13, RES-14. Each payload parser is pure Dart with its own tests.
- [x] **Link safety:** LINK-1–LINK-5, LINK-8, LINK-9 (LINK-2 bolds the full host until S11), and the one-time link callout RUN-8, so every tester sees it on their first link
- [x] **History and delete:** HIS-1 (segments), HIS-3–HIS-5, HIS-7, HIS-11, DEL-2, DEL-4
- [x] **Generator and save:**
  - GEN-1, GEN-3, GEN-5, GEN-6 (closed-test fields), GEN-7, GEN-8, GEN-12, GEN-13 (every created code is saved until HIS-8's switch ships in 2b)
  - STY-1, STY-5 (if S2 fails, STY-5 moves to v1 and the listing doesn't claim a scan check)
  - SAVE-1, SAVE-2, SAVE-4, SAVE-5
- [x] **Ads, consent, Pro, settings:** ADS-1–ADS-8, PRO-1–PRO-7, PRIV-1, PRIV-2, PRIV-4–PRIV-8, SET-1 (Settings row), SET-2, SET-3, SET-5–SET-8. Release builds request the app's own banner unit (created 2026-09-19); debug builds use Google's test unit.
- [ ] **Crash reports:** PRIV-3 with spike S14 (no Firebase traffic before opt-in), once `google-services.json` arrives. The Settings row stays hidden until then (`crashReportsAvailable` in `lib/screens/settings/privacy_section.dart`).
- [ ] Internal-testing AAB uploaded by hand by Oct 2, and every upload after it (decided 2026-09-21). The `remove_ads` product needs an uploaded build with the billing permission. The bundle is built here; it can only be uploaded once `android/key.properties` exists, or it is debug-signed and Play refuses it.
- [ ] Right after that upload: the `remove_ads` product at US$1.99 and license testers (PRO-1, PRO-3), so the Pro PR is driven with a test purchase before Oct 9
- [ ] Spikes S5 (Wi-Fi join) and S6 (cold start to first scan) on real phones, Sep 28 – Oct 2; S12 (share-target permissions) before Oct 19

## Phase 2b: v1 during the closed test (Oct 19–30)
- [x] **The app's own look** (2026-09-20): the instrument design — chassis, signal colour, paper for content, Space Grotesk and IBM Plex Mono, registration marks, hairline rails. Designed on a canvas first, then built (v0.9.0).
Shipped to the closed track as updates; the testers' 14-day clock keeps running.
- [x] **Languages** (LANG-7): eighteen added at once — Bengali, Simplified Chinese, Dutch, French, German, Hindi, Indonesian, Italian, Japanese, Korean, Polish, Portuguese, Russian, Spanish, Thai, Turkish, Urdu, Vietnamese — for twenty in total (2026-09-21). Greek was translated too and is held back until a font that covers it is bundled (Known bugs). Done first, so every later PR translates as it goes.
- [ ] **Scan modes and entry points:** SCAN-8, SCAN-10, SCAN-14 with HIS-6, ENTRY-1, ENTRY-2 (only if S12 passes)
- [ ] **More results:** RES-5 (only if S5 passes; otherwise RES-4's flow stays), RES-8, RES-10, RES-11, SET-4
- [ ] **Link safety, extended:** LINK-2's registrable domain (S11), LINK-6 with its bundled tables and credits, LINK-7 with its data-safety update (PRIV-6)
- [ ] **History, organised:** HIS-1 type chips, HIS-2 with LANG-4, HIS-8 with DATA-6, HIS-9, HIS-10 with DEL-3, DEL-5, DEL-6
- [ ] **Generator, complete:** GEN-2 (barcode PNGs as S13 found), GEN-4, GEN-6 (v1 fields), GEN-9–GEN-11, GEN-14, GEN-15, STY-2–STY-4, SAVE-3, SAVE-6
- [ ] **Export and backup:** EXP-1–EXP-6, then BAK-1–BAK-7 (decided 2026-09-16: v1), after the last schema step, so the format covers every field

## Phase 3: Store readiness (Oct 1–9)
Play needs most of this before the closed-test release can be reviewed, so it overlaps Phase 2a.
- [x] Display name "QR Scanner + Generator" in the launcher, and its Arabic name (2026-09-20). Store title still to choose (30 characters at most, no competitor names).
- [x] Launcher icons and splash screen (ICON-1–ICON-7), generated from one committed source (2026-09-20). The mark is painted in `tool/app_icon_painter.dart`; `docs/STACK_NOTES.md` has the regeneration steps.
- [ ] Store IDs, permanent after the first upload and free of personal names: `com.oasisforge.qrscanner`
- [x] Privacy policy published on Pages at `/qr-scanner-generator/privacy-policy/`, linked from Settings (SET-6) and listed on the Oasis Forge site (2026-09-20). Keep it updated for every feature that touches user data (PRIV-6).
- [x] The release build declares only the permissions the listing admits to (RUN-2). Fill `ALLOWED` in `release.yml` with the camera, internet, network state, billing, the ad ID, and those the ads SDK adds, checked with `aapt2`.
- [ ] Play app content: data safety, ads declaration, content rating, target audience 13+, app access (no login)
- [x] Store listing drawn from the app itself, in all twenty languages (2026-09-21): title, short and full description, six captioned phone screenshots and a 1024×500 feature graphic per language, and the 512 px icon, rendered from the real screens by `integration_test/store_screenshots_test.dart`. It waits on the upload. No tablet screenshots yet, so Play will flag large screens.
- [x] Release notes in all twenty languages with every release (2026-09-21), built by `tool/build_release_notes.dart` from one hand-written source per version (`docs/RELEASING.md`).
- [x] `app-ads.txt` published at the root of the developer website on the listing (`docs/RELEASING.md`). Live at `https://oasis-forge.github.io/app-ads.txt` with the AdMob publisher line; checked 2026-09-21.
- [ ] Closed-test release submitted by Oct 9, since a new account's first review can take days

## Phase 4: Before release (Oct 26–30)
Late checks. The review prompt comes last, so it asks about finished features.
- [ ] Review prompt (SET-9)
- [ ] Scan-reliability pass on real phones: confirm GEN-12's 80% meter, STY-3's 20% logo cap, and SCAN-2 and SCAN-3's budgets from S6. Amend the rules if a number changes.
- [ ] Pre-launch report read for every closed-track upload; crashes and accessibility findings fixed or listed under Known bugs
- [ ] Data safety and the policy checked against the final manifest (PRIV-6). The listing itself is already in all twenty languages (LANG-7, 2026-09-21); it needs rewriting only where a Phase 2b feature changes what it claims.

## Phase 5: Release (Nov 2–13)
- [x] ~~Play service account and `PLAY_SERVICE_ACCOUNT_JSON`, so releases upload to Play automatically.~~ Dropped 2026-09-21: nothing publishes to Play from GitHub. Every bundle is built locally with `flutter build appbundle --release` and uploaded by hand, so no service account exists and the keystore never leaves the machine (`docs/RELEASING.md`).
- [ ] Closed test complete: 12+ testers opted in for 14 continuous days (Oct 16–30).
- [ ] Apply for production on Nov 2. The decision takes about 1–3 business days (up to 7), then up to about 7 days of review.
- [ ] Staged rollout 10% → 50% → 100%, holding if the user-perceived crash rate reaches 1.09% or the ANR rate 0.47%.
- [ ] Live by Nov 13 (contingency Nov 20). Recalibrate the portfolio schedule against QR's actual pace.

## After v1
- Needs a backend decision (2026-09-14): dynamic QR codes, online link reputation, product information lookup
- GS1 results (RES-12); generator formats ITF-14, Data Matrix, PDF417, Aztec (GEN-2); label sheets (SAVE-7); current location (GEN-16, S10)
- App lock (LOCK-1–LOCK-3, S9); Quick Settings tile (ENTRY-3, S4). No home-screen widget or text-selection action (ENTRY-4).
- Share target for text and links; scanning a copied image (`super_clipboard`); XLSX export
- Whether Pro ever adds anything beyond ad removal (PRO-2)
- Optional auto-delete of old history
- More languages, chosen from testers' and users' locales (LANG-7)
- Move `lib/core/` into the shared core repo when Notes starts (Nov 2)

## Known bugs
- **Greek renders wrongly, and it is the fonts, not the translation** (found 2026-09-21, driven on the emulator at v0.11.0). Accents sit detached after their letter ("Προεπιλογη΄" for "Προεπιλογή", "Φωτεινο΄" for "Φωτεινό") and sigma comes out as a Latin or lunate C in the uppercased rail and headers ("ϹΑΡΩϹΗ", "ΡΥΘΜΊCΕΙC"). The ARB is correct — the source bytes are precomposed U+03AC. Space Grotesk and IBM Plex Mono carry *part* of Greek, so Flutter takes the plain letters from them and the accented ones from a fallback font, and the two don't match. Every other non-Latin script is clean precisely because the bundled fonts have no coverage at all and the whole run falls back together. Greek is therefore NOT offered yet: `el` is commented out of `lib/l10n/languages.dart` and `app_el.arb` is not in the tree. Its translation is kept at `tool/translations/el.json`, so restoring it once a Greek-covering font is bundled is one line plus `dart tool/new_language.dart el tool/translations/el.json` (LANG-7). Nothing else is affected.
