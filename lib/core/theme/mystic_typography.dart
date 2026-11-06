import 'package:flutter/material.dart';

abstract final class MysticTypography {
  static TextStyle pageTitle({double fontSize = 25}) => TextStyle(
    color: const Color(0xFFFFD978),
    fontFamily: 'serif',
    fontSize: fontSize,
    height: 1.1,
    fontWeight: FontWeight.w900,
    fontStyle: FontStyle.italic,
    shadows: const [
      Shadow(color: Color(0xCC3B2108), blurRadius: 3, offset: Offset(0, 2)),
    ],
  );
}
