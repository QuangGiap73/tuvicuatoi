import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/chart_request.dart';
import '../state/chart_form_state.dart';

class ChartFormController extends Notifier<ChartFormState> {
  @override
  ChartFormState build() {
    final user = ref.read(authControllerProvider).asData?.value?.user;
    final birthDate = _parseDate(user?.birthDate);
    final birthHour = _parseHour(user?.birthTime);
    return ChartFormState(
      fullName: user?.fullName ?? '',
      day: birthDate?.day ?? 15,
      month: birthDate?.month ?? 8,
      year: birthDate?.year ?? 1995,
      hour: birthHour ?? 7,
      gender: _normalizeGender(user?.gender),
    );
  }

  void setFullName(String value) =>
      state = state.copyWith(fullName: value, clearError: true);

  void setDay(int value) =>
      state = state.copyWith(day: value, clearError: true);
  void setMonth(int value) =>
      state = state.copyWith(month: value, clearError: true);
  void setYear(int value) =>
      state = state.copyWith(year: value, clearError: true);
  void setHour(int value) =>
      state = state.copyWith(hour: value, clearError: true);
  void setGender(String value) =>
      state = state.copyWith(gender: value, clearError: true);
  void setCalendarType(String value) =>
      state = state.copyWith(calendarType: value, clearError: true);

  bool validate() {
    final error = state.validate();
    state = state.copyWith(errorMessage: error, clearError: error == null);
    return error == null;
  }

  ChartRequest toRequest() => ChartRequest(
    name: state.fullName,
    gender: state.gender,
    day: state.day,
    month: state.month,
    year: state.year,
    hour: state.hour,
    calendarType: state.calendarType,
  );

  DateTime? _parseDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final iso = DateTime.tryParse(raw);
    if (iso != null) return iso;
    final parts = raw.split(RegExp(r'[/\-]'));
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }

  int? _parseHour(String? raw) {
    if (raw == null) return null;
    final hour = int.tryParse(raw.split(':').first);
    return hour != null && hour >= 0 && hour <= 23 ? hour : null;
  }

  String _normalizeGender(String? raw) {
    final value = raw?.trim().toLowerCase();
    return value == 'nữ' || value == 'female' ? 'Nữ' : 'Nam';
  }
}
