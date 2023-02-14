import 'package:device_calendar/device_calendar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:planv3/pages/view_settings_page_support/CalendarViewSettingsViewItem.dart';

part 'DeviceCalendarsCalendar.g.dart';

@JsonSerializable()
class DeviceCalendarsCalendar {
  bool selected = true;
  String title = "";
  String id;

  DeviceCalendarsCalendar();

  void setWithCalendarObject(Calendar calendar) {
    title = calendar.name;
    id = calendar.id;
  }

  CalendarViewSettingsViewItem toCalendarViewSettingsViewItem() {
    return CalendarViewSettingsViewItem(this.title, this.id, visible: selected);
  }

  factory DeviceCalendarsCalendar.fromJson(Map<String, dynamic> json) =>
      _$DeviceCalendarsCalendarFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceCalendarsCalendarToJson(this);
}
