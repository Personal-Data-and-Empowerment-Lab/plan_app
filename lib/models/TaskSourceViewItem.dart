import 'package:planv3/models/TaskViewViewItem.dart';

class TaskSourceViewItem {
  final String title;
  bool expanded;
  final bool isSetUp;
  final List<TaskViewViewItem> views;
  final String id;
  bool isVisible;
  int position;
  bool isSyncing;

  TaskSourceViewItem(this.title, this.expanded, this.isSetUp, this.views,
      this.id, this.isVisible, this.position, this.isSyncing);
}
