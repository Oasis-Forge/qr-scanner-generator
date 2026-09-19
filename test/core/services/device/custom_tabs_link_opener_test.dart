import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/core/services/device/custom_tabs_link_opener.dart';
import 'package:qrscanner/core/services/link_opener.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CustomTabsLinkOpener off Android (this test host)', () {
    const CustomTabsLinkOpener opener = CustomTabsLinkOpener(
      themeColor: Color(0xFF3F51B5),
    );

    test('RES-14: reports no app for web links, so the action shows '
        'disabled with its reason instead of doing nothing', () async {
      expect(await opener.canOpenWebLinks(), isFalse);
    });

    test('LINK-8: a launch that cannot happen reports failed and never '
        'throws at the caller', () async {
      expect(
        await opener.open(
          Uri.parse('https://example.com/search?q=5901234123457'),
        ),
        LinkOpenOutcome.failed,
      );
    });

    test('LINK-5: refuses a blocked scheme before any launch', () {
      expect(
        () => opener.open(Uri.parse('javascript:alert(1)')),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
