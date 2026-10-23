import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/mystic_colors.dart';
import '../../../core/theme/mystic_spacing.dart';
import '../../../core/widgets/mystic_app_bar.dart';
import '../../../core/widgets/mystic_scaffold.dart';
import 'controllers/daily_fortune_controller.dart';
import 'widgets/daily_fortune_empty_state.dart';

class DailyFortunePage extends ConsumerWidget {
  const DailyFortunePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dailyFortuneControllerProvider);
    return MysticScaffold(
      appBar: const MysticAppBar(title: 'Vận hạn hôm nay'),
      body: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          MysticSpacing.md,
          MysticSpacing.lg,
          MysticSpacing.md,
          110,
        ),
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            color: MysticColors.gold,
            size: 28,
          ),
          const SizedBox(height: MysticSpacing.sm),
          const Text(
            'VẬN HẠN HÔM NAY',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: MysticColors.paleGold,
              fontFamily: 'serif',
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: MysticSpacing.lg),
          DailyFortuneEmptyState(date: state.selectedDate),
        ],
      ),
    );
  }
}
