import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/core/services/ads_service.dart';
import 'package:qrscanner/core/services/billing_service.dart';
import 'package:qrscanner/core/services/clipboard_service.dart';
import 'package:qrscanner/core/services/consent_service.dart';
import 'package:qrscanner/core/services/crash_reporter.dart';
import 'package:qrscanner/core/services/link_opener.dart';
import 'package:qrscanner/core/services/share_service.dart';
import 'package:qrscanner/services/app_services.dart';
import 'package:qrscanner/services/camera_scanner.dart';
import 'package:qrscanner/services/image_decoder.dart';
import 'package:qrscanner/services/permission_service.dart';
import 'package:qrscanner/services/system_intents.dart';
import 'package:qrscanner/services/wifi_service.dart';

void main() {
  group('AppServices.fakes()', () {
    test('holds a no-op fake for every device capability', () {
      final services = AppServices.fakes();

      expect(services.cameraScanner, isA<NoopCameraScanner>());
      expect(services.imageDecoder, isA<NoopImageDecoder>());
      expect(services.permissions, isA<NoopPermissionService>());
      expect(services.clipboard, isA<NoopClipboardService>());
      expect(services.share, isA<NoopShareService>());
      expect(services.crashReporter, isA<NoopCrashReporter>());
      expect(services.ads, isA<NoopAdsService>());
      expect(services.consent, isA<NoopConsentService>());
      expect(services.billing, isA<NoopBillingService>());
      expect(services.linkOpener, isA<NoopLinkOpener>());
      expect(services.systemIntents, isA<NoopSystemIntents>());
      expect(services.wifi, isA<NoopWifiService>());
    });

    test(
      'every capability answers from Dart alone and records the call',
      () async {
        final services = AppServices.fakes();

        await services.cameraScanner.start();
        await services.imageDecoder.decodeFile('/does/not/exist.png');
        await services.permissions.cameraStatus();
        await services.clipboard.copyText('text');
        await services.share.shareText('text');
        await services.crashReporter.setCollectionEnabled(enabled: false);
        await services.ads.initialize();
        await services.consent.refresh();
        await services.billing.initialize();
        await services.linkOpener.open(Uri.parse('https://example.com'));
        await services.systemIntents.openWifiSettings();
        await services.wifi.canJoinNetworks();

        expect(
          <String>[
            ...(services.cameraScanner as NoopCameraScanner).calls,
            ...(services.imageDecoder as NoopImageDecoder).calls,
            ...(services.permissions as NoopPermissionService).calls,
            ...(services.clipboard as NoopClipboardService).calls,
            ...(services.share as NoopShareService).calls,
            ...(services.crashReporter as NoopCrashReporter).calls,
            ...(services.ads as NoopAdsService).calls,
            ...(services.consent as NoopConsentService).calls,
            ...(services.billing as NoopBillingService).calls,
            ...(services.linkOpener as NoopLinkOpener).calls,
            ...(services.systemIntents as NoopSystemIntents).calls,
            ...(services.wifi as NoopWifiService).calls,
          ],
          <String>[
            'start',
            'decodeFile: /does/not/exist.png',
            'cameraStatus',
            'copyText: text',
            'shareText: text',
            'setCollectionEnabled: false',
            'initialize',
            'refresh',
            'initialize',
            'open: https://example.com',
            'openWifiSettings',
            'canJoinNetworks',
          ],
        );

        await services.cameraScanner.dispose();
        await services.billing.dispose();
      },
    );

    test(
      'builds a fresh set per call, so no fake carries calls between tests',
      () async {
        final first = AppServices.fakes();
        final second = AppServices.fakes();

        await first.clipboard.copyText('one');

        expect((first.clipboard as NoopClipboardService).calls, <String>[
          'copyText: one',
        ]);
        expect((second.clipboard as NoopClipboardService).calls, isEmpty);
      },
    );
  });

  group('NoopClipboardService', () {
    test(
      'copies, and hands the same text back on an explicit read (RES-1, RES-2)',
      () async {
        const payload = 'WIFI:T:WPA;S:Home;P:hunter2;;';
        final clipboard = NoopClipboardService();

        expect(await clipboard.readText(), isNull);
        await clipboard.copyText(payload);

        expect(await clipboard.readText(), payload);
        expect(clipboard.calls, <String>[
          'readText',
          'copyText: $payload',
          'readText',
        ]);
      },
    );
  });

  group('NoopShareService', () {
    test(
      'records the save with its byte count and writes no file (SAVE-2, EXP-1)',
      () async {
        const name = 'qr-history-20260917-1030.csv';
        final share = NoopShareService();

        final result = await share.saveFile(
          suggestedName: name,
          mimeType: 'text/csv',
          bytes: Uint8List.fromList(<int>[1, 2, 3]),
        );

        expect(result.saved, isTrue);
        expect(result.displayName, name);
        expect(share.calls, <String>['saveFile: $name (text/csv, 3 bytes)']);
        expect(File(name).existsSync(), isFalse);
      },
    );

    test('reports a cancelled save with no name (SAVE-2)', () async {
      final share = NoopShareService(saveOutcome: SaveOutcome.cancelled);

      final result = await share.saveFile(
        suggestedName: 'wifi-Home-20260917-1030.png',
        mimeType: 'image/png',
        bytes: Uint8List(0),
      );

      expect(result.saved, isFalse);
      expect(result.displayName, isNull);
    });

    test('shares a file it never opens (SAVE-5)', () async {
      final share = NoopShareService();

      await share.shareFile(path: '/no/such/code.png', mimeType: 'image/png');

      expect(share.calls, <String>['shareFile: /no/such/code.png (image/png)']);
    });
  });

  group('NoopCrashReporter', () {
    test(
      'keeps no error until the user turns collection on (PRIV-3)',
      () async {
        final reporter = NoopCrashReporter();

        expect(reporter.isCollectionEnabled, isFalse);
        await reporter.recordError(
          StateError('boom'),
          null,
          reason: 'before opt-in',
        );
        expect(reporter.recordedErrors, isEmpty);

        await reporter.setCollectionEnabled(enabled: true);
        await reporter.recordError(
          StateError('later'),
          StackTrace.empty,
          reason: 'after opt-in',
        );

        expect(reporter.recordedErrors, <String>[
          'Bad state: later (after opt-in)',
        ]);
        expect(reporter.calls, <String>[
          'recordError: Bad state: boom',
          'setCollectionEnabled: true',
          'recordError: Bad state: later',
        ]);
      },
    );
  });

  group('NoopConsentService', () {
    test(
      'an unresolved or unavailable session requests no ad (ADS-5, PRIV-1)',
      () async {
        final consent = NoopConsentService();

        expect(consent.status, ConsentStatus.unresolved);
        expect(consent.canRequestAds, isFalse);

        expect(await consent.refresh(), ConsentStatus.unavailable);

        expect(consent.canRequestAds, isFalse);
        expect(consent.personalizedAdsAllowed, isFalse);
        expect(consent.calls, <String>['refresh']);
      },
    );

    test(
      'a required form is answered before the first ad request (PRIV-1, ADS-5)',
      () async {
        final consent = NoopConsentService(
          seededStatus: ConsentStatus.formRequired,
          personalizedAllowed: true,
        );

        await consent.refresh();
        expect(consent.canRequestAds, isFalse);

        expect(await consent.showFormIfRequired(), ConsentStatus.obtained);

        expect(consent.canRequestAds, isTrue);
        expect(consent.personalizedAdsAllowed, isTrue);
        expect(consent.calls, <String>['refresh', 'showFormIfRequired']);
      },
    );
  });

  group('NoopAdsService', () {
    test('reserves a height, reports nothing ready and shows no banner (ADS-4, ADS-5)', () async {
      final ads = NoopAdsService();

      expect(await ads.bannerHeight(widthDp: 360), 50);
      final ready = await ads.loadBanner(
        slot: 'history',
        widthDp: 360,
        personalized: false,
      );

      expect(ready, isFalse);
      expect(ads.bannerFor('history'), isNull);
      expect(ads.calls, <String>[
        'bannerHeight: 360.0',
        'loadBanner: history (360.0 dp, personalized: false)',
      ]);
    });

    test('records one entry per request, not one per frame a screen reads the '
        'banner (ADS-1, ADS-4)', () async {
      final ads = NoopAdsService();

      await ads.loadBanner(slot: 'history', widthDp: 360, personalized: false);
      // What a screen does on every rebuild: read the slot and keep the
      // reserved height (ADS-4). The fake must not count these.
      for (var frame = 0; frame < 3; frame++) {
        expect(ads.bannerFor('history'), isNull);
      }
      await ads.loadBanner(slot: 'settings', widthDp: 360, personalized: false);

      expect(ads.requestedSlots, <String>['history', 'settings']);
      expect(ads.calls, <String>[
        'loadBanner: history (360.0 dp, personalized: false)',
        'loadBanner: settings (360.0 dp, personalized: false)',
      ]);
    });
  });

  group('NoopBillingService', () {
    test('owns nothing, records the buy, and reports a refund (PRO-1, PRO-6, PRO-7)', () async {
      const productId = 'remove_ads';
      final billing = NoopBillingService();
      final ownership = <Set<String>>[];
      final subscription = billing.ownedProducts.listen(ownership.add);

      expect(await billing.isOwned(productId), isFalse);
      expect((await billing.buy(productId)).ownsProduct, isFalse);
      expect(await billing.restorePurchases(), isEmpty);

      billing.grantOwnership(productId);
      expect(await billing.isOwned(productId), isTrue);
      expect(await billing.restorePurchases(), <String>{productId});

      billing.revokeOwnership(productId);
      expect(await billing.isOwned(productId), isFalse);

      await pumpEventQueue();
      expect(ownership, <Set<String>>[
        <String>{productId},
        <String>{},
      ]);
      expect(billing.calls, <String>[
        'isOwned: remove_ads',
        'buy: remove_ads',
        'restorePurchases',
        'isOwned: remove_ads',
        'restorePurchases',
        'isOwned: remove_ads',
      ]);

      await subscription.cancel();
      await billing.dispose();
    });

    test('reports the store price for a seeded product and none for another (PRO-3, PRO-5)', () async {
      final billing = NoopBillingService(
        product: const StoreProduct(
          id: 'remove_ads',
          title: 'Remove ads',
          formattedPrice: r'$1.99',
        ),
      );

      expect(
        (await billing.loadProduct('remove_ads'))?.formattedPrice,
        r'$1.99',
      );
      expect(await billing.loadProduct('something_else'), isNull);

      await billing.dispose();
    });
  });

  group('NoopLinkOpener', () {
    test(
      'records the URL and reports a Custom Tab, never a bare launch (LINK-8)',
      () async {
        final opener = NoopLinkOpener();
        final url = Uri.parse('https://example.com/a?b=c');

        expect(await opener.open(url), LinkOpenOutcome.customTab);

        expect(opener.openedUrls, <Uri>[url]);
        expect(opener.calls, <String>['open: https://example.com/a?b=c']);
      },
    );

    test('reports when no app can show a web link (RES-14)', () async {
      final opener = NoopLinkOpener(
        outcome: LinkOpenOutcome.noHandler,
        canOpen: false,
      );

      expect(await opener.canOpenWebLinks(), isFalse);
      expect(
        await opener.open(Uri.parse('https://example.com')),
        LinkOpenOutcome.noHandler,
      );
    });
  });

  group('NoopImageDecoder', () {
    test(
      'a path that does not exist comes back as no code found (SCAN-11)',
      () async {
        final decoder = NoopImageDecoder();

        final result = await decoder.decodeFile('/does/not/exist.png');

        expect(result.foundCode, isFalse);
        expect(result.detections, isEmpty);
        expect(decoder.calls, <String>['decodeFile: /does/not/exist.png']);
      },
    );

    test(
      'a seeded pass with two codes is listed, not guessed at (SCAN-13)',
      () async {
        final decoder = NoopImageDecoder(
          result: const ImageDecodeResult(<CodeDetection>[
            CodeDetection(payload: 'https://example.com', symbology: 'qrCode'),
            CodeDetection(payload: '5901234123457', symbology: 'ean13'),
          ]),
        );

        final result = await decoder.decodeFile('/photos/two-codes.png');

        expect(result.hasSeveralCodes, isTrue);
        expect(
          result.detections.map((CodeDetection code) => code.payload).toList(),
          <String>['https://example.com', '5901234123457'],
        );
      },
    );
  });

  group('NoopCameraScanner', () {
    test(
      'delivers a detection pass, and none while paused (SCAN-3, SCAN-13)',
      () async {
        const detection = CodeDetection(
          payload: 'https://example.com',
          symbology: 'qrCode',
        );
        final scanner = NoopCameraScanner();
        final passes = <List<CodeDetection>>[];
        final subscription = scanner.detections.listen(passes.add);

        expect(await scanner.start(), isTrue);
        expect(scanner.isDetecting, isTrue);
        scanner.emit(const <CodeDetection>[detection]);
        await pumpEventQueue();

        expect(passes, <List<CodeDetection>>[
          <CodeDetection>[detection],
        ]);

        await scanner.pause();
        scanner.emit(const <CodeDetection>[detection]);
        await pumpEventQueue();

        expect(passes, hasLength(1));
        expect(scanner.isDetecting, isFalse);

        await scanner.resume();
        expect(scanner.isDetecting, isTrue);

        await subscription.cancel();
        await scanner.dispose();
        expect(scanner.calls, <String>['start', 'pause', 'resume', 'dispose']);
      },
    );

    test('the torch goes off when the camera stops, and does nothing without a flash (SCAN-6)', () async {
      final scanner = NoopCameraScanner();
      addTearDown(scanner.dispose);

      expect(scanner.torchState, TorchState.off);
      await scanner.start();
      await scanner.setTorch(on: true);
      expect(scanner.torchState, TorchState.on);

      await scanner.stop();
      expect(scanner.torchState, TorchState.off);
      expect(scanner.isRunning, isFalse);

      final noFlash = NoopCameraScanner(torchAvailable: false);
      addTearDown(noFlash.dispose);
      await noFlash.setTorch(on: true);

      expect(noFlash.torchState, TorchState.unavailable);
    });

    test(
      'zoom is clamped and the scan window is kept (SCAN-4, SCAN-7)',
      () async {
        const target = Rect.fromLTWH(20, 200, 320, 320);
        final scanner = NoopCameraScanner();
        addTearDown(scanner.dispose);

        expect(scanner.zoom, 1);
        await scanner.setZoom(2);
        expect(scanner.zoom, 2);

        await scanner.setZoom(99);
        expect(scanner.zoom, scanner.maxZoom);

        await scanner.setScanWindow(target);
        expect(scanner.scanWindow, target);
      },
    );

    test('a screen can build the preview before the camera starts (RUN-1)', () {
      final scanner = NoopCameraScanner(startSucceeds: false);
      addTearDown(scanner.dispose);

      final Widget preview = scanner.buildPreview(fit: BoxFit.contain);

      // The fake shows no camera at all: it hands back an empty box that asks
      // for no space, so what a screen draws over it is RUN-1's own
      // placeholder, reason and button. It still records the fit it was asked
      // for, so a screen that asks for the wrong one is caught.
      expect(
        preview,
        isA<SizedBox>()
            .having((SizedBox box) => box.width, 'width', 0)
            .having((SizedBox box) => box.height, 'height', 0)
            .having((SizedBox box) => box.child, 'child', isNull),
      );
      expect(scanner.isRunning, isFalse);
      expect(scanner.calls, <String>['buildPreview: BoxFit.contain']);
    });
  });

  group('NoopPermissionService', () {
    test(
      'a fresh install reads denied and was never asked (RUN-1, spike S8)',
      () async {
        final permissions = NoopPermissionService();

        expect(await permissions.cameraStatus(), CameraPermissionState.denied);
        expect(await permissions.cameraRequestedBefore(), isFalse);
        expect(await permissions.shouldShowCameraRationale(), isFalse);
      },
    );

    test('a prompt Android will not show reports permanently denied (RUN-6, spike S8)', () async {
      final permissions = NoopPermissionService(
        requestResult: CameraPermissionState.permanentlyDenied,
      );

      expect(
        await permissions.requestCamera(),
        CameraPermissionState.permanentlyDenied,
      );
      expect(await permissions.cameraRequestedBefore(), isTrue);
      // Spike S8: the system status still only says denied, which is why RUN-6
      // keys off what the request returned.
      expect(await permissions.cameraStatus(), CameraPermissionState.denied);
      expect(await permissions.openAppSettings(), isTrue);
      expect(permissions.calls, <String>[
        'requestCamera',
        'cameraRequestedBefore',
        'cameraStatus',
        'openAppSettings',
      ]);
    });

    test('an allowed camera reads granted (RUN-7)', () async {
      final permissions = NoopPermissionService(
        initialState: CameraPermissionState.granted,
      );

      expect(await permissions.cameraStatus(), CameraPermissionState.granted);
    });
  });

  group('NoopWifiService', () {
    test(
      'joining is unsupported until spike S5 passes (RES-4, RES-5)',
      () async {
        final wifi = NoopWifiService();

        expect(await wifi.canJoinNetworks(), isFalse);
        expect(
          await wifi.join(ssid: 'Home', security: WifiSecurity.wpa2),
          WifiJoinOutcome.unsupported,
        );
      },
    );

    test(
      'a joinable network is recorded without its password (RES-5, DATA-5)',
      () async {
        final wifi = NoopWifiService(canJoin: true);

        final outcome = await wifi.join(
          ssid: 'Home',
          security: WifiSecurity.wpa2,
          password: 'hunter2',
        );

        expect(outcome, WifiJoinOutcome.joined);
        expect(wifi.calls, <String>['join: Home (wpa2, hidden: false)']);
        expect(wifi.calls.join(), isNot(contains('hunter2')));
      },
    );

    test('Android cannot join a WEP network from an app (RES-4)', () async {
      final wifi = NoopWifiService(canJoin: true);

      expect(
        await wifi.join(
          ssid: 'Old',
          security: WifiSecurity.wep,
          password: 'hunter2',
        ),
        WifiJoinOutcome.unsupported,
      );
    });
  });

  group('NoopSystemIntents', () {
    test(
      'a contact is handed over with its leading + kept (RES-6, GEN-7)',
      () async {
        final intents = NoopSystemIntents();

        final outcome = await intents.insertContact(
          const ContactDraft(
            name: 'Ada Lovelace',
            phoneNumbers: <String>['+49301234567'],
            emails: <String>['ada@example.com'],
            organisation: 'Analytical Engines',
          ),
        );

        expect(outcome, SystemHandOffOutcome.handedOff);
        expect(intents.calls.single, startsWith('insertContact: Ada Lovelace'));
        expect(intents.calls.single, contains('+49301234567'));
        expect(intents.calls.single, contains('Analytical Engines'));
      },
    );

    test(
      'an event keeps the times it was encoded with (RES-6, DATE-3)',
      () async {
        final intents = NoopSystemIntents();

        await intents.insertCalendarEvent(
          CalendarEventDraft(
            title: 'Launch',
            start: DateTime.utc(2026, 10, 16, 9),
            end: DateTime.utc(2026, 10, 16, 10),
          ),
        );

        expect(intents.calls.single, contains('2026-10-16T09:00:00.000Z'));
        expect(intents.calls.single, contains('2026-10-16T10:00:00.000Z'));
      },
    );

    test('the dialer and messaging apps are only prefilled (RES-7)', () async {
      final intents = NoopSystemIntents();

      await intents.dial('+49301234567');
      await intents.composeSms(phoneNumber: '+49301234567', message: 'Hi');
      await intents.composeEmail(
        to: <String>['ada@example.com'],
        subject: 'Feedback',
      );
      await intents.openWifiSettings();
      await intents.showLocation(latitude: 52.52, longitude: 13.405);

      expect(intents.calls, <String>[
        'dial: +49301234567',
        'composeSms: +49301234567 (message: Hi)',
        'composeEmail: ada@example.com (subject: Feedback)',
        'openWifiSettings',
        'showLocation: 52.52,13.405 (label: )',
      ]);
    });

    test(
      'an action no installed app can take reports no handler (RES-14)',
      () async {
        final intents = NoopSystemIntents(
          unhandled: <SystemHandOff>{SystemHandOff.dial},
        );

        expect(await intents.canHandle(SystemHandOff.dial), isFalse);
        expect(await intents.canHandle(SystemHandOff.sms), isTrue);
        expect(
          await intents.dial('+49301234567'),
          SystemHandOffOutcome.noHandler,
        );
      },
    );
  });
}
