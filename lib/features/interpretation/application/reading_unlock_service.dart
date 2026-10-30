import 'package:dio/dio.dart';

import '../data/interpretation_repository.dart';
import '../domain/interpretation_models.dart';

class ReadingUnlockPollResult {
  const ReadingUnlockPollResult({
    required this.permissions,
    required this.legacyKeys,
    required this.confirmed,
  });

  final Set<ReadingSectionKey> permissions;
  final List<LegacyUnlockKey> legacyKeys;
  final bool confirmed;
}

/// Reads backend-owned permissions without mutating presentation state.
///
/// The controller remains the transaction orchestrator and publishes the
/// returned snapshot only after this service has finished polling.
class ReadingUnlockService {
  const ReadingUnlockService(this._repository);

  final InterpretationRepository _repository;

  Future<ReadingUnlockPollResult> waitForPermissions({
    required String chartId,
    required Set<ReadingSectionKey> expectedKeys,
    required bool shareAcrossModes,
    required bool Function() isCurrent,
    CancelToken? cancelToken,
    List<Duration> retryDelays = const [
      Duration.zero,
      Duration(milliseconds: 350),
      Duration(milliseconds: 900),
    ],
  }) async {
    var permissions = const <ReadingSectionKey>{};
    var legacyKeys = const <LegacyUnlockKey>[];
    for (final delay in retryDelays) {
      if (delay > Duration.zero) await Future<void>.delayed(delay);
      if (!isCurrent()) break;
      final rawKeys = await _repository.getUnlocks(
        chartId: chartId,
        cancelToken: cancelToken,
      );
      if (!isCurrent()) break;
      final parsed = ReadingUnlockSnapshot.fromRaw(
        rawKeys,
        expectedChartId: chartId,
      );
      permissions = shareAcrossModes
          ? sharePermissionsAcrossModes(parsed.canonicalKeys)
          : parsed.canonicalKeys;
      legacyKeys = parsed.legacyKeys;
      if (expectedKeys.every(permissions.contains)) {
        return ReadingUnlockPollResult(
          permissions: permissions,
          legacyKeys: legacyKeys,
          confirmed: true,
        );
      }
    }
    return ReadingUnlockPollResult(
      permissions: permissions,
      legacyKeys: legacyKeys,
      confirmed: false,
    );
  }

  static Set<ReadingSectionKey> sharePermissionsAcrossModes(
    Set<ReadingSectionKey> permissions,
  ) {
    final shared = <ReadingSectionKey>{};
    for (final key in permissions) {
      for (final mode in InterpretationMode.values) {
        shared.add(
          ReadingSectionKey(
            chartId: key.chartId,
            mode: mode,
            groupSlug: key.groupSlug,
            sectionSlug: key.sectionSlug,
          ),
        );
      }
    }
    return Set.unmodifiable(shared);
  }
}
