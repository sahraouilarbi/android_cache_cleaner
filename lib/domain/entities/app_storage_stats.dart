import 'dart:typed_data';
import 'package:equatable/equatable.dart';

class AppStorageStats extends Equatable {
  final String packageName;
  final String appName;
  final int cacheSize;
  final int dataSize;
  final int apkSize;
  final Uint8List? iconBytes;

  const AppStorageStats({
    required this.packageName,
    required this.appName,
    required this.cacheSize,
    required this.dataSize,
    required this.apkSize,
    this.iconBytes,
  });

  int get totalSize => cacheSize + dataSize + apkSize;

  @override
  List<Object?> get props => [packageName, appName, cacheSize, dataSize, apkSize, iconBytes];
}
