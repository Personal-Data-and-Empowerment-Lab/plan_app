import 'package:planv3/blocs/sources_list_bloc.dart';
import 'package:planv3/models/TaskViewItem.dart';

class TaskViewViewItem {
  final String title;
  final String id;
  bool _expanded;
  final List<TaskViewItem> items;
  SortType sortedBy;
  bool visible;

  TaskViewViewItem(this.title, this.id, this._expanded, this.items,
      this.sortedBy, this.visible);

  List<TaskViewItem> getSelectedItems() {
    List<TaskViewItem> selectedIDs = [];
    for (TaskViewItem item in items) {
      if (item.selected) {
        selectedIDs.add(item);
      }
    }
    return selectedIDs;
  }

  int getSelectedItemCount() {
    return items.where((TaskViewItem item) => item.selected).length;
  }

  bool hasAllSelected() {
    return this.getSelectedItemCount() == this.items.length &&
        this.items.length > 0;
  }

  bool hasSomeSelected() {
    return this.getSelectedItemCount() > 0;
  }

  void clearSelections() {
    for (TaskViewItem item in items) {
      item.selected = false;
    }
  }

  void selectAllItems() {
    for (TaskViewItem item in items) {
      item.selected = true;
    }
  }

  bool get expanded => items.length > 0 ? _expanded : false;

  set expanded(bool value) {
    _expanded = value;
  }
}
