import '../entities/app_storage_stats.dart';

abstract class IStorageRepository {
  /// Fetches storage statistics for all installed third-party apps.
  Future<List<AppStorageStats>> getAppsStorageStats();
}
