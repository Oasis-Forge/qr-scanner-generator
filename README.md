# QR Scanner + Generator

Scan any QR code or barcode and see exactly where it leads before anything opens, then create clean, styled codes that are checked to scan, without ads covering the camera or the result.

**Principles:** no ad in the working area (viewfinder, scan result, generator editor), and the largest button is always the real action; nothing opens before the user has seen where it leads; the free app does the whole core job, and Pro is a one-time purchase that removes ads, never a subscription; no account, and scans, codes and history leave the device only when the user shares or exports them; ads and crash reports run only as far as the user's consent allows.

## Getting started

```bash
flutter pub get
flutter run
```

## Docs

- [Roadmap](docs/ROADMAP.md): phases and what's done
- [Product rules](docs/PRODUCT_RULES.md): how the app behaves, with rule IDs
- [Releasing](docs/RELEASING.md): versions, signing, stores
- [Handoff: where the project stands](docs/HANDOFF.md)
- [Privacy policy](https://oasis-forge.github.io/qr-scanner-generator/privacy-policy/) (`docs/privacy-policy/index.html`)
- [Changelog](CHANGELOG.md)

## Development

Built with Claude Code. `CLAUDE.md` holds the conventions. The project skills are `/spec` (rules before code), `/verify` (checks), `/release` (version bump), `/ship` (pre-merge gate), and `/handoff` (session notes). Every merge is checked; a release is cut when the maintainer asks for one.
