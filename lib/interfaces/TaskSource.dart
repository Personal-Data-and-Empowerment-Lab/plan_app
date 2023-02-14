import 'package:planv3/interfaces/TaskRepository.dart';
import 'package:planv3/models/TaskSourceViewItem.dart';
import 'package:planv3/models/TaskView.dart';
import 'package:planv3/pages/view_settings_page_support/TaskSourceViewSettingsViewItem.dart';
import 'package:planv3/repositories/TaskSourceRepository.dart';

abstract class TaskSource {
  TaskSourceViewSettingsViewItem toTaskSourceViewSettingsViewItem();

  TaskSourceViewItem toTaskSourceViewItem();

  List<TaskView> get views;

  TaskSourceRepository getSourceRepository();

  bool get isVisible;

  String get id;

  bool get isSetUp;

  set isSetUp(bool isSetUp);

  set isVisible(bool isVisible);

  set isSyncing(bool isSyncing);

  void updateLastUpdatedTimestamp();

  TaskRepository getRepository();

  void onFailedUpdate();

  void onSuccessfulUpdate();

  set expanded(bool expanded);
}
