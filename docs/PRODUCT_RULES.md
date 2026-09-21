# Product rules

_15–16 September 2026._

This file defines how QR Scanner + Generator behaves: the defaults, limits, orders and edge cases behind each screen. Each section says what the competitor does (see `docs/research/competitor-analysis.md`), what we take from it, and our rule. We learn from their app; we don't copy its rules. What's buildable is in `docs/research/technical-constraints.md`; which release each rule ships in is in `docs/ROADMAP.md`.

- Rule IDs (`SCAN-3`) are stable: never renumber or reuse one. A dropped rule stays, struck through, with its date and reason. Tests, code comments, PRs, and roadmap items reference them.
- A rule is testable: a number, a default, an order, an edge case. "Scanning is fast" isn't a rule; "the live preview appears within 1.5 s of a cold start" is.
- "Not verified" marks competitor behavior we saw only partly.
- Every rule keeps the product principles in `CLAUDE.md`: no ad in the working area (viewfinder, scan result, generator editor), and the largest button is always the real action; nothing opens before the user has seen where it leads; the free app does the whole core job, and Pro is a one-time purchase that removes ads, never a subscription; no account, and scans, codes and history leave the device only when the user shares or exports them; ads and crash reports run only as far as the user's consent allows.

## Section shape

`/spec <area>` writes a section in this shape:

> ## N. Area
>
> **They do:** what the competitor does, in our words. Parts we couldn't check: not verified.
>
> **Learn:** the user need behind it, and where they fall short.
>
> - **AREA-1** Our rule.

## 1. Data foundations

**They do:** No IDs or dates show anywhere. Scanning the same content again moves the existing history row to the top instead of adding one. Type labels follow the in-app language. Deleting is immediate and final. A Wi-Fi password is masked on the create form but shown in plain text on the scan result for the same network.

**Learn:** Undo, trash, search, export, backup and translation all depend on IDs, timestamps and flags that exist before the first record is written. Whether a field is sensitive belongs to the data, not to each screen.

~~MONEY-1~~ Dropped 15 September 2026: the app stores no money amounts.

- **REC-1** Every record has `created_at` and `updated_at`, set when it's written.
- **REC-2** Every record ID is a UUID v4, so records from a backup never collide.
- **REC-3** A scanned record's content (`payload`, `symbology`, `parsed_type`, `source`) never changes. A created code's content and style change only by editing it (GEN-14). The other fields that can change are `favourite`, `label`, `deleted_at`, `last_seen_at` and `duplicate_count`, and every change, a duplicate scan included, updates `updated_at` in the same write.
- **REC-4** Undo (DEL-2) and restore from Trash (DEL-5) clear `deleted_at` and update `updated_at`.
- **DATA-1** Types (`url`, `wifi`, `product`...) and sources are stored as fixed IDs and shown as translated labels, so a language change relabels every record.
- **DATA-2** A record stores the payload as UTF-8 text, plus the raw bytes when they aren't valid UTF-8; the symbology; the parsed type; and the source: `camera`, `image`, `shared_image`, `manual` or `created`.
- **DATA-3** The app never stores a camera frame or an imported image, only the decoded payload. A created code stores its content fields and style settings, not a rendered image, and is redrawn on demand.
- **DATA-4** Two records are duplicates when both are scans, or both are created codes, and their symbology and raw payload match exactly. A duplicate of a live record updates that record's `last_seen_at` and `duplicate_count` and never its `source` or `created_at`. A payload that matches only a deleted record creates a new record. Codes in a saved batch (SCAN-14) are matched only within that batch: a batch keeps every code it counted, and single scans and batch codes never merge with each other.
- **DATA-5** Sensitive fields (a Wi-Fi password today) are flagged in the schema, and every surface reads the flag: list rows and share previews mask them (HIS-7), search skips them (HIS-2), export hides them by default (EXP-4). Backups keep them (BAK-2).
- **DATA-6** While "Save history" is off (HIS-8), a result screen works from an unsaved in-memory record and nothing is written.
- **DATA-7** A batch session in progress (SCAN-14) is kept in a separate staging table under its session ID, written after every 5 new codes or 10 seconds, whichever comes first. Staged codes never appear in History, search, export or backup, and are hard-deleted once the session is saved or discarded.
- **DATA-8** A successful scan is one that reaches a result screen (RES-1), including Unknown (RES-13) and blocked links (LINK-5); "No code found" isn't one. A successful create is a created code's first render (GEN-13). Ads (ADS-6) and the Pro prompt (PRO-4) count these, stored on the device; the review prompt has its own trigger (SET-9).
- **DATE-1** Timestamps are stored in UTC to the second, with an insert sequence number that orders records written in the same second. Screens show local time, formatted for the app's language (LANG-3).
- **DATE-2** History date headers (Today, Yesterday, the weekday within 7 days, then the date) use local calendar days, worked out each time the list is drawn.
- **DATE-3** Dates inside a code's content, such as an event's start and end, are kept exactly as encoded (floating local time, UTC, or with a time zone) and don't shift when the device's time zone changes (RES-6, GEN-9).

## 2. First run and permissions

**They do:** The first launch goes straight to the system camera prompt with no explanation, then a tips dialog. Later launches open on the scanner with no dialogs. What happens after "Don't allow" or "Only this time": not verified.

**Learn:** A camera request with no reason costs trust before the app has earned any, and scanning a photo or typing a code doesn't need the camera at all.

- **RUN-1** Until the camera is allowed, the scanner shows a placeholder, one reason of at most 70 characters, and an "Allow camera" button, the largest control, which opens the system prompt. No splash, setup page or walkthrough comes first.
- **RUN-2** The release build declares no permission a shipped feature doesn't need, so the data-safety answers stay true. The release workflow fails on any other permission.
- **RUN-3** A permission is requested only when the feature that needs it is first used. The camera is the only one requested on first launch, and only from RUN-1's button.
- **RUN-4** After "Don't allow", the scanner keeps RUN-1's placeholder, reason and button, plus "Scan a photo" (SCAN-11) and "Type a code" (SCAN-12), always visible.
- **RUN-5** After "Only this time", the next launch that needs the camera shows RUN-1 again, with no extra dialog of our own.
- **RUN-6** When Android won't show its prompt any more (denied twice, or "Don't ask again"), the button becomes "Open settings" and opens the app's permission page (spike S8).
- **RUN-7** Once the camera is allowed, every launch goes straight to the live scanner within SCAN-2's budget: no dialogs, tips or prompts.
- **RUN-8** No walkthrough. The first link result ever shown carries a one-time callout about the link check (LINK-3); one tap dismisses it for good.

## 3. Scanner

**They do:** The app opens on a full-screen scanner: a framed target with an animated band and rotating hints, gallery, torch and typed-entry shortcuts along the top, and a zoom slider plus pinch at the bottom. Back camera only. Vibration is on and sound off by default. Speed, low light and phones without a flash: not verified (the emulator camera is virtual).

**Learn:** The visible zoom slider and quiet defaults are worth matching. Low light, light-on-dark codes and slow starts cause many failed scans across the category, so ours get numbers.

- **SCAN-1** The app opens on the live scanner. A bottom navigation bar leads to Scan, Create, History and Settings.
- **SCAN-2** Cold start to a live camera preview takes at most 1.5 s on the reference phone. Provisional until spike S6.
- **SCAN-3** From a readable code in the target: a haptic within 150 ms and the result screen within 400 ms (provisional until S6). Detection pauses while the result is open. Back on the scanner, the same payload is ignored for 2 s; other codes scan normally.
- **SCAN-4** Detection is automatic, with no shutter, and limited to a square target about 70% of the screen's shorter side. Codes outside it are ignored.
- **SCAN-5** Feedback on a successful scan: vibration on, sound off (SET-2).
- **SCAN-6** The torch button appears only when the camera reports a flash. The torch turns off when the user leaves the scanner.
- **SCAN-7** Zoom: a slider, pinch, and double-tap to switch between 1× and 2×. Auto-zoom steps in, up to 2×, when a code is seen but unreadable for more than 1 s. Any manual zoom stops auto-zoom until the scanner is reopened.
- **SCAN-8** A light-on-dark code scans with no setting, within twice SCAN-3's result budget.
- **SCAN-9** Formats: QR, Data Matrix, PDF417, Aztec, Code 128, Code 39, Code 93, Codabar, ITF, EAN-13, EAN-8, UPC-A, UPC-E (the bundled ML Kit set). Micro QR, MaxiCode and DataBar aren't promised on Android. Back camera only in v1.
- **SCAN-10** If nothing decodes for 4 s and the phone has a flash, a "Try the flash" button appears under the target. It disappears when the torch turns on or a code scans.

## 4. Scan modes

**They do:** Gallery import uses the system photo picker, then asks for an extra "Scan" tap. A photo with no code gets a clear message with Retry. An image with two codes silently returned one of them. There's no batch mode. A barcode number can be typed.

**Learn:** Keep the no-code message and typed entry; drop the extra tap. Never guess between several codes: the wrong network or link misleads people. Batch scanning is a praised extra the competitor doesn't have.

- **SCAN-11** Scan from a photo: the system photo picker (no media permission), decoding as soon as a photo is picked. With no code: "No code found", one hint, and "Try another photo" and "Type a code".
- **SCAN-12** Typed entry runs the same parsers and opens the same result screen as a camera scan, with source `manual`.
- **SCAN-13** When one detection pass, camera or photo, finds two or more codes, the app pauses and lists them (type icon and the first 40 characters). The chosen code opens its result. In batch mode every code is added instead.
- **SCAN-14** Batch mode: a switch on the scanner starts continuous scanning with a running count. A code already in the session increases its own count instead of adding a row. Ending the session opens a review list where codes can be removed before "Save all" adds them to History as one batch (HIS-6). An interrupted session is recovered from staging (DATA-7) and offered for review at the next launch.

## 5. Entry points

**They do:** The app is a share target for images, confirmed from its manifest only (not verified in use). No launcher shortcuts, Quick Settings tile, widget or text-selection action.

**Learn:** Scanning is opportunistic, so every tap before the camera counts. Launcher shortcuts are cheap in Flutter; a tile is riskier; a widget isn't possible Flutter-only.

- **ENTRY-1** Launcher shortcuts "Scan" and "Create" open those screens directly, within SCAN-2's budget.
- **ENTRY-2** The app is a share target for one image at a time. A shared image decodes like SCAN-11, including the no-code message and the multi-code list (SCAN-13). Shared text and links aren't accepted. It ships only if it needs no storage or media permission, removing any the plugin adds in the manifest (spike S12, RUN-2).
- **ENTRY-3** A Quick Settings tile ships only after spike S4 passes, and must reach the live scanner within SCAN-2's budget.
- **ENTRY-4** No home-screen widget (Flutter only, 2026-09-14) and no text-selection action.

## 6. Results

**They do:** Every result shows a type label, the full decoded text, and two or three actions of equal weight. Nothing opens by itself, and copying on scan is an opt-in setting (verified). Right under the actions sits an ad whose green "VIEW NOW" button matches the app's own buttons. Wi-Fi passwords show unmasked, and "Connect to Wi-Fi" only opens system Wi-Fi settings. Product codes offer "Shop now" and "Web search", after a popup warning that product details may not appear. Contact, event, phone, message, email, location, payment and app-store codes weren't scanned: not verified.

**Learn:** People need one obvious real action, no ad anywhere near it, secrets hidden by default, and honest hand-offs instead of promises an app without a backend can't keep.

- **RES-1** A result shows, top to bottom: type and format ("Link · QR code"); the full decoded content, selectable and never truncated; one primary action as a full-width filled button at least 1.4× the height of any other control; and up to three smaller outlined actions, always including Copy and Share of the exact decoded text. No ad, upsell or Pro prompt appears anywhere on the screen (ADS-1).
- **RES-2** Nothing happens without a tap: no automatic opening, dialling, joining or sharing. Copy on scan is a setting, off by default (SET-3), and when on it copies only once the result is on screen.
- **RES-3** One result screen serves every source: camera, photo, shared image, typed entry, a pick from the multi-code list, and a History reopen.
- **RES-4** Wi-Fi shows the network name, the security type, and the password masked with a reveal button; an open network shows no password row. The primary action is "Open Wi-Fi settings", with "Copy password" beside it. A WEP network shows a line saying Android can't join WEP networks from apps.
- **RES-5** Once spike S5 passes and its permissions pass RUN-2, "Join network" becomes the primary action for WPA, WPA2, WPA3 and open networks. If the join hasn't succeeded within 6 s or fails, the screen says so and shows "Copy password" and "Open Wi-Fi settings"; nothing is copied or opened without a tap. If S5 fails, RES-5 doesn't ship and RES-4's flow stays.
- **RES-6** A contact (vCard, MeCard) shows name, phone numbers, emails and organisation exactly as encoded, a leading "+" included. An event (iCalendar) shows title, start, end, location and notes (DATE-3). The primary action, "Add to contacts" or "Add to calendar", hands off to the system app (`ACTION_INSERT`); the app requests no contacts or calendar permission.
- **RES-7** Phone, SMS and email show their fields. The primary action opens the dialer, messaging or email app prefilled, and never calls or sends.
- **RES-8** A location (`geo:`) shows its coordinates and label. "Open in maps" lets Android choose the maps app.
- **RES-9** A product code (EAN-13, EAN-8, UPC-A, UPC-E, ISBN) shows the number and format. The primary action, "Search the web", uses the search engine chosen in Settings (SET-4), which is Google until that setting ships. No shopping action, no product database, no warning popup.
- **RES-10** A payment code (UPI, EPC/SEPA) shows every field read-only, with Copy. There's no Pay button and no hand-off to a payment app.
- **RES-11** An app-store link (`play.google.com/store/apps/...`) is a Link, and every LINK rule applies. "Open in Play Store" comes before "Open in browser".
- **RES-12** GS1 (GS1-128 element strings, GS1 Digital Link) shows each application identifier (GTIN, batch, expiry, serial...) as a labelled, copyable field. A Digital Link also gets the link checks.
- **RES-13** A payload that fits no type is "Unknown": its text if valid UTF-8, otherwise "Binary data, N bytes", with only Copy and Share.
- **RES-14** When no installed app can handle an action (no dialer, maps or calendar app), that action shows disabled with a one-line reason, and Copy stays available.

## 7. Link safety

**They do:** A look-alike domain with no other tricks was offered a plain one-tap "Open browser", with no warning and no emphasis on the host (verified). A link hiding an IP address behind `user@` wasn't recognised as a link at all: it became text with Send SMS and Send email actions (verified).

**Learn:** People need to see where a link goes before it opens, and an odd-looking link must never fall back to a less careful type. Every check runs on the device; online reputation would need a backend we don't have.

- **LINK-1** A payload that isn't a more specific type (RES-4 to RES-12) is a Link when Dart's `Uri` parses it with an `http` or `https` scheme and a host (userinfo and IP hosts included), or with a blocked scheme (LINK-5). Classification never matches raw strings and never falls back to text.
- **LINK-2** A Link result shows the full URL (monospace, selectable, never truncated) and, above the primary action, the host in larger bold text. When spike S11 finds a Public Suffix List source, only the registrable domain is emphasised (`example.co.uk` in `login.example.co.uk`).
- **LINK-3** On-device checks, without network: an IP-address host; userinfo (`user@`); `http` instead of `https`; a port other than the scheme's default; more than 200 characters. With no hits, the primary action is "Open". With any hit, it's "Review", which opens the warning sheet (LINK-4).
- **LINK-4** The warning sheet lists one plain-language line per triggered check, repeats the URL and emphasised host, and offers a filled "Copy without opening" and an outlined "Open anyway" of the same size. It never closes by itself and carries no ad.
- **LINK-5** `javascript:`, `data:`, `file:`, `intent:` and `content:` links can't be opened: the result says the link type is blocked and offers Copy only.
- **LINK-6** A punycode or look-alike host (a bundled table from Unicode's `confusables.txt`) and a known link-shortener domain (a bundled list, CC BY-SA 4.0) also trigger the warning sheet. Both sources are credited on the licences page (SET-7).
- **LINK-7** "Check where this link goes" is a secondary action, never automatic. It follows redirects from the device, with at most 5 hops, 4 s per hop and 10 s in total, shows each hop and the final host, and runs LINK-3 and LINK-6 on the final URL. Before the first check in a session, one line explains that it contacts the link's servers and shows them the device's IP address. It's declared in the data-safety form (PRIV-6).
- **LINK-8** Links open in Custom Tabs, falling back to the default browser, never in an in-app WebView.
- **LINK-9** The checks run every time a link result is shown, including a History reopen, using the installed app version's tables.

## 8. Generator

**They do:** 18 QR types in a flat grid, all free, each a short form producing a black-on-white JPG. No barcodes can be made, though the app scans them. Wi-Fi has no WPA3 or hidden-network option; a contact carries only name, phone and email, and the phone field strips a leading "+" (verified app behaviour). Links aren't validated. Created codes can be saved and shared again but never edited.

**Learn:** A real generator needs barcode formats, complete fields, international numbers that survive, validation before a broken code exists, and editing.

- **GEN-1** Types at closed test: URL, Text, Wi-Fi, Contact, Phone, Email and SMS. Every type and format is free (PRO-2).
- **GEN-2** v1 adds Location, Calendar event and App-store link, plus barcodes in EAN-13, EAN-8, UPC-A, UPC-E, Code 128 and Code 39. ITF-14, Data Matrix, PDF417 and Aztec come after v1.
- **GEN-3** URL: `http` and `https` only. A bare domain gets `https://` added where the user can see and edit it; any other scheme is rejected before Create enables. Whether a link is safe is judged when it's scanned (LINK).
- **GEN-4** URL presets: chips for WhatsApp, Instagram, X, Facebook, YouTube and Telegram fill in a link template (such as `https://wa.me/<number>`) inside the URL type, without separate tiles.
- **GEN-5** Wi-Fi: network name (required); security WPA/WPA2, WPA3, WEP (labelled insecure) or none; password, masked with a reveal button; and a hidden-network switch.
- **GEN-6** Contact: name (required), plus phone, email and organisation at closed test; v1 adds job title, address, website and a photo from the photo picker.
- **GEN-7** Phone numbers take an optional leading "+" and 3–15 digits. Spaces, dashes and brackets are allowed while typing and removed when encoding; a leading "+" is never removed.
- **GEN-8** Text: any text that fits (GEN-12), encoded as is. Phone: one number (GEN-7), encoded as `tel:<number>`. SMS: number (GEN-7) and an optional message, encoded as `SMSTO:<number>:<message>`. Email: address (required and validated), with optional subject and body, encoded as a `mailto:` link with percent-encoded fields.
- **GEN-9** Location: latitude −90 to 90 and longitude −180 to 180, typed, with an optional label and no permission. Calendar event: title (required), start, end or all-day, location, notes. The end can't be before the start, and times are encoded as the local time the user picked (DATE-3).
- **GEN-10** App-store link: a package name (`com.example.app`) or a pasted Play link, normalised to `https://play.google.com/store/apps/details?id=<package>` and shown before Create.
- **GEN-11** Each barcode format checks its characters and length before Create enables, naming the limit inline. EAN and UPC compute the check digit; a wrong typed check digit is replaced, and the corrected number is shown before Create.
- **GEN-12** Above 80% of the format's capacity at the chosen error-correction level, a capacity meter appears. Over the limit, Create is blocked with the fix (shorter content, or lower error correction). Content is never truncated.
- **GEN-13** A created code is added to History when Create first renders it, if "Save history" is on (HIS-8).
- **GEN-14** A created code can be reopened from History and edited: the same form refills, and saving updates the same record (same ID, new `updated_at`) and redraws it.
- **GEN-15** Form contents survive the app being killed in the background (for example while the photo picker is open), and are lost only when the user discards them.
- **GEN-16** "Use current location" on the Location form comes after spike S10. Location is requested only when that button is tapped (RUN-3).

## 9. Styling

**They do:** No styling at all, free or paid: no colours, logo, shapes or frame.

**Learn:** Styling is easy to add and easy to get wrong: low contrast, big logos and light-on-dark codes are leading causes of failed scans. Ours is free, and every style has to prove it still scans.

- **STY-1** Create shows a plain code first (black on white, error correction M); styling is an optional "Customize" step below it.
- **STY-2** Colours: every foreground colour, gradient stops included, needs at least 4.5:1 contrast against the background, or Save, Share and Print stay blocked with a message. Dark on light is the default; light on dark needs an explicit choice.
- **STY-3** A logo, picked with the photo picker, covers at most 20% of the code's area and raises error correction to H. If the content no longer fits (GEN-12), Create is blocked with the fix.
- **STY-4** A preset gallery of module shapes, and an optional frame with an editable caption drawn outside the quiet zone. Separate finder-eye shapes only if the rendering package supports them (technical constraints).
- **STY-5** Before a code can be saved, shared or printed, the app decodes its own rendered image and compares the result byte for byte with the content. On a mismatch, Save, Share and Print are blocked with a message, and the preview returns to the last style that passed (spike S2).

## 10. Save, share and print

**They do:** Save writes a fixed-size JPG, named with a long number, to a "QR Code" folder in DCIM. Share sends the same JPG. There's no SVG, PDF or print. A native ad sits under the Save and Share buttons (verified).

**Learn:** A code has to stay sharp enough to rescan and print: lossless formats, readable names, and nothing competing with Save and Share.

- **SAVE-1** Save and Share are the two largest buttons on the created-code screen, equal in size, and nothing else there (no ad, no upsell) competes with them (ADS-1).
- **SAVE-2** Save writes a PNG (QR codes 1024 × 1024 px, barcodes 1200 px wide) through the system file picker, with no storage permission.
- **SAVE-3** v1 adds SVG, for plain codes only (styled codes save as PNG or PDF), and PDF, with the code centred on A4 or Letter.
- **SAVE-4** File names follow `<type>-<name>-<YYYYMMDD-HHmmss>.<ext>`, ASCII and at most 60 characters. The name comes only from a non-secret field (host, network name, contact name, event title, barcode format), never from a password, number, email address or message. Types with no such field (text, phone, SMS, email) use the type alone (`phone-20261016-101500.png`).
- **SAVE-5** Share sends the same format and file as Save (PNG by default), without re-encoding.
- **SAVE-6** Print opens the system print dialog with the code centred, and warns when the printed code would be smaller than 2 cm.
- **SAVE-7** Label sheets (many codes on one page) come after v1.

## 11. History

**They do:** Separate Scan and Create tabs, newest first; each row has a type icon, the value and a type label. No dates, grouping, search, filters, favourites or notes. Scanning again moves the existing row to the top. Swiping a row switches tabs instead of acting on the row. Saving history can't be turned off. A banner ad sits under the tab bar (verified).

**Learn:** A list without dates or search stops working as it grows. People can't organise their records, or stop the app keeping them.

- **HIS-1** One History list for scanned and created codes, newest first by `last_seen_at`, with All / Scanned / Created as tap-only segments, never swipeable pages, so a swipe always reaches the row (DEL-2). Type chips (Link, Wi-Fi, Contact, Text, Product, Event, Favourites) combine with the segment.
- **HIS-2** Search matches content and label as the user types, ignoring case and accents (LANG-4). Sensitive fields are never searched (DATA-5).
- **HIS-3** Rows are grouped under date headers (DATE-2).
- **HIS-4** A row shows the type icon; the label if set, otherwise the content, in bold; the content on a second line when a label is set; the time; and "×N" when the code was seen N ≥ 2 times.
- **HIS-5** Scanning or creating matching content again (DATA-4) updates that row's time and count and moves it to the top; its favourite and label stay.
- **HIS-6** A saved batch (SCAN-14) is one collapsible row with its start time and code count. Expanded, each code behaves like any other row.
- **HIS-7** Wi-Fi passwords are masked in rows and share previews; the result screen has a reveal button (RES-4).
- **HIS-8** Settings → "Save history", on by default. When off, new scans and created codes aren't written (DATA-6), results work the same, and existing history stays until the user clears it.
- **HIS-9** Favourites (a star on the row and on the result) and one free-text label per record.
- **HIS-10** "Clear history" in History's menu clears exactly what the current segment and chips show, after DEL-3's confirmation.
- **HIS-11** An empty History shows one line and two buttons, "Scan a code" and "Create a code". While "Save history" is off, it also says new scans aren't being saved, with a button to that setting.

## 12. Deletion and trash

**They do:** Long-press starts multi-select, and any delete, one row or all, asks the same confirmation. Confirmed deletes are final: no undo, no trash (verified).

**Learn:** Heavy friction on the common single delete, and no protection against the rare wipe-everything mistake. We invert that: fast and undoable for the common case, a confirmation only where there's no second chance.

- **DEL-1** Deleting sets `deleted_at`. Deleted records count nowhere: History, search, chips, duplicate matching (DATA-4), counts and export.
- **DEL-2** Deleting one or several selected records needs no confirmation: a snackbar offers Undo for 5 seconds. A row can also be swiped away, toward the start edge (mirrored in right-to-left languages), with the same Undo.
- **DEL-3** "Clear history" asks once, naming how many records will move to Trash.
- **DEL-4** Deleted records stay in Trash for 30 local calendar days from `deleted_at`, and are purged at the first app start after that.
- **DEL-5** Trash, in History's menu, lists deleted records with the days left before purge; each can be restored (REC-4) or deleted forever.
- **DEL-6** "Delete forever" and "Empty trash" ask once. They're the only deletes that can't be undone.

## 13. Export

**They do:** No export of any kind; codes leave the app only one image at a time (verified).

**Learn:** Reviewers single out CSV export as what makes a scanner practical for inventory and record-keeping.

- **EXP-1** History exports to one CSV file through the share sheet or the file picker. The button names its scope and count ("Export all (N)" or "Export filtered (N)") and is disabled at 0. Columns: id, created_at, last_seen_at, source, symbology, type, label, favourite, count, content.
- **EXP-2** The file is UTF-8 with a byte-order mark, so spreadsheets show every script. Dates are ISO 8601 in UTC whatever the language. A value starting with `=`, `+`, `-` or `@` gets a leading apostrophe.
- **EXP-3** Sharing one record as text sends its label, if any, and its content on the next line, nothing else.
- **EXP-4** In CSV exports and text shares, a Wi-Fi record's content keeps its whole payload except the password value, which becomes "••••" (`WIFI:T:WPA;S:Home;P:••••;;`), unless the user turns on "Include passwords" just before that export.
- **EXP-5** The file is named `qr-history-YYYYMMDD-HHmm.csv` (local time).
- **EXP-6** Deleted records are never exported.

## 14. Backup and restore

**They do:** Nothing: a new phone or a reinstall loses all history (verified).

**Learn:** A raw database copy breaks across schema versions, so a backup needs a versioned, mergeable file from its first release.

- **BAK-1** A backup is one JSON file carrying the app version, the schema version, every record including those in Trash, and the settings (theme, language, sound, vibration, copy on scan, search engine, save history). It's created only when the user taps "Back up", saved through the file picker or share sheet, and named `qr-backup-YYYYMMDD-HHmm.json` (local time).
- **BAK-2** Backups include Wi-Fi passwords, since restoring needs them, and the backup screen says so in one line before saving.
- **BAK-3** Restore opens a file through the system file picker. Before changing anything, the app saves a backup of the current data in its private storage, and "Undo last restore" stays available until the next restore.
- **BAK-4** Restore matches records by ID; the later `updated_at` wins, deletions included (REC-3, REC-4). The app then shows how many records were added, updated and unchanged.
- **BAK-5** A backup from a newer schema is refused with a message to update the app; an older one is migrated with the app's own steps before merging. A file that isn't a valid backup is refused without changing anything.
- **BAK-6** Created codes are backed up as content and style settings, not images (DATA-3), and redraw identically after a restore.
- **BAK-7** Backup and restore work offline with no account or cloud service, and are never Pro-only (PRO-2).

## 15. Ads

**They do:** A native ad sits under the tab bar on every main screen. A second native ad sits directly under the actions on every result, created-code and history-detail screen, with a green "VIEW NOW" button that matches the app's own buttons. In our session a banner shifted as it loaded and turned a tap on the History tab into an ad click. Only test ads were served; the ads over the viewfinder and full-screen ads described in reviews weren't seen: not verified.

**Learn:** An ad must never compete with the action people came for, look like that action, or move under a finger.

- **ADS-1** Ads appear on three screens only: the History list, the top level of Settings, and the Create type picker. Never on the scanner, any result (a History reopen included), a generator form or created code, the link sheets, Trash, export, backup, batch review, first run, or any dialog.
- **ADS-2** Adaptive banners only: no interstitial, app-open, rewarded or native ads. None of our own controls imitates an ad's styling.
- **ADS-3** A banner sits in a fixed, non-scrolling area, never inside a scrolling list, separated by a divider and at least 16 dp from the content and from the navigation bar. Before release, the placement is checked against AdMob's banner implementation guidance.
- **ADS-4** The banner's height is reserved before an ad loads, so loading, failing or refreshing never moves a control.
- **ADS-5** No ad is requested until consent is resolved for the session (PRIV-1). If it can't be resolved, for example offline, no ads show that session. Where consent is refused, only non-personalised ads show.
- **ADS-6** No ad shows before the install's first successful scan or create (DATA-8).
- **ADS-7** Pro owners see no ads, and no ad requests are made for them.
- **ADS-8** An ad's own layout may stay left to right in right-to-left languages; the SDK draws it.

## 16. Pro

**They do:** A one-time "Remove ads" purchase for AED 11.99 (about US$3.26) opens straight into the Play purchase sheet from a green button pinned to the top of Settings, carrying a "Save 50%" badge with no reference price. Whether it unlocks anything else: not verified.

**Learn:** Keep the honest, one-time purchase; drop the nagging button and the fake discount.

- **PRO-1** Pro is one non-consumable Play product, `remove_ads`: one-time, never a subscription.
- **PRO-2** Pro removes ads and nothing else through v1. It never gates scanning, results, link checks, creating, styling, history, export or backup.
- **PRO-3** The price is US$1.99, with Play's local prices elsewhere.
- **PRO-4** Pro is offered from a Settings row ("Remove ads, one-time purchase") and one dismissible prompt, shown at most once per install on History or Settings after the 5th successful scan or create (DATA-8). Never on the scanner, results or generator.
- **PRO-5** No discount badges, crossed-out prices or countdowns; the Play price is the only price shown.
- **PRO-6** "Restore purchase" sits next to the purchase row, and the app re-checks ownership at every start when online.
- **PRO-7** Ownership is cached, so an offline Pro owner sees no ads. A refunded purchase brings ads back after the next successful online check.

## 17. Privacy and consent

**They do:** The data-safety page declares device IDs, app activity, crash logs and diagnostics collected and nothing shared, while the build declares advertising-ID, attribution and topics permissions. The listing claims only the camera permission is needed. No consent form appeared, but the session ran outside the regions that require one: not verified. The app has no privacy controls.

**Learn:** A privacy claim that doesn't match the manifest spends the trust it was meant to earn. The story has to be short and true.

- **PRIV-1** Consent status is refreshed silently at each start. The consent form shows only where required, and only when an ad screen (ADS-1) is about to request an ad once ADS-6 is met, never on first launch.
- **PRIV-2** Settings shows "Privacy options" whenever the consent SDK reports that the user's region needs it.
- **PRIV-3** Crash reports (Firebase Crashlytics) stay off until the user turns on "Send crash reports" in Settings: collection is disabled in the manifest, and no Firebase traffic happens before the switch is on (spike S14; anything unavoidable is disclosed under PRIV-5 and in the privacy policy). No analytics SDK ships.
- **PRIV-4** Scanned and created content leaves the device only when the user shares, exports, backs up, opens or searches it in another app, or runs the link check (LINK-7). Crash reports never contain it.
- **PRIV-5** The app itself connects only for ads and consent, Play Billing, crash reports (when on) and the link check (when tapped).
- **PRIV-6** The data-safety form and `docs/privacy-policy/index.html` are updated in the same PR as any change to permissions, SDKs or network use, and checked against the release manifest before every release (RUN-2).
- **PRIV-7** No account and no cloud sync.
- **PRIV-8** Consent and crash-report choices are stored only on the device.

## 18. Settings

**They do:** A tidy card list: beep (off), copy on scan (off), vibration (on), search engine (Google plus five others), language, a categorised feedback form, and a privacy-policy link, with the "Remove ads" button on top. No theme option. No review prompt appeared.

**Learn:** The tidy layout is worth matching. Add a theme and privacy controls, and ask for a review only after something worked.

- **SET-1** Theme: Dark (the initial choice), Light or System default. The app opens on its own dark chassis whatever the phone is set to, and keeps its own palette in both halves (decided 2026-09-20): the signal colour, the paper a code is printed on and the hairline chassis are the product's identity, so neither the phone's palette nor its light setting recolours them.
- **SET-2** Vibrate on scan: on. Sound on scan: off.
- **SET-3** Copy on scan: off. When on, a snackbar confirms what was copied (RES-2).
- **SET-4** Search engine: Google (default), Bing, DuckDuckGo, Ecosia, Brave, Yahoo or Yandex, used by "Search the web" (RES-9).
- **SET-5** Groups, in order: General (theme, language, sound, vibration, copy on scan, search engine); Privacy (save history, send crash reports, privacy options); Pro (remove ads, restore purchase); About (feedback, privacy policy, open-source licences, version).
- **SET-6** "Privacy policy" opens the published policy in Custom Tabs.
- **SET-7** "Open-source licences" opens Flutter's licence page, including the credits for LINK-6's bundled sources.
- **SET-8** Feedback: category chips (Scanning, Results, Creating codes, Ads, Other) and a text box. Send opens the user's email app addressed to the app's support address (the one on the Play listing, never a personal address), with the app and Android versions in the subject. The app sends nothing itself.
- **SET-9** The Play in-app review is requested at most once per install, within Play's quota, right after a success moment: an action taken from a result, or a code saved or shared. Never on launch and never after an error.

## 19. Accessibility

**They do:** Back, close, delete, share and select-all buttons have no screen-reader label, while the ad SDK's own views do (verified). Touch targets look comfortable. No dark theme. Text scaling and scan announcements: not verified.

**Learn:** An unlabelled icon is invisible to a screen-reader user, and a scanner's core answer, "what is this code?", can be spoken.

- **A11Y-1** Every icon-only control has a screen-reader label; a widget test fails on any unlabelled icon button.
- **A11Y-2** Every tappable control is at least 48 × 48 dp, checked by widget tests.
- **A11Y-3** When a code is detected, screen readers announce its type ("QR code detected: link").
- **A11Y-4** At 200% text size, no content or primary action is clipped on any screen or sheet, checked by widget tests on a phone-size screen, together with LANG-6.
- **A11Y-5** Contrast meets WCAG AA (4.5:1 for text, 3:1 for large text and icons) in both themes, including text over the camera preview.
- **A11Y-6** No state (a warning, success, Pro) is shown by colour alone.

## 20. Languages

**They do:** An in-app language list with about 24 languages (one session counted 24, another 13). Arabic mirrors the whole app, including list rows and the zoom slider, while URLs stay left to right; only the ads stay unmirrored (verified).

**Learn:** A translated app feels native only when dates, numbers, search and layout direction are right too, and a clipped label looks broken.

- **LANG-1** The app follows the device language and falls back to English. Settings offers "System default" and each language in its own name, and a change applies without a restart. Those names are never translated (amended 2026-09-21): someone who has opened the app in a language they can't read still has to find their own, and "Deutsch" is findable where a translated "German" is not. The list is built from one place, so a new language is a message file and a line. The choice is a dropdown, closed to the chosen language, not the row of chips the other switchers use (amended 2026-09-21): at twenty languages the chips filled the screen and pushed every setting below them out of sight. A switcher stays chips while its options fit in a glance — Theme's three do.
- **LANG-2** Every user-facing text comes from the message files, with ICU plurals and placeholders, share text included; file names stay ASCII (SAVE-4). CI fails on a missing message or mismatched placeholders.
- **LANG-3** Dates and numbers follow the chosen language. Exported and backup files don't (EXP-2, BAK-1).
- **LANG-4** Search ignores case and accents in every language, including Turkish dotted and dotless i.
- **LANG-5** Right-to-left languages mirror navigation, lists, swipe directions, icon rows, sliders and arrows. URLs, numbers, codes and phone numbers stay left to right inside them.
- **LANG-6** Translations are machine-made in the same PR as the English text, and a second pass checks each language against the English before it lands: placeholders intact, ICU plurals using the categories that language actually has, and apostrophes doubled for `use-escaping`. Widget tests render the main screens in **every** language at 2.0× text on a phone-size screen and fail on overflow, because how long a label runs is exactly what differs between languages. The accessibility harness runs English and Arabic only (amended 2026-09-21): what it checks — that every control has a name and a large enough target — is the same in all of them, so running it 21 times re-checks one fact 21 ways.
- **LANG-7** English and Arabic at closed test. v1 adds Bengali, Simplified Chinese, Dutch, French, German, Hindi, Indonesian, Italian, Japanese, Korean, Polish, Portuguese, Russian, Spanish, Thai, Turkish, Urdu and Vietnamese, for twenty in total (amended 2026-09-21, following the portfolio's expense app). A language ships only when the app can draw it: Greek is translated and held back because the bundled typefaces cover it only partly, and the app renders its accents beside the letters instead of on them (Known bugs in `docs/ROADMAP.md`). Later languages are chosen from testers' and users' locales; `tool/new_language.dart` adds one from the English file.

## 21. App lock

**They do:** No app lock, PIN or biometric option; scanned Wi-Fi passwords are readable by anyone holding the unlocked phone (verified).

**Learn:** The real exposure is secrets in plain sight. Masking them (HIS-7, RES-4) is cheap and ships first; a lock follows once its plugins are proven.

- **LOCK-1** App lock ships after spike S9. It's off by default, uses only the device's biometrics or screen lock (no app PIN), and asks for authentication to turn it on or off.
- **LOCK-2** With app lock on, the app locks at launch and after at least 1 minute in the background, and hides History, Trash, results, backup and its recent-apps preview until unlocked.
- **LOCK-3** If the phone no longer has biometrics or a screen lock, app lock turns itself off instead of locking the user out.

## 22. Launcher icon and splash

**They do:** On the launcher they take a keyword-stuffed name, "QR Code Reader and Scanner - QR Scanner", rather than the app's own. Their icon artwork, adaptive-icon layers, themed-icon support and launch window: not verified.

**Learn:** The icon is the app's first and most-repeated appearance, and it is seen at 48 px in a grid of competitors that nearly all draw the same literal code. A mark of our own is recognised faster than the category is. The launch window is not a place to say anything: it exists only so the app does not flash white on the way to a dark scanner (RUN-1, RUN-7).

- **ICON-1** The icon is drawn from one committed source and rendered to the platform files by a tool; no generated file is hand-edited, and regenerating produces no diff. A test reads the shipped Android resource back and fails when it no longer matches the source, because each step is run by hand and a skipped one leaves a stale icon that nothing else catches. The Play 512 px listing icon comes from the same source; it isn't generated yet, and ships with the listing rather than the app.
- **ICON-2** The mark is the concentric square of a QR code's finder pattern, in signal `#C9F24D` on the chassis `#0E0D0B`. It is the same in light and dark, because the app keeps its own palette (SET-1).
- **ICON-3** The Android icon is adaptive: a chassis background layer and the mark as foreground. A launcher shows only the inner 72 dp of the 108 dp canvas, and 66 dp is the most a mark may be without a mask clipping it, so the mark is drawn at 44 dp — about two thirds of what is seen — and the chassis stays the ground on every mask (ICON-2). Drawn at the 66 dp ceiling it fills 92% of the visible circle and the icon reads as a signal-coloured tile instead.
- **ICON-4** A monochrome layer ships for Android 13 themed icons: the mark alone, no background, within ICON-3's safe zone.
- **ICON-5** The mark stays legible at 48 px: no stroke thinner than 4 dp on the 108 dp canvas, and no detail that merges at that size. A test renders the source at 48, 72 and 192 px and checks at each size that the ring, the gap inside it and the centre are each still solid and distinct, so the pattern can't be thinned or filled in unnoticed. It asserts the shapes rather than the pixels, because the goldens would be drawn on Windows and checked on CI's Linux.
- **ICON-6** The launch window is the chassis with the icon centred, no text and no animation. It is the platform's own cold-start window: the app adds no splash screen, no delay and no minimum display time (RUN-1), and the cold start still meets SCAN-2's budget (RUN-7).
- **ICON-7** The launcher name stays the app's own name in each language, never keywords (see LANG-2). The store title is chosen separately.

## Decisions

1. (14 September 2026) Flutter only, with no hand-written Kotlin or Java; no home-screen widgets; no backend in v1 (so no dynamic codes, online link reputation or product database); iOS deferred (ENTRY-4, LINK-3, RES-9).
2. (15 September 2026) Ads only outside the working area and with consent; a one-time Pro removes ads; crash reports only with consent; no account (ADS, PRO, PRIV).
3. (15 September 2026) Application ID `com.oasisforge.qrscanner`. The GitHub repo is public.
4. (16 September 2026) Ads may appear on the History list, the top of Settings and the Create type picker (ADS-1).
5. (16 September 2026) Pro costs US$1.99, one-time (PRO-3).
6. (16 September 2026) The closed test still starts on 16 October, with a trimmed first build; the rest ships as updates during the test, before the 2 November production application (`docs/ROADMAP.md`).
7. (16 September 2026) Backup and restore ship in v1, before the production application (BAK-1–BAK-7).
8. (20 September 2026) The launcher mark is the concentric square of a QR code's finder pattern, signal on chassis, over a literal code glyph or viewfinder brackets; the cold-start window is that chassis and that icon, nothing else (ICON-2, ICON-6).
9. (21 September 2026) Twenty languages, following the portfolio's expense app, rather than the ten LANG-7 first set out. Greek was translated with them and held back: a language ships only when the app can draw it, and the bundled typefaces cover Greek only partly. Their names are never translated (LANG-1). The overflow harness renders all of them; the accessibility harness stays on English and Arabic, since what it checks doesn't vary by language (LANG-6).

10. (21 September 2026) The language switcher is a dropdown, not chips (LANG-1). Driven on the emulator at v0.11.1, the twenty-one chips ran ten rows down the screen and left sound, vibration, copy on scan and the Privacy, Pro and About groups below the fold — a list long enough to hide the settings around it is no longer a switcher. Chips stay wherever the options fit in a glance, so Theme keeps them.

### Defaults chosen while writing the rules

Set on 16 September 2026 and not yet confirmed by the user; change any of them here first.
- **History:** one list with Scanned/Created segments instead of two tabs (HIS-1). Turning off "Save history" keeps existing history (HIS-8).
- **Passwords:** exports hide Wi-Fi passwords unless "Include passwords" is on, and backups include them (EXP-4, BAK-2).
- **First run and input:** no walkthrough, just one callout (RUN-8). The share target takes images only (ENTRY-2). A batch ends in a review list (SCAN-14).
- **Generator:** barcode formats are staged (GEN-2), and social profiles are URL presets, not tiles (GEN-4).
- **Link safety:** warnings need one distinct tap, and thresholds are fixed rather than settings (LINK-3, LINK-4). The redirect check ships in v1 (LINK-7). Checks re-run whenever a link is shown (LINK-9).
- **Pro and privacy:** Pro removes only ads through v1 (PRO-2). Crash reports are a Settings switch, off by default, and there's no analytics SDK (PRIV-3).
- **Languages:** English and Arabic at closed test, ten by v1 (LANG-7).
- **Security and support:** app lock comes after v1, with passwords masked meanwhile (LOCK-1). Feedback goes by email to a non-personal support address (SET-8).

## Roadmap impact

- **Schema before any screen** (Phase 1, first migration step): records with id, created_at, updated_at, deleted_at, last_seen_at, insert sequence, source, symbology, parsed type, payload text and bytes, sensitive-field flag, label, favourite, duplicate count, batch session id, and created-code content fields plus style settings. Also a batch staging table (DATA-7) and stores for settings, consent, Pro ownership and success counts (DATA-8). All of it lands before testers have data, including fields that v1 features use.
- **Services behind interfaces, with no-op fakes:** camera scanner, image decoder, permissions, ads, consent, billing, crash reports, clipboard, file picker and share, Custom Tabs and system intents, Wi-Fi.
- **Build order:**
  - permission states (RUN) before the scanner
  - the scanner before its modes (SCAN-13, SCAN-14)
  - scan from a photo (SCAN-11) before the share target (ENTRY-2)
  - the shared result screen (RES-1–RES-3) before type-specific results
  - Custom Tabs (LINK-8) before any Open action
  - the plain render and scan check (STY-1, STY-5) before styling
  - export and backup after the last schema step
- **Spikes:**
  - S1, S2, S3 and S8 before the closed-test features.
  - S5 and S6 on real phones before RES-5 and before SCAN-2 and SCAN-3 are final.
  - S11 before LINK-2's registrable-domain emphasis, S12 before the share target, S13 before barcode generation, and S14 in the crash-report PR.
  - S4, S9 and S10 after v1.
- **Data safety:** the form and privacy policy change in the PRs that add ads, consent, billing, Crashlytics and the link check (PRIV-6).
