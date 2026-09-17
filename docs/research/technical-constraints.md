# Technical constraints: Flutter only, Android

_Researched 14 September 2026 (a 15-agent workflow over pub.dev, plugin issue trackers, Android and Play documentation, each topic adversarially verified); digested 15 September 2026._

Every rule in `docs/PRODUCT_RULES.md` has to be buildable within these limits. Versions are what was current on 14 September 2026: check pub.dev again before pinning. When a rule needs something listed here as a constraint, the rule changes or a spike decides.

## Hard limits (the user's decisions, 2026-09-14)

- **Flutter only.** No hand-written Kotlin or Java; plugins bring their own native code. CI's Flutter-only guard enforces it.
- **No home-screen widget.** An `AppWidgetProvider` has to be app code, and no plugin avoids that.
- **No backend in v1.** So no dynamic (editable, trackable) QR codes, and no online link reputation: Web Risk needs a server-held key, and Safe Browsing (v4 and v5) and the VirusTotal public API are non-commercial only, which rules them out for an app with ads.
- **iOS is deferred.** Nothing here is shaped by iOS.

## By area

### Scanning
- `mobile_scanner` 7.4.2: live detection stream, the common 1D/2D formats (on Android the bundled ML Kit reads QR, Data Matrix, PDF417, Aztec, Code 128/39/93, Codabar, ITF, EAN-13/8 and UPC-A/E; the plugin also lists Micro QR, DataBar and MaxiCode, which SCAN-9 doesn't promise), torch, zoom, lens switch, pause/resume, scan window, auto-zoom, `returnImage`, and `analyzeImage(path)` for images.
- Use the **bundled** ML Kit model (one `gradle.properties` flag). The Play-services model downloads on first use and returns nothing until it has.
- Light-on-dark codes need `invertImage`; ML Kit doesn't read inverted codes by itself.
- Weak spots: dense multi-code grids and very small codes (issue #1364). `flutter_zxing` 3.0.1 (FFI, no Kotlin) is the fallback decoder for images ML Kit misses.
- `analyzeImage` has had platform bugs (PNG rejection on Android, #665). S2 (2026-09-16) found none on API 37: PNG, JPEG, an inverted code and a phone-sized screenshot all decoded (see Spike results).
- The torch toggle silently does nothing on devices without a torch. Pinch-to-zoom is wired by the app (`setZoomScale`). Haptics come from Flutter's built-in `HapticFeedback`; no plugin needed.
- The emulator's back camera is a virtual scene. Codes are fed through Extended Controls → Camera → virtual scene images, by hand only.

### Results and actions
- Payload parsers: pure Dart for `WIFI:`, `MECARD:`, `tel:`, `sms:`, `mailto:`, `geo:`, UPI and EPC; `vcard_dart` 2.1.0 for vCard; `enough_icalendar` 0.17.0 for events; `gs1_barcode_parser` 1.1.2 for GS1-128. GS1 Digital Link needs a small custom parser.
- Links open in Custom Tabs with `flutter_custom_tabs` 2.6.0.
- Save a contact or event with `android_intent_plus` 6.1.0 `ACTION_INSERT`: the system app does the write, so the app needs no contacts or calendar permission. That also keeps the app outside Play's April 2026 contacts policy.
- Wi-Fi join uses `wifi_iot` 0.4.0. There's no Flutter-only path to Android's "Add this network" system sheet. A joined network may not persist or route internet without `registerNetwork` (a system approval dialog); WEP always fails on API 29+. Check which permissions the plugin adds (RUN-2). Real phone only.

### Link safety, on the device
- Dart's `Uri` covers an IP-address host, userinfo (`user@host`), and dangerous schemes (`javascript:`, `data:`, `intent:`, `file:`). Classify the parsed `Uri`; never match raw strings.
- Look-alike (homograph) detection needs a table built from Unicode's `confusables.txt` (Unicode licence, attribution). No Dart package exists. Showing punycode hosts decoded needs a decoder too (none verified yet).
- Link-shortener domains: the best list found (`PeterDaveHello/url-shorteners`) is CC BY-SA 4.0, so the list needs attribution and share-alike.
- Following redirects ("where does this link go") works with `http` 1.6.0 or `dio` 5.11.1 with auto-redirect off, a hop cap and timeouts. Every hop's server sees the device's IP address, so it must be opt-in and declared in the data-safety form.

### Generator
- `pretty_qr_code` 3.6.0: module shapes, gradients, embedded logo, quiet zone, error-correction level, PNG export. It has no SVG export.
- `barcode` 2.2.9: SVG for QR and every 1D/2D format in scope (Code 39/93/128, GS1-128, ITF, EAN/UPC, Codabar, ISBN, PDF417, Data Matrix, Aztec). `barcode_widget` 2.0.4 is fine for on-screen previews only (no release in about 3 years).
- A styled SVG therefore goes through a second renderer and can differ from the styled PNG; plain SVG is safe.
- `barcode` has no raster export, so a PNG of a 1D barcode means drawing its bar elements on a Flutter canvas (pure Dart) or using `barcode_image`; spike S13 confirms which.
- No research defined when styling breaks scanning (logo size, colours, error correction). Our rules set the limits, and the rendered image is decoded before export to prove them.
- Large payloads (an event, a long vCard) make dense codes that are hard to scan small; not measured yet.

### Export and printing
- `share_plus` 13.3.0 for the share sheet; `flutter_file_dialog` 3.3.2 saves through the system file picker, so no storage permission.
- `pdf` 3.13.0 + `printing` 5.15.0 for PDFs and label sheets. No label-template package exists, so label grids are hand-coded.
- `csv` 8.0.0 for CSV.
- XLSX is a later decision: `excel` 4.0.6 is free but unreleased for about 2 years; `syncfusion_flutter_xlsio` 34.2.7 is maintained but needs a Community Licence with revenue and team-size caps.
- Licences checked 2026-09-16 (S7): all permissive except `enough_icalendar` (MPL-2.0, fine unmodified). See Spike results.

### History and data
- The kit's proven setup is `sqflite` with an ordered list of migration steps (`docs/STACK_NOTES.md`); the earlier plan named `drift` 2.35.0. Neither was researched for QR specifically.
- Picking an image uses the system photo picker. Play has required it for occasional photo access since 28 May 2025, so no `READ_MEDIA_IMAGES`.

### Entry points
- Launcher shortcuts: `quick_actions` 1.1.1, pure Dart, maintained. The v1 fast-access path.
- Share target (scan a shared image): `receive_sharing_intent` 1.9.0 (manifest-only; it adds a storage permission line to check against RUN-2) or `share_handler`, which is better maintained. Evaluate both.
- Quick Settings tile: `quick_settings_with_flutter_plugins` 1.3.1 keeps the tile service inside the plugin, but it's thinly maintained and nobody has built it against compileSdk 36 (spike S4). Android 13+ already has a system "Scan QR code" tile, which opens the phone's own scanner, not this app.
- Clipboard: Android 12+ shows a toast whenever an app reads the clipboard, so reading happens only on an explicit tap. Pasting an image needs `super_clipboard`, 15 months without a release: re-verify first.
- The text-selection menu (`ACTION_PROCESS_TEXT`) wasn't researched for QR.

### Ads, Pro, consent, crash reports
- `google_mobile_ads` 9.1.0 (Mobile Ads SDK 25.4.0, UMP 4.0.0); `in_app_purchase` 3.3.0 with `in_app_purchase_android` 0.5.3 (Play Billing Library 8.0.0).
- `firebase_crashlytics` 5.4.0, off until the user turns it on (PRIV-3). No `firebase_analytics`: no analytics SDK ships.
- A Google-certified consent platform (UMP) is required for the EEA and UK since 16 January 2024 and Switzerland since 31 July 2024; without it ads are limited.
- AdMob forbids ads next to interactive controls, and our principles keep ads out of the working area entirely.
- One-time "remove ads" prices in the category cluster around US$3–7 (medium confidence). The competitor charges AED 11.99 (about US$3.26).
- Ship the consent and purchase flows in the closed-test build, so testers exercise them before production.

### Platform UI
- Predictive back: manifest flag plus `PopScope`. The flag without `PopScope` can swallow back events (flutter/flutter#135815): test every screen.
- Edge-to-edge is on by default from targetSdk 35: every screen needs an insets pass.
- `dynamic_color` stays on 1.9.0 (2.x breaks `ThemeData`).

## Play policy checklist

| Topic | Requirement |
|---|---|
| Target API | API 36 for new apps and updates (deadline 31 Aug 2026, extension to 1 Nov 2026). Flutter 3.44 defaults to 36. |
| 16 KB pages | Native libraries must be 16 KB aligned (`mobile_scanner` fixed in 7.0.1). Check App Bundle Explorer for every release. |
| Billing | Play Billing Library 8+ from 31 Aug 2026 (extension to 1 Nov 2026). |
| Closed test | Personal account: 12+ testers opted in for 14 continuous days before applying for production; a tester who leaves restarts their own count. The decision takes about 1–3 business days (up to 7), then up to about 7 days of review. |
| Pre-launch report | Runs on every testing-track upload; read it before applying for production. |
| Consent | UMP for EEA, UK, Switzerland (above). |
| Data safety | AdMob: collected and shared (IP address, device and app-set IDs, interactions, diagnostics). On-device scanning sends no code content anywhere. Any off-device lookup (redirects, product data) is collection and most likely sharing. Inaccurate answers risk blocked updates or removal. |
| Target audience | 13+, not child-directed (the Families policy restricts ads). |
| Permissions | Camera isn't restricted: explain it before asking. No `MANAGE_EXTERNAL_STORAGE`, no `QUERY_ALL_PACKAGES`, no `READ_MEDIA_IMAGES` for occasional picks. |
| Clipboard | Read only on an explicit user action (toast on Android 12+). |
| App access | No login: "all functionality is available without special access". |
| Listing | Title ≤ 30 characters, short description ≤ 80, full ≤ 4,000; no keyword stuffing, no competitor brand names. Icon 512×512 PNG, feature graphic 1024×500, 2–8 phone screenshots. |

## Spikes

Run each before the feature that depends on it.

| # | Question | Blocks |
|---|---|---|
| S1 | Does `mobile_scanner` scan the emulator's virtual-scene codes reliably enough for hand-driving? | the scanner PR |
| S2 | Does `analyzeImage` decode PNG, JPEG and screenshots on API 36/37? | scan from image, generator self-check, tests |
| S3 | Does `flutter_zxing`'s FFI build work from the OneDrive path? | the image fallback decoder |
| S4 | Does the Quick Settings tile plugin build against compileSdk 36 and survive a release build? | the optional tile |
| S5 | Does `wifi_iot` join and keep a WPA2/WPA3 network on a real phone, and which permissions does it add? | Wi-Fi join |
| S6 | Cold start to first scan on two or three low/mid-range Android 14–16 phones | the speed rules |
| S7 | Licence check of every pinned package | release |
| S8 | Does `permission_handler` (or an equivalent) tell "denied" from "permanently denied" for the camera on API 36/37, without Kotlin? | the scanner PR (RUN-4 to RUN-6) |
| S9 | Do `local_auth` (needs `FlutterFragmentActivity`, which the guard allows) and a recent-apps preview-hiding plugin build Flutter-only against compileSdk 36 and survive predictive back? | app lock (LOCK-1 to LOCK-3) |
| S10 | Which location package, permission text and data-safety answer does "Use current location" need? | GEN-16 |
| S11 | Is there a Flutter-only Public Suffix List source (a package, or a bundled asset with an acceptable licence) for registrable-domain emphasis? | LINK-2's registrable domain |
| S12 | Which permissions does the share-target plugin add, and do shared images still arrive once every storage or media permission is removed in the manifest? | ENTRY-2 |
| S13 | Do barcodes (EAN, UPC, Code 128, Code 39) render to a sharp PNG Flutter-only, by drawing the `barcode` package's elements or with `barcode_image`? | GEN-2's barcodes, SAVE-2 |
| S14 | With Crashlytics collection disabled in the manifest, is there any Firebase network traffic (installation IDs included) before the user turns crash reports on? | PRIV-3, PRIV-5 |

S8–S14 were added on 16 September 2026, when the product rules were written and reviewed.

## Spike results

Run 16 September 2026 on Flutter 3.47.4 / Dart 3.13.3, the `Medium_Phone` emulator (API 37), with a throwaway app built from a OneDrive path with spaces.

**S1, virtual-scene scanning: yes, within a distance band.** `mobile_scanner` 7.4.2 streams the emulator's virtual scene and decoded a QR poster in **194–212 ms** once it was framed (checked again 2026-09-17). Load codes with `emulator -virtualscene-poster wall=<png> -virtualscene-poster table=<png>`, using a path **without spaces**; the emulator log prints `Found poster wall at <path>`. The poster is a 2 m square on a wall at (-0.807, 0.320, 5.316) facing -150°, so it is never in view from the scene's start pose.
- Distance from a 2 m poster: 1.5 m decoded in 2.1 s (the code overflows the frame), 2.0 m and 2.5 m in about 0.2 s, and 3 m and beyond never decoded at any heading, because the scene's own texture is too soft by then. So frame a code at roughly one poster-width away.
- Move the camera exactly with the emulator's gRPC port, not the mouse: mouse drags mix yaw and pitch and drift (`docs/STACK_NOTES.md` → Device drill). `adb emu sensor set` does not move it, and `adb emu virtualscene-image` is accepted but the running camera keeps the old image.
- The emulator is fine for driving scan screens by hand. Real reliability numbers still come from S6 on real phones.

**S2, `analyzeImage` on API 37: yes.** Bundled ML Kit decoded every test image from a file path: a QR code as PNG (313 ms on the first call, which loads the model), as JPEG at quality 80 (131 ms), as a light-on-dark PNG (125 ms, so `invertImage` isn't needed for still images), a 360 px QR code inside a 1080×2400 screenshot-style PNG (89 ms), and an EAN-13 (87 ms). `analyzeImage` works on a controller that was never started.

**S3, `flutter_zxing` 3.0.1 FFI from the OneDrive path: yes.** The debug APK built with no path workaround, and `readBarcodeImagePathString` with `tryInverted` and `tryHarder` decoded the same five images in 28–135 ms.

**S7, versions and licences: done.** Nothing listed above changed since 14 September. All licences are permissive (MIT, BSD, Apache-2.0) except `enough_icalendar` (MPL-2.0: fine as an unmodified dependency, don't edit its source). New since then: `sqflite` 2.4.4, `sqflite_common_ffi` 2.4.3, `provider` 6.1.5+1, `intl` 0.20.3, `image` 4.10.1, `permission_handler` 13.0.2, `in_app_review` 2.0.12, `firebase_core` 4.15.0, `shared_preferences` 2.5.5, `url_launcher` 6.3.2, `zxing2` 0.2.4 (pure Dart, but QR only: no 1D decoding). No release for 18+ months: `barcode` 2.2.9, `barcode_widget` 2.0.4, `barcode_image` 2.0.3. Still pre-1.0: `share_handler` 0.0.25, `super_clipboard` 0.9.1. Versions are pinned in `pubspec.yaml` as each feature adds its package.

**S8, camera permission states: yes, with one limit.** `permission_handler` 13.0.2 needs no Kotlin, but its Android side (`permission_handler_android` 14.x) requires **compileSdk 37**: set `compileSdk = 37` in `android/app/build.gradle.kts` (AGP 9.1.0 warns but builds). `targetSdk` stays 36. What it reports on API 37:

| Situation | `status` | `shouldShowRequestRationale` | `request()` returns |
|---|---|---|---|
| Never asked | denied | false | shows the dialog |
| Denied once | denied | true | shows the dialog again |
| Denied twice (Android stops asking) | denied | false | permanentlyDenied, no dialog |
| Revoked after a denial (`pm revoke`) | denied | false | not tested |
| Granted, or "Only this time" | granted | false | granted |

`status` alone can't tell "never asked" from "permanently denied". So RUN-4 to RUN-6 need a stored "asked before" flag, or they call `request()` and read its result. `openAppSettings()` covers the Settings route.

**S11, Public Suffix List: bundle it.** No usable package: `public_suffix` 3.0.0 (2021) requires Dart below 3.0 and doesn't resolve, and `tldts` is a single 0.0.1 beta. Bundle `public_suffix_list.dat` (about 330 KB, MPL-2.0: keep its header, don't edit it) as an asset, with a small pure-Dart matcher for the `*` wildcard and `!` exception rules, ICANN section only, on the punycode host. Refresh the file as a data-only change.

**S13, sharp barcode PNGs Flutter-only: yes, both ways.** EAN-13, UPC-A, Code 128 and Code 39 rendered with no grey pixels and decoded back to their data. The key is integer module widths: `Barcode1D` gives the module count (EAN-13 and UPC-A 95, Code 39 13 per character), so call `make()` with `width = modules × pixels per module` and every bar lands on whole pixels. Neither approach adds a quiet zone: draw it yourself. `barcode` computes the EAN/UPC check digit and adds Code 39's `*`. With `drawText: true`, the text height comes out of the `height` you pass.
- Drawing `barcode`'s elements on a `dart:ui` canvas: exact quiet zones on both sides. Human-readable text needs a separate `TextPainter` pass. **Use this.**
- `barcode_image` 2.0.3: every bar comes out 1 px wider on its right, because `fillRect` corners are inclusive, so the right quiet zone loses 1 px. It still decodes at 3 px per module, and it can draw text with `image`'s bitmap fonts.


## Not researched yet

These came up while writing the rules. Check pub.dev (maintenance, licence, the permissions they add) before relying on them.
- `in_app_review` for the review prompt (SET-9).
- `local_auth` and a recent-apps preview-hiding plugin for app lock (S9).
- A location package such as `geolocator` (S10).
- Whether `pretty_qr_code` 3.6.0 shapes the finder "eyes" independently of the other modules (STY-4).
