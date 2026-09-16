import 'package:flutter_test/flutter_test.dart';
import 'package:qrscanner/main.dart';

void main() {
  testWidgets('the app starts and shows its name', (tester) async {
    await tester.pumpWidget(const QrScannerApp());

    expect(find.text('QR Scanner + Generator'), findsOneWidget);
  });
}
