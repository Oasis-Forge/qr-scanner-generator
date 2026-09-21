# Changelog

Notable changes per release, written for users. Versions follow [Semantic Versioning](https://semver.org) and match the app version and the `vX.Y.Z` git tags. Every merged PR is a release (see `docs/RELEASING.md`).

## [Unreleased]

## [0.11.0] - 2026-09-21

### Added
- The app speaks eighteen more languages: Bengali, Simplified Chinese, Dutch, French, German, Hindi, Indonesian, Italian, Japanese, Korean, Polish, Portuguese, Russian, Spanish, Thai, Turkish, Urdu and Vietnamese — twenty in all. It follows the phone's language on its own, and Settings lists every one.
- Each language is listed under its own name — Deutsch, 日本語, العربية — so you can find yours even if the app has opened in one you don't read.

### Fixed
- A group heading in Settings ran off the side of the screen at the largest text size in Russian, and in any other language whose word for it is long.

### Known issues
- Greek isn't offered yet. It is translated, but the app's two typefaces cover only part of the Greek alphabet, so accents came out beside their letters instead of on them. It will arrive once a typeface that covers Greek ships with the app.

## [0.10.0] - 2026-09-20

### Added
- The app has its own icon: the corner square a scanner looks for first, in the signal colour on the dark chassis. It keeps its shape whatever mask the phone puts around it — round, squircle or rounded square — and has a monochrome version for phones that tint their icons.
- Opening the app now shows the chassis and that mark while it starts, instead of Flutter's white screen. Nothing is added to how long it takes.

### Fixed
- A white flash on the way into the app on a phone set to light. The app opens on its own dark chassis whatever the phone is set to, but the window behind it was still the phone's light one for a frame.

## [0.9.1] - 2026-09-20

### Changed
- Nothing users can see: a handoff guide for developers picking the project up, and two roadmap lines brought up to date.

## [0.9.0] - 2026-09-20

### Changed
- The app has a look of its own: a dark instrument chassis, one signal colour that marks what the app is doing, and paper only where a code's content is shown.
- Two typefaces do different jobs: Space Grotesk names things, and IBM Plex Mono says what the machine read — codes, sizes, times and states.
- The viewfinder is marked like an instrument: corner ticks and a centre crosshair, with "Ready" beside the torch.
- A scan result is printed on paper: the site's name large, the address below it in the monospaced voice.
- The bottom bar is a thin rail, marked by a line above the tab you are on.
- Create lists the seven formats in order, numbered, instead of a grid of cards.
- Days in History and groups in Settings are labelled in small capitals against a hairline rule.
- The app opens on its own dark chassis whatever the phone is set to, and keeps its own colours in both halves instead of following the phone's palette. Light and System default are still there in Settings.

## [0.8.2] - 2026-09-20

### Changed
- The privacy policy moved to https://oasis-forge.github.io/qr-scanner-generator/privacy-policy/, which is the address Settings opens.

## [0.8.1] - 2026-09-20

### Changed
- The app now shows as "QR Scanner + Generator" under the launcher icon, in Arabic too.
- The privacy policy has its own page, written for what this version actually does, with oasisforge.support@gmail.com as the contact: https://oasis-forge.github.io/qr-scanner-generator/privacy-policy/

### Fixed
- Release builds are signed with the upload key when one is set up, so a build can be uploaded to Google Play.

## [0.8.0] - 2026-09-21

### Added
- Settings, in four groups:
  - General: theme, language, sound, vibration, and copy on scan.
  - Privacy: whether history is saved, and Privacy options where your region needs them.
  - Pro: Remove ads and Restore purchase.
  - About: version, privacy policy, open-source licences, and Send feedback.
- Pro: one purchase that removes ads for good. It isn't a subscription, and the Play price is the only price shown.
- Restore purchase. The app also re-checks Pro at every start, and a Pro owner who is offline still sees no ads.
- A single, dismissible Pro offer on History or Settings after your fifth scan or created code. It never comes back once closed.
- Send feedback: pick a topic and write a note. It opens your email app with the app and Android versions filled in, and nothing is sent until you send it.
- Banner ads, only at the bottom of History, Settings and the Create screen. Never on the scanner, a result or the code editor, and none before your first scan or created code. Their space is held while they load, so nothing jumps.
- Where the law requires it, the app asks for ad consent before the first ad, not on first launch. You can change your choice later in Settings → Privacy options.

## [0.7.0] - 2026-09-21

### Added
- Create codes: a link, text, Wi-Fi network, contact, phone number, email or text message.
- Each form checks what you type before Create turns on. A web address gets `https://` added where you can see it, and a phone number takes an optional + and 3 to 15 digits.
- Wi-Fi passwords are hidden as you type, with a button to show them, and WEP is labelled insecure.
- Close to the size limit, a meter shows how full the code is. Over it, Create says to shorten the content, and nothing is ever cut off.
- A created code is a plain black-on-white QR code. Before you can save or share it, the app scans its own image to check it reads back exactly what you typed.
- Save writes a 1024 × 1024 PNG wherever you pick, named after the code's type, a name from it (never a password) and the time. Share sends the same file.
- Created codes appear in History under Created.

### Fixed
- The release version check no longer makes a full local clone shallow.

## [0.6.0] - 2026-09-20

### Added
- Links show where they go before anything opens: the whole address, with the site's name in large bold type above the buttons.
- The app checks every link on your phone, with nothing sent anywhere. It flags a raw number instead of a site name, a user name hidden before the site, an unencrypted (http) address, an unusual port, or an unusually long address.
- A clean link opens with "Open". A flagged one says "Review" instead and lists what looks wrong, with "Copy without opening" and "Open anyway" side by side.
- Links that can't be opened safely (javascript:, data:, file:, intent:, content:) are marked as blocked, and can only be copied.
- Links open in Custom Tabs, never inside the app.
- The first link you scan carries a short note about these checks. One tap hides it for good.

## [0.5.0] - 2026-09-20

### Added
- History: every code you scan, newest first, under Today, Yesterday, the day of the week, then the date. Filter by All, Scanned or Created.
- Each row shows the code's type, its content (or your label), the time, and how many times you've scanned it. Wi-Fi passwords stay hidden.
- Tap a row to open its result again.
- Swipe a row away, or long-press to select several, and delete them. There's no "are you sure?": Undo is right there for 5 seconds.
- Deleted codes go to Trash and are removed for good after 30 days.
- An empty History offers to scan or create a code, and says so if saving history is turned off.

## [0.4.0] - 2026-09-19

### Added
- Results made for each kind of code:
  - A Wi-Fi code shows the network, its security and a hidden password you can reveal, with "Open Wi-Fi settings" and "Copy password". Android can't join WEP networks from apps, and a WEP result says so.
  - A contact or an event opens Android's own "add" screen, filled in exactly as the code has it. The app needs no access to your contacts or calendar.
  - A phone number, text message or email opens the dialer, messaging or email app prefilled. Nothing is called or sent for you.
  - A product barcode shows its number and format, with "Search the web".
  - A code the app can't read as text shows "Binary data" with its size.
- When no app on the phone can take an action, it shows greyed out with the reason, and Copy still works.
- Links open in Custom Tabs, never inside the app.

- Event times read in words in your language ("Thu, Oct 1, 2026 9:00 AM"), exactly as the code has them, with UTC or the time zone named when the code gives one.

### Fixed
- With "Copy on scan" on, the copy now shows its confirmation, like the Copy button does.
- The camera no longer keeps running behind a result opened from a typed code or a photo, which wasted battery.
- An event code with no start time shows no empty rows, and "Add to calendar" explains why it can't be used.

## [0.3.0] - 2026-09-19

### Added
- The app opens on a live scanner. Point it at a QR code or barcode and the result opens with its type, the full content, and Copy and Share. Nothing opens by itself.
- Asking for the camera: the app explains why before Android asks, and if you say no you can still scan a photo or type a code. If Android stops asking, the button opens the app's settings instead.
- Torch (on phones with a flash), zoom by slider, pinch or double-tap, and a square target so codes elsewhere in view are ignored.
- Scan from a photo with the system photo picker, which needs no access to your photos. "No code found" says so and lets you try another.
- When a photo or a camera view holds several codes, you pick which one to open.
- Type a code by hand and get the same result screen.
- Screen readers announce each code the scanner finds.
- A bottom bar for Scan, Create, History and Settings. Create and History arrive in the next test builds.

## [0.2.0] - 2026-09-18

### Added
- The app now opens to a screen of its own, in English or Arabic, following the phone's language and falling back to English.
- Light, dark and system themes, using the phone's own colours where it offers them. Your choice is remembered.
- Arabic mirrors the whole layout, right to left.

### Changed
- Groundwork for everything that stores a scan: the database, its first schema step, and the counters behind history, so nothing testers save will need a rebuild later.

## [0.1.2] - 2026-09-17

### Changed
- Still nothing to see in the app: this release records that scanning works on the test emulator, and how far from a code the camera has to be.

## [0.1.1] - 2026-09-16

### Changed
- Nothing you can see in the app yet: this release records the technical checks that shape scanning, image decoding and camera permissions.

## [0.1.0] - 2026-09-16

### Added
- Project setup: docs, Claude Code tooling, CI, and the release workflow.
- A first Android build that opens to a placeholder screen with the app's name.
