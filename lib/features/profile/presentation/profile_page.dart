import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/mystic_spacing.dart';
import '../../../core/widgets/ancient_paper_card.dart';
import '../../../core/widgets/golden_button.dart';
import '../../../core/widgets/mystic_app_bar.dart';
import '../../../core/widgets/mystic_scaffold.dart';
import '../../auth/presentation/controllers/auth_controller.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).asData?.value;
    final user = session?.user;
    final fullName = user?.fullName.trim() ?? '';
    return MysticScaffold(
      appBar: const MysticAppBar(title: 'Cá Nhân'),
      body: ListView(
        padding: const EdgeInsets.all(MysticSpacing.md),
        children: [
          const SizedBox(height: MysticSpacing.lg),
          CircleAvatar(
            radius: 40,
            child: Text(
              fullName.isEmpty ? 'T' : fullName.substring(0, 1).toUpperCase(),
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            user?.fullName ?? 'Tài khoản',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(user?.email ?? '', textAlign: TextAlign.center),
          const SizedBox(height: MysticSpacing.lg),
          AncientPaperCard(
            child: Column(
              children: [
                _InfoRow(
                  label: 'Gói hiện tại',
                  value: user?.packageName ?? 'Miễn phí',
                ),
                const Divider(),
                _InfoRow(label: 'Số dư', value: '${user?.coinBalance ?? 0} Xu'),
                const Divider(),
                _InfoRow(
                  label: 'Mã giới thiệu',
                  value: user?.referralCode ?? '—',
                ),
              ],
            ),
          ),
          const SizedBox(height: MysticSpacing.lg),
          GoldenButton(
            label: 'Đăng xuất',
            icon: Icons.logout,
            expanded: true,
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Text(label)),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.end,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    ],
  );
}
