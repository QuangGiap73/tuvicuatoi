import 'package:flutter/material.dart';
import '../theme/mystic_spacing.dart';
import 'mystic_background.dart';

class MysticScaffold extends StatelessWidget {
  const MysticScaffold({
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset = true,
    this.safeTop = true,
    this.constrainBody = true,
    super.key,
  });
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final bool resizeToAvoidBottomInset, safeTop, constrainBody;
  @override
  Widget build(BuildContext context) {
    final content = SafeArea(
      top: appBar == null && safeTop,
      bottom: bottomNavigationBar == null,
      child: constrainBody
          ? Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: MysticSpacing.contentMaxWidth,
                ),
                child: body,
              ),
            )
          : body,
    );
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: MysticBackground(child: content),
    );
  }
}
