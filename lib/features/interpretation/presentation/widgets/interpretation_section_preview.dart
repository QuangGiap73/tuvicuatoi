import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/interpretation_models.dart';
import '../../domain/section_content.dart';
import '../providers/topic_interpretation_provider.dart';
import 'rich_interpretation_text.dart';

Future<void> showInterpretationSectionPreview(
  BuildContext context, {
  required ReadingSection section,
  required SectionContent content,
  required bool isUnlocked,
  required VoidCallback onUnlock,
  String? topic,
  bool canUnlock = true,
  bool isSharedContent = false,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) => _SectionPreviewSheet(
    section: section,
    content: content,
    isUnlocked: isUnlocked,
    onUnlock: onUnlock,
    topic: topic,
    canUnlock: canUnlock,
    isSharedContent: isSharedContent,
  ),
);

class _SectionPreviewSheet extends StatelessWidget {
  const _SectionPreviewSheet({
    required this.section,
    required this.content,
    required this.isUnlocked,
    required this.onUnlock,
    this.topic,
    this.canUnlock = true,
    this.isSharedContent = false,
  });

  final ReadingSection section;
  final SectionContent content;
  final bool isUnlocked;
  final VoidCallback onUnlock;
  final String? topic;
  final bool canUnlock;
  final bool isSharedContent;

  @override
  Widget build(BuildContext context) {
    final text = isUnlocked ? content.displayContent : content.preview;
    return SafeArea(
      top: false,
      child: DraggableScrollableSheet(
        initialChildSize: isUnlocked ? .78 : .58,
        minChildSize: .42,
        maxChildSize: .92,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF5E3BC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(
              top: BorderSide(color: Color(0xFFC28B30), width: 1.4),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFB99A69),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 10, 9),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (section.groupTitle.trim().isNotEmpty) ...[
                            Text(
                              section.groupTitle.toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFF9A681F),
                                fontSize: 9.5,
                                letterSpacing: 1.35,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                          Text(
                            section.title,
                            style: const TextStyle(
                              color: Color(0xFF4D2D13),
                              fontFamily: 'serif',
                              fontSize: 21,
                              height: 1.15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          if (section.subtitle.trim().isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              section.subtitle,
                              style: const TextStyle(
                                color: Color(0xFF806445),
                                fontSize: 11.5,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                      color: const Color(0xFF6B431B),
                    ),
                  ],
                ),
              ),
              const Divider(color: Color(0x66996A28), height: 1),
              if (isSharedContent)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: const Color(0x1F986216),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: const Color(0x55986216)),
                  ),
                  child: const Text(
                    'Nội dung chuyên đề chung, chưa cá nhân hóa theo dữ liệu lá số.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF76501F),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
                  children: [
                    if (isUnlocked && topic?.trim().isNotEmpty == true)
                      _TopicContent(topic: topic!.trim())
                    else if (text.isEmpty)
                      const Text(
                        'Máy chủ chưa cung cấp nội dung xem trước cho mục này.',
                        style: TextStyle(color: Color(0xFF786044)),
                      )
                    else
                      Stack(
                        children: [
                          RichInterpretationText(
                            text: text,
                            maxLines: isUnlocked ? null : 6,
                            overflow: isUnlocked
                                ? TextOverflow.visible
                                : TextOverflow.ellipsis,
                          ),
                          if (!isUnlocked)
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              height: 42,
                              child: IgnorePointer(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        const Color(0x00F5E3BC),
                                        const Color(0xFFF5E3BC),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    if (!isUnlocked) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0x33C7953C),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0x88B77C24)),
                        ),
                        child: const Text(
                          'Phần còn lại gồm nội dung luận giải chi tiết dành riêng cho lá số này.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF6D4A20),
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (canUnlock)
                        FilledButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            onUnlock();
                          },
                          icon: const Icon(Icons.lock_open_rounded, size: 18),
                          label: Text(
                            'Mở khóa ${section.coinCost} Xu để đọc tiếp',
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF8D5A12),
                            foregroundColor: const Color(0xFFFFE8AF),
                            minimumSize: const Size.fromHeight(46),
                          ),
                        )
                      else
                        const Text(
                          'Backend chưa cấu hình giá Xu cho mục này.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF7A5528),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicContent extends ConsumerWidget {
  const _TopicContent({required this.topic});

  final String topic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(topicInterpretationProvider(topic));
    return result.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 42),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(color: Color(0xFF9A6416)),
              SizedBox(height: 12),
              Text(
                'Đang tải nội dung chuyên đề...',
                style: TextStyle(color: Color(0xFF786044), fontSize: 12),
              ),
            ],
          ),
        ),
      ),
      error: (error, _) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0x22A34432),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0x669D332C)),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFF9D332C),
              size: 26,
            ),
            const SizedBox(height: 7),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF6D402D), fontSize: 12),
            ),
            const SizedBox(height: 9),
            OutlinedButton.icon(
              onPressed: () =>
                  ref.invalidate(topicInterpretationProvider(topic)),
              icon: const Icon(Icons.refresh_rounded, size: 17),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
      data: (data) {
        final paragraphs = data.content
            .split(RegExp(r'\n\s*\n'))
            .map((value) => value.trim())
            .where((value) => value.isNotEmpty)
            .toList(growable: false);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0x229A6416),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: const Color(0x559A6D31)),
              ),
              child: const Text(
                'Nội dung chuyên đề tổng quát từ thư viện Tử Vi; chưa phải '
                'luận giải cá nhân hóa theo dữ liệu lá số của bạn.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF725332),
                  fontSize: 10.5,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (data.name.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                data.name,
                style: const TextStyle(
                  color: Color(0xFF573416),
                  fontFamily: 'serif',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
            const SizedBox(height: 10),
            for (var index = 0; index < paragraphs.length; index++) ...[
              RichInterpretationText(text: paragraphs[index]),
              if (index != paragraphs.length - 1) const SizedBox(height: 13),
            ],
          ],
        );
      },
    );
  }
}
