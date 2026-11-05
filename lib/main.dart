import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // The app contains many full-screen PNG assets. Flutter's default 100 MB
  // decoded-image cache is unnecessarily high for the low-memory Android
  // devices we support and can push them into swap after visiting a few tabs.
  final imageCache = PaintingBinding.instance.imageCache;
  imageCache
    ..maximumSize = 150
    ..maximumSizeBytes = 64 << 20;
  runApp(const ProviderScope(child: TuViCuaToiApp()));
}
