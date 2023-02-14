import 'package:planv3/models/TaskViewItem.dart';

abstract class TaskViewViewItemInterface {
  List<TaskViewItem> getSelectedItems();
  int getSelectedItemCount();
  bool hasAllSelected();
  bool hasSomeSelected();
  void clearSelections();
  void selectAllItems();
//  String get title;
//  bool get expanded;
//  set expanded(bool expanded);
  get id;
  get items;
  get sortedBy;
}
