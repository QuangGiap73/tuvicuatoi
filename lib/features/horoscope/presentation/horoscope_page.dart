import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../core/assets/mystic_assets.dart';
import '../../../core/widgets/mystic_scaffold.dart';
import 'providers/chart_form_providers.dart';
import 'widgets/chart_birth_form_card.dart';

class HoroscopePage extends ConsumerWidget {
  const HoroscopePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final generation = ref.watch(chartGenerationControllerProvider);
    return MysticScaffold(
      constrainBody: false,
      background: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            MysticAssets.homeBackground,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            cacheWidth:
                (MediaQuery.sizeOf(context).width *
                        MediaQuery.devicePixelRatioOf(context))
                    .round(),
            filterQuality: FilterQuality.medium,
          ),
          const ColoredBox(color: Color(0x8A030A12)),
        ],
      ),
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 92),
        children: [
          const Text(
            'Lập Lá Số Tử Vi',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFFFE8B4),
              fontFamily: 'serif',
              fontSize: 34,
              height: 1.05,
              fontWeight: FontWeight.w700,
              shadows: [
                Shadow(
                  color: Colors.black,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
                Shadow(color: Color(0x997C501B), blurRadius: 12),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              'Điền thông tin sinh để mở ra lá số, khám phá 12 cung và bắt đầu hành trình luận giải của riêng bạn.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFE1D8C8),
                fontSize: 13,
                height: 1.45,
                shadows: [Shadow(color: Colors.black, blurRadius: 5)],
              ),
            ),
          ),
          const SizedBox(height: 22),
          ChartBirthFormCard(
            isSubmitting: generation.isGenerating,
            onSubmit: () => _submit(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context, WidgetRef ref) async {
    final formController = ref.read(chartFormControllerProvider.notifier);
    if (!formController.validate()) return;

    final success = await ref
        .read(chartGenerationControllerProvider.notifier)
        .generate(formController.toRequest());
    if (!context.mounted) return;
    if (success) {
      context.push(AppRoute.chartResult);
      return;
    }
    final message = ref.read(chartGenerationControllerProvider).errorMessage;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message ?? 'Không thể lập lá số.')));
  }
}
