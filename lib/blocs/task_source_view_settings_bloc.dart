import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:planv3/interfaces/TaskSource.dart';
import 'package:planv3/models/TaskView.dart';
import 'package:planv3/pages/view_settings_page_support/TaskSourceViewSettingsViewItem.dart';
import 'package:planv3/repositories/TaskSourceRepository.dart';

part 'task_source_view_settings_event.dart';
part 'task_source_view_settings_state.dart';

class TaskSourceViewSettingsBloc
    extends Bloc<TaskSourceViewSettingsEvent, TaskSourceViewSettingsState> {
  TaskSource _tasksSource;
  TaskSourceRepository _taskSourceRepository;

  TaskSourceViewSettingsBloc(TaskSource taskSource) {
    //set task source and task repository

    _taskSourceRepository = taskSource.getSourceRepository();

    _tasksSource = taskSource;
    _taskSourceRepository = _tasksSource.getSourceRepository();
    this.add(LoadTaskSourceViewSettings());
  }

  @override
  Stream<TaskSourceViewSettingsState> mapEventToState(
    TaskSourceViewSettingsEvent event,
  ) async* {
    if (event is LoadTaskSourceViewSettings) {
      yield* _mapLoadTaskSourceViewSettings(event);
    } else if (event is TaskViewVisibilityChanged) {
      yield* _mapTaskViewVisibilityChangedToState(event);
    }
  }

  @override
  TaskSourceViewSettingsState get initialState =>
      TaskSourceViewSettingsInitial();

  Stream<TaskSourceViewSettingsState> _mapLoadTaskSourceViewSettings(
      event) async* {
    _tasksSource = await _taskSourceRepository.readTasksSource();

    TaskSourceViewSettingsViewItem viewItem =
        _tasksSource.toTaskSourceViewSettingsViewItem();

    yield TaskViewSettingsLoaded(viewItem);
  }

  Stream<TaskSourceViewSettingsState> _mapTaskViewVisibilityChangedToState(
      TaskViewVisibilityChanged event) async* {
    for (TaskView taskView in _tasksSource.views) {
      if (taskView.id == event.viewID) {
        taskView.active = event.newValue;
        _taskSourceRepository.writeTasksSource(_tasksSource);
      }
    }
  }
}
