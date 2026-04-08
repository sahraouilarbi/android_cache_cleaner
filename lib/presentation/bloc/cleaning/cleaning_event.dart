import 'package:equatable/equatable.dart';

abstract class CleaningEvent extends Equatable {
  const CleaningEvent();

  @override
  List<Object> get props => [];
}

class StartCleaning extends CleaningEvent {
  final List<String> packageNames;

  const StartCleaning(this.packageNames);

  @override
  List<Object> get props => [packageNames];
}
