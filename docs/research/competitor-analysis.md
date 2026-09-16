# Competitor analysis: "QR Scanner: Barcode Scanner" by Simple Design Ltd. (Android)

_Researched 15 September 2026. App: `qrcodereader.barcodescanner.scan.qrscanner`, version 2.7.6 (versionCode 71, targetSdk 36). On the launcher it's called "QR Code Reader and Scanner - QR Scanner"._

**How:** installed from Google Play on the `Medium_Phone` emulator (Android 17) and used with made-up data in five research sessions: first run and settings, generator, scanner, history and integration, and a follow-up on open questions. Codes were fed in as images through the system photo picker. We also read the Play listing, the data-safety page and public reviews, and compared category leaders and official QR-phishing guidance (FTC, FBI IC3, UK NCSC). Everything below is described in our own words; nothing from the app (assets, text, code) was copied.

**Not explored:**
- **Live camera scanning.** The emulator camera shows a virtual room, so every code was scanned from an image.
- **Real ad load.** Only the ad network's test ads were served. No interstitial or app-open ad appeared, and the review complaint about ads covering the viewfinder couldn't be reproduced in 2.7.6: not verified either way.
- **Camera permission refused.** The "Don't allow" and "Only this time" paths weren't reached.
- **Product lookups.** Where "Shop now" and "Web search" lead wasn't checked; both open external sites.
- **Pro contents.** Whether "Remove ads" unlocks anything else is unknown; nothing was bought.
- **Network traffic.** Whether scanned content leaves the device would need traffic inspection.
- **Coverage gaps.** The share target was confirmed from the manifest only. Four of the 18 creation forms were opened (Website, Wi-Fi, Contacts, Text).

## At a glance

| Area | Simple Design QR Scanner | QR Scanner + Generator today | Our plan |
|---|---|---|---|
| Account / sign-in | None | Not built yet (v0.1.0 is docs and tooling) | None |
| Ads & tracking | A native ad under the tab bar on every main screen, and a large native ad directly below the actions on every result and created-code screen. Its green "VIEW NOW" button looks like the app's own buttons. Ad ID, attribution and topics permissions. Data safety declares device IDs, app interactions, crash logs and diagnostics collected, nothing shared | — | No ad on the scanner, any result, or the generator editor and preview. Ads only where the rules allow, visibly separate from controls, after consent. Crash reports only with consent |
| Price | Free. One-time "Remove ads" for AED 11.99 (about US$3.26), straight to the Play purchase sheet, with a "Save 50%" badge and no reference price | — | Free core job. One-time Pro removes ads. No subscription, no fake discount |
| First run | Straight into the system camera prompt with no reason given, then one tips dialog | — | A short reason before the prompt; scanning from an image still works if the camera is refused |
| Scanning | Auto-detect, photo picker import, torch, zoom slider plus pinch, typing a barcode number. No batch mode, no front camera. An image with two codes silently returns one | — | Match the basics; let the user pick when several codes are found; batch mode with duplicate counts; light-on-dark codes; share target and launcher shortcuts |
| Results | Full decoded text, type-specific actions, nothing opens by itself, auto-copy opt-in (off). The Wi-Fi password is shown unmasked; "Connect" only opens system Wi-Fi settings | — | The largest button is the real action; the Wi-Fi password is masked; joining happens in-app where the platform allows, with a copy-password fallback |
| Link safety | None. A look-alike domain gets a plain one-tap "Open browser". A link with `user@` and an IP-address host was misfiled as plain text | — | Every link opens only from a sheet that shows the full address with the domain emphasised and on-device warnings (IP host, `user@`, look-alike or punycode host, shortener, http); dangerous schemes can't be opened |
| Generator | 18 QR content types in plain forms; black-on-white JPG only, fixed size; no barcodes, styling or editing; the contact form has three fields and the phone field strips "+" | — | QR and 1D/2D barcodes with validation, styling that's checked to scan, PNG/SVG/PDF, editable codes |
| History | Scan and Create tabs, newest first, duplicates merged into one row. No dates, search, filters, favourites, notes, export, backup, or switch to stop saving. Delete: long-press multi-select, a confirmation, no undo | — | Dates, search, filters, favourites and notes; undo and trash; CSV export; backup and restore; history can be turned off |
| Languages | About 24 in-app languages; Arabic mirrors the whole app well, except the ads | — | Follow the device language; full right-to-left support |
| Appearance & accessibility | Light theme only; several icon-only buttons have no screen-reader label | — | System, light and dark themes with dynamic colour; every control labelled |
| System integration | Share target only: no launcher shortcuts, Quick Settings tile, widget or text-selection action | — | Share target and launcher shortcuts in v1; a tile only if spike S4 passes; no widget (Flutter only) |

## What they do well (worth matching)
- **The scanner stays out of the way:** the camera fills the screen, three labelled shortcuts sit at the top, and a visible zoom slider complements pinch, so zoom is discoverable.
- **Nothing happens by itself:** every result waits for a tap, and copying to the clipboard is opt-in and off by default.
- **Full content on results:** the decoded text is never truncated, so people can inspect it.
- **Duplicates merge:** scanning the same content again moves the existing history row to the top instead of adding another.
- **Useful failure state:** an image without a code gets a clear message, a hint, and Retry.
- **Manual entry:** a barcode number can be typed when a code won't scan.
- **Tidy settings:** grouped cards, tall rows, one accent colour.
- **Right-to-left done properly:** in Arabic, tabs, icon rows, list rows, chevrons and the zoom slider all mirror, and URLs stay left to right.
- **Simple ad removal:** a one-time purchase with no trial or subscription trap.
- **Structured feedback:** the in-app feedback form has categories (scanning not working, too many ads...).

## Weak spots (our opening)
1. **Ads crowd the work:** on every result screen an ad sits directly under the real actions, and its call-to-action matches the app's own button style. A banner under the tab bar shifted as it loaded and turned a tap aimed at the History tab into an ad click. Reviews also describe ads over the viewfinder and an ad "Open" button bigger than the real one (not seen in 2.7.6's test ads).
2. **No link safety:** a convincing look-alike domain gets a plain one-tap Open with no warning, and the host isn't emphasised. A link hiding an IP address behind `user@` wasn't even recognised as a link. Official guidance (FTC, FBI IC3, NCSC) says people should see where a code leads before it opens.
3. **A bare generator:** no barcodes (the app scans them but can't make them), no colours, logo or frame, JPG only at a fixed size, codes can't be edited, the contact code carries only name, phone and email, and the phone field strips the "+" so international numbers can't be entered.
4. **Multiple codes are guessed:** an image with two codes silently returns one, and there's no batch mode for scanning many codes in a row.
5. **History can't be managed:** no dates, search, filters, favourites or notes; no export or backup, so a new phone loses everything; saving can't be turned off; delete has no undo or trash; swiping a row switches tabs instead.
6. **Secrets on show:** Wi-Fi passwords appear unmasked on scan results, and there's no app lock.
7. **Trust gaps:**
   - The listing claims only the camera permission is needed, but the build also declares ad, attribution, foreground-service and local-network permissions.
   - The camera is requested with no explanation.
   - The "Save 50%" badge has no reference price.
8. **Product barcodes lead nowhere:** no product details, only "Shop now" and "Web search" hand-offs, introduced by a popup that warns lookups may not work.
9. **"Connect to Wi-Fi" doesn't connect:** it opens system Wi-Fi settings, and the user retypes the password.
10. **Visual and accessibility basics:** light theme only; back, close, delete, share and select-all buttons have no screen-reader labels.

## Beyond this competitor
- **Table stakes across the category** (Gamma Play, TeaCapps and others):
  - automatic scanning and broad format support
  - structured actions and scan from gallery
  - torch, pinch zoom, history, and QR generation
- **Praised extras:** CSV export, batch scanning, a link check before opening, and Wi-Fi join.
- **Category-wide complaints:**
  - ads next to results that lead to accidental clicks, some ending in fraudulent charges
  - ads before every scan
  - trial-to-subscription traps
  - permissions unrelated to scanning
  - scanner apps turned malicious by an update
  - light-on-dark codes that won't scan
  - links opened before the address is shown
- **Built-in scanners** (Android's Quick Settings tile, Google Lens, Circle to Search) cover the quick scan but not generation, history, batch scanning or export.

## Positioning
**"See where every code leads, with nothing in your way":** no ad in the scanner, results or editor (principle 1); every link shown and checked on the device before it opens (principle 2); a generator and history that do the whole job for free (principle 3), with data that stays on the phone unless you share or export it (principle 4).

## Roadmap impact
- **Link safety is core:** the confirm-before-open sheet and the offline warnings ship in the closed-test build, not as a later add-on; they're the clearest gap.
- **Ad placement rules come first:** they're written and tested before any ad code, and the result-screen layout is designed without an ad slot.
- **The history data model lands in Phase 1,** before any record exists: timestamps, source, duplicate count, favourite, note and soft delete.
- **Export and backup follow the last schema step:** CSV export and backup and restore come after it.
- **The generator is one feature item:** barcode generation, validation, a scan check and PNG/SVG/PDF export belong to it, not to "later".
- **Entry points:** share target and launcher shortcuts are v1; the Quick Settings tile waits for spike S4.
- **Built into every screen:** dark theme, right-to-left and screen-reader labels are part of each screen's definition of done, not a late pass.
- **Real phones are still needed:**
  - live camera scanning and the permission-refused flow
  - Wi-Fi join (spike S5)
  - cold start to first scan (spike S6)
