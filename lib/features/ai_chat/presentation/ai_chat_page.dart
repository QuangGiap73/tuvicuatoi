import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../core/assets/mystic_assets.dart';
import '../../horoscope/domain/saved_chart.dart';
import 'controllers/ai_chat_controller.dart';
import 'widgets/ai_chat_message_bubble.dart';
import 'widgets/chart_picker_dialog.dart';

class AiChatPage extends ConsumerStatefulWidget {
  const AiChatPage({super.key});

  @override
  ConsumerState<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends ConsumerState<AiChatPage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Tự động cuộn xuống cuối khi vừa mở màn hình
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollToBottom(immediate: true),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send([String? suggestion]) {
    final text = suggestion ?? _textController.text;
    if (text.trim().isEmpty) return;
    ref.read(aiChatControllerProvider.notifier).send(text);
    _textController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom({bool immediate = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final target = _scrollController.position.maxScrollExtent;
      if (immediate) {
        _scrollController.jumpTo(target);
      } else {
        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tự động cuộn xuống khi có tin nhắn mới (kể cả khi AI phản hồi)
    ref.listen(aiChatControllerProvider.select((s) => s.messages.length), (
      prev,
      next,
    ) {
      if (next > (prev ?? 0)) {
        _scrollToBottom();
      }
    });

    final media = MediaQuery.of(context);
    final dpr = media.devicePixelRatio;
    final screenWidth = media.size.width;
    final keyboardOpen = media.viewInsets.bottom > 0;

    // Khoảng đệm đáy để toàn bộ khung chat và composer nằm trọn vẹn PHÍA TRÊN BottomNav
    final bottomNavClearance = keyboardOpen
        ? 6.0
        : (media.padding.bottom > 0 ? media.padding.bottom + 2.0 : 18.0);

    return Scaffold(
      backgroundColor: const Color(0xFF030D19),
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Nền vũ trụ huyền bí sao chòm & tinh bàn
          RepaintBoundary(
            child: Image.asset(
              MysticAssets.myChartsBackground,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              cacheWidth: (screenWidth * dpr).round(),
              filterQuality: FilterQuality.medium,
            ),
          ),
          const ColoredBox(color: Color(0x3B010813)),

          // Nội dung chính
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // 1. Header (Nút quay lại, Tiêu đề AI Tử Vi, Cố vấn 24/7, Nút Lịch sử)
                _ChatHeader(
                  onBack: () => context.canPop()
                      ? context.pop()
                      : context.go(AppRoute.home),
                ),

                // 2. Thẻ lá số đang luận giải (thiết kế gọn gàng để tối đa hóa không gian chat)
                const _CurrentChartCard(),
                const SizedBox(height: 6),

                // 3. Thanh chọn chủ đề (Mệnh, Quan Lộc, Tài Bạch, Phu Thê, Phúc Đức)
                const _TopicSelector(),
                const SizedBox(height: 4),

                // 4. Khung chat lớn nghệ thuật (frame_chat.png)
                // Đặt bottom clearance Ở NGOÀI để khung tranh và mây đáy không bị che lấp
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: bottomNavClearance),
                    child: _MainChatFrame(
                      scrollController: _scrollController,
                      textController: _textController,
                      onSend: _send,
                      onSuggestion: _send,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 1. HEADER
// ============================================================================

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
    child: Row(
      children: [
        _RoundButton(icon: Icons.arrow_back_rounded, onPressed: onBack),
        const Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, color: Color(0xFFFFDF94), size: 15),
                  SizedBox(width: 4),
                  Text(
                    'AI Tử Vi',
                    style: TextStyle(
                      color: Color(0xFFFFDF94),
                      fontFamily: 'serif',
                      fontSize: 21,
                      height: 1.1,
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.italic,
                      shadows: [
                        Shadow(
                          color: Color(0x99DDA746),
                          blurRadius: 8,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3),
              _OnlinePill(),
            ],
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RoundButton(
              icon: Icons.history_rounded,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Lịch sử trò chuyện sẽ được hiển thị tại đây.',
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 2),
            const Text(
              'Lịch sử',
              style: TextStyle(
                color: Color(0xFFF3E2BD),
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _OnlinePill extends StatelessWidget {
  const _OnlinePill();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
    decoration: BoxDecoration(
      color: const Color(0xD9071727),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFC89B3D), width: 1.0),
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('● ', style: TextStyle(color: Color(0xFFFFD568), fontSize: 7)),
        Text(
          'Cố vấn 24/7',
          style: TextStyle(
            color: Color(0xFFFFE5A3),
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ],
    ),
  );
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, this.onPressed});
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Container(
    width: 38,
    height: 38,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: const Color(0xDD081827),
      border: Border.all(color: const Color(0xFFD6A74B), width: 1.2),
      boxShadow: const [
        BoxShadow(
          color: Color(0x66000000),
          blurRadius: 5,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: IconButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      icon: Icon(icon, color: const Color(0xFFFFDF97), size: 21),
    ),
  );
}

// ============================================================================
// 2. THẺ LÁ SỐ ĐANG LUẬN GIẢI (Gọn gàng & Tinh tế)
// ============================================================================

class _CurrentChartCard extends ConsumerWidget {
  const _CurrentChartCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final chart = ref.watch(
      aiChatControllerProvider.select((state) => state.selectedChart),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7E6C1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD3A144), width: 1.6),
        boxShadow: const [
          BoxShadow(
            color: Color(0x88000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: CustomPaint(painter: _CornerFiligreePainter()),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
            child: Row(
              children: [
                // Avatar bậc thầy Tử Vi
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF081827),
                        border: Border.all(
                          color: const Color(0xFFDDAF4B),
                          width: 1.8,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        MysticAssets.profileMaster,
                        fit: BoxFit.cover,
                        cacheWidth: (48 * dpr).round(),
                        filterQuality: FilterQuality.medium,
                      ),
                    ),
                    Positioned(
                      right: -1,
                      bottom: -1,
                      child: Container(
                        width: 17,
                        height: 17,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF081827),
                          border: Border.all(
                            color: const Color(0xFFDDAF4B),
                            width: 1.0,
                          ),
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          color: Color(0xFFFFE3A0),
                          size: 9.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),

                // Thông tin bản mệnh
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Lá số đang luận giải',
                        style: TextStyle(
                          color: Color(0xFF7A6244),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        chart?.displayName ?? 'Giáp',
                        style: const TextStyle(
                          color: Color(0xFF22140A),
                          fontFamily: 'serif',
                          fontSize: 19,
                          height: 1.1,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        _chartSummary(chart),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF4A3622),
                          fontSize: 10,
                          height: 1.25,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),

                // Nút Đổi lá số
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      final selected = await showChartPickerDialog(
                        context,
                        selectedChartId: chart?.id,
                      );
                      if (selected == null) return;
                      ref
                          .read(aiChatControllerProvider.notifier)
                          .selectChart(selected);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Ink(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF081827),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFC7983F),
                          width: 1.2,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.sync_rounded,
                            color: Color(0xFFFFDC88),
                            size: 13,
                          ),
                          SizedBox(width: 3),
                          Text(
                            'Đổi lá số',
                            style: TextStyle(
                              color: Color(0xFFFFE3A0),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: Color(0xFFFFDC88),
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _chartSummary(SavedChart? chart) {
    if (chart == null) {
      return 'Nam  •  Sơn Đầu Hỏa  •  Kim Tứ Cục\n15/08/1995 (DL)  •  Giờ Giáp Thìn';
    }
    final gender = chart.gender.trim().isEmpty ? 'Chưa rõ' : chart.gender;
    final menh = chart.menh?.trim().isNotEmpty == true
        ? chart.menh!.trim()
        : 'Chưa cập nhật bản mệnh';
    final date = chart.solarDate.trim().isEmpty
        ? 'Chưa cập nhật ngày sinh'
        : '${chart.solarDate} (DL)';
    return '$gender  •  $menh\n$date  •  Giờ ${chart.hourBranch ?? 'chưa rõ'}';
  }
}

class _CornerFiligreePainter extends CustomPainter {
  const _CornerFiligreePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC9983E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const cornerSize = 10.0;

    // Góc trên trái
    canvas.drawLine(const Offset(4, 4 + cornerSize), const Offset(4, 4), paint);
    canvas.drawLine(const Offset(4, 4), const Offset(4 + cornerSize, 4), paint);

    // Góc trên phải
    canvas.drawLine(
      Offset(size.width - 4 - cornerSize, 4),
      Offset(size.width - 4, 4),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - 4, 4),
      Offset(size.width - 4, 4 + cornerSize),
      paint,
    );

    // Góc dưới trái
    canvas.drawLine(
      Offset(4, size.height - 4 - cornerSize),
      Offset(4, size.height - 4),
      paint,
    );
    canvas.drawLine(
      Offset(4, size.height - 4),
      Offset(4 + cornerSize, size.height - 4),
      paint,
    );

    // Góc dưới phải
    canvas.drawLine(
      Offset(size.width - 4 - cornerSize, size.height - 4),
      Offset(size.width - 4, size.height - 4),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - 4, size.height - 4 - cornerSize),
      Offset(size.width - 4, size.height - 4),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// 3. THANH CHỌN CHỦ ĐỀ LUẬN GIẢI
// ============================================================================

class _TopicSelector extends ConsumerWidget {
  const _TopicSelector();

  static const topics = <(IconData, String)>[
    (Icons.auto_awesome, 'Mệnh'),
    (Icons.work_outline_rounded, 'Quan Lộc'),
    (Icons.toll_outlined, 'Tài Bạch'),
    (Icons.favorite_border_rounded, 'Phu Thê'),
    (Icons.spa_outlined, 'Phúc Đức'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(
      aiChatControllerProvider.select((state) => state.selectedTopic),
    );

    return SizedBox(
      height: 35,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        itemCount: topics.length,
        separatorBuilder: (_, _) => const SizedBox(width: 7),
        itemBuilder: (context, index) {
          final topic = topics[index];
          final active = selected == index;

          return RepaintBoundary(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => ref
                    .read(aiChatControllerProvider.notifier)
                    .selectTopic(index),
                borderRadius: BorderRadius.circular(18),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: active
                        ? const Color(0xFF061523)
                        : const Color(0xCC091B2C),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: active
                          ? const Color(0xFFFFD568)
                          : const Color(0xFF3F5369),
                      width: active ? 1.5 : 1,
                    ),
                    boxShadow: active
                        ? const [
                            BoxShadow(color: Color(0x33FFD568), blurRadius: 6),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        topic.$1,
                        size: 13.5,
                        color: active
                            ? const Color(0xFFFFD568)
                            : const Color(0xFFC8D3DE),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        topic.$2,
                        style: TextStyle(
                          color: active
                              ? const Color(0xFFFFE6A5)
                              : const Color(0xFFE8DFD1),
                          fontFamily: 'serif',
                          fontSize: 11.5,
                          fontWeight: active
                              ? FontWeight.w800
                              : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// 4. KHUNG CHAT LỚN NGHỆ THUẬT (frame_chat.png)
// ============================================================================

class _MainChatFrame extends StatelessWidget {
  const _MainChatFrame({
    required this.scrollController,
    required this.textController,
    required this.onSend,
    required this.onSuggestion,
  });

  final ScrollController scrollController;
  final TextEditingController textController;
  final VoidCallback onSend;
  final ValueChanged<String> onSuggestion;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final screenWidth = MediaQuery.sizeOf(context).width;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cacheWidth = (screenWidth * dpr).round();

        return Stack(
          fit: StackFit.expand,
          children: [
            // Khung tranh cổ lớn (lồng đèn hai bên, vân giấy cổ, mây vàng đáy khung)
            Positioned.fill(
              child: RepaintBoundary(
                child: Image.asset(
                  MysticAssets.aiChatMainFrame,
                  fit: BoxFit.fill,
                  cacheWidth: cacheWidth,
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ),

            // Khu vực nội dung bên trong cuộn giấy:
            // Căn lề trái/phải 28px để chữ không đè lồng đèn, lề đáy 10px để thanh nhập nằm gọn trên mây vàng
            Padding(
              // Chừa phần đáy cho composer đang đè lên khung, tránh tin nhắn
              // và gợi ý bị thanh nhập che khuất.
              // frame_chat_A cao 132px nhưng có vùng alpha trong suốt ở phía
              // trên; chỉ chừa phần khung vàng thực sự nhìn thấy.
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 98),
              child: ClipRect(
                child: _ConversationList(
                  scrollController: scrollController,
                  onSuggestion: onSuggestion,
                ),
              ),
            ),

            // Composer là một lớp độc lập, đè trực tiếp lên mép cuối khung chat.
            Positioned(
              left: -8,
              right: -8,
              bottom: -6,
              child: _Composer(controller: textController, onSend: onSend),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================================
// 5. DANH SÁCH CUỘN TIN NHẮN & GỢI Ý CÂU HỎI
// ============================================================================

class _ConversationList extends ConsumerWidget {
  const _ConversationList({
    required this.scrollController,
    required this.onSuggestion,
  });

  final ScrollController scrollController;
  final ValueChanged<String> onSuggestion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(
      aiChatControllerProvider.select((state) => state.messages),
    );

    return ListView.builder(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      itemCount: messages.length + 1,
      itemBuilder: (context, index) {
        // Tin nhắn hội thoại
        if (index < messages.length) {
          final message = messages[index];
          return RepaintBoundary(
            child: AiChatMessageBubble(
              key: ValueKey(message.id),
              message: message,
            ),
          );
        }

        // Khối gợi ý câu hỏi ở cuối (gọn gàng, không che khuất tin nhắn)
        return RepaintBoundary(child: _Suggestions(onTap: onSuggestion));
      },
    );
  }
}

// ============================================================================
// 6. GỢI Ý CÂU HỎI NHANH (Thiết kế thanh thoát)
// ============================================================================

class _Suggestions extends StatelessWidget {
  const _Suggestions({required this.onTap});
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 6, bottom: 4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.auto_awesome, color: Color(0xFF3C2612), size: 13),
            SizedBox(width: 4),
            Text(
              'Gợi ý câu hỏi cho bạn',
              style: TextStyle(
                color: Color(0xFF3C2612),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _SuggestionCard(
                icon: Icons.business_center_rounded,
                text: 'Phân tích\ncung Quan Lộc',
                onTap: () => onTap('Phân tích cung Quan Lộc của tôi'),
              ),
              const SizedBox(width: 6),
              _SuggestionCard(
                icon: Icons.favorite_rounded,
                text: 'Tình duyên\nnăm 2026',
                onTap: () => onTap('Dự đoán tình duyên năm 2026'),
              ),
              const SizedBox(width: 6),
              _SuggestionCard(
                icon: Icons.auto_awesome_rounded,
                text: 'Gợi ý cải vận',
                onTap: () => onTap('Gợi ý phương pháp cải vận theo lá số'),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  final IconData icon;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Ink(
        padding: const EdgeInsets.fromLTRB(7, 5, 10, 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF7E8C8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFD4AA64), width: 1.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                color: const Color(0xFFE5CE9F),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: const Color(0xFF4A341C), size: 14),
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(
                color: Color(0xFF2A190C),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ============================================================================
// 7. THANH NHẬP LIỆU (frame_chat_A.png + icon_gui_A.png)
// ============================================================================

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);

    return SizedBox(
      height: 132,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          RepaintBoundary(
            child: Image.asset(
              MysticAssets.aiChatComposerFrame,
              fit: BoxFit.fill,
              cacheWidth: (MediaQuery.sizeOf(context).width * dpr).round(),
              filterQuality: FilterQuality.medium,
            ),
          ),
          Positioned(
            left: 54,
            right: 85,
            top: 44,
            height: 44,
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              style: const TextStyle(
                color: Color(0xFF3B2B1B),
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.transparent,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                hintText: 'Nhập câu hỏi của bạn về lá số...',
                hintStyle: TextStyle(
                  color: Color(0xFF9A8768),
                  fontFamily: 'serif',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Positioned(
            right: 56,
            top: 42,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onSend,
                customBorder: const CircleBorder(),
                child: RepaintBoundary(
                  child: Image.asset(
                    MysticAssets.aiChatSend,
                    width: 48,
                    height: 48,
                    fit: BoxFit.contain,
                    cacheWidth: (48 * dpr).round(),
                    cacheHeight: (48 * dpr).round(),
                    filterQuality: FilterQuality.medium,
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
