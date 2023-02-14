import 'package:json_annotation/json_annotation.dart';
import 'package:planv3/interfaces/TaskRepository.dart';
import 'package:planv3/interfaces/TaskSource.dart';
import 'package:planv3/models/TaskSourceViewItem.dart';
import 'package:planv3/pages/view_settings_page_support/TaskSourceViewSettingsViewItem.dart';
import 'package:planv3/pages/view_settings_page_support/TaskViewSettingsViewItem.dart';
import 'package:planv3/repositories/CanvasTasksRepository.dart';
import 'package:planv3/repositories/CanvasTasksSourceRepository.dart';
import 'package:planv3/repositories/TaskSourceRepository.dart';

import 'CanvasCourse.dart';
import 'TaskSourceSettingsViewItem.dart';
import 'TaskView.dart';
import 'TaskViewViewItem.dart';

part 'CanvasTasksSource.g.dart';

@JsonSerializable()
class CanvasTasksSource implements TaskSource {
  final String title = "Canvas Tasks";
  final String id = "canvas_tasks";
  bool expanded = true;
  List<CanvasCourse> courses = [];
  List<TaskView> views = [];
  DateTime dateUpdatedFor;
  @JsonKey(disallowNullValue: true, defaultValue: false)
  bool isSetUp = false;
  DateTime lastUpdated;
  @JsonKey(disallowNullValue: true, defaultValue: true)
  bool isVisible = true;
  @JsonKey(disallowNullValue: true, defaultValue: false)
  bool isSyncing = false;
  @JsonKey(disallowNullValue: true, defaultValue: false)
  bool isSettingUp = false;
  @JsonKey(disallowNullValue: true, defaultValue: 2)
  int position = 2;

  CanvasTasksSource();

  void setPosition(int position) {
    this.position = position;
  }

  void updateDateUpdatedFor(DateTime date) {
    dateUpdatedFor = date;
  }

  TaskSourceSettingsViewItem toTaskSourceSettingsViewItem() {
    return TaskSourceSettingsViewItem(this.title, this.id, this.lastUpdated,
        this.isSetUp, this.isVisible, this.isSyncing, this.isSettingUp);
  }

  factory CanvasTasksSource.fromJson(Map<String, dynamic> json) =>
      _$CanvasTasksSourceFromJson(json);

  Map<String, dynamic> toJson() => _$CanvasTasksSourceToJson(this);

  @override
  TaskSourceRepository getSourceRepository() {
    return CanvasTasksSourceRepository();
  }

  @override
  TaskSourceViewSettingsViewItem toTaskSourceViewSettingsViewItem() {
    List<TaskViewSettingsViewItem> viewItems = [];
    viewItems = this
        .views
        .map((TaskView viewItem) => viewItem.toTaskViewSettingsViewItem())
        .toList();

    return TaskSourceViewSettingsViewItem(this.title, this.id, viewItems);
  }

  @override
  void updateLastUpdatedTimestamp() {
    lastUpdated = DateTime.now();
  }

  @override
  TaskRepository getRepository() {
    return CanvasTasksRepository();
  }

  @override
  TaskSourceViewItem toTaskSourceViewItem() {
    if (!this.isSetUp || !this.isVisible) {
      return null;
    }
    List<TaskViewViewItem> taskViewViewItems =
        this.views.map((TaskView view) => view.toTaskViewViewItem()).toList();

    return TaskSourceViewItem(
        this.title,
        this.expanded,
        this.isSetUp,
        taskViewViewItems,
        this.id,
        this.isVisible,
        this.position,
        this.isSyncing);
  }

  @override
  void onFailedUpdate() {
    this.isSetUp = false;
    this.isVisible = false;
  }

  @override
  void onSuccessfulUpdate() {
    this.isSetUp = true;
    this.isSyncing = false;
  }
}
