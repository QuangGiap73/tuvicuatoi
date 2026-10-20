import 'package:flutter/material.dart';
import '../../shared/presentation/feature_placeholder.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});
  @override
  Widget build(BuildContext context) => const FeaturePlaceholder(
    title: 'Ví Xu',
    icon: Icons.toll,
    description:
        'Theo dõi số dư, lịch sử giao dịch và các gói Premium minh bạch.',
  );
}
