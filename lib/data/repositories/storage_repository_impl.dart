import 'package:android_cache_cleaner/data/datasources/native_channel.dart';
import 'package:android_cache_cleaner/domain/entities/app_storage_stats.dart';
import 'package:android_cache_cleaner/domain/repositories/i_storage_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: IStorageRepository)
class StorageRepositoryImpl implements IStorageRepository {
  final NativeChannel _nativeChannel;

  StorageRepositoryImpl(this._nativeChannel);

  @override
  Future<List<AppStorageStats>> getAppsStorageStats() async {
    final rawStats = await _nativeChannel.getAppStats();

    // Process mapping in an isolate to avoid blocking the main thread
    return await compute(_mapToEntities, rawStats);
  }

  static List<AppStorageStats> _mapToEntities(
    List<Map<String, dynamic>> rawList,
  ) {
    return rawList.map((map) {
      return AppStorageStats(
        packageName: map['packageName'] as String? ?? '',
        appName: map['appName'] as String? ?? 'Unknown',
        cacheSize: map['cacheSize'] as int? ?? 0,
        dataSize: map['dataSize'] as int? ?? 0,
        apkSize: map['apkSize'] as int? ?? 0,
        iconBytes: map['iconBytes'] as Uint8List?,
      );
    }).toList();
  }
}
