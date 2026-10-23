import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../core/assets/mystic_assets.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../../horoscope/domain/saved_chart.dart';
import '../domain/ai_chat_message.dart';
import 'controllers/ai_chat_controller.dart';
import 'state/ai_chat_state.dart';
import 'widgets/chat_history_sheet.dart';
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

  void _revealAssistantStart() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final position = _scrollController.position;

      // Chỉ hé phần đầu câu trả lời; không đẩy đầu bubble dài qua mép trên.
      position.jumpTo(
        (position.pixels + 92).clamp(
          position.minScrollExtent,
          position.maxScrollExtent,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    if (auth.isLoading) {
      return const _AiChatAccessBoundary(isLoading: true);
    }
    if (auth.asData?.value == null) {
      return const _AiChatAccessBoundary();
    }

    // Tự động cuộn xuống khi có tin nhắn mới (kể cả khi AI phản hồi)
    ref.listen(
      aiChatControllerProvider.select(
        (state) => (
          count: state.messages.length,
          lastRole: state.messages.isEmpty ? null : state.messages.last.role,
        ),
      ),
      (previous, next) {
        if (next.count <= (previous?.count ?? 0)) return;
        if (next.lastRole == AiChatRole.user) {
          _scrollToBottom();
        } else {
          _revealAssistantStart();
        }
      },
    );
    ref.listen(aiChatControllerProvider.select((s) => s.errorMessage), (
      previous,
      next,
    ) {
      if (next == null || next == previous) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next)));
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
                  onHistory: () => showAiChatHistorySheet(context),
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
// AUTH BOUNDARY
// ============================================================================

class _AiChatAccessBoundary extends StatelessWidget {
  const _AiChatAccessBoundary({this.isLoading = false});
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final width = MediaQuery.sizeOf(context).width;
    final loginLocation = Uri(
      path: AppRoute.login,
      queryParameters: const {'redirect': AppRoute.chat},
    ).toString();
    final registerLocation = Uri(
      path: AppRoute.register,
      queryParameters: const {'redirect': AppRoute.chat},
    ).toString();

    return Scaffold(
      backgroundColor: const Color(0xFF030D19),
      body: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: Image.asset(
              MysticAssets.myChartsBackground,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              cacheWidth: (width * dpr).round(),
            ),
          ),
          const ColoredBox(color: Color(0x8A010813)),
          SafeArea(
            child: Column(
              children: [
                _ChatHeader(
                  onBack: () => context.canPop()
                      ? context.pop()
                      : context.go(AppRoute.welcome),
                  onHistory: isLoading
                      ? () {}
                      : () => context.go(loginLocation),
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: isLoading
                          ? const _AuthCheckingState()
                          : _LoginRequiredState(
                              onLogin: () => context.go(loginLocation),
                              onRegister: () => context.go(registerLocation),
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
}

class _AuthCheckingState extends StatelessWidget {
  const _AuthCheckingState();

  @override
  Widget build(BuildContext context) => const Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox.square(
        dimension: 30,
        child: CircularProgressIndicator(
          strokeWidth: 2.3,
          color: Color(0xFFFFD568),
        ),
      ),
      SizedBox(height: 13),
      Text(
        'Đang kiểm tra phiên đăng nhập...',
        style: TextStyle(color: Color(0xFFF3E2BD), fontSize: 13),
      ),
    ],
  );
}

class _LoginRequiredState extends StatelessWidget {
  const _LoginRequiredState({required this.onLogin, required this.onRegister});

  final VoidCallback onLogin;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    constraints: const BoxConstraints(maxWidth: 360),
    padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
    decoration: BoxDecoration(
      color: const Color(0xEE081827),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFD3A144), width: 1.4),
      boxShadow: const [BoxShadow(color: Color(0x99000000), blurRadius: 18)],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF10283C),
            border: Border.all(color: const Color(0xFFDDB04D), width: 1.5),
          ),
          child: const Icon(
            Icons.lock_outline_rounded,
            color: Color(0xFFFFD568),
            size: 28,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Đăng nhập để trò chuyện',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFFFE5A5),
            fontFamily: 'serif',
            fontSize: 21,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Đăng nhập giúp AI sử dụng đúng lá số, lưu riêng lịch sử trò chuyện '
          'và đồng bộ quyền lợi tài khoản của bạn.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFD8CCB7),
            fontSize: 12,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onLogin,
            icon: const Icon(Icons.login_rounded, size: 18),
            label: const Text('ĐĂNG NHẬP'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD3A144),
              foregroundColor: const Color(0xFF15202B),
              padding: const EdgeInsets.symmetric(vertical: 13),
              textStyle: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
        const SizedBox(height: 7),
        TextButton(
          onPressed: onRegister,
          style: TextButton.styleFrom(foregroundColor: const Color(0xFFFFD978)),
          child: const Text(
            'Chưa có tài khoản? Đăng ký',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

// ============================================================================
// 1. HEADER
// ============================================================================

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({required this.onBack, required this.onHistory});
  final VoidCallback onBack;
  final VoidCallback onHistory;

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
            _RoundButton(icon: Icons.history_rounded, onPressed: onHistory),
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
                        chart?.displayName ?? 'Chưa chọn lá số',
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.sync_rounded,
                            color: Color(0xFFFFDC88),
                            size: 13,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            chart == null ? 'Chọn lá số' : 'Đổi lá số',
                            style: const TextStyle(
                              color: Color(0xFFFFE3A0),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Icon(
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
      return 'Hãy chọn một lá số đã lưu để bắt đầu luận giải cùng AI.';
    }
    final gender = chart.gender.trim().isEmpty ? 'Chưa rõ' : chart.gender;
    final menh = chart.menh?.trim().isNotEmpty == true
        ? chart.menh!.trim()
        : 'Chưa cập nhật bản mệnh';
    final cuc = chart.cuc?.trim().isNotEmpty == true ? '  •  ${chart.cuc}' : '';
    final date = chart.solarDate.trim().isEmpty
        ? 'Chưa cập nhật ngày sinh'
        : '${chart.solarDate} (DL)';
    final rawHour = chart.hourBranch?.trim() ?? '';
    final hour = rawHour.isEmpty
        ? 'Giờ chưa rõ'
        : rawHour.toLowerCase().startsWith('giờ ')
        ? rawHour
        : 'Giờ $rawHour';
    return '$gender  •  $menh$cuc\n$date  •  $hour';
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
    (Icons.family_restroom_rounded, 'Phụ Mẫu'),
    (Icons.spa_outlined, 'Phúc Đức'),
    (Icons.home_work_outlined, 'Điền Trạch'),
    (Icons.work_outline_rounded, 'Quan Lộc'),
    (Icons.groups_2_outlined, 'Nô Bộc'),
    (Icons.travel_explore_rounded, 'Thiên Di'),
    (Icons.health_and_safety_outlined, 'Tật Ách'),
    (Icons.toll_outlined, 'Tài Bạch'),
    (Icons.child_care_outlined, 'Tử Tức'),
    (Icons.favorite_border_rounded, 'Phu Thê'),
    (Icons.diversity_1_outlined, 'Huynh Đệ'),
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
    final chat = ref.watch(
      aiChatControllerProvider.select(
        (state) => (
          messages: state.messages,
          selectedChart: state.selectedChart,
          phase: state.phase,
          waiting: state.isWaitingForFirstToken,
        ),
      ),
    );
    final messages = chat.messages;

    if (chat.selectedChart == null) {
      return const _NoSelectedChartState();
    }
    final onlyWelcome = messages.length == 1 && messages.single.id == 'welcome';
    if (chat.phase == AiChatPhase.loadingChart ||
        (chat.phase == AiChatPhase.loadingHistory && onlyWelcome)) {
      return const _ChatLoadingState();
    }
    if (onlyWelcome && !chat.waiting) {
      return Stack(
        children: [
          Positioned.fill(
            child: ListView(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(0, 14, 0, 82),
              children: [
                RepaintBoundary(
                  child: AiChatMessageBubble(
                    key: ValueKey(messages.single.id),
                    message: messages.single,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 6,
            child: RepaintBoundary(child: _Suggestions(onTap: onSuggestion)),
          ),
        ],
      );
    }

    final conversationItemCount = messages.length + (chat.waiting ? 1 : 0);
    return CustomScrollView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(top: 14),
          sliver: SliverList.builder(
            itemCount: conversationItemCount,
            itemBuilder: (context, index) {
              if (index < messages.length) {
                final message = messages[index];
                return RepaintBoundary(
                  child: AiChatMessageBubble(
                    key: ValueKey(message.id),
                    message: message,
                  ),
                );
              }
              return const _TypingIndicator();
            },
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          fillOverscroll: false,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: RepaintBoundary(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _Suggestions(onTap: onSuggestion),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChatLoadingState extends StatelessWidget {
  const _ChatLoadingState();

  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
          dimension: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            color: Color(0xFF9A6B28),
          ),
        ),
        SizedBox(height: 11),
        Text(
          'Đang tải lá số và lịch sử trò chuyện...',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF6D5131),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _NoSelectedChartState extends ConsumerWidget {
  const _NoSelectedChartState();

  @override
  Widget build(BuildContext context, WidgetRef ref) => Center(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            color: Color(0xFF9A6B28),
            size: 36,
          ),
          const SizedBox(height: 9),
          const Text(
            'Chọn lá số để bắt đầu',
            style: TextStyle(
              color: Color(0xFF3A2615),
              fontFamily: 'serif',
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'AI cần dữ liệu lá số để đưa ra phần luận giải phù hợp với bạn.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF7A6245),
              fontSize: 11.5,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 13),
          FilledButton.icon(
            onPressed: () async {
              final selected = await showChartPickerDialog(context);
              if (selected == null || !context.mounted) return;
              await ref
                  .read(aiChatControllerProvider.notifier)
                  .selectChart(selected);
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF082033),
              foregroundColor: const Color(0xFFFFD978),
              side: const BorderSide(color: Color(0xFFC99A3D)),
            ),
            icon: const Icon(Icons.description_outlined, size: 17),
            label: const Text(
              'CHỌN LÁ SỐ',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    ),
  );
}

// ============================================================================
// 6. GỢI Ý CÂU HỎI NHANH (Thiết kế thanh thoát)
// ============================================================================

class _Suggestions extends ConsumerWidget {
  const _Suggestions({required this.onTap});
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(
      aiChatControllerProvider.select((state) => state.selectedTopic),
    );
    final palace = AiChatController.palaceNames[selected];
    return Padding(
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
          SizedBox(
            height: 43,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _SuggestionCard(
                    icon: Icons.business_center_rounded,
                    text: 'Phân tích\ncung $palace',
                    onTap: () => onTap('Phân tích cung $palace của tôi'),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _SuggestionCard(
                    icon: Icons.favorite_rounded,
                    text: 'Điểm mạnh\ncủa cung này',
                    onTap: () => onTap('Cung $palace thể hiện điểm mạnh gì?'),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _SuggestionCard(
                    icon: Icons.auto_awesome_rounded,
                    text: 'Điều cần\nlưu ý',
                    onTap: () => onTap('Tôi cần chú ý điều gì ở cung $palace?'),
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

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.fromLTRB(18, 2, 18, 12),
    child: Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFF9A6B28),
        ),
      ),
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
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 96;
      final iconSize = compact ? 22.0 : 25.0;
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Ink(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: compact ? 5 : 7),
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
              children: [
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5CE9F),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF4A341C),
                    size: compact ? 13 : 14,
                  ),
                ),
                SizedBox(width: compact ? 4 : 6),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      text,
                      maxLines: 2,
                      style: const TextStyle(
                        color: Color(0xFF2A190C),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

// ============================================================================
// 7. THANH NHẬP LIỆU (frame_chat_A.png + icon_gui_A.png)
// ============================================================================

class _Composer extends ConsumerWidget {
  const _Composer({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final enabled = ref.watch(
      aiChatControllerProvider.select(
        (state) => state.selectedChartDetail != null && !state.isBusy,
      ),
    );

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
              enabled: enabled,
              minLines: 1,
              maxLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) {
                if (enabled) onSend();
              },
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
                onTap: enabled ? onSend : null,
                customBorder: const CircleBorder(),
                child: Opacity(
                  opacity: enabled ? 1 : .48,
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
          ),
        ],
      ),
    );
  }
}
