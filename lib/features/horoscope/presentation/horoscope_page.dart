import 'package:flutter/material.dart';
import '../../shared/presentation/feature_placeholder.dart';

class HoroscopePage extends StatelessWidget {
  const HoroscopePage({super.key});
  @override
  Widget build(BuildContext context) => const FeaturePlaceholder(
    title: 'Lá Số',
    icon: Icons.auto_awesome,
    description:
        'Quản lý hồ sơ ngày giờ sinh, lập lá số và xem luận giải theo từng cung.',
  );
}
