import 'package:equatable/equatable.dart';
import 'package:planv3/models/Plan.dart';

abstract class MultiDayViewEvent extends Equatable {
  const MultiDayViewEvent();

  @override
  List<Object> get props => [];
}

class MultiDayViewInitialized extends MultiDayViewEvent {
  @override
  List<Object> get props => [];
}

class PlansLoaded extends MultiDayViewEvent {
  final List<Plan> plans;

  const PlansLoaded(this.plans);

  @override
  List<Object> get props => [this.plans];
}

class StartDateChanged extends MultiDayViewEvent {
  final DateTime startDate;

  const StartDateChanged(this.startDate);

  @override
  List<Object> get props => [this.startDate];
}

class PlanItemsReordered extends MultiDayViewEvent {
  final int oldDayIndex;
  final int newDayIndex;
  final int oldItemIndex;
  final int newItemIndex;

  const PlanItemsReordered(
      this.oldDayIndex, this.newDayIndex, this.oldItemIndex, this.newItemIndex);

  @override
  List<Object> get props => [
        this.oldDayIndex,
        this.newDayIndex,
        this.oldItemIndex,
        this.newItemIndex
      ];
}

class AppForeground extends MultiDayViewEvent {
  @override
  List<Object> get props => [];
}

class AppBackground extends MultiDayViewEvent {
  @override
  List<Object> get props => [];
}

class ExportLogsBackground extends MultiDayViewEvent {
  @override
  List<Object> get props => [];
}
