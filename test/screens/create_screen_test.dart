import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/core/services/ads_service.dart';
import 'package:qrscanner/core/services/consent_service.dart';
import 'package:qrscanner/models/record_enums.dart' show ParsedType;
import 'package:qrscanner/screens/create/create_form_body.dart';
import 'package:qrscanner/screens/create/created_code_view.dart';
import 'package:qrscanner/screens/create/text_form.dart';
import 'package:qrscanner/screens/create/type_picker.dart';
import 'package:qrscanner/screens/create/wifi_form.dart';
import 'package:qrscanner/screens/create_screen.dart';
import 'package:qrscanner/services/app_services.dart';
import 'package:qrscanner/state/success_counts.dart';

import '../harness/generator_scope.dart';
import '../helpers/fake_stores.dart';
import '../helpers/memory_record_dao.dart';
import '../helpers/test_app.dart';
import 'create/create_test_helpers.dart';

void main() {
  group('the Create type picker (GEN-1)', () {
    testWidgets('shows all seven types, each with an icon and a label', (
      WidgetTester tester,
    ) async {
      await pumpApp(
        tester,
        GeneratorScope(dao: MemoryRecordDao(), child: const CreateScreen()),
      );

      for (final String label in <String>[
        'Link',
        'Text',
        'Wi-Fi',
        'Contact',
        'Phone number',
        'Email',
        'SMS',
      ]) {
        expect(find.text(label), findsOneWidget);
      }
      // The banner sits below the list (ADS-1), not inside the picker.
    });

    testWidgets('tapping a tile opens that type\'s form', (
      WidgetTester tester,
    ) async {
      await pumpApp(
        tester,
        GeneratorScope(dao: MemoryRecordDao(), child: const CreateScreen()),
      );

      await tester.tap(find.byKey(CreateTypePicker.tileKey(_wifi)));
      await tester.pumpAndSettle();

      expect(find.text('Wi-Fi'), findsOneWidget);
      expect(find.byKey(WifiFormFields.ssidFieldKey), findsOneWidget);
      expect(find.byKey(CreateFormBody.createButtonKey), findsOneWidget);
    });

    testWidgets('the back button returns to the picker', (
      WidgetTester tester,
    ) async {
      await pumpApp(
        tester,
        GeneratorScope(dao: MemoryRecordDao(), child: const CreateScreen()),
      );

      await tester.tap(find.byKey(CreateTypePicker.tileKey(_wifi)));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(CreateScreen.backKey));
      await tester.pumpAndSettle();

      expect(find.byType(CreateTypePicker), findsOneWidget);
      expect(find.byKey(WifiFormFields.ssidFieldKey), findsNothing);
    });

    testWidgets('LANG-5: the picker reads in Arabic and mirrors', (
      WidgetTester tester,
    ) async {
      await pumpApp(
        tester,
        GeneratorScope(dao: MemoryRecordDao(), child: const CreateScreen()),
        locale: const Locale('ar'),
      );

      expect(find.text('اختر ما تريد إنشاءه'), findsOneWidget);
      expect(find.text('نص'), findsOneWidget);
      expect(find.text('شبكة Wi-Fi'), findsOneWidget);
      // Each format is its own row, in GEN-1's order, so URL sits above
      // Text whichever way the screen reads.
      expect(
        tester.getCenter(find.byKey(CreateTypePicker.tileKey(_url))).dy,
        lessThan(
          tester.getCenter(find.byKey(CreateTypePicker.tileKey(_text))).dy,
        ),
      );
      // The row itself mirrors: its number leads from the right in Arabic.
      final double screenCentre = tester
          .getCenter(find.byKey(CreateTypePicker.tileKey(_url)))
          .dx;
      expect(tester.getCenter(find.text('01')).dx, greaterThan(screenCentre));
    });
  });

  group('the Create flow end to end (GEN-1, GEN-13, STY-1, SAVE-1)', () {
    testWidgets('picking Text, filling it in and tapping Create shows the '
        'created code', (WidgetTester tester) async {
      final SeedableImageDecoder decoder = SeedableImageDecoder();
      seedMatchingCheck(decoder, 'hello world');
      decoder.hold = Completer<void>();
      await pumpApp(
        tester,
        GeneratorScope(
          dao: MemoryRecordDao(),
          imageDecoder: decoder,
          child: const CreateScreen(),
        ),
      );

      await tester.tap(find.byKey(CreateTypePicker.tileKey(_text)));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(TextFormFields.fieldKey),
        'hello world',
      );
      await tester.pump();
      await tester.tap(find.byKey(CreateFormBody.createButtonKey));
      await tester.pump();

      expect(find.byKey(CreatedCodeView.progressKey), findsOneWidget);

      decoder.hold!.complete();
      await tester.pumpAndSettle();

      expect(find.byKey(CreatedCodeView.imageKey), findsOneWidget);
      expect(find.text('hello world'), findsOneWidget);
      final SelectableText content = tester.widget<SelectableText>(
        find.byType(SelectableText),
      );
      expect(content.data, 'hello world');
      // LANG-5: the payload stays left to right even were the screen
      // Arabic.
      expect(content.textDirection, TextDirection.ltr);

      final FilledButton save = tester.widget<FilledButton>(
        find.byKey(CreatedCodeView.saveButtonKey),
      );
      expect(save.onPressed, isNotNull);
    });
  });

  group('going back (GEN-1)', () {
    testWidgets('Back from a created code returns to its form with the text '
        'kept, and picking the same type again opens that form', (
      WidgetTester tester,
    ) async {
      final SeedableImageDecoder decoder = SeedableImageDecoder();
      seedMatchingCheck(decoder, 'first code');
      await pumpApp(
        tester,
        GeneratorScope(
          dao: MemoryRecordDao(),
          imageDecoder: decoder,
          child: const CreateScreen(),
        ),
      );
      await tester.tap(find.byKey(CreateTypePicker.tileKey(_text)));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(TextFormFields.fieldKey), 'first code');
      await tester.pump();
      await tester.tap(find.byKey(CreateFormBody.createButtonKey));
      await tester.pumpAndSettle();
      expect(find.byKey(CreatedCodeView.imageKey), findsOneWidget);

      await tester.tap(find.byKey(CreateScreen.backKey));
      await tester.pumpAndSettle();
      expect(find.byKey(CreatedCodeView.imageKey), findsNothing);
      expect(find.byKey(CreateFormBody.createButtonKey), findsOneWidget);
      expect(find.text('first code'), findsOneWidget);

      // Create again, then leave through the picker and pick Text again.
      await tester.tap(find.byKey(CreateFormBody.createButtonKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(CreateScreen.backKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(CreateScreen.backKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(CreateTypePicker.tileKey(_text)));
      await tester.pumpAndSettle();

      expect(find.byKey(CreatedCodeView.imageKey), findsNothing);
      expect(find.byKey(CreateFormBody.createButtonKey), findsOneWidget);
    });
  });

  group('the banner (ADS-1, ADS-3)', () {
    testWidgets('sits below the type picker once ads are allowed, and never '
        'on a form', (WidgetTester tester) async {
      final NoopAdsService ads = NoopAdsService();
      final SuccessCounts counts = SuccessCounts(FakeKeyValueStore());
      await counts.load();
      await counts.recordSuccessfulScan();
      addTearDown(counts.dispose);
      await pumpApp(
        tester,
        GeneratorScope(dao: MemoryRecordDao(), child: const CreateScreen()),
        successCounts: counts,
        services: AppServices.fakes().copyWith(
          ads: ads,
          consent: NoopConsentService(seededStatus: ConsentStatus.notNeeded),
        ),
      );

      expect(ads.calls.last, startsWith('loadBanner: create_type_picker'));
      expect(find.byType(Divider), findsOneWidget);
      expect(
        tester.getTopLeft(find.byType(Divider)).dy,
        greaterThanOrEqualTo(
          tester.getBottomLeft(find.byType(CreateTypePicker)).dy,
        ),
      );

      await tester.tap(find.byKey(CreateTypePicker.tileKey(_text)));
      await tester.pumpAndSettle();

      expect(find.byType(Divider), findsNothing);
      expect(ads.calls.last, 'disposeBanner: create_type_picker');
    });
  });
}

const ParsedType _url = ParsedType.url;
const ParsedType _wifi = ParsedType.wifi;
const ParsedType _text = ParsedType.text;
