import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/mystic_colors.dart';
import '../../../../core/theme/mystic_typography.dart';

class ProfileMysticAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const ProfileMysticAppBar({
    required this.onBackPressed,
    required this.onSettingsPressed,
    super.key,
  });

  final VoidCallback onBackPressed;
  final VoidCallback onSettingsPressed;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
    backgroundColor: Colors.transparent,
    foregroundColor: MysticColors.appBarTitle,
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
    leadingWidth: 52,
    leading: IconButton(
      tooltip: 'Về Trang chủ',
      onPressed: onBackPressed,
      icon: const Icon(
        Icons.arrow_back_ios_new_rounded,
        size: 20,
        color: MysticColors.appBarGold,
      ),
    ),
    title: Text('Cá nhân', style: MysticTypography.pageTitle(fontSize: 23)),
    actions: [
      IconButton(
        tooltip: 'Cài đặt',
        onPressed: onSettingsPressed,
        icon: const Icon(
          Icons.settings_outlined,
          size: 22,
          color: MysticColors.appBarGold,
        ),
      ),
      const SizedBox(width: 5),
    ],
  );
}
