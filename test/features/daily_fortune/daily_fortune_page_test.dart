import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuvicuatoi/features/daily_fortune/data/daily_fortune_repository.dart';
import 'package:tuvicuatoi/features/daily_fortune/domain/daily_fortune.dart';
import 'package:tuvicuatoi/features/daily_fortune/presentation/daily_fortune_page.dart';

void main() {
  for (final width in [288.0, 360.0, 430.0]) {
    testWidgets('daily fortune header fits ${width.toInt()}dp width', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(Size(width, 760));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dailyFortuneRepositoryProvider.overrideWithValue(
              _FakeDailyFortuneRepository(),
            ),
          ],
          child: const MaterialApp(home: DailyFortunePage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Vận Hạn Hôm Nay'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.byIcon(Icons.calendar_month_rounded), findsWidgets);
      expect(find.text('Hôm trước'), findsOneWidget);
      expect(find.text('Hôm sau'), findsOneWidget);
      expect(find.text('Hôm nay'), findsOneWidget);
      expect(find.textContaining('Ngày Canh Ngọ'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('previous day updates date and reloads calendar data', (
    tester,
  ) async {
    final repository = _FakeDailyFortuneRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dailyFortuneRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(home: DailyFortunePage()),
      ),
    );
    await tester.pumpAndSettle();
    final callsBefore = repository.requestedDates.length;

    await tester.tap(find.text('Hôm trước'));
    await tester.pumpAndSettle();

    expect(repository.requestedDates, hasLength(callsBefore + 1));
    expect(tester.takeException(), isNull);
  });
}

class _FakeDailyFortuneRepository implements DailyFortuneRepository {
  final requestedDates = <DateTime>[];

  @override
  Future<DailyFortune> getForDate({
    required DateTime date,
    CancelToken? cancelToken,
  }) async {
    requestedDates.add(date);
    return DailyFortune(
      date: date,
      summary: '',
      canChiDay: 'Canh Ngọ',
      canChiMonth: 'Mậu Tuất',
      canChiYear: 'Bính Ngọ',
    );
  }
}
