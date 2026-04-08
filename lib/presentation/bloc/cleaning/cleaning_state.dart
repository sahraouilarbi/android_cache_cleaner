import 'package:equatable/equatable.dart';

abstract class CleaningState extends Equatable {
  const CleaningState();
  
  @override
  List<Object?> get props => [];
}

class CleaningInitial extends CleaningState {}

class CleaningInProgress extends CleaningState {}

class CleaningSuccess extends CleaningState {}

class AccessibilityPermissionRequired extends CleaningState {}

class CleaningError extends CleaningState {
  final String message;

  const CleaningError(this.message);

  @override
  List<Object?> get props => [message];
}
