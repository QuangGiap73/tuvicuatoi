import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/mystic_colors.dart';

class HomeMysticAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeMysticAppBar({
    super.key,
    required this.coinBalance,
    this.onMenuPressed,
    this.onWalletPressed,
    this.onAddCoinPressed,
  });

  final int coinBalance;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onWalletPressed;
  final VoidCallback? onAddCoinPressed;

  @override
  Size get preferredSize => const Size.fromHeight(66);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MysticColors.appBarBackground,
      child: Container(
        decoration: const BoxDecoration(
          gradient: MysticColors.appBarGradient,
          border: Border(
            bottom: BorderSide(color: MysticColors.appBarDivider, width: 0.65),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x44000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: 66,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  _MysticIconButton(
                    tooltip: 'Mở menu',
                    icon: Icons.menu_rounded,
                    color: MysticColors.appBarGold,
                    onPressed: onMenuPressed,
                  ),

                  const SizedBox(width: 7),

                  // Logo thương hiệu
                  const Expanded(child: _MysticBrand()),

                  const SizedBox(width: 3),

                  _MysticCoinWallet(
                    balance: coinBalance,
                    onPressed: onWalletPressed,
                    onAddPressed: onAddCoinPressed,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Logo Tử Vi hai dòng, tránh chữ bị ép khi màn hình nhỏ.
class _MysticBrand extends StatelessWidget {
  const _MysticBrand();

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'TỬ VI',
            maxLines: 1,
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 23,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.1,
              color: MysticColors.appBarTitle,
              height: 1.05,
              shadows: [Shadow(color: Color(0x997D531B), blurRadius: 9)],
            ),
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 17, height: 1, color: const Color(0xFFB98D3B)),
              const SizedBox(width: 6),
              const Text(
                'AI 2026',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                  color: Color(0xFFD5AD63),
                ),
              ),
              const SizedBox(width: 6),
              Container(width: 17, height: 1, color: const Color(0xFFB98D3B)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MysticIconButton extends StatelessWidget {
  const _MysticIconButton({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 36, height: 42),
      icon: Icon(icon, color: color, size: 25),
    );
  }
}

class _MysticCoinWallet extends StatelessWidget {
  const _MysticCoinWallet({
    required this.balance,
    required this.onPressed,
    required this.onAddPressed,
  });

  final int balance;
  final VoidCallback? onPressed;
  final VoidCallback? onAddPressed;

  String _formatBalance(int value) {
    final negative = value < 0;
    final digits = value.abs().toString();
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[i]);
    }

    return '${negative ? '-' : ''}$buffer';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.only(left: 4, right: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF080E18),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF755727), width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _GoldCoinIcon(size: 27),
                  const SizedBox(width: 5),
                  Text(
                    '${_formatBalance(balance)} Xu',
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFFF1D6),
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
              ),
            ),
          ),

          // Nút nạp xu
          Tooltip(
            message: 'Nạp thêm xu',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onAddPressed,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFFE68C),
                        Color(0xFFF5BE47),
                        Color(0xFFB87A13),
                      ],
                    ),
                    border: Border.all(
                      color: const Color(0xFFFFE9A7),
                      width: 1,
                    ),
                    boxShadow: const [
                      BoxShadow(color: Color(0x55E3A429), blurRadius: 5),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    size: 21,
                    color: Color(0xFF49300C),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Đồng xu vàng âm dương, vẽ trực tiếp bằng Flutter.
/// Không cần SVG, PNG hoặc thư viện bên ngoài.
class _GoldCoinIcon extends StatelessWidget {
  const _GoldCoinIcon({this.size = 27});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoldCoinPainter()),
    );
  }
}

class _GoldCoinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Viền ngoài của đồng xu
    final outerPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFF1AD),
          Color(0xFFD99A18),
          Color(0xFF80500C),
          Color(0xFFFFDB6B),
        ],
      ).createShader(rect);

    canvas.drawCircle(center, radius, outerPaint);

    // Mặt đồng xu
    final innerRadius = radius * 0.83;
    final innerRect = Rect.fromCircle(center: center, radius: innerRadius);

    final facePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.4),
        radius: 1.1,
        colors: const [Color(0xFFFFEE9B), Color(0xFFF3C343), Color(0xFFC78913)],
      ).createShader(innerRect);

    canvas.drawCircle(center, innerRadius, facePaint);

    // Vòng khắc phía trong
    canvas.drawCircle(
      center,
      radius * 0.69,
      Paint()
        ..color = const Color(0xFF98600F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.055,
    );

    // Biểu tượng âm dương
    final symbolRadius = radius * 0.51;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-math.pi / 6);

    final light = Paint()..color = const Color(0xFFFFED9F);
    final dark = Paint()..color = const Color(0xFF99600C);

    canvas.drawCircle(Offset.zero, symbolRadius, dark);

    final yinYang = Path()
      ..moveTo(0, -symbolRadius)
      ..arcToPoint(
        Offset(0, symbolRadius),
        radius: Radius.circular(symbolRadius),
        clockwise: true,
      )
      ..arcToPoint(
        Offset.zero,
        radius: Radius.circular(symbolRadius / 2),
        clockwise: false,
      )
      ..arcToPoint(
        Offset(0, -symbolRadius),
        radius: Radius.circular(symbolRadius / 2),
        clockwise: true,
      )
      ..close();

    canvas.drawPath(yinYang, light);

    canvas.drawCircle(Offset(0, -symbolRadius / 2), symbolRadius * 0.105, dark);

    canvas.drawCircle(Offset(0, symbolRadius / 2), symbolRadius * 0.105, light);

    canvas.restore();

    // Ánh sáng trên viền kim loại
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.92),
      math.pi * 1.12,
      math.pi * 0.7,
      false,
      Paint()
        ..color = const Color(0xBBFFF3BD)
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.08
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _GoldCoinPainter oldDelegate) => false;
}
