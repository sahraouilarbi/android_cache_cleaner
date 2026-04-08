import 'package:injectable/injectable.dart';

import '../../domain/repositories/i_cleaning_repository.dart';
import '../datasources/native_channel.dart';

@Injectable(as: ICleaningRepository)
class CleaningRepositoryImpl implements ICleaningRepository {
  final NativeChannel _nativeChannel;

  CleaningRepositoryImpl(this._nativeChannel);

  @override
  Future<bool> clearCache(List<String> packageNames) async {
    return await _nativeChannel.clearCache(packageNames);
  }

  @override
  Future<bool> isAccessibilityServiceEnabled() async {
    return await _nativeChannel.isAccessibilityServiceEnabled();
  }

  @override
  Future<void> requestAccessibilityService() async {
    await _nativeChannel.requestAccessibilityService();
  }

  @override
  Future<bool> triggerAccessibilityCleaning(List<String> packageNames) async {
    return await _nativeChannel.triggerAccessibilityCleaning(packageNames);
  }
}
