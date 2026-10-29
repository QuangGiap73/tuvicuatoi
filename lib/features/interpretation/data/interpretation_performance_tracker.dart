import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class InterpretationRequestMetric {
  const InterpretationRequestMetric({
    required this.count,
    required this.successCount,
    required this.failureCount,
    required this.totalElapsed,
    required this.lastElapsed,
    required this.maxElapsed,
  });

  const InterpretationRequestMetric.empty()
    : count = 0,
      successCount = 0,
      failureCount = 0,
      totalElapsed = Duration.zero,
      lastElapsed = Duration.zero,
      maxElapsed = Duration.zero;

  final int count;
  final int successCount;
  final int failureCount;
  final Duration totalElapsed;
  final Duration lastElapsed;
  final Duration maxElapsed;

  Duration get averageElapsed => count == 0
      ? Duration.zero
      : Duration(microseconds: totalElapsed.inMicroseconds ~/ count);

  InterpretationRequestMetric add(Duration elapsed, {required bool success}) =>
      InterpretationRequestMetric(
        count: count + 1,
        successCount: successCount + (success ? 1 : 0),
        failureCount: failureCount + (success ? 0 : 1),
        totalElapsed: totalElapsed + elapsed,
        lastElapsed: elapsed,
        maxElapsed: elapsed > maxElapsed ? elapsed : maxElapsed,
      );
}

/// Lightweight, in-memory measurements for interpretation API calls.
///
/// It has no timer, does not retain request/response bodies and never sends
/// telemetry. Logs are emitted only in debug/profile builds.
class InterpretationPerformanceTracker {
  final Map<String, InterpretationRequestMetric> _metrics = {};

  Map<String, InterpretationRequestMetric> get snapshot =>
      Map.unmodifiable(_metrics);

  Future<T> measure<T>(String operation, Future<T> Function() action) async {
    final stopwatch = Stopwatch()..start();
    var success = false;
    try {
      final result = await action();
      success = true;
      return result;
    } finally {
      stopwatch.stop();
      final metric =
          (_metrics[operation] ?? const InterpretationRequestMetric.empty())
              .add(stopwatch.elapsed, success: success);
      _metrics[operation] = metric;
      if (kDebugMode || kProfileMode) {
        debugPrint(
          '[InterpretationMetrics] $operation '
          '#${metric.count} ${success ? 'ok' : 'failed'} '
          '${stopwatch.elapsedMilliseconds}ms '
          '(avg ${metric.averageElapsed.inMilliseconds}ms, '
          'max ${metric.maxElapsed.inMilliseconds}ms)',
        );
      }
    }
  }

  void reset() => _metrics.clear();
}

final interpretationPerformanceTrackerProvider =
    Provider<InterpretationPerformanceTracker>(
      (ref) => InterpretationPerformanceTracker(),
    );
