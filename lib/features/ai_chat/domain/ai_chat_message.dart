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

class AiChatUsageUpdate {
  const AiChatUsageUpdate({
    this.coinsSpent,
    this.coinBalance,
    this.dailyAiQuestionsLeft,
    this.dailyQuestionsUsed,
    this.aiDailyLimit,
    this.hasUnlimitedAi,
  });

  final int? coinsSpent;
  final int? coinBalance;
  final int? dailyAiQuestionsLeft;
  final int? dailyQuestionsUsed;
  final int? aiDailyLimit;
  final bool? hasUnlimitedAi;

  bool get hasData =>
      coinsSpent != null ||
      coinBalance != null ||
      dailyAiQuestionsLeft != null ||
      dailyQuestionsUsed != null ||
      aiDailyLimit != null ||
      hasUnlimitedAi != null;

  factory AiChatUsageUpdate.fromJson(Map<dynamic, dynamic> json) {
    final nested = json['data'];
    final values = <dynamic, dynamic>{if (nested is Map) ...nested, ...json};
    return AiChatUsageUpdate(
      coinsSpent: _nullableInt(values['coinsSpent']),
      coinBalance: _nullableInt(values['coinBalance']),
      dailyAiQuestionsLeft: _nullableInt(values['dailyAiQuestionsLeft']),
      dailyQuestionsUsed: _nullableInt(values['dailyQuestionsUsed']),
      aiDailyLimit: _nullableInt(values['aiDailyLimit']),
      hasUnlimitedAi: values['hasUnlimitedAi'] is bool
          ? values['hasUnlimitedAi'] as bool
          : null,
    );
  }
}

class AiChatFailureDetails {
  const AiChatFailureDetails({
    required this.message,
    this.code,
    this.requiredCoins,
    this.usage,
  });

  final String message;
  final String? code;
  final int? requiredCoins;
  final AiChatUsageUpdate? usage;

  bool get isInsufficientCoins => code == 'INSUFFICIENT_COINS';

  factory AiChatFailureDetails.fromJson(Map<dynamic, dynamic> json) {
    final usage = AiChatUsageUpdate.fromJson(json);
    return AiChatFailureDetails(
      message: (json['error'] ?? json['message'] ?? json['detail'] ?? '')
          .toString(),
      code: json['code']?.toString(),
      requiredCoins: _nullableInt(json['requiredCoins']),
      usage: usage.hasData ? usage : null,
    );
  }
}

class AiChatDone extends AiChatStreamEvent {
  const AiChatDone(this.fullText, {this.usage});
  final String fullText;
  final AiChatUsageUpdate? usage;
}

class AiChatStreamError extends AiChatStreamEvent {
  const AiChatStreamError(this.details);
  final AiChatFailureDetails details;
}

int? _nullableInt(Object? value) =>
    value is num ? value.toInt() : int.tryParse(value?.toString().trim() ?? '');
