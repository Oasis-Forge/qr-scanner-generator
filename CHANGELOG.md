# Changelog

Notable changes per release, written for users. Versions follow [Semantic Versioning](https://semver.org) and match the app version and the `vX.Y.Z` git tags. Every merged PR is a release (see `docs/RELEASING.md`).

## [Unreleased]

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
