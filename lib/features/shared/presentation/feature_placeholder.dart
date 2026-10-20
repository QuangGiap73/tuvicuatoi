import 'package:flutter/material.dart';
import '../../../core/theme/mystic_colors.dart';
import '../../../core/theme/mystic_spacing.dart';
import '../../../core/widgets/ancient_paper_card.dart';
import '../../../core/widgets/mystic_app_bar.dart';
import '../../../core/widgets/mystic_scaffold.dart';

class FeaturePlaceholder extends StatelessWidget {
  const FeaturePlaceholder({
    required this.title,
    required this.icon,
    required this.description,
    super.key,
  });
  final String title, description;
  final IconData icon;
  @override
  Widget build(BuildContext context) => MysticScaffold(
    appBar: MysticAppBar(title: title),
    body: ListView(
      padding: const EdgeInsets.all(MysticSpacing.md),
      children: [
        const SizedBox(height: 40),
        Icon(icon, size: 54, color: MysticColors.gold),
        const SizedBox(height: 18),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 24),
        AncientPaperCard(child: Text(description, textAlign: TextAlign.center)),
      ],
    ),
  );
}
