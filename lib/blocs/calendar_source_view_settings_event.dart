import 'package:equatable/equatable.dart';

abstract class CalendarSourceViewSettingsEvent extends Equatable {
  const CalendarSourceViewSettingsEvent();
}

class LoadCalendarSourceViewSettings extends CalendarSourceViewSettingsEvent {
  @override
  List<Object> get props => [];
}

class CalendarViewVisibilityChanged extends CalendarSourceViewSettingsEvent {
  final String viewID;
  final bool newValue;

  CalendarViewVisibilityChanged(this.viewID, this.newValue);

  @override
  List<Object> get props => [viewID, newValue];
}
