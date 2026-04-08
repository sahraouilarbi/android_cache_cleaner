import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/repositories/i_cleaning_repository.dart';
import '../../../domain/usecases/clean_cache_usecase.dart';
import 'cleaning_event.dart';
import 'cleaning_state.dart';

@injectable
class CleaningBloc extends Bloc<CleaningEvent, CleaningState> {
  final CleanCacheUseCase _cleanCacheUseCase;
  final ICleaningRepository _cleaningRepository;

  CleaningBloc(this._cleanCacheUseCase, this._cleaningRepository) : super(CleaningInitial()) {
    on<StartCleaning>(_onStartCleaning);
  }

  Future<void> _onStartCleaning(StartCleaning event, Emitter<CleaningState> emit) async {
    emit(CleaningInProgress());
    try {
      // 1. Try silent root cleaning via usecase
      final isRootSuccess = await _cleanCacheUseCase(event.packageNames);
      
      if (isRootSuccess) {
        emit(CleaningSuccess());
        return;
      }
      
      // 2. Fallback to Accessibility mode
      final isAccessibilityEnabled = await _cleaningRepository.isAccessibilityServiceEnabled();
      if (!isAccessibilityEnabled) {
        emit(AccessibilityPermissionRequired());
        // Trigger intent to open settings
        await _cleaningRepository.requestAccessibilityService();
      } else {
        // Trigger automation via the method channel
        final success = await _cleaningRepository.triggerAccessibilityCleaning(event.packageNames);
        if (success) {
          emit(CleaningSuccess());
        } else {
          emit(const CleaningError("Failed to start accessibility service automation."));
        }
      }
    } catch (e) {
      emit(CleaningError(e.toString()));
    }
  }
}
