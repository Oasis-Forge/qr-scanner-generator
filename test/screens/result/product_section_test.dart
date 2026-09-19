import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/core/services/link_opener.dart';
import 'package:qrscanner/models/parsed_payload.dart';
import 'package:qrscanner/models/record_enums.dart';
import 'package:qrscanner/screens/result/product_section.dart';
import 'package:qrscanner/state/result_state.dart';
import 'package:qrscanner/state/settings_state.dart';

import 'section_test_helpers.dart';

void main() {
  group('ProductSection (RES-9)', () {
    testWidgets('shows the number and the format', (WidgetTester tester) async {
      final ResultState state = resultStateFor(
        outcomeFor(
          '4006381333931',
          parsedType: ParsedType.product,
          symbology: Symbology.ean13,
        ),
      );
      await pumpSection(
        tester,
        state,
        ProductSection(product: state.payload as Product),
      );

      expect(find.text('4006381333931'), findsOneWidget);
      expect(find.text('EAN-13'), findsOneWidget);
    });

    testWidgets('an ISBN shows ISBN as its format, not EAN-13', (
      WidgetTester tester,
    ) async {
      final ResultState state = resultStateFor(
        outcomeFor(
          '9780306406157',
          parsedType: ParsedType.product,
          symbology: Symbology.ean13,
        ),
      );
      await pumpSection(
        tester,
        state,
        ProductSection(product: state.payload as Product),
      );

      expect(find.text('ISBN'), findsOneWidget);
      expect(find.text('EAN-13'), findsNothing);
    });

    testWidgets(
      "Search the web opens the chosen engine's search for the number, no "
      'shopping action and no warning',
      (WidgetTester tester) async {
        final NoopLinkOpener linkOpener = NoopLinkOpener();
        final ResultState state = resultStateFor(
          outcomeFor(
            '4006381333931',
            parsedType: ParsedType.product,
            symbology: Symbology.ean13,
          ),
          linkOpener: linkOpener,
          searchEngine: SearchEngine.bing,
        );
        await pumpSection(
          tester,
          state,
          ProductSection(product: state.payload as Product),
        );

        expect(find.text('Shop now'), findsNothing);
        await tester.tap(find.text('Search the web'));
        await tester.pumpAndSettle();

        expect(linkOpener.openedUrls.single.host, 'www.bing.com');
        expect(
          linkOpener.openedUrls.single.queryParameters['q'],
          '4006381333931',
        );
      },
    );

    testWidgets(
      'RES-14: with no browser, Search the web is disabled with a reason',
      (WidgetTester tester) async {
        final ResultState state = resultStateFor(
          outcomeFor(
            '4006381333931',
            parsedType: ParsedType.product,
            symbology: Symbology.ean13,
          ),
          linkOpener: NoopLinkOpener(canOpen: false),
        );
        await pumpSection(
          tester,
          state,
          ProductSection(product: state.payload as Product),
        );

        final FilledButton button = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Search the web'),
        );
        expect(button.onPressed, isNull);
        expect(find.text('No browser is installed.'), findsOneWidget);
      },
    );
  });
}
