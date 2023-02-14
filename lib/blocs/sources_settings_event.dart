import 'package:equatable/equatable.dart';
import 'package:planv3/models/SnackBarData.dart';

abstract class SourcesSettingsEvent extends Equatable {
  const SourcesSettingsEvent();
}

class LoadSourcesSettings extends SourcesSettingsEvent {
  @override
  List<Object> get props => [];
}

class SetUpSourceSettings extends SourcesSettingsEvent {
  final String sourceID;

  SetUpSourceSettings(this.sourceID);

  @override
  List<Object> get props => [this.sourceID];
}

class ManageViews extends SourcesSettingsEvent {
  final String sourceID;

  ManageViews(this.sourceID);

  @override
  List<Object> get props => [this.sourceID];
}

class SaveSourcesSettings extends SourcesSettingsEvent {
  @override
  List<Object> get props => [];
}

class CancelSourcesSettings extends SourcesSettingsEvent {
  @override
  List<Object> get props => [];
}

class SourceVisibilityChanged extends SourcesSettingsEvent {
  final String sourceID;
  final bool newValue;

  SourceVisibilityChanged(this.sourceID, this.newValue);

  @override
  List<Object> get props => [this.sourceID, this.newValue];
}

class ShowSourcesSettingsError extends SourcesSettingsEvent {
  final SnackBarData errorData;

  ShowSourcesSettingsError(this.errorData);

  @override
  List<Object> get props => [this.errorData];
}

class ViewSettingsChanged extends SourcesSettingsEvent {
  @override
  List<Object> get props => [];
}

class SourceSetupCancelled extends SourcesSettingsEvent {
  final String sourceID;

  SourceSetupCancelled(this.sourceID);

  @override
  List<Object> get props => [this.sourceID];
}

class SourceSyncCancelled extends SourcesSettingsEvent {
  final String sourceID;

  SourceSyncCancelled(this.sourceID);

  @override
  List<Object> get props => [this.sourceID];
}
