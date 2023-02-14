part of 'task_source_view_settings_bloc.dart';

abstract class TaskSourceViewSettingsState extends Equatable {
  const TaskSourceViewSettingsState();
}

class TaskSourceViewSettingsInitial extends TaskSourceViewSettingsState {
  @override
  List<Object> get props => [];
}

class TaskViewSettingsLoaded extends TaskSourceViewSettingsState {
  final TaskSourceViewSettingsViewItem viewData;

  TaskViewSettingsLoaded(this.viewData);

  @override
  List<Object> get props => [this.viewData];
}
