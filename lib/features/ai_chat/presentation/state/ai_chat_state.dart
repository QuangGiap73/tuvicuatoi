import '../../../horoscope/domain/saved_chart.dart';

enum AiChatRole { assistant, user }

class AiChatMessage {
  const AiChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.time,
  });

  final String id;
  final AiChatRole role;
  final String content;
  final String time;
}

class AiChatState {
  const AiChatState({
    this.selectedTopic = 0,
    this.isSending = false,
    this.messages = initialMessages,
    this.selectedChart,
  });

  final int selectedTopic;
  final bool isSending;
  final List<AiChatMessage> messages;
  final SavedChart? selectedChart;

  AiChatState copyWith({
    int? selectedTopic,
    bool? isSending,
    List<AiChatMessage>? messages,
    SavedChart? selectedChart,
  }) => AiChatState(
    selectedTopic: selectedTopic ?? this.selectedTopic,
    isSending: isSending ?? this.isSending,
    messages: messages ?? this.messages,
    selectedChart: selectedChart ?? this.selectedChart,
  );

  static const initialMessages = <AiChatMessage>[
    AiChatMessage(
      id: 'welcome',
      role: AiChatRole.assistant,
      content:
          'Chào bạn, rất vui được đồng hành cùng bạn trên hành trình khám phá những góc nhìn sâu sắc và thiết thực từ lá số Tử Vi.\n\nBạn có thể hỏi về bất kỳ cung nào, vận hạn năm nào, hoặc những vấn đề trong cuộc sống. Tôi sẽ phân tích dựa trên lá số của bạn một cách chi tiết và dễ hiểu nhất.',
      time: '21:04',
    ),
    AiChatMessage(
      id: 'question-demo',
      role: AiChatRole.user,
      content: 'Cung Quan Lộc của tôi phản ánh điều gì về sự nghiệp?',
      time: '21:05',
    ),
    AiChatMessage(
      id: 'answer-demo',
      role: AiChatRole.assistant,
      content:
          '**Cung Quan Lộc** của bạn phản ánh một phong cách công việc rất quyết liệt, giàu tính thực chiến và luôn hướng tới việc tự mình kiểm soát kết quả thay vì dựa dẫm vào người khác.\n\nTại **cung Quan Lộc** (tại Thân), sự hiện diện của **Phá Quân** (hãm địa) đi cùng **Văn Khúc**, **Thiên Việt**, **Thiên Phúc** và chịu ảnh hưởng của vòng **Tuần** cho thấy bạn là người có tư duy đột phá, dám thay đổi và không ngại thử thách. Bạn phù hợp với những lĩnh vực cần sáng tạo, cải tiến, quản lý dự án hoặc môi trường cạnh tranh cao.',
      time: '21:06',
    ),
  ];
}
