# Changelog

Notable changes per release, written for users. Versions follow [Semantic Versioning](https://semver.org) and match the app version and the `vX.Y.Z` git tags. Every merged PR is a release (see `docs/RELEASING.md`).

## [Unreleased]

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
