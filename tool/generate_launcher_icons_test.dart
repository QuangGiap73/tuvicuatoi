import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generate Android and iOS launcher icons from the logo vector', () async {
    const androidSizes = <String, int>{
      'mdpi': 48,
      'hdpi': 72,
      'xhdpi': 96,
      'xxhdpi': 144,
      'xxxhdpi': 192,
    };
    const adaptiveSizes = <String, int>{
      'mdpi': 108,
      'hdpi': 162,
      'xhdpi': 216,
      'xxhdpi': 324,
      'xxxhdpi': 432,
    };
    const iosIcons = <String, int>{
      'Icon-App-20x20@1x.png': 20,
      'Icon-App-20x20@2x.png': 40,
      'Icon-App-20x20@3x.png': 60,
      'Icon-App-29x29@1x.png': 29,
      'Icon-App-29x29@2x.png': 58,
      'Icon-App-29x29@3x.png': 87,
      'Icon-App-40x40@1x.png': 40,
      'Icon-App-40x40@2x.png': 80,
      'Icon-App-40x40@3x.png': 120,
      'Icon-App-60x60@2x.png': 120,
      'Icon-App-60x60@3x.png': 180,
      'Icon-App-76x76@1x.png': 76,
      'Icon-App-76x76@2x.png': 152,
      'Icon-App-83.5x83.5@2x.png': 167,
      'Icon-App-1024x1024@1x.png': 1024,
    };

    for (final entry in androidSizes.entries) {
      await _writeRgbaPng(
        'android/app/src/main/res/mipmap-${entry.key}/ic_launcher.png',
        await _render(entry.value, _IconVariant.legacy),
      );
      await _writeRgbaPng(
        'android/app/src/main/res/mipmap-${entry.key}/ic_launcher_round.png',
        await _render(entry.value, _IconVariant.round),
      );
    }
    for (final entry in adaptiveSizes.entries) {
      await _writeRgbaPng(
        'android/app/src/main/res/mipmap-${entry.key}/ic_launcher_foreground.png',
        await _render(entry.value, _IconVariant.adaptiveForeground),
      );
    }
    for (final entry in iosIcons.entries) {
      await _writeRgbPng(
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/${entry.key}',
        await _render(entry.value, _IconVariant.fullBackground),
      );
    }

    await _writeRgbPng(
      'assets/images/logo/logo_app_1024.png',
      await _render(1024, _IconVariant.fullBackground),
    );
    await _writeRgbPng(
      'assets/images/logo/logo_google_play_512.png',
      await _render(512, _IconVariant.fullBackground),
    );
    await _writeRgbaPng(
      'assets/images/logo/logo_android_foreground_432.png',
      await _render(432, _IconVariant.adaptiveForeground),
    );
  });
}

enum _IconVariant { legacy, round, adaptiveForeground, fullBackground }

Future<ui.Image> _render(int size, _IconVariant variant) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  canvas.scale(size / 64);

  if (variant == _IconVariant.legacy) {
    final background = ui.Paint()
      ..shader = ui.Gradient.linear(
        const ui.Offset(8, 4),
        const ui.Offset(56, 60),
        const [ui.Color(0xFF17233F), ui.Color(0xFF050912)],
      );
    canvas.drawRRect(
      ui.RRect.fromRectAndRadius(
        const ui.Rect.fromLTWH(2, 2, 60, 60),
        const ui.Radius.circular(14),
      ),
      background,
    );
    _drawSymbol(canvas);
  } else if (variant == _IconVariant.round) {
    canvas.save();
    canvas.clipPath(
      ui.Path()..addOval(const ui.Rect.fromLTWH(1, 1, 62, 62)),
    );
    _drawFullBackground(canvas);
    _drawSymbol(canvas);
    canvas.restore();
  } else if (variant == _IconVariant.fullBackground) {
    _drawFullBackground(canvas);
    _drawSymbol(canvas);
  } else {
    canvas.save();
    canvas.translate(32, 32);
    canvas.scale(.75);
    canvas.translate(-32, -32);
    _drawSymbol(canvas);
    canvas.restore();
  }

  return recorder.endRecording().toImage(size, size);
}

void _drawFullBackground(ui.Canvas canvas) {
  final background = ui.Paint()
    ..shader = ui.Gradient.linear(
      const ui.Offset(8, 4),
      const ui.Offset(56, 60),
      const [ui.Color(0xFF17233F), ui.Color(0xFF050912)],
    );
  canvas.drawRect(const ui.Rect.fromLTWH(0, 0, 64, 64), background);
}

void _drawSymbol(ui.Canvas canvas) {
  final goldGradient = ui.Gradient.linear(
    const ui.Offset(18, 14),
    const ui.Offset(48, 52),
    const [
      ui.Color(0xFFFFF0A8),
      ui.Color(0xFFD4AF37),
      ui.Color(0xFF9B6B13),
    ],
    const [0, .48, 1],
  );
  canvas.drawCircle(
    const ui.Offset(32, 32),
    20.5,
    ui.Paint()
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..shader = goldGradient,
  );
  canvas.drawCircle(
    const ui.Offset(32, 32),
    14.5,
    ui.Paint()
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const ui.Color(0xB3D4AF37),
  );

  final star = ui.Path()
    ..moveTo(32, 6)
    ..lineTo(35.2, 24.8)
    ..lineTo(58, 32)
    ..lineTo(35.2, 39.2)
    ..lineTo(32, 58)
    ..lineTo(28.8, 39.2)
    ..lineTo(6, 32)
    ..lineTo(28.8, 24.8)
    ..close();
  canvas.drawPath(star, ui.Paint()..shader = goldGradient);

  canvas.drawCircle(
    const ui.Offset(32, 32),
    8.5,
    ui.Paint()..color = const ui.Color(0xFF0B1326),
  );
  canvas.drawCircle(
    const ui.Offset(32, 32),
    8.5,
    ui.Paint()
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const ui.Color(0xFFFFF0A8),
  );

  final yinYang = ui.Path()
    ..moveTo(32, 23.5)
    ..cubicTo(36.694, 23.5, 40.5, 27.306, 40.5, 32)
    ..cubicTo(40.5, 36.694, 36.694, 40.5, 32, 40.5)
    ..cubicTo(34.347, 40.5, 36.25, 38.597, 36.25, 36.25)
    ..cubicTo(36.25, 33.903, 34.347, 32, 32, 32)
    ..cubicTo(29.653, 32, 27.75, 30.097, 27.75, 27.75)
    ..cubicTo(27.75, 25.403, 29.653, 23.5, 32, 23.5)
    ..close();
  canvas.drawPath(yinYang, ui.Paint()..color = const ui.Color(0xFFF5D77F));
  canvas.drawCircle(
    const ui.Offset(32, 27.75),
    1.35,
    ui.Paint()..color = const ui.Color(0xFF0B1326),
  );
  canvas.drawCircle(
    const ui.Offset(32, 36.25),
    1.35,
    ui.Paint()..color = const ui.Color(0xFFF5D77F),
  );
}

Future<void> _writeRgbaPng(String path, ui.Image image) async {
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  if (bytes == null) throw StateError('Không thể xuất PNG: $path');
  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
}

Future<void> _writeRgbPng(String path, ui.Image image) async {
  final rgba = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  final width = image.width;
  final height = image.height;
  image.dispose();
  if (rgba == null) throw StateError('Không thể xuất RGB PNG: $path');
  final source = rgba.buffer.asUint8List();
  final scanlines = BytesBuilder(copy: false);
  var offset = 0;
  for (var y = 0; y < height; y++) {
    scanlines.addByte(0);
    final row = Uint8List(width * 3);
    var target = 0;
    for (var x = 0; x < width; x++) {
      row[target++] = source[offset++];
      row[target++] = source[offset++];
      row[target++] = source[offset++];
      offset++;
    }
    scanlines.add(row);
  }

  final output = BytesBuilder(copy: false)
    ..add(const [137, 80, 78, 71, 13, 10, 26, 10])
    ..add(_chunk('IHDR', _ihdr(width, height)))
    ..add(_chunk('IDAT', ZLibEncoder().convert(scanlines.takeBytes())))
    ..add(_chunk('IEND', Uint8List(0)));
  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsBytes(output.takeBytes(), flush: true);
}

Uint8List _ihdr(int width, int height) {
  final data = ByteData(13)
    ..setUint32(0, width)
    ..setUint32(4, height)
    ..setUint8(8, 8)
    ..setUint8(9, 2)
    ..setUint8(10, 0)
    ..setUint8(11, 0)
    ..setUint8(12, 0);
  return data.buffer.asUint8List();
}

Uint8List _chunk(String type, List<int> data) {
  final typeBytes = Uint8List.fromList(type.codeUnits);
  final body = Uint8List.fromList(data);
  final result = BytesBuilder(copy: false)
    ..add(_uint32(body.length))
    ..add(typeBytes)
    ..add(body)
    ..add(_uint32(_crc32([...typeBytes, ...body])));
  return result.takeBytes();
}

Uint8List _uint32(int value) => (ByteData(4)..setUint32(0, value)).buffer
    .asUint8List();

int _crc32(List<int> bytes) {
  var crc = 0xFFFFFFFF;
  for (final byte in bytes) {
    crc ^= byte;
    for (var bit = 0; bit < 8; bit++) {
      crc = (crc & 1) != 0 ? (crc >> 1) ^ 0xEDB88320 : crc >> 1;
    }
  }
  return (crc ^ 0xFFFFFFFF) & 0xFFFFFFFF;
}
