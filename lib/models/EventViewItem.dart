import 'package:planv3/utils/TimeParser.dart';

import 'EventItem.dart';
import 'SourceItem.dart';

class EventViewItem extends SourceItem {
  final String text;
  final DateTime startTime;
  final DateTime endTime;
  final String id;
  bool selected = false;

  EventViewItem(this.text, this.startTime, this.endTime, this.id);

  static EventViewItem fromEventItem(EventItem eventItem) {
    return EventViewItem(
        eventItem.title, eventItem.startTime, eventItem.endTime, eventItem.id);
  }

  String getDisplayText() {
    return TimeParser.getFullTimeAsString(this.startTime, this.endTime) +
        " " +
        text;
  }
}
