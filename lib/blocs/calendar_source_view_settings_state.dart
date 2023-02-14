import 'package:equatable/equatable.dart';
import 'package:planv3/pages/view_settings_page_support/CalendarSourceViewSettingsViewItem.dart';

abstract class CalendarSourceViewSettingsState extends Equatable {
  const CalendarSourceViewSettingsState();
}

class InitialCalendarSourceViewSettingsState
    extends CalendarSourceViewSettingsState {
  @override
  List<Object> get props => [];
}

class CalendarViewSettingsLoaded extends CalendarSourceViewSettingsState {
  final CalendarSourceViewSettingsViewItem viewData;

  CalendarViewSettingsLoaded(this.viewData);

  @override
  List<Object> get props => [viewData];
}
