/// GEN-12's capacity math: the QR byte-mode data capacity at error
/// correction M, version by version, and the version a given content length
/// needs.
///
/// Pure Dart, and deliberately independent of the `barcode` / `qr` packages:
/// it exists so [qr_renderer.dart] can pick, *before* asking either package
/// to encode anything, the exact module count STY-1's canvas will draw at —
/// which is what lets that canvas use integer pixels-per-module (spike S13)
/// instead of a fractional scale factor. The numbers below reproduce
/// ISO/IEC 18004's own version-selection rule (ANSI table of data codewords
/// per version, mirrored in the bundled `qr` package's `rs_block.dart`) in a
/// closed form, so this file never imports either package and can't drift
/// out of step with what they actually draw — `qr_renderer_test.dart` checks
/// the two agree.
library;

/// The total data codewords (bytes) a QR symbol carries at error correction
/// M, version by version — the sum of each version+M row's `dataCount`
/// column in the RS-block table every QR encoder is built from (ISO/IEC
/// 18004 Table 9; ZXing and the `qr` package this app's encoder is built on
/// both carry the same numbers, just laid out as blocks instead of a total).
///
/// Index 0 is version 1, index 39 is version 40.
const List<int> _dataCodewordsAtErrorCorrectionM = <int>[
  16, 28, 44, 64, 86, 108, 124, 154, 182, 216, //
  254, 290, 334, 365, 415, 453, 507, 563, 627, 669, //
  714, 782, 860, 914, 1000, 1062, 1128, 1193, 1267, 1373, //
  1455, 1541, 1631, 1725, 1812, 1914, 1992, 2102, 2216, 2334, //
];

/// The smallest QR version (1 to 40).
const int qrMinVersion = 1;

/// The largest QR version (1 to 40): 177 x 177 modules.
const int qrMaxVersion = 40;

/// The byte-mode character-count-indicator width, in bits, for [version]
/// (ISO/IEC 18004 Table 3): 8 bits for versions 1-9, 16 bits for 10-40. Byte
/// mode is the only mode this app's encoder ever uses, so the numeric and
/// alphanumeric widths in the standard don't apply here.
int _countIndicatorBits(int version) => version <= 9 ? 8 : 16;

/// The most bytes a byte-mode QR symbol can carry at error correction M and
/// [version], after its 4-bit mode indicator and count-indicator overhead
/// (ISO/IEC 18004 §7.4.1; verified against the `qr` package's own
/// `_calculateTypeNumberFromData` by `qr_capacity_test.dart`).
int qrMaxByteCapacityAtErrorCorrectionM(int version) {
  RangeError.checkValueInInterval(
    version,
    qrMinVersion,
    qrMaxVersion,
    'version',
  );
  final int dataBits = _dataCodewordsAtErrorCorrectionM[version - 1] * 8;
  final int overheadBits = 4 + _countIndicatorBits(version);
  return (dataBits - overheadBits) ~/ 8;
}

/// GEN-12: the most bytes any QR symbol can carry in byte mode at error
/// correction M — [qrMaxByteCapacityAtErrorCorrectionM] at [qrMaxVersion].
/// The capacity meter and the over-the-limit block are both measured against
/// this one number, since STY-1 always renders at M.
final int qrMaxCapacityBytes = qrMaxByteCapacityAtErrorCorrectionM(
  qrMaxVersion,
);

/// The smallest QR version that can hold [byteLength] bytes in byte mode at
/// error correction M, or [qrMaxVersion] when [byteLength] is over
/// [qrMaxCapacityBytes] (content this large is blocked by GEN-12 before this
/// is ever asked, so this stays total rather than throwing).
int qrVersionForByteLength(int byteLength) {
  for (int version = qrMinVersion; version < qrMaxVersion; version++) {
    if (qrMaxByteCapacityAtErrorCorrectionM(version) >= byteLength) {
      return version;
    }
  }
  return qrMaxVersion;
}

/// A QR symbol's side length in modules at [version] (ISO/IEC 18004 §6.2):
/// 21 at version 1, growing by 4 modules per version.
int qrModuleCountForVersion(int version) => version * 4 + 17;

/// The module count [qrVersionForByteLength] and [qrModuleCountForVersion]
/// pick for [byteLength] bytes of byte-mode content at error correction M —
/// what [qr_renderer.dart] sizes its canvas from.
int qrModuleCountForByteLength(int byteLength) =>
    qrModuleCountForVersion(qrVersionForByteLength(byteLength));
