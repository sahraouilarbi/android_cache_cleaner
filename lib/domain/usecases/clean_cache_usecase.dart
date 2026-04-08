import 'package:injectable/injectable.dart';

import '../repositories/i_cleaning_repository.dart';

@injectable
class CleanCacheUseCase {
  final ICleaningRepository _repository;

  CleanCacheUseCase(this._repository);

  Future<bool> call(List<String> packageNames) async {
    return await _repository.clearCache(packageNames);
  }
}
