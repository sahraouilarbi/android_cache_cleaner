import 'package:android_cache_cleaner/domain/entities/app_storage_stats.dart';
import 'package:equatable/equatable.dart';

abstract class StorageState extends Equatable {
  const StorageState();

  @override
  List<Object?> get props => [];
}

class StorageInitial extends StorageState {}

class StorageLoading extends StorageState {}

class StorageLoaded extends StorageState {
  final List<AppStorageStats> apps;
  final int totalCacheSize;

  const StorageLoaded(this.apps, this.totalCacheSize);

  @override
  List<Object?> get props => [apps, totalCacheSize];
}

class StorageError extends StorageState {
  final String message;

  const StorageError(this.message);

  @override
  List<Object?> get props => [message];
}
