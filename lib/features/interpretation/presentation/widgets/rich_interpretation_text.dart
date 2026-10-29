import 'package:flutter/material.dart';

/// Trình bày bài luận giải thành các khối dễ đọc mà không thay đổi nội dung
/// backend. Tiêu đề đoạn và phần nhãn trước dấu hai chấm được làm nổi bật.
class RichInterpretationText extends StatelessWidget {
  const RichInterpretationText({
    required this.text,
    super.key,
    this.maxLines,
    this.overflow = TextOverflow.clip,
  });

  final String text;
  final int? maxLines;
  final TextOverflow overflow;

  static const _bodyStyle = TextStyle(
    color: Color(0xFF493522),
    fontSize: 14,
    height: 1.62,
    letterSpacing: .05,
  );

  @override
  Widget build(BuildContext context) {
    final blocks = _blocks(text);
    if (maxLines != null) {
      return Text.rich(
        _inlineSpan(text.trim()),
        maxLines: maxLines,
        overflow: overflow,
        style: _bodyStyle,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < blocks.length; index++) ...[
          if (_isHeading(blocks[index], index, blocks.length))
            _SectionHeading(text: blocks[index])
          else
            SelectableText.rich(_inlineSpan(blocks[index]), style: _bodyStyle),
          if (index != blocks.length - 1)
            SizedBox(
              height: _isHeading(blocks[index], index, blocks.length) ? 11 : 16,
            ),
        ],
      ],
    );
  }

  static List<String> _blocks(String source) => source
      .replaceAll('\r\n', '\n')
      .split(RegExp(r'\n\s*\n'))
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toList(growable: false);

  static bool _isHeading(String value, int index, int total) {
    if (total < 2 || index == total - 1 || value.contains('\n')) return false;
    final normalized = value.trim();
    final words = normalized.split(RegExp(r'\s+')).length;
    if (normalized.length > 120 || words > 20) return false;
    if (RegExp(r'[.!?…][\"”’)]?$').hasMatch(normalized)) return false;
    // Các tiêu đề do engine trả về thường là một dòng riêng và bắt đầu bằng
    // chữ hoa. Điều kiện này tránh biến câu văn thông thường thành tiêu đề.
    return RegExp(r'^[A-ZÀ-ỸĐ0-9]').hasMatch(normalized);
  }

  static TextSpan _inlineSpan(String value) {
    final colon = value.indexOf(':');
    final firstBreak = value.indexOf('\n');
    final hasShortLabel =
        colon > 0 &&
        colon <= 48 &&
        (firstBreak < 0 || colon < firstBreak) &&
        !value.substring(0, colon).contains(RegExp(r'[.!?]'));
    if (!hasShortLabel) return TextSpan(text: value);
    return TextSpan(
      children: [
        TextSpan(
          text: value.substring(0, colon + 1),
          style: const TextStyle(
            color: Color(0xFF4A2A12),
            fontWeight: FontWeight.w800,
          ),
        ),
        TextSpan(text: value.substring(colon + 1)),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.only(bottom: 8),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: Color(0x3D9C6A27))),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Color(0xFF3D210E),
        fontFamily: 'serif',
        fontSize: 18,
        height: 1.28,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}
