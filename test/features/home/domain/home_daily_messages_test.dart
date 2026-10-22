import 'package:flutter_test/flutter_test.dart';
import 'package:tuvicuatoi/features/home/domain/home_daily_messages.dart';

void main() {
  test('keeps the same message throughout one local day', () {
    final morning = dailyMessageFor(DateTime(2026, 10, 21, 8));
    final evening = dailyMessageFor(DateTime(2026, 10, 21, 23, 59));

    expect(evening, morning);
  });

  test('changes the selected message on the next day', () {
    final today = dailyMessageFor(DateTime(2026, 10, 21));
    final tomorrow = dailyMessageFor(DateTime(2026, 10, 22));

    expect(tomorrow, isNot(today));
  });

  test('messages stay within the compact card copy budget', () {
    expect(homeDailyMessages, hasLength(greaterThanOrEqualTo(15)));
    expect(homeDailyMessages.every((message) => message.length <= 115), isTrue);
  });
}
