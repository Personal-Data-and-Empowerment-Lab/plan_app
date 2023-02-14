import 'package:planv3/models/EventViewItem.dart';

class CalendarViewViewItem {
  final String title;
  bool _expanded;
  final List<EventViewItem> items;

  CalendarViewViewItem(this.title, this._expanded, this.items);

  List<EventViewItem> getSelectedItems() {
    List<EventViewItem> selectedIDs = [];
    for (EventViewItem item in items) {
      if (item.selected) {
        selectedIDs.add(item);
      }
    }
    return selectedIDs;
  }

  void clearSelections() {
    for (EventViewItem item in items) {
      item.selected = false;
    }
  }

  int getSelectedItemCount() {
    return items.where((EventViewItem item) => item.selected).length;
  }

  bool hasAllSelected() {
    return this.getSelectedItemCount() == this.items.length &&
        this.items.length > 0;
  }

  bool hasSomeSelected() {
    return this.getSelectedItemCount() > 0;
  }

  // mark all items contained in view as selected
  void selectAllItems() {
    for (EventViewItem item in items) {
      item.selected = true;
    }
  }

  bool get expanded => items.length > 0 ? _expanded : false;

  set expanded(bool value) {
    _expanded = value;
  }
}
