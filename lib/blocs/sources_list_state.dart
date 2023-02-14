import 'package:equatable/equatable.dart';
import 'package:planv3/models/SourcesListViewData.dart';

abstract class SourcesListState extends Equatable {
  const SourcesListState();
}

class InitialSourcesListState extends SourcesListState {
  @override
  List<Object> get props => [];
}

class SourcesListLoaded extends SourcesListState {
  final SourcesListViewData viewData;

  const SourcesListLoaded(this.viewData);

  @override
  List<Object> get props => [this.viewData];
}

class SourcesListLoading extends SourcesListState {
  @override
  List<Object> get props => [];
}

class Selecting extends SourcesListState {
  @override
  List<Object> get props => [];
}

class SetUpFirstSource extends SourcesListState {
  @override
  List<Object> get props => [];
}

class SourcesListTutorial extends SourcesListState {
  @override
  List<Object> get props => [];
}

class MakeSourcesVisible extends SourcesListState {
  @override
  List<Object> get props => [];
}

class SourcesListSyncing extends SourcesListState {
  @override
  List<Object> get props => [];
}
