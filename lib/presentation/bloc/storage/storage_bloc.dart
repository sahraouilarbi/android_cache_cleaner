import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/usecases/get_app_stats_usecase.dart';
import 'storage_event.dart';
import 'storage_state.dart';

@injectable
class StorageBloc extends Bloc<StorageEvent, StorageState> {
  final GetAppStatsUseCase _getAppStatsUseCase;

  StorageBloc(this._getAppStatsUseCase) : super(StorageInitial()) {
    on<FetchStorageStats>(_onFetchStorageStats);
  }

  Future<void> _onFetchStorageStats(FetchStorageStats event, Emitter<StorageState> emit) async {
    emit(StorageLoading());
    try {
      final apps = await _getAppStatsUseCase();
      
      // Calculate total cache size
      int totalCache = 0;
      for (var app in apps) {
        totalCache += app.cacheSize;
      }
      
      emit(StorageLoaded(apps, totalCache));
    } catch (e) {
      emit(StorageError(e.toString()));
    }
  }
}
