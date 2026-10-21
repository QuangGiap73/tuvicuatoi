import 'package:flutter/material.dart';
import '../theme/mystic_colors.dart';

class MysticAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MysticAppBar({
    required this.title,
    this.actions,
    this.leading,
    super.key,
  });
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
  @override
  Widget build(BuildContext context) => AppBar(
    title: Text(title),
    leading: leading,
    actions: actions,
    centerTitle: true,
    backgroundColor: MysticColors.appBarBackground,
    foregroundColor: MysticColors.appBarTitle,
    flexibleSpace: const DecoratedBox(
      decoration: BoxDecoration(gradient: MysticColors.appBarGradient),
    ),
    surfaceTintColor: Colors.transparent,
    scrolledUnderElevation: 0,
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Divider(height: 1, color: MysticColors.appBarDivider),
    ),
  );
}
