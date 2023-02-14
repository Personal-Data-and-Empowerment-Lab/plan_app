import 'package:equatable/equatable.dart';
import 'package:planv3/interfaces/TaskSource.dart';
import 'package:planv3/models/DeviceCalendarsSource.dart';
import 'package:planv3/models/SnackBarData.dart';

abstract class SourcesSettingsState extends Equatable {
  const SourcesSettingsState();
}

class InitialSourcesSettingsState extends SourcesSettingsState {
  @override
  List<Object> get props => [];
}

class SourcesSettingsLoaded extends SourcesSettingsState {
  final List sourceViews;

  SourcesSettingsLoaded(this.sourceViews);

  @override
  List<Object> get props => [this.sourceViews];
}

class DisplayingSourcesSettingsErrorMessage extends SourcesSettingsState {
  final SnackBarData messageData;

  DisplayingSourcesSettingsErrorMessage(this.messageData);

  @override
  List<Object> get props => [this.messageData];
}

class SettingUpCanvas extends SourcesSettingsState {
  @override
  List<Object> get props => [];
}

class OpeningCalendarSourceViewSettings extends SourcesSettingsState {
  final DeviceCalendarsSource deviceCalendarsSource;

  OpeningCalendarSourceViewSettings(this.deviceCalendarsSource);

  @override
  List<Object> get props => [deviceCalendarsSource];
}

class OpeningTaskSourceViewSettings extends SourcesSettingsState {
  final TaskSource taskSource;

  OpeningTaskSourceViewSettings(this.taskSource);

  @override
  List<Object> get props => [this.taskSource];
}
