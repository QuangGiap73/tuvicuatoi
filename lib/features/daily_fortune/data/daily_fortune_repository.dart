import '../domain/daily_fortune.dart';

/// Ranh giới dữ liệu cho Vận hạn hôm nay.
///
/// Chưa có implementation HTTP cho đến khi endpoint và JSON response thực tế
/// được xác nhận; nhờ vậy presentation không phụ thuộc vào payload giả định.
abstract interface class DailyFortuneRepository {
  Future<DailyFortune> getForDate({
    required String chartId,
    required DateTime date,
  });
}
