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
- [ ] Git history: this folder's leftover `.git` holds the deleted first scaffold (2 commits, remote deleted). Start a fresh history before the first commit (confirm with the user).
- [ ] Flutter pin: the local SDK is 3.44.8; the newest stable was 3.47.4 on 2026-09-15. Pick one, then match the local SDK, `FLUTTER_VERSION` in `ci.yml`, `release.yml` and `claude.yml`, and `STACK` in `CLAUDE.md`.
- [ ] Finish `/kickoff` steps 4–9:
  - scaffold with `flutter create --org com.oasisforge --project-name qrscanner --platforms android .` (gives `com.oasisforge.qrscanner` directly)
  - set version `0.1.0+1`, merge `.gitignore`, add strict lints, run `/verify`
  - delete the kickoff skill, make the first commit
  - `gh repo create Oasis-Forge/qr-scanner-generator --public --source=. --push`
- [ ] GitHub repo, Dependabot, CI (checks, Flutter-only guard, Android build) green on a first PR
- [ ] `main` ruleset: PR required, the CI checks required, no force pushes or deletion (`docs/RELEASING.md`)
- [ ] Every merged PR is a release: the CI version check, then a tag and a draft GitHub Release on merge. `v0.1.0` is the first.
- [ ] The release workflow runs once by hand without secrets (unsigned artifacts, nothing published)
- [ ] Privacy policy served by GitHub Pages (draft in `docs/privacy-policy.md`)
- [ ] Re-check package versions on pub.dev, pin them, and run the licence check (S7) (`docs/research/technical-constraints.md`)
- [ ] Spikes S1 (virtual-scene scanning), S2 (`analyzeImage` on API 36/37), S3 (`flutter_zxing` from the OneDrive path) and S8 (camera permission states), plus the desk spikes S11 (Public Suffix List source) and S13 (barcode PNG rendering). Book real phones for S5 and S6 on Sep 28 – Oct 2.
- [ ] Accounts:
  - Play Console app `com.oasisforge.qrscanner` with Play App Signing and the upload keystore
  - the upload keystore backed up and its secrets set in GitHub (`docs/RELEASING.md`), so every testing upload is signed with the upload key
  - AdMob app, consent messages, and a Firebase project (`docs/RELEASING.md`)
  - a non-personal support email for the listing and feedback (SET-8)
- [ ] Testers: a Google Group, recruiting 20+ now so at least 12 are opted in on Oct 16 and stay for 14 days

## Phase 1: Foundations (Sep 21–25)
Groundwork every feature builds on. Settle everything that shapes stored data now, before testers have any.
- [ ] Architecture (default set 2026-09-16, confirm):
  - the kit's single app at the repo root: `provider` + `ChangeNotifier`, `sqflite` with ordered migrations (`docs/STACK_NOTES.md`)
  - code other apps will reuse (theme, ads and consent, Pro, database helpers) lives in `lib/core/` without app imports, so it can move to the shared core repo when Notes starts on Nov 2
- [ ] Strict lints (unawaited futures, declared return types, single quotes, const where possible)
- [ ] Inject the storage layer and every device service into the state layer, so tests use an in-memory database and no-op fakes: camera scanner, image decoder, permissions, ads, consent, billing, crash reports, clipboard, file picker and share, Custom Tabs and intents, Wi-Fi
- [ ] Migration scaffold: an ordered list of schema steps run on upgrade, with a test that upgrades the oldest schema
- [ ] Reliable writes: write first, then change state; on failure roll back and show an error
- [ ] Schema step 1 (REC-1–REC-4, DATA-1–DATA-8, DATE-1–DATE-3, DEL-1):
  - the records table with every field in "Roadmap impact" of `docs/PRODUCT_RULES.md`
  - the batch staging table
  - stores for settings, consent, Pro ownership and success counts
  - v1 fields included, so no migration touches testers' data
- [ ] Localization scaffolding: English and Arabic message files, locale-formatted dates and numbers, and right-to-left layout from the start (LANG-1–LANG-3, LANG-5), with the CI message check
- [ ] Themes: system, light and dark with dynamic colour (SET-1 theme engine, `dynamic_color` 1.9.0), edge-to-edge insets, predictive back
- [ ] Test harnesses: icon labels (A11Y-1), touch targets (A11Y-2), every language at 2.0× text (A11Y-4, LANG-6). Contrast in both themes (A11Y-5) and no colour-only states (A11Y-6) go into every screen PR's checklist.
- [ ] Tests: model round-trip, migration upgrade, duplicate matching (DATA-4), the sensitive-field flag (DATA-5)
- [x] Platform decision: Android only in v1; iOS deferred (2026-09-14)

## Phase 2a: Closed-test build (Sep 28 – Oct 9)
In dependency order, one theme per PR. Everything else in Phase 2 arrives during the test.
- [ ] **Scanner and permissions:** RUN-1–RUN-7, SCAN-1–SCAN-7, SCAN-9, SCAN-11–SCAN-13, A11Y-3. SCAN-2 and SCAN-3's numbers stay provisional until S6.
- [ ] **Result screens and parsers:** RES-1–RES-4, RES-6, RES-7, RES-9, RES-13, RES-14. Each payload parser is pure Dart with its own tests.
- [ ] **Link safety:** LINK-1–LINK-5, LINK-8, LINK-9 (LINK-2 bolds the full host until S11), and the one-time link callout RUN-8, so every tester sees it on their first link
- [ ] **History and delete:** HIS-1 (segments), HIS-3–HIS-5, HIS-7, HIS-11, DEL-2, DEL-4
- [ ] **Generator and save:**
  - GEN-1, GEN-3, GEN-5, GEN-6 (closed-test fields), GEN-7, GEN-8, GEN-12, GEN-13 (every created code is saved until HIS-8's switch ships in 2b)
  - STY-1, STY-5 (if S2 fails, STY-5 moves to v1 and the listing doesn't claim a scan check)
  - SAVE-1, SAVE-2, SAVE-4, SAVE-5
- [ ] **Ads, consent, Pro, crash reports, settings:** ADS-1–ADS-8, PRO-1–PRO-7, PRIV-1–PRIV-8, SET-1 (Settings row), SET-2, SET-3, SET-5–SET-8, with spike S14 (no Firebase traffic before opt-in). Testing builds use Google's test ad units.
- [ ] Internal-testing AAB uploaded by hand by Oct 2. The first upload can't go through the API, and the `remove_ads` product needs an uploaded build with the billing permission.
- [ ] Right after that upload: the `remove_ads` product at US$1.99 and license testers (PRO-1, PRO-3), so the Pro PR is driven with a test purchase before Oct 9
- [ ] Spikes S5 (Wi-Fi join) and S6 (cold start to first scan) on real phones, Sep 28 – Oct 2; S12 (share-target permissions) before Oct 19

## Phase 2b: v1 during the closed test (Oct 19–30)
Shipped to the closed track as updates; the testers' 14-day clock keeps running.
- [ ] **Languages** (LANG-7): French, Spanish, German, Portuguese (Brazil), Hindi, Indonesian, Russian, Turkish. First, so every later PR translates as it goes.
- [ ] **Scan modes and entry points:** SCAN-8, SCAN-10, SCAN-14 with HIS-6, ENTRY-1, ENTRY-2 (only if S12 passes)
- [ ] **More results:** RES-5 (only if S5 passes; otherwise RES-4's flow stays), RES-8, RES-10, RES-11, SET-4
- [ ] **Link safety, extended:** LINK-2's registrable domain (S11), LINK-6 with its bundled tables and credits, LINK-7 with its data-safety update (PRIV-6)
- [ ] **History, organised:** HIS-1 type chips, HIS-2 with LANG-4, HIS-8 with DATA-6, HIS-9, HIS-10 with DEL-3, DEL-5, DEL-6
- [ ] **Generator, complete:** GEN-2 (barcode PNGs as S13 found), GEN-4, GEN-6 (v1 fields), GEN-9–GEN-11, GEN-14, GEN-15, STY-2–STY-4, SAVE-3, SAVE-6
- [ ] **Export and backup:** EXP-1–EXP-6, then BAK-1–BAK-7 (decided 2026-09-16: v1), after the last schema step, so the format covers every field

## Phase 3: Store readiness (Oct 1–9)
Play needs most of this before the closed-test release can be reviewed, so it overlaps Phase 2a.
- [ ] Display name "QR Scanner + Generator" in the launcher; store title chosen (30 characters at most, no competitor names)
- [ ] Launcher icons and splash screen, generated from one committed source (`docs/STACK_NOTES.md`)
- [ ] Store IDs, permanent after the first upload and free of personal names: `com.oasisforge.qrscanner`
- [ ] Privacy policy published on Pages, linked from Settings (SET-6) and Play, and updated for every feature that touches user data (PRIV-6)
- [ ] The release build declares only the permissions the listing admits to (RUN-2). Fill `ALLOWED` in `release.yml` with the camera, internet, network state, billing, the ad ID, and those the ads SDK adds, checked with `aapt2`.
- [ ] Play app content: data safety, ads declaration, content rating, target audience 13+, app access (no login)
- [ ] Store listing in English and Arabic: short and full description, icon, feature graphic, phone screenshots
- [ ] `app-ads.txt` published at the root of the developer website on the listing (`docs/RELEASING.md`)
- [ ] Closed-test release submitted by Oct 9, since a new account's first review can take days

## Phase 4: Before release (Oct 26–30)
Late checks. The review prompt comes last, so it asks about finished features.
- [ ] Review prompt (SET-9)
- [ ] Scan-reliability pass on real phones: confirm GEN-12's 80% meter, STY-3's 20% logo cap, and SCAN-2 and SCAN-3's budgets from S6. Amend the rules if a number changes.
- [ ] Pre-launch report read for every closed-track upload; crashes and accessibility findings fixed or listed under Known bugs
- [ ] Listing translated into all ten languages (LANG-7); data safety and policy checked against the final manifest (PRIV-6)

## Phase 5: Release (Nov 2–13)
- [ ] Finish the one-time setup in `docs/RELEASING.md`: the Play service account and `PLAY_SERVICE_ACCOUNT_JSON`, so releases upload to Play automatically (uploads by hand work until then).
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
None yet: no app code exists.
