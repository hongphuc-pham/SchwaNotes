// Draws the Schwa Notes icon, logo and store graphics (M8, direction A,
// "Marked": a white schwa on the theme's green with a coral highlight bar).
//
// Not part of the suite - it lives in tool/, and `flutter test` with no path
// only runs test/. Run it by hand when the artwork changes, look at every PNG,
// and commit them:
//
//     flutter test tool/brand_assets_test.dart
//
// A test rather than a script because it needs dart:ui to rasterise, and a
// Flutter test is the one place that has it without adding a dependency
// (RULES §42 - no flutter_launcher_icons).
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/core/theme/tokens.dart';

/// The glyph the whole identity is built on.
const String _schwa = 'ə';

/// White, not pure: the theme's light surface, so the icon and the app agree.
const Color _paper = AppSurfaces.surfaceLight;
const Color _green = AppColorSeeds.primary;
const Color _coral = AppColorSeeds.secondary;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await _loadFont('Charis SIL', 'assets/fonts/charis_sil/CharisSIL-Bold.ttf');
    await _loadFont('Inter', 'assets/fonts/inter/Inter-Medium.ttf');
  });

  const res = 'android/app/src/main/res';

  testWidgets('legacy launcher icons (pre-Android 8), full bleed', (
    tester,
  ) async {
    const densities = <String, int>{
      'mdpi': 48,
      'hdpi': 72,
      'xhdpi': 96,
      'xxhdpi': 144,
      'xxxhdpi': 192,
    };
    for (final MapEntry(key: density, value: size) in densities.entries) {
      await _write(
        tester,
        '$res/mipmap-$density/ic_launcher.png',
        size,
        size,
        (canvas, s) => _markedIcon(canvas, s, background: _green),
      );
    }
  });

  testWidgets('adaptive icon layers (Android 8+) and the themed monochrome', (
    tester,
  ) async {
    // 108dp at xxxhdpi. Launchers mask to at least the inner 72dp and promise
    // only the central 66dp circle, so the mark is drawn to that circle.
    const size = 432;
    await _write(
      tester,
      '$res/mipmap-xxxhdpi/ic_launcher_foreground.png',
      size,
      size,
      (canvas, s) => _markedIcon(canvas, s, safeZone: 66 / 108),
    );
    await _write(
      tester,
      '$res/mipmap-xxxhdpi/ic_launcher_monochrome.png',
      size,
      size,
      (canvas, s) => _markedIcon(
        canvas,
        s,
        safeZone: 66 / 108,
        glyph: const Color(0xFFFFFFFF),
        bar: const Color(0xFFFFFFFF),
      ),
    );
  });

  testWidgets('Play Store icon, 512 x 512', (tester) async {
    await _write(
      tester,
      '../store/graphics/icon-512.png',
      512,
      512,
      (canvas, s) => _markedIcon(canvas, s, background: _green),
    );
  });

  testWidgets('site logo and favicons', (tester) async {
    for (final size in <int>[512, 180, 32]) {
      await _write(
        tester,
        '../site/assets/icon-$size.png',
        size,
        size,
        (canvas, s) => _markedIcon(
          canvas,
          s,
          background: _green,
          cornerRadius: size == 32 ? 0.18 : 0.23,
        ),
      );
    }
  });

  testWidgets('Play feature graphic, 1024 x 500, no alpha', (tester) async {
    await _writeOpaque(
      tester,
      '../store/graphics/feature-graphic.png',
      1024,
      500,
      (canvas, size) {
        // The mark, left, drawn as a borderless icon at the height of the art.
        canvas
          ..drawRect(Offset.zero & size, Paint()..color = _green)
          ..save()
          ..translate(96, 70);
        _markedIcon(canvas, const Size(360, 360));
        canvas.restore();

        final name = _text(
          'Schwa Notes',
          family: 'Charis SIL',
          size: 92,
          color: _paper,
          weight: FontWeight.w700,
        )..layout(maxWidth: 520);
        final line = _text(
          'Note words. Mark the sounds\nyou keep getting wrong.',
          family: 'Inter',
          size: 34,
          color: _paper.withValues(alpha: 0.86),
          height: 1.3,
        )..layout(maxWidth: 520);

        const left = 470.0;
        final top = (size.height - name.height - 28 - line.height) / 2;
        name.paint(canvas, Offset(left, top));
        line.paint(canvas, Offset(left, top + name.height + 28));
      },
    );
  });
}

/// Draws direction A into a [size] square.
///
/// [safeZone] shrinks the mark to that fraction of the square (adaptive
/// icons); [background] null leaves it transparent (a foreground layer).
void _markedIcon(
  Canvas canvas,
  Size size, {
  Color? background,
  double safeZone = 0.78,
  double cornerRadius = 0,
  Color glyph = _paper,
  Color bar = _coral,
}) {
  final side = size.shortestSide;
  if (background != null) {
    final paint = Paint()..color = background;
    if (cornerRadius == 0) {
      canvas.drawRect(Offset.zero & size, paint);
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(side * cornerRadius),
        ),
        paint,
      );
    }
  }

  // Proportions from the approved concept (512 box: glyph 330px, bar 160x24,
  // 34px below the baseline), scaled so the mark fills [safeZone] of the side.
  final scale = side * safeZone / 400;
  final painter = _text(
    _schwa,
    family: 'Charis SIL',
    size: 330 * scale,
    color: glyph,
    weight: FontWeight.w700,
  )..layout();

  final barWidth = 160 * scale;
  final barHeight = 24 * scale;
  final gap = 34 * scale;

  // Centre the ink - the glyph from its x-height to its baseline, plus the
  // bar - rather than the line box, which carries ascender space the schwa
  // does not use.
  final baseline = painter.computeDistanceToActualBaseline(
    TextBaseline.alphabetic,
  );
  final xHeight = 0.5 * 330 * scale;
  final inkHeight = xHeight + gap + barHeight;
  final inkTop = (size.height - inkHeight) / 2;
  final glyphOrigin = Offset(
    (size.width - painter.width) / 2,
    inkTop + xHeight - baseline,
  );
  painter.paint(canvas, glyphOrigin);

  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(
        (size.width - barWidth) / 2,
        inkTop + xHeight + gap,
        barWidth,
        barHeight,
      ),
      Radius.circular(barHeight / 2),
    ),
    Paint()..color = bar,
  );
}

/// Like [_write], but as a 24-bit RGB PNG with no alpha channel - which Play
/// requires of a feature graphic - because `ImageByteFormat.png` always writes
/// RGBA. [draw] must paint every pixel opaque.
Future<void> _writeOpaque(
  WidgetTester tester,
  String path,
  int width,
  int height,
  void Function(Canvas canvas, Size size) draw,
) async {
  final recorder = ui.PictureRecorder();
  draw(Canvas(recorder), Size(width.toDouble(), height.toDouble()));
  final picture = recorder.endRecording();
  final rgba = await tester.runAsync(() async {
    final image = await picture.toImage(width, height);
    final data = await image.toByteData(
      format: ui.ImageByteFormat.rawStraightRgba,
    );
    image.dispose();
    return data!.buffer.asUint8List();
  });
  picture.dispose();
  final pixels = rgba!;

  // One filter byte (0, none) then RGB for each row.
  final raw = BytesBuilder(copy: false);
  for (var y = 0; y < height; y++) {
    final row = Uint8List(1 + width * 3);
    for (var x = 0; x < width; x++) {
      final i = (y * width + x) * 4;
      if (pixels[i + 3] != 255) {
        throw StateError('$path: pixel ($x, $y) is not opaque');
      }
      row
        ..[1 + x * 3] = pixels[i]
        ..[2 + x * 3] = pixels[i + 1]
        ..[3 + x * 3] = pixels[i + 2];
    }
    raw.add(row);
  }

  final header = ByteData(13)
    ..setUint32(0, width)
    ..setUint32(4, height)
    ..setUint8(8, 8) // bit depth
    ..setUint8(9, 2) // colour type 2: truecolour, no alpha
    ..setUint8(10, 0) // deflate
    ..setUint8(11, 0) // standard filtering
    ..setUint8(12, 0); // not interlaced

  final png = BytesBuilder(copy: false)
    ..add(const <int>[0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
    ..add(_chunk('IHDR', header.buffer.asUint8List()))
    ..add(_chunk('IDAT', ZLibCodec(level: 9).encode(raw.takeBytes())))
    ..add(_chunk('IEND', const <int>[]));

  File(path)
    ..parent.createSync(recursive: true)
    ..writeAsBytesSync(png.takeBytes());
}

/// A PNG chunk: length, type, data, CRC-32 of type and data.
List<int> _chunk(String type, List<int> data) {
  final typeBytes = type.codeUnits;
  final length = ByteData(4)..setUint32(0, data.length);
  final crc = ByteData(4)..setUint32(0, _crc32(<int>[...typeBytes, ...data]));
  return <int>[
    ...length.buffer.asUint8List(),
    ...typeBytes,
    ...data,
    ...crc.buffer.asUint8List(),
  ];
}

final List<int> _crcTable = List<int>.generate(256, (n) {
  var c = n;
  for (var k = 0; k < 8; k++) {
    c = (c & 1) != 0 ? 0xEDB88320 ^ (c >> 1) : c >> 1;
  }
  return c;
});

int _crc32(List<int> bytes) {
  var c = 0xFFFFFFFF;
  for (final b in bytes) {
    c = _crcTable[(c ^ b) & 0xFF] ^ (c >> 8);
  }
  return c ^ 0xFFFFFFFF;
}

TextPainter _text(
  String text, {
  required String family,
  required double size,
  required Color color,
  FontWeight weight = FontWeight.w500,
  double? height,
}) => TextPainter(
  text: TextSpan(
    text: text,
    style: TextStyle(
      fontFamily: family,
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
    ),
  ),
  textDirection: TextDirection.ltr,
);

Future<void> _loadFont(String family, String asset) async {
  final bytes = File(asset).readAsBytesSync();
  final loader = FontLoader(family)
    ..addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
  await loader.load();
}

/// Rasterises [draw] into a [width] x [height] PNG at [path], relative to app/.
Future<void> _write(
  WidgetTester tester,
  String path,
  int width,
  int height,
  void Function(Canvas canvas, Size size) draw,
) async {
  final recorder = ui.PictureRecorder();
  draw(Canvas(recorder), Size(width.toDouble(), height.toDouble()));
  final picture = recorder.endRecording();
  final bytes = await tester.runAsync(() async {
    final image = await picture.toImage(width, height);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data!.buffer.asUint8List();
  });
  picture.dispose();
  File(path)
    ..parent.createSync(recursive: true)
    ..writeAsBytesSync(bytes!);
}
