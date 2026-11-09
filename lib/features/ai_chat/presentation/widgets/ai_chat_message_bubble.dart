import 'package:flutter/material.dart';

import '../../../../core/assets/mystic_assets.dart';
import '../../domain/ai_chat_message.dart';

/// Bong bóng tin nhắn Tử Vi AI hiển thị theo mẫu thiết kế huyền học:
/// - AI Assistant: Avatar La bàn sao 8 cánh, nền giấy cổ sáng, hỗ trợ định dạng chữ đậm **...**
/// - User: Căn phải, Avatar người dùng, nền giấy cổ vàng hổ phách ấm, dấu tích đôi ✓✓
class AiChatMessageBubble extends StatelessWidget {
  const AiChatMessageBubble({required this.message, super.key});

  final AiChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == AiChatRole.user;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final bubbleAsset = isUser
        ? MysticAssets.aiChatBubbleUser
        : MysticAssets.aiChatBubbleAi;

    final topPadding = isUser ? 14.0 : 13.0;
    final bottomPadding = isUser ? 12.0 : 11.0;
    final leftPadding = isUser ? 17.0 : 14.0;
    final rightPadding = isUser ? 17.0 : 14.0;

    return RepaintBoundary(
      child: Padding(
        // Không để bong bóng và avatar chạm sát hai viền của khung giấy.
        padding: EdgeInsets.fromLTRB(isUser ? 14 : 5, 0, isUser ? 14 : 12, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: isUser
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            if (!isUser) ...[
              Transform.translate(
                offset: const Offset(0, 4),
                child: const _AstrologyStarAvatar(),
              ),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isUser ? 300 : 328),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: isUser
                          ? Image.asset(
                              bubbleAsset,
                              fit: BoxFit.fill,
                              cacheWidth: (300 * dpr).round(),
                              filterQuality: FilterQuality.medium,
                            )
                          : const DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFFFF9E9),
                                    Color(0xFFF5DFB1),
                                  ],
                                ),
                                border: Border.fromBorderSide(
                                  BorderSide(
                                    color: Color(0xFFC18B32),
                                    width: 1.2,
                                  ),
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(16),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x30000000),
                                    blurRadius: 3,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        leftPadding,
                        topPadding,
                        rightPadding,
                        bottomPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: _parseMarkdownSpans(
                                message.content,
                                normalStyle: const TextStyle(
                                  color: Color(0xFF342417),
                                  fontSize: 13.5,
                                  height: 1.44,
                                  fontWeight: FontWeight.w500,
                                ),
                                boldStyle: const TextStyle(
                                  color: Color(0xFF1E1208),
                                  fontSize: 13.5,
                                  height: 1.44,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              isUser ? '${message.time} ✓✓' : message.time,
                              style: TextStyle(
                                color: isUser
                                    ? const Color(0xFF6B543B)
                                    : const Color(0xFF7A644A),
                                fontSize: 10,
                                fontWeight: isUser
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isUser) ...[
              const SizedBox(width: 8),
              // Nâng avatar nhẹ để hai mép trên nằm ngang nhau.
              Transform.translate(
                offset: const Offset(0, 4),
                child: const _UserAvatar(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Phân tích cú pháp chuỗi markdown có đánh dấu **in đậm** thành danh sách TextSpan
  static List<TextSpan> _parseMarkdownSpans(
    String text, {
    required TextStyle normalStyle,
    required TextStyle boldStyle,
  }) {
    if (!text.contains('**')) {
      return [TextSpan(text: text, style: normalStyle)];
    }
    final spans = <TextSpan>[];
    final parts = text.split('**');
    for (var i = 0; i < parts.length; i++) {
      if (parts[i].isEmpty) continue;
      final isBold = i % 2 == 1;
      spans.add(
        TextSpan(text: parts[i], style: isBold ? boldStyle : normalStyle),
      );
    }
    return spans;
  }
}

/// Avatar Trợ lý AI: Vòng tròn xanh đen, viền vàng kim, tâm là la bàn sao 8 cánh
class _AstrologyStarAvatar extends StatelessWidget {
  const _AstrologyStarAvatar();

  @override
  Widget build(BuildContext context) => Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: const Color(0xFF081726),
      border: Border.all(color: const Color(0xFFD6A74B), width: 1.4),
      boxShadow: const [
        BoxShadow(
          color: Color(0x66000000),
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: const Center(
      child: CustomPaint(size: Size(22, 22), painter: _AstrologyStarPainter()),
    ),
  );
}

/// CustomPainter vẽ la bàn sao bát giác (8-pointed compass star) chuẩn phong cách huyền học
class _AstrologyStarPainter extends CustomPainter {
  const _AstrologyStarPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final primaryRadius = size.width * 0.46;
    final secondaryRadius = size.width * 0.26;
    final innerRadius = size.width * 0.08;

    final paintPrimary = Paint()
      ..color = const Color(0xFFFFD568)
      ..style = PaintingStyle.fill;

    final paintSecondary = Paint()
      ..color = const Color(0xFFE5B340)
      ..style = PaintingStyle.fill;

    // Vòng tròn nhỏ trung tâm
    canvas.drawCircle(Offset(cx, cy), innerRadius * 1.5, paintPrimary);

    // Vẽ 4 cánh chính (Đông - Tây - Nam - Bắc)
    final pathMain = Path()
      ..moveTo(cx, cy - primaryRadius)
      ..lineTo(cx + innerRadius, cy)
      ..lineTo(cx, cy + primaryRadius)
      ..lineTo(cx - innerRadius, cy)
      ..close()
      ..moveTo(cx - primaryRadius, cy)
      ..lineTo(cx, cy + innerRadius)
      ..lineTo(cx + primaryRadius, cy)
      ..lineTo(cx, cy - innerRadius)
      ..close();
    canvas.drawPath(pathMain, paintPrimary);

    // Vẽ 4 cánh phụ chéo 45 độ
    final pathDiag = Path()
      ..moveTo(cx - secondaryRadius * 0.707, cy - secondaryRadius * 0.707)
      ..lineTo(cx, cy)
      ..lineTo(cx + secondaryRadius * 0.707, cy + secondaryRadius * 0.707)
      ..lineTo(cx, cy)
      ..close()
      ..moveTo(cx + secondaryRadius * 0.707, cy - secondaryRadius * 0.707)
      ..lineTo(cx, cy)
      ..lineTo(cx - secondaryRadius * 0.707, cy + secondaryRadius * 0.707)
      ..lineTo(cx, cy)
      ..close();
    final strokePaint = Paint()
      ..color = const Color(0xFFFFE6A2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawPath(pathDiag, strokePaint);
    canvas.drawPath(pathDiag, paintSecondary);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Avatar Người dùng: Vòng tròn xanh đen, viền vàng kim, biểu tượng người dùng
class _UserAvatar extends StatelessWidget {
  const _UserAvatar();

  @override
  Widget build(BuildContext context) => Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: const Color(0xFF081726),
      border: Border.all(color: const Color(0xFFD6A74B), width: 1.4),
      boxShadow: const [
        BoxShadow(
          color: Color(0x66000000),
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: const Center(
      child: Icon(Icons.person_rounded, color: Color(0xFFFFD568), size: 21),
    ),
  );
}
