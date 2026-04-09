import 'package:android_cache_cleaner/domain/repositories/i_cleaning_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class CleanCacheUseCase {
  final ICleaningRepository _repository;

  CleanCacheUseCase(this._repository);

  Future<bool> call(List<String> packageNames) async {
    return await _repository.clearCache(packageNames);
  }
}
