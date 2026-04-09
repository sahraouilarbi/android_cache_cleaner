import 'package:android_cache_cleaner/domain/entities/app_storage_stats.dart';
import 'package:android_cache_cleaner/domain/repositories/i_storage_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetAppStatsUseCase {
  final IStorageRepository _repository;

  GetAppStatsUseCase(this._repository);

  Future<List<AppStorageStats>> call() async {
    final apps = await _repository.getAppsStorageStats();
    // Sort by cache size descending
    apps.sort((a, b) => b.cacheSize.compareTo(a.cacheSize));
    return apps;
  }
}
