enum AiChatRole { assistant, user }

enum AiChatMessageStatus { sending, streaming, sent, failed }

class AiChatMessage {
  const AiChatMessage({
    required this.id,
    required this.role,
    required this.content,
    this.time = '',
    this.createdAt,
    this.status = AiChatMessageStatus.sent,
  });

  final String id;
  final AiChatRole role;
  final String content;
  final String time;
  final DateTime? createdAt;
  final AiChatMessageStatus status;

  AiChatMessage copyWith({
    String? content,
    String? time,
    DateTime? createdAt,
    AiChatMessageStatus? status,
  }) => AiChatMessage(
    id: id,
    role: role,
    content: content ?? this.content,
    time: time ?? this.time,
    createdAt: createdAt ?? this.createdAt,
    status: status ?? this.status,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'sender': role == AiChatRole.user ? 'user' : 'assistant',
    'text': content,
    'time': time,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    'status': status.name,
  };

  factory AiChatMessage.fromJson(Map<String, dynamic> json) {
    final sender = (json['sender'] ?? json['role'])?.toString().toLowerCase();
    final statusName = json['status']?.toString();
    return AiChatMessage(
      id: (json['id'] ?? 'history-${json.hashCode}').toString(),
      role: sender == 'user' ? AiChatRole.user : AiChatRole.assistant,
      content: (json['text'] ?? json['content'] ?? json['message'] ?? '')
          .toString(),
      time: json['time']?.toString() ?? '',
      createdAt: DateTime.tryParse(
        (json['createdAt'] ?? json['created_at'])?.toString() ?? '',
      ),
      status: AiChatMessageStatus.values.firstWhere(
        (value) => value.name == statusName,
        orElse: () => AiChatMessageStatus.sent,
      ),
    );
  }
}

sealed class AiChatStreamEvent {
  const AiChatStreamEvent();
}

class AiChatDelta extends AiChatStreamEvent {
  const AiChatDelta(this.text);
  final String text;
}

class AiChatDone extends AiChatStreamEvent {
  const AiChatDone(this.fullText);
  final String fullText;
}

class AiChatStreamError extends AiChatStreamEvent {
  const AiChatStreamError(this.message);
  final String message;
}
