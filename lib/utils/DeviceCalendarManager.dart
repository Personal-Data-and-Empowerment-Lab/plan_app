import 'dart:async';

import 'package:device_calendar/device_calendar.dart';

class DeviceCalendarManager {
  static Future<List<Calendar>> getCalendars() async {
    DeviceCalendarPlugin _deviceCalendarPlugin = new DeviceCalendarPlugin();

    try {
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      if (permissionsGranted.isSuccess && !permissionsGranted.data) {
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        if (!permissionsGranted.isSuccess || !permissionsGranted.data) {
          return null;
        }
      }
    } catch (e) {
      print(e);
      return null;
    }

    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    List<Calendar> calendars = calendarsResult?.data;
    return _filterOutReadOnlyCalendars(calendars);
  }

  static Future<List<Event>> getCalendarEventsForDate(
      String calendarID, DateTime date) async {
    DeviceCalendarPlugin _deviceCalendarPlugin = new DeviceCalendarPlugin();

    DateTime startDate = new DateTime(date.year, date.month, date.day, 0, 0, 0);
    DateTime endDate = startDate.add(Duration(days: 1));

    Result<List<Event>> eventsResult =
        await _deviceCalendarPlugin.retrieveEvents(calendarID,
            new RetrieveEventsParams(startDate: startDate, endDate: endDate));

    List<Event> events = eventsResult?.data;

    return _filterOutAllDayEvents(events);
  }

  // HELPER FUNCTIONS
  static List<Calendar> _filterOutReadOnlyCalendars(List<Calendar> calendars) {
    return calendars.where((Calendar calendar) {
      return !calendar.isReadOnly ?? false;
    }).toList();
  }

  static List<Event> _filterOutAllDayEvents(List<Event> events) {
    return events.where((Event event) => !event.allDay).toList();
  }
}
