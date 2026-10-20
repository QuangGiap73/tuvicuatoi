import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../core/theme/mystic_colors.dart';
import '../../../core/theme/mystic_spacing.dart';
import '../../../core/widgets/ancient_paper_card.dart';
import '../../../core/widgets/golden_button.dart';
import '../../../core/widgets/mystic_dialog.dart';
import '../../../core/widgets/mystic_scaffold.dart';
import '../../../core/widgets/ornate_frame.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import 'widgets/home_mystic_app_bar.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MysticScaffold(
    appBar: HomeMysticAppBar(
      coinBalance: ref.watch(
        authControllerProvider.select(
          (state) => state.asData?.value?.user.coinBalance ?? 0,
        ),
      ),
      onMenuPressed: () => _showComingSoon(context, 'Menu'),
      onWalletPressed: () => context.go(AppRoute.wallet),
      onAddCoinPressed: () => context.go(AppRoute.wallet),
    ),
    body: ListView(
      padding: const EdgeInsets.all(MysticSpacing.md),
      children: [
        const SizedBox(height: MysticSpacing.sm),
        OrnateFrame(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
          child: Column(
            children: [
              const Icon(
                Icons.brightness_7_outlined,
                color: MysticColors.paleGold,
                size: 44,
              ),
              const SizedBox(height: 12),
              Text(
                'KHAI MỞ THIÊN MỆNH',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Luận giải lá số phương Đông cùng trí tuệ nhân tạo',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 22),
              GoldenButton(
                label: 'Lập lá số của bạn',
                icon: Icons.auto_awesome,
                onPressed: () => _showIntro(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: MysticSpacing.lg),
        const AncientPaperCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thông điệp hôm nay',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 8),
              Text(
                'Tâm tĩnh thì trí sáng. Hãy dành một nhịp chậm để nhìn rõ cơ hội đang đến gần.',
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_month_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('Ngày cát lành • 2026'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: MysticSpacing.lg),
        Text('Khám phá', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: MysticSpacing.md),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _entries.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.25,
          ),
          itemBuilder: (context, index) => _FeatureTile(entry: _entries[index]),
        ),
      ],
    ),
  );

  void _showComingSoon(BuildContext context, String feature) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$feature sẽ được hoàn thiện ở bước tiếp theo.'),
        ),
      );

  void _showIntro(BuildContext context) => MysticDialog.show<void>(
    context,
    dialog: const MysticDialog(
      title: 'Bắt đầu hành trình',
      content: Text(
        'Tính năng lập lá số sẽ được kết nối với biểu mẫu ngày, giờ và nơi sinh ở bước tiếp theo.',
      ),
    ),
  );
}

const _entries = [
  (Icons.grid_view_rounded, 'Lá số tử vi'),
  (Icons.forum_outlined, 'Luận giải AI'),
  (Icons.favorite_outline, 'Tình duyên'),
  (Icons.work_outline, 'Sự nghiệp'),
];

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.entry});
  final (IconData, String) entry;
  @override
  Widget build(BuildContext context) => OrnateFrame(
    padding: const EdgeInsets.all(14),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(entry.$1, color: MysticColors.gold, size: 28),
        const SizedBox(height: 8),
        Text(
          entry.$2,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    ),
  );
}
