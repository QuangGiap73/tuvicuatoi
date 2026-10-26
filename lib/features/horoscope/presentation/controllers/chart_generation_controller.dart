import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/chart_repository.dart';
import '../../domain/chart_request.dart';
import '../state/chart_generation_state.dart';

class ChartGenerationController extends Notifier<ChartGenerationState> {
  CancelToken? _generateToken;
  CancelToken? _saveToken;
  int _generationSession = 0;

  @override
  ChartGenerationState build() {
    ref.onDispose(() {
      _generateToken?.cancel();
      _saveToken?.cancel();
    });
    return const ChartGenerationState();
  }

  Future<bool> generate(ChartRequest request) async {
    if (state.isGenerating || state.isSaving) return false;
    final session = ++_generationSession;
    _generateToken?.cancel('Đang lập lá số mới');
    _saveToken?.cancel('Đang lập lá số mới');
    final token = CancelToken();
    _generateToken = token;
    state = ChartGenerationState(
      status: ChartGenerationStatus.generating,
      request: request,
    );
    try {
      final result = await ref
          .read(chartRepositoryProvider)
          .generate(request, cancelToken: token);
      if (token.isCancelled || session != _generationSession) return false;
      state = ChartGenerationState(
        status: ChartGenerationStatus.ready,
        request: request,
        result: result,
      );
      return true;
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) return false;
      state = ChartGenerationState(
        status: ChartGenerationStatus.error,
        request: request,
        errorMessage: error.message,
      );
      return false;
    } on ChartException catch (error) {
      if (session != _generationSession) return false;
      state = ChartGenerationState(
        status: ChartGenerationStatus.error,
        request: request,
        errorMessage: error.message,
      );
      return false;
    } catch (_) {
      if (session != _generationSession) return false;
      state = ChartGenerationState(
        status: ChartGenerationStatus.error,
        request: request,
        errorMessage: 'Không thể lập lá số. Vui lòng thử lại.',
      );
      return false;
    } finally {
      if (identical(_generateToken, token)) _generateToken = null;
    }
  }

  Future<bool> save() async {
    final request = state.request;
    final result = state.result;
    if (request == null || result == null || state.isSaving || state.isSaved) {
      return false;
    }
    state = ChartGenerationState(
      status: ChartGenerationStatus.saving,
      request: request,
      result: result,
    );
    final token = CancelToken();
    _saveToken = token;
    try {
      final id = await ref
          .read(chartRepositoryProvider)
          .save(request, result, cancelToken: token);
      if (token.isCancelled) return false;
      if (id.trim().isEmpty) {
        throw const ChartException('Máy chủ không trả về mã lá số đã lưu.');
      }
      state = ChartGenerationState(
        status: ChartGenerationStatus.saved,
        request: request,
        result: result,
        savedChartId: id,
      );
      try {
        await ref.read(authControllerProvider.notifier).refreshProfile();
      } catch (_) {
        // Giao dịch lưu đã thành công; lỗi làm mới hồ sơ không được khiến
        // người dùng bấm lưu lần nữa và tạo dữ liệu trùng.
      }
      return true;
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) return false;
      state = ChartGenerationState(
        status: ChartGenerationStatus.ready,
        request: request,
        result: result,
        errorMessage: error.message,
      );
      return false;
    } on ChartException catch (error) {
      state = ChartGenerationState(
        status: ChartGenerationStatus.ready,
        request: request,
        result: result,
        errorMessage: error.message,
      );
      return false;
    } finally {
      if (identical(_saveToken, token)) _saveToken = null;
    }
  }

  void clear() {
    _generationSession++;
    _generateToken?.cancel('Đã xóa phiên lập lá số');
    _saveToken?.cancel('Đã xóa phiên lập lá số');
    state = const ChartGenerationState();
  }

  void markSaved(String chartId) {
    final request = state.request;
    final result = state.result;
    if (request == null || result == null || chartId.trim().isEmpty) return;
    state = ChartGenerationState(
      status: ChartGenerationStatus.saved,
      request: request,
      result: result,
      savedChartId: chartId,
    );
  }
}
