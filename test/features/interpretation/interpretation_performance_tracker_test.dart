import 'package:flutter_test/flutter_test.dart';
import 'package:tuvicuatoi/features/interpretation/data/interpretation_performance_tracker.dart';

void main() {
  test(
    'counts calls and records request duration without retaining payloads',
    () async {
      final tracker = InterpretationPerformanceTracker();

      await tracker.measure('generate-chuyen-sau', () async {
        await Future<void>.delayed(const Duration(milliseconds: 2));
        return 'private interpretation content';
      });
      await tracker.measure('generate-chuyen-sau', () async => 2);

      final metric = tracker.snapshot['generate-chuyen-sau'];
      expect(metric, isNotNull);
      expect(metric!.count, 2);
      expect(metric.successCount, 2);
      expect(metric.failureCount, 0);
      expect(metric.totalElapsed, greaterThanOrEqualTo(Duration.zero));
      expect(metric.maxElapsed, greaterThanOrEqualTo(metric.lastElapsed));
      expect(
        tracker.snapshot.toString(),
        isNot(contains('private interpretation')),
      );
    },
  );

  test('records failed calls and rethrows the original error', () async {
    final tracker = InterpretationPerformanceTracker();

    await expectLater(
      tracker.measure<void>(
        'permissions',
        () async => throw StateError('network'),
      ),
      throwsStateError,
    );

    final metric = tracker.snapshot['permissions']!;
    expect(metric.count, 1);
    expect(metric.successCount, 0);
    expect(metric.failureCount, 1);
  });
}
