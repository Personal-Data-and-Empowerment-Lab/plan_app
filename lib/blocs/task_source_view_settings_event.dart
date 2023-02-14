part of 'task_source_view_settings_bloc.dart';

abstract class TaskSourceViewSettingsEvent extends Equatable {
  const TaskSourceViewSettingsEvent();
}

class LoadTaskSourceViewSettings extends TaskSourceViewSettingsEvent {
  @override
  List<Object> get props => [];
}

class TaskViewVisibilityChanged extends TaskSourceViewSettingsEvent {
  final String viewID;
  final bool newValue;

  TaskViewVisibilityChanged(this.viewID, this.newValue);

  @override
  List<Object> get props => [this.viewID, this.newValue];
}
