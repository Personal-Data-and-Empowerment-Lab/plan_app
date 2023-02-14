import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:planv3/models/DeviceCalendarsCalendar.dart';
import 'package:planv3/models/DeviceCalendarsSource.dart';
import 'package:planv3/pages/view_settings_page_support/CalendarSourceViewSettingsViewItem.dart';
import 'package:planv3/repositories/DeviceCalendarsSourceRepository.dart';

import './bloc.dart';

class CalendarSourceViewSettingsBloc extends Bloc<
    CalendarSourceViewSettingsEvent, CalendarSourceViewSettingsState> {
  DeviceCalendarsSource _deviceCalendarsSource;

  CalendarSourceViewSettingsBloc() {
    this.add(LoadCalendarSourceViewSettings());
  }

  @override
  CalendarSourceViewSettingsState get initialState =>
      InitialCalendarSourceViewSettingsState();

  @override
  Stream<CalendarSourceViewSettingsState> mapEventToState(
    CalendarSourceViewSettingsEvent event,
  ) async* {
    if (event is LoadCalendarSourceViewSettings) {
      yield* _mapLoadCalendarSourceViewSettingsToState(event);
    } else if (event is CalendarViewVisibilityChanged) {
      yield* _mapCalendarViewVisibilityChangedToState(event);
    }
  }

  Stream<CalendarSourceViewSettingsState>
      _mapLoadCalendarSourceViewSettingsToState(
          LoadCalendarSourceViewSettings event) async* {
    _deviceCalendarsSource =
        await DeviceCalendarsSourceRepository.readDeviceCalendarsSettings();

    CalendarSourceViewSettingsViewItem viewItem =
        _deviceCalendarsSource.toCalendarSourceViewSettingsViewItem();

    yield CalendarViewSettingsLoaded(viewItem);
  }

  Stream<CalendarSourceViewSettingsState>
      _mapCalendarViewVisibilityChangedToState(
          CalendarViewVisibilityChanged event) async* {
    for (DeviceCalendarsCalendar calendar in _deviceCalendarsSource.calendars) {
      if (calendar.id == event.viewID) {
        calendar.selected = event.newValue;
        DeviceCalendarsSourceRepository.writeDeviceCalendarsSettings(
            _deviceCalendarsSource);
      }
    }
  }
}
