class TopicInterpretation {
  const TopicInterpretation({
    required this.topicId,
    required this.name,
    required this.content,
    required this.route,
    required this.meta,
  });

  final String topicId;
  final String name;
  final String content;
  final Map<String, dynamic> route;
  final Map<String, dynamic> meta;

  factory TopicInterpretation.fromJson(Map<String, dynamic> json) =>
      TopicInterpretation(
        topicId: (json['topic_id'] ?? json['topicId'] ?? json['topic'] ?? '')
            .toString()
            .trim(),
        name: (json['name'] ?? json['title'] ?? '').toString().trim(),
        content: (json['content'] ?? '').toString().trim(),
        route: _map(json['route']),
        meta: _map(json['meta']),
      );

  static Map<String, dynamic> _map(Object? value) =>
      value is Map ? Map<String, dynamic>.from(value) : const {};
}
