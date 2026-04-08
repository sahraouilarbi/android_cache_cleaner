import 'package:injectable/injectable.dart';

import '../entities/app_storage_stats.dart';
import '../repositories/i_storage_repository.dart';

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
