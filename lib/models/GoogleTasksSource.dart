import 'package:json_annotation/json_annotation.dart';
import 'package:planv3/interfaces/TaskRepository.dart';
import 'package:planv3/interfaces/TaskSource.dart';
import 'package:planv3/models/GoogleTaskList.dart';
import 'package:planv3/models/TaskSourceSettingsViewItem.dart';
import 'package:planv3/pages/view_settings_page_support/TaskSourceViewSettingsViewItem.dart';
import 'package:planv3/pages/view_settings_page_support/TaskViewSettingsViewItem.dart';
import 'package:planv3/repositories/GoogleTasksRepository.dart';
import 'package:planv3/repositories/GoogleTasksSourceRepository.dart';
import 'package:planv3/repositories/TaskSourceRepository.dart';

import 'TaskSourceViewItem.dart';
import 'TaskView.dart';
import 'TaskViewViewItem.dart';

part 'GoogleTasksSource.g.dart';

@JsonSerializable()
class GoogleTasksSource implements TaskSource {
  String title = "Google Tasks";
  String id = "google_tasks";
  bool expanded = true;
  List<GoogleTaskList> lists = [];
  List<TaskView> views = [];
  DateTime dateUpdatedFor;
  @JsonKey(disallowNullValue: true, defaultValue: false)
  bool isSetUp = false;
  String primaryAccountInfo;
  DateTime lastUpdated;
  @JsonKey(disallowNullValue: true, defaultValue: true)
  bool isVisible = true;
  @JsonKey(disallowNullValue: true, defaultValue: false)
  bool isSyncing = false;
  @JsonKey(disallowNullValue: true, defaultValue: false)
  bool isSettingUp = false;
  @JsonKey(disallowNullValue: true, defaultValue: 1)
  int position = 1;

  GoogleTasksSource();

  void setPosition(int position) {
    this.position = position;
  }

  void addView(TaskView view) {
    views.add(view);
  }

  void updateLastUpdatedTimestamp() {
    lastUpdated = DateTime.now();
  }

  void updateDateUpdatedFor(DateTime date) {
    dateUpdatedFor = date;
  }

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

  TaskSourceSettingsViewItem toTaskSourceSettingsViewItem() {
    return TaskSourceSettingsViewItem(this.title, this.id, this.lastUpdated,
        this.isSetUp, this.isVisible, this.isSyncing, this.isSettingUp);
  }

  TaskSourceViewSettingsViewItem toTaskSourceViewSettingsViewItem() {
    List<TaskViewSettingsViewItem> viewItems = [];
    viewItems = this
        .views
        .map((TaskView viewItem) => viewItem.toTaskViewSettingsViewItem())
        .toList();

    return TaskSourceViewSettingsViewItem(this.title, this.id, viewItems);
  }

  factory GoogleTasksSource.fromJson(Map<String, dynamic> json) =>
      _$GoogleTasksSourceFromJson(json);

  Map<String, dynamic> toJson() => _$GoogleTasksSourceToJson(this);

  @override
  TaskSourceRepository getSourceRepository() {
    return GoogleTasksSourceRepository();
  }

  @override
  TaskRepository getRepository() {
    return GoogleTasksRepository();
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
