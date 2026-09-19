# Stack notes: Flutter

Read on demand: the fill-ins `/kickoff` uses, and the traps earlier Flutter apps ran into.

## Fill-ins

| Placeholder | Value |
|---|---|
| `STACK` | `Flutter x.y.z / Dart x.y.z` from `flutter --version` |
| `FLUTTER_VERSION` | the Flutter version alone; it's used by `ci.yml`, `release.yml`, and `claude.yml` |
| `CMD_INSTALL` | `flutter pub get > $null` |
| `CMD_ANALYZE` | `flutter analyze` |
| `CMD_FORMAT` | `dart format lib test` |
| `CMD_FORMAT_CHECK` | `dart format --output=none --set-exit-if-changed lib test` |
| `CMD_TEST_FILE` | `flutter test test/<file>_test.dart` |
| `CMD_TEST_ALL` | `flutter test -r failures-only` |
| `CMD_COVERAGE` | `flutter test --coverage` (writes `coverage/lcov.info`) |
| `CMD_BUILD_RELEASE` | `flutter build apk --release` (writes `build/app/outputs/flutter-apk/app-release.apk`) |
| `CMD_RUN` | `flutter run` |

SDK: CI pins the version (`FLUTTER_VERSION` in `ci.yml`). On the QR machine Flutter is on PATH at `C:\src\flutter\bin`; the kit's original machine used `D:\Desktop\projects\flutter_sdk\flutter\bin\flutter.bat`. Check that `flutter --version` matches the pin before committing. `adb` isn't on PATH: use `$LOCALAPPDATA/Android/Sdk/platform-tools/adb.exe`.

## Scaffold

From the repo root, after the kit is copied (it keeps existing files):

```bash
flutter create --org <APP_ID without its last part> --project-name <snake_case_name> --platforms android,ios .
```

Add `windows,macos,linux` to `--platforms` if desktop is a target. Then:
- `pubspec.yaml`: `version: 0.1.0+1`. The version lives only there; Android and iOS read it from pubspec.
- Set the Android `applicationId`/`namespace` and the iOS/macOS bundle IDs to `APP_ID` exactly. `flutter create` appends the project name to the org.
- `.gitignore`: add `/dist/`, `/coverage/`, `android/key.properties`, and `*.jks`.
- `analysis_options.yaml`: add `unawaited_futures`, `prefer_single_quotes`, `prefer_const_constructors`, and `always_declare_return_types`.
- Release signing reads `android/key.properties`. Without it, release builds are debug-signed.
- `release.yml` fails when the release APK declares a permission missing from its `ALLOWED` list (RUN-2). Add each permission as a shipped feature needs it, space-separated (`android.permission.POST_NOTIFICATIONS`), and update the privacy policy in the same PR.
- Delete the `desktop` job in `ci.yml` if desktop isn't a target, and the `ios` job if iOS isn't.

## Don't read

`build/`, `.dart_tool/`, `android/.gradle/`, `ios/Flutter/ephemeral/`. Grep `pubspec.lock` and `ios/Runner.xcodeproj/project.pbxproj`; never read them whole. Open `android/ ios/ linux/ macos/ windows/ web/` only for platform tasks.

## Architecture that worked

- `lib/models/`: pure classes with `toMap`/`fromMap`, and `copyWith` using a sentinel so nullable fields can be cleared. Calculations live here as pure functions, so they're easy to test.
- `lib/db/`: a `DBHelper` sqflite wrapper with an ordered list of migration steps. Never edit a merged step or the version-1 create.
- `lib/providers/`: `provider` + `ChangeNotifier`; write first, then change state, roll back on failure. Don't add another state library.
- `lib/services/`: device services behind interfaces (`Noop…` for tests, `Device…` built only in `main.dart`). A real service as a default parameter hung the test suite for 10 minutes.
- `lib/screens/`: presentational; `context.read/watch<Provider>()`.
- `lib/l10n/`: ARB files → generated `AppLocalizations`, committed. CI runs `flutter gen-l10n` and then `git diff --exit-code -- lib/l10n`.
- `test/helpers.dart`: `FakeDB`, `testApp`, and fixture builders. Database tests use `sqflite_common_ffi` in memory.

## Traps

- **Right-to-left:** use `EdgeInsetsDirectional` and `AlignmentDirectional`, and wrap amounts and numbers in `textDirection: TextDirection.ltr`. `intl` exports its own `TextDirection`, so import it with `hide TextDirection`.
- `DateFormat` with a locale away from a screen (a widget payload, a PDF, a background task) needs `initializeDateFormatting` first. Screens get it from the Material delegate.
- `pumpAndSettle` never settles with some widgets (`PdfPreview`, endless animations). Pump until a condition holds instead.
- Windows and Linux need `sqflite_common_ffi` set up in `main.dart`, with the database in the app support folder. Web has no sqflite.
- `local_auth`: Android's `MainActivity` must be a `FlutterFragmentActivity` with an AppCompat launch theme, and iOS needs `NSFaceIDUsageDescription`.
- Some plugins need the MSVC ATL component on Windows, so CI installs it.
- `permission_handler` 13.x pulls in `permission_handler_android` 14.x, which fails `checkDebugAarMetadata` unless `compileSdk = 37` is set in `android/app/build.gradle.kts` (found 2026-09-16). Keep `targetSdk` at Flutter's default.
- `mobile_scanner` 7.4.2: `controller.start()` requests the camera permission itself, so check the permission first (RUN-3). The plugin reads `autoZoom` only when a controller is built, and ML Kit's auto-zoom may go to the camera's maximum digital zoom, so SCAN-7's 2x cap can't be enforced. ML Kit brings Google's data transport, which adds INTERNET and ACCESS_NETWORK_STATE and sends ML Kit usage statistics (privacy policy → Code reading).
- Plugins add permissions silently. Check the release APK with `aapt2 dump permissions`, and prefer ~100 lines of platform-channel glue over a package that brings in WorkManager or boot receivers.
- `pdf` package: use static TTF fonts (variable fonts lose their weights), and set text direction per run on right-to-left pages. Test a PDF by reading its text back, not by byte count.
- Writing `\u` escapes has put literal invisible characters in files. Use `String.fromCharCode` instead.
- The format hook may use a different SDK than CI. Run the pinned SDK's `dart format lib test` before committing.
- Icons and splash: draw them in a test (`tool/render_app_icons_test.dart`), then run `dart run flutter_launcher_icons` and `dart run flutter_native_splash:create`, and commit the generated files.

## Device drill (Android emulator, Git Bash)

```bash
"$LOCALAPPDATA/Android/Sdk/emulator/emulator.exe" -avd Medium_Phone -no-boot-anim
adb install -r dist/<slug>-X.Y.Z.apk
adb shell am start -S -n <APP_ID>/.MainActivity
```

- Put codes in front of the virtual-scene camera with `emulator -avd Medium_Phone -virtualscene-poster wall=<png> -virtualscene-poster table=<png>`. The path must have **no spaces**, so copy the images to a temp folder first; the emulator log line `Found poster wall at <path>` confirms it loaded, though on some boots the flag still showed the default grid. `adb emu virtualscene-image wall <png>` swaps the image while the camera is open, and the swap is lost when the camera reopens (an app restart), so swap again after each restart.
- Aim the scene camera over the emulator's gRPC port, which is exact and repeatable; mouse drags mix yaw with pitch and drift. Start the emulator with `-grpc 8554` (otherwise gRPC demands a signed token), generate stubs from `emulator/lib/emulator_controller.proto` with `grpcio-tools`, then `setPhysicalModel` POSITION `[x, y, z]` in metres and ROTATION `[pitch, yaw, roll]` in degrees. The wall poster sits at (-0.807, 0.320, 5.316) facing -150°, so position (-2.06, 0.32, 3.15) with rotation (0, -150, 0) looks straight at it from 2.5 m, which decodes in about 0.2 s. Codes stop decoding past about 3 m: the scene texture is too soft. Some boots still demand the local session token even with `-grpc`: read `grpc.token` from `%LOCALAPPDATA%/Temp/avd/running/pid_*.ini` and send it as `authorization: Bearer <token>` metadata, as Android Studio does. Never print or commit it.
- The scene camera keeps its pose across an app restart, and a cold boot can start it facing the ceiling, so set the pose explicitly instead of assuming the start view.
- The scene is soft in the frames ML Kit reads (960 x 1280 on API 37): a code only reads when it covers about 55% of the frame's width, which is wider than SCAN-4's target (about 47%). So on the emulator a live code never reads inside the target, while live reads with no target work at 2 to 2.5 m; the positive in-target read needs a real phone (S6). Check SCAN-4 on the emulator from the logs (an oversized code is dropped) and the unit tests.
- `screencap` files under `/sdcard/` get indexed and show up in the photo picker. Delete them, and any test images pushed to `/sdcard/Pictures/`, then rescan: `adb shell content call --uri content://media --method scan_volume --arg external_primary`.
- Before tapping inside the photo picker, wait until `dumpsys activity activities` shows `photopicker` on top: a tap sent too early lands on whatever is underneath (once, the Play Store). On API 37 the system photo picker has its own Done step even for one photo.
- With `MSYS_NO_PATHCONV=1`, give `adb install` a Windows path (`C:/...`), not `/c/...`.
- Screenshots need `MSYS_NO_PATHCONV=1` on both halves: `adb shell "screencap -p /sdcard/s.png"`, then `adb pull /sdcard/s.png <local>`. Without it, Git Bash rewrites `/sdcard`.
- A long press or drag needs `input motionevent DOWN x y`, a sleep, `MOVE`s, and `UP` as separate calls. `input swipe` is too smooth for the launcher.
- Screenshot coordinates are in the displayed image's frame; scale them before tapping.
- In a right-to-left locale the app bar is mirrored, so the overflow menu is on the left.
- Take a screenshot after every navigation step. Blind batches of taps go wrong without anyone noticing.
- The first tap on a home-screen widget after `am force-stop` gets eaten. Tap again before concluding it's broken.
- The emulator holds the user's own test data. Back up in the app first, and restore or undo every change before finishing.
