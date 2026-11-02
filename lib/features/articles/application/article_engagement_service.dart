import '../data/article_repository.dart';

/// Sends non-critical article engagement without coupling it to UI state.
class ArticleEngagementService {
  ArticleEngagementService(this._repository);

  final ArticleRepository _repository;
  final Set<String> _recordedPageViews = {};

  Future<void> recordPageView(String path) async {
    final value = path.trim();
    if (value.isEmpty || !_recordedPageViews.add(value)) return;
    try {
      await _repository.recordPageView(value);
    } catch (_) {
      // Analytics must never block reading. Allow a later visit to retry.
      _recordedPageViews.remove(value);
    }
  }
}
