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
    this.background,
    this.extendBodyBehindAppBar = false,
    super.key,
  });
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final bool resizeToAvoidBottomInset, safeTop, constrainBody;
  final Widget? background;
  final bool extendBodyBehindAppBar;
  @override
  Widget build(BuildContext context) {
    Widget bodyContent = constrainBody
        ? Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: MysticSpacing.contentMaxWidth,
              ),
              child: body,
            ),
          )
        : body;

    if (extendBodyBehindAppBar && appBar != null) {
      bodyContent = Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.paddingOf(context).top + appBar!.preferredSize.height,
        ),
        child: bodyContent,
      );
    }

    final content = SafeArea(
      top: appBar == null && safeTop,
      bottom: bottomNavigationBar == null,
      child: bodyContent,
    );

    final decoratedBody = background == null
        ? MysticBackground(child: content)
        : Stack(fit: StackFit.expand, children: [background!, content]);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: appBar,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      bottomNavigationBar: bottomNavigationBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: decoratedBody,
    );
  }
}
