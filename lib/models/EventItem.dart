import 'package:json_annotation/json_annotation.dart';
import 'package:planv3/models/SourceItem.dart';
import 'package:device_calendar/device_calendar.dart';

part 'EventItem.g.dart';

@JsonSerializable()
class EventItem extends SourceItem {
  String title;
  String id;
  DateTime startTime;
  DateTime endTime;
  // could include other things like location, attendees, calendarId, reminders, etc.

  EventItem(this.title, this.id, {this.startTime, this.endTime});

  static EventItem fromDeviceCalendarEvent(Event event) {
    EventItem newItem = EventItem(event.title, event.eventId);
    newItem.startTime = event.start ?? null;
    newItem.endTime = event.end ?? null;

    return newItem;
  }

  factory EventItem.fromJson(Map<String, dynamic> json) =>
      _$EventItemFromJson(json);

  Map<String, dynamic> toJson() => _$EventItemToJson(this);
}
