import 'package:device_calendar/device_calendar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:planv3/models/DeviceCalendarsCalendar.dart';
import 'package:planv3/models/EventItem.dart';
import 'package:planv3/pages/view_settings_page_support/CalendarSourceViewSettingsViewItem.dart';
import 'package:planv3/pages/view_settings_page_support/CalendarViewSettingsViewItem.dart';
import 'package:planv3/repositories/DeviceCalendarsSourceRepository.dart';
import 'package:planv3/utils/DeviceCalendarManager.dart';

import 'CalendarSourceSettingsViewItem.dart';

part 'DeviceCalendarsSource.g.dart';

@JsonSerializable()
class DeviceCalendarsSource {
  String title = "Device Calendars";
  String id = "device_calendars";
  bool expanded = true;
  List<DeviceCalendarsCalendar> _calendars = [];
  List<EventItem> events = [];
  DateTime dateUpdatedFor;
  DateTime lastUpdated;
  @JsonKey(disallowNullValue: true, defaultValue: false)
  bool isSetUp = false;
  @JsonKey(disallowNullValue: true, defaultValue: true)
  bool isVisible = true;
  @JsonKey(disallowNullValue: true, defaultValue: false)
  bool isSyncing = false;
  @JsonKey(disallowNullValue: true, defaultValue: false)
  bool isSettingUp = false;
  @JsonKey(disallowNullValue: true, defaultValue: 0)
  int position = 0;

  void setPosition(int position) {
    this.position = position;
  }

  DeviceCalendarsSource(List<DeviceCalendarsCalendar> calendars) {
    this._calendars = calendars;
  }

  List<DeviceCalendarsCalendar> get calendars => _calendars;

  set calendars(List<DeviceCalendarsCalendar> value) {
    _calendars = value;
    _sortCalendarsByTitle();
  }

  // updates calendars and events from device given the date to get them for
  Future<DeviceCalendarsSource> syncDeviceCalendarSource(DateTime date) async {
    List<Calendar> rawCalendars = await DeviceCalendarManager.getCalendars();

    // update calendars
    mergeWithRawData(rawCalendars);

    // now that calendars are updated, update the events
    List<Event> events = [];
    for (DeviceCalendarsCalendar calendar in _calendars) {
      if (calendar.selected ?? true) {
        List<Event> thisCalendarEvents =
            await DeviceCalendarManager.getCalendarEventsForDate(
                calendar.id, date);
        events.addAll(thisCalendarEvents);
      }
    }

    //sort by time
    events.sort((Event a, Event b) {
      if (a.start.isBefore(b.start)) {
        return -1;
      } else if (a.start.isAfter(b.start)) {
        return 1;
      } else {
        return 0;
      }
    });

    // save to object
    this.events = events
        .map((Event event) => EventItem.fromDeviceCalendarEvent(event))
        .toList();

    // update date for list of events to given date
    // TODO: come up with a more elegant solution for this
    this.dateUpdatedFor = date;
    this.updateLastUpdatedTimestamp();
    this.isSetUp = true;
    this.isSyncing = false;
    // write to storage
    DeviceCalendarsSourceRepository.writeDeviceCalendarsSettings(this);
    return this;
  }

  void mergeWithRawData(List<Calendar> rawCalendars) {
    for (int i = 0; i < rawCalendars.length; i++) {
      // if a calendar with that id is already in the list
      if (_calendars.indexWhere((DeviceCalendarsCalendar model) =>
              model.id == rawCalendars[i].id) !=
          -1) {
        //do nothing
      } else {
        DeviceCalendarsCalendar newModel = new DeviceCalendarsCalendar();
        newModel.setWithCalendarObject(rawCalendars[i]);
        _calendars.add(newModel);
      }
    }

    // remove any calendars no longer on the device
    _calendars = _calendars.where((DeviceCalendarsCalendar model) {
      return rawCalendars
              .indexWhere((Calendar calendar) => model.id == calendar.id) !=
          -1;
    }).toList();

    _sortCalendarsByTitle();
  }

  void _sortCalendarsByTitle() {
    if (_calendars != null) {
      _calendars.sort((DeviceCalendarsCalendar a, DeviceCalendarsCalendar b) {
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      });
    }
  }

  void updateLastUpdatedTimestamp() {
    lastUpdated = DateTime.now();
  }

  bool lastUpdatedBefore(DateTime date) {
    return this.lastUpdated == null || this.lastUpdated.isBefore(date);
  }

  bool updatedForDate(DateTime date) {
    if (this.dateUpdatedFor == null) {
      return false;
    }
    DateTime beginningDateUpdatedFor = DateTime(this.dateUpdatedFor.year,
        this.dateUpdatedFor.month, this.dateUpdatedFor.day);
    if (!beginningDateUpdatedFor.isAtSameMomentAs(date)) {
      return false;
    } else {
      return true;
    }
  }

  CalendarSourceSettingsViewItem toCalendarSourceSettingsViewItem() {
    return CalendarSourceSettingsViewItem(this.title, this.id, this.lastUpdated,
        this.isSetUp, this.isVisible, this.isSyncing, this.isSettingUp);
  }

  CalendarSourceViewSettingsViewItem toCalendarSourceViewSettingsViewItem() {
    List<CalendarViewSettingsViewItem> viewSettingsViewItems = [];
    viewSettingsViewItems = this
        ._calendars
        .map((DeviceCalendarsCalendar deviceCalendar) =>
            deviceCalendar.toCalendarViewSettingsViewItem())
        .toList();
    return CalendarSourceViewSettingsViewItem(
        this.title, this.id, viewSettingsViewItems);
  }

  factory DeviceCalendarsSource.fromJson(Map<String, dynamic> json) =>
      _$DeviceCalendarsSourceFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceCalendarsSourceToJson(this);
}
