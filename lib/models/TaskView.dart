import 'package:json_annotation/json_annotation.dart';
import 'package:planv3/blocs/sources_list_bloc.dart';
import 'package:planv3/models/TaskItem.dart';
import 'package:planv3/models/TaskViewFilter.dart';
import 'package:planv3/models/TaskViewViewItem.dart';
import 'package:planv3/pages/view_settings_page_support/TaskViewSettingsViewItem.dart';
import 'package:uuid/uuid.dart';

import 'TaskViewItem.dart';

part 'TaskView.g.dart';

@JsonSerializable()
class TaskView {
  String title;
  @JsonKey(disallowNullValue: true)
  String id = Uuid().v4();
  @JsonKey(disallowNullValue: true)
  bool expanded = true;
  bool active = true;
  int position;
  List<TaskItem> items = [];
  List<String> subSourceIDs = [];
  List<TaskViewFilter> filters = [];
  SortType sortedBy = SortType.Original;

  TaskView(this.title);

  void removeSubSources(List<String> idsToRemove) {
    for (String idToRemove in idsToRemove) {
      subSourceIDs.remove(idToRemove);
    }
  }

  void addSubSourceID(List<String> idsToAdd) {
    for (String idToAdd in idsToAdd) {
      // only add if it's not there already
      if (!subSourceIDs.contains(idToAdd)) {
        subSourceIDs.add(idToAdd);
      }
    }
  }

  void addFilter(TaskViewFilter filter) {
    this.filters.add(filter);
  }

  TaskViewSettingsViewItem toTaskViewSettingsViewItem() {
    return TaskViewSettingsViewItem(this.title, this.id, visible: this.active);
  }

  TaskViewViewItem toTaskViewViewItem() {
    return TaskViewViewItem(this.title, this.id, this.expanded,
        this.getItemsAsViewItems(), this.sortedBy, this.active);
  }

  List<TaskViewItem> getItemsAsViewItems() {
    List<TaskViewItem> taskViewItems = this
        .items
        .map((TaskItem taskItem) =>
            TaskViewItem(taskItem.title, taskItem.dueDate, null, taskItem.id))
        .toList();
    for (int i = 0; i < taskViewItems.length; i++) {
      taskViewItems[i].position = i;
    }

    return taskViewItems;
  }

  factory TaskView.fromJson(Map<String, dynamic> json) =>
      _$TaskViewFromJson(json);

  Map<String, dynamic> toJson() => _$TaskViewToJson(this);
}
