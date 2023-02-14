import 'package:planv3/models/CalendarSourceViewItem.dart';
import 'package:planv3/models/CalendarViewViewItem.dart';
import 'package:planv3/models/EventViewItem.dart';
import 'package:planv3/models/TaskSourceViewItem.dart';
import 'package:planv3/models/TaskViewItem.dart';

import 'TaskViewViewItem.dart';

class SourcesListViewData {
  Map<String, TaskSourceViewItem> taskSourceViewItems;
  CalendarSourceViewItem deviceCalendarViewData;

//  final TaskSourceViewItem taskSourceViewData;

  SourcesListViewData(this.deviceCalendarViewData, this.taskSourceViewItems);

  String toLogString() {
    String returnString = "";
    if (deviceCalendarViewData != null) {
      returnString += deviceCalendarViewData.title + ": ";
      int totalItemCount = 0;
      for (CalendarViewViewItem view in deviceCalendarViewData.views) {
        totalItemCount += view.items.length;
      }
      returnString += "$totalItemCount total | ";
      returnString +=
          getSelectedEventItems().length.toString() + " selected | ";
    }

    if (taskSourceViewItems != null) {
      for (TaskSourceViewItem taskSourceViewItem
          in this.taskSourceViewItems.values) {
        if (taskSourceViewItem == null) {
          continue;
        }
        returnString += taskSourceViewItem.title + ": ";
        int selectedItemsCount = 0;
        int totalItemCount = 0;
        returnString += "Views: ${taskSourceViewItem.views.length} | ";
        for (TaskViewViewItem view in taskSourceViewItem.views) {
          totalItemCount += view.items.length;
          selectedItemsCount += view.getSelectedItems().length;
        }
        returnString += "Items: $totalItemCount | ";
        returnString += selectedItemsCount.toString() + " selected | ";
      }
    }

    return returnString;
  }

  List<EventViewItem> getSelectedEventItems() {
    //get for calendar
    List<EventViewItem> selectedIDs = [];

    if (deviceCalendarViewData != null) {
      for (CalendarViewViewItem view in deviceCalendarViewData.views) {
        selectedIDs.addAll(view.getSelectedItems());
      }
    }
    return selectedIDs;
  }

  List<TaskViewItem> getSelectedTaskItems() {
    List<TaskViewItem> selectedItems = [];

    if (taskSourceViewItems != null) {
      for (TaskSourceViewItem taskSourceViewItem
          in this.taskSourceViewItems.values) {
        if (taskSourceViewItem == null) {
          continue;
        }
        for (TaskViewViewItem view in taskSourceViewItem.views) {
          selectedItems.addAll(view.getSelectedItems());
        }
      }
    }

    return selectedItems;
  }

  int getSelectedItemsCount() {
    return getSelectedEventItems().length + getSelectedTaskItems().length;
  }

  void clearSelections() {
    // clear for device calendar
    if (this.deviceCalendarViewData != null) {
      for (CalendarViewViewItem view in deviceCalendarViewData.views) {
        view.clearSelections();
      }
    }

    // clear for task items
    if (this.taskSourceViewItems != null) {
      for (TaskSourceViewItem taskSourceViewItem
          in this.taskSourceViewItems.values) {
        for (TaskViewViewItem view in taskSourceViewItem.views) {
          view.clearSelections();
        }
      }
    }
  }

  bool anySourcesSyncing() {
    if (this.deviceCalendarViewData != null &&
        this.deviceCalendarViewData.isSyncing) {
      return true;
    }

    if (this.taskSourceViewItems != null) {
      for (TaskSourceViewItem taskSourceViewItem
          in this.taskSourceViewItems.values) {
        if (taskSourceViewItem?.isSyncing ?? false) {
          return true;
        }
      }
    }

    return false;
  }

  SourcesListViewData copyWith(
      {CalendarSourceViewItem deviceCalendarViewData,
      Map<String, TaskSourceViewItem> taskSourceViewItems}) {
    return SourcesListViewData(
        deviceCalendarViewData ?? this.deviceCalendarViewData,
        taskSourceViewItems ?? this.taskSourceViewItems);
  }
}
