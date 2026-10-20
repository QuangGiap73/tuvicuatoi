import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/mystic_theme.dart';
import '../features/ai_chat/presentation/widgets/global_ai_chat_launcher.dart';
import 'router/app_router.dart';

class TuViCuaToiApp extends ConsumerWidget {
  const TuViCuaToiApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
    title: 'Tử Vi AI 2026',
    debugShowCheckedModeBanner: false,
    theme: MysticTheme.dark,
    routerConfig: ref.watch(appRouterProvider),
    builder: (context, child) => MediaQuery.withClampedTextScaling(
      minScaleFactor: .85,
      maxScaleFactor: 1.35,
      child: GlobalAiChatLauncher(child: child ?? const SizedBox.shrink()),
    ),
  );
}
