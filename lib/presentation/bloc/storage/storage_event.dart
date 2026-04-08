import 'package:equatable/equatable.dart';

abstract class StorageEvent extends Equatable {
  const StorageEvent();

  @override
  List<Object> get props => [];
}

class FetchStorageStats extends StorageEvent {}
