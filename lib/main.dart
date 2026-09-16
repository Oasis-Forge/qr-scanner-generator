import 'package:flutter/material.dart';

void main() {
  runApp(const QrScannerApp());
}

/// Placeholder shell until Phase 1 adds the theme, state layer and services.
class QrScannerApp extends StatelessWidget {
  const QrScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Scanner + Generator',
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      home: const Scaffold(body: Center(child: Text('QR Scanner + Generator'))),
    );
  }
}
