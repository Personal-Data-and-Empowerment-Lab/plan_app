import 'package:equatable/equatable.dart';

abstract class MultiDayViewState extends Equatable {
  const MultiDayViewState();
}

class MultiDayViewInitial extends MultiDayViewState {
  @override
  List<Object> get props => [];
}

class MultiDayViewLoadInProgress extends MultiDayViewState {
  @override
  List<Object> get props => [];
}

class MultiDayViewLoadSuccess extends MultiDayViewState {
  @override
  List<Object> get props => [];
}

class MultiDayViewUpdateInProgress extends MultiDayViewState {
  @override
  List<Object> get props => [];
}

/// Normal multi day view state
class MultiDayViewActiveSuccess extends MultiDayViewState {
  @override
  List<Object> get props => [];
}
