import 'package:flutter/material.dart';

abstract final class MysticColors {
  static const midnight = Color(0xFF071821);
  static const deepOcean = Color(0xFF0B2630);
  static const jade = Color(0xFF16463F);
  static const gold = Color(0xFFD9AE5F);
  static const paleGold = Color(0xFFF4D99B);
  static const antiquePaper = Color(0xFFF1DCAD);
  static const ink = Color(0xFF352716);
  static const ivory = Color(0xFFF9F1DF);
  static const error = Color(0xFFE78375);

  // Shared App Bar palette.
  static const appBarBackground = Color(0xFF081120);
  static const appBarTop = Color(0xFF111E30);
  static const appBarBottom = Color(0xFF0D1726);
  static const appBarGold = Color(0xFFDDAF50);
  static const appBarTitle = Color(0xFFFFE3A0);
  static const appBarDivider = Color(0xFF574324);
  static const appBarGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [appBarTop, appBarBackground, appBarBottom],
  );
}
