import 'package:equatable/equatable.dart';
import 'package:planv3/blocs/sources_list_bloc.dart';
import 'package:planv3/models/SourcesListViewData.dart';

abstract class SourcesListEvent extends Equatable {
  const SourcesListEvent();
}

class Select extends SourcesListEvent {
  final String itemID;

  const Select(this.itemID);

  @override
  List<Object> get props => [];
}

class Sync extends SourcesListEvent {
  final String sourceID;
  final SourcesListViewData viewData;

  const Sync(this.sourceID, this.viewData);

  @override
  List<Object> get props => [this.sourceID, this.viewData];
}

class SyncAll extends SourcesListEvent {
  final SourcesListViewData viewData;

  const SyncAll(this.viewData);

  @override
  List<Object> get props => [this.viewData];
}

class AddSelectionToPlan extends SourcesListEvent {
  final SourcesListViewData viewData;

  const AddSelectionToPlan(this.viewData);

  @override
  List<Object> get props => [viewData];
}

class LoadInitialSources extends SourcesListEvent {
  const LoadInitialSources();

  @override
  List<Object> get props => [];
}

class LoadTutorialSources extends SourcesListEvent {
  @override
  List<Object> get props => [];
}

class SaveSourcesListLayout extends SourcesListEvent {
  final SourcesListViewData viewData;

  const SaveSourcesListLayout(this.viewData);

  @override
  List<Object> get props => [];
}

class SetUpSource extends SourcesListEvent {
  final String sourceID;
  final SourcesListViewData viewData;

  SetUpSource(this.sourceID, this.viewData);

  @override
  List<Object> get props => [sourceID, viewData];
}

class SourceExpansionChanged extends SourcesListEvent {
  final String sourceID;
  final bool newValue;

  SourceExpansionChanged(this.sourceID, this.newValue);

  @override
  List<Object> get props => [this.sourceID, this.newValue];
}

class ViewExpansionChanged extends SourcesListEvent {
  final String sourceID;
  final String viewID;
  final bool newValue;

  ViewExpansionChanged(this.viewID, this.newValue, this.sourceID);

  @override
  List<Object> get props => [this.viewID, this.newValue, this.sourceID];
}

class ViewSortTypeChanged extends SourcesListEvent {
  final String sourceID;
  final String viewID;
  final SortType newValue;

  ViewSortTypeChanged(this.viewID, this.newValue, this.sourceID);

  @override
  List<Object> get props => [this.viewID, this.newValue, this.sourceID];
}

class SourceSettingsChanged extends SourcesListEvent {
  @override
  List<Object> get props => [];
}

class AddTutorialSelectionToPlan extends SourcesListEvent {
  final String textToAdd;

  AddTutorialSelectionToPlan(this.textToAdd);

  @override
  List<Object> get props => [this.textToAdd];
}
