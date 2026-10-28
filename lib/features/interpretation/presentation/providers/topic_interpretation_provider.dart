import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/interpretation_repository.dart';
import '../../domain/topic_interpretation.dart';

final topicInterpretationProvider = FutureProvider.autoDispose
    .family<TopicInterpretation, String>((ref, topic) {
      // Topic articles are generic library content, not chart-specific data.
      ref.keepAlive();
      return ref
          .read(interpretationRepositoryProvider)
          .getTopicInterpretation(topic: topic);
    });
