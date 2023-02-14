import 'package:planv3/models/CalendarViewViewItem.dart';

class CalendarSourceViewItem {
  final String title;
  bool expanded;
  final List<CalendarViewViewItem> views;
  final bool isSetUp;
  final String id;
  bool isVisible;
  int position;
  bool isSyncing;

  CalendarSourceViewItem(this.title, this.expanded, this.isSetUp, this.views,
      this.id, this.isVisible, this.position, this.isSyncing);
}
