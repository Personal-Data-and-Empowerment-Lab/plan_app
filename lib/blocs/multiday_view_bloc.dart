import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:planv3/blocs/multiday_view_event.dart';
import 'package:planv3/blocs/multiday_view_state.dart';
import 'package:planv3/models/Plan.dart';
import 'package:planv3/repositories/PlansRepository.dart';
import 'package:planv3/utils/PlanParser.dart';

import 'editor_bloc.dart';

class MultiDayViewBloc extends Bloc<MultiDayViewEvent, MultiDayViewState> {
  List<Plan> plans = [];

  final PlansRepository localRepository;
  StreamSubscription _plansSubscription;
  StreamSubscription<FGBGType> _appStateSubscription;

  final EditorBloc editorBloc;

  MultiDayViewBloc({@required this.localRepository, @required this.editorBloc})
      : assert(localRepository != null) {
    _appStateSubscription = FGBGEvents.stream.listen((event) {
      switch (event) {
        case FGBGType.foreground:
          this.add(AppForeground());
          this.add(ExportLogsBackground());
          break;
        case FGBGType.background:
          // export logs in background
          this.add(AppBackground());
          this.add(ExportLogsBackground());
          print("exporting logs");
          break;
      }
    });
  }

  @override
  MultiDayViewState get initialState => MultiDayViewLoadInProgress();

  @override
  Stream<MultiDayViewState> mapEventToState(MultiDayViewEvent event) async* {
    if (event is MultiDayViewInitialized) {
      yield* _mapInitialState(event);
    } else if (event is PlansLoaded) {
      yield* _mapPlansLoadedToState(event);
    } else if (event is StartDateChanged) {
      yield* _mapStartDateChangedToState(event);
    } else if (event is PlanItemsReordered) {
      yield* _mapPlanItemsReorderedToState(event);
    }
  }

  Stream<MultiDayViewState> _mapInitialState(MultiDayViewEvent event) async* {
    _loadPlanRange(DateTime.now().toLocal(), 8);
    return;
  }

  Stream<MultiDayViewState> _mapPlansLoadedToState(PlansLoaded event) async* {
    this.plans = event.plans;
    yield MultiDayViewLoadSuccess();
  }

  Stream<MultiDayViewState> _mapStartDateChangedToState(
      StartDateChanged event) async* {
    yield MultiDayViewUpdateInProgress();
    _loadPlanRange(event.startDate, 8);
  }

  Stream<MultiDayViewState> _mapPlanItemsReorderedToState(
      PlanItemsReordered event) async* {
    yield MultiDayViewUpdateInProgress();
    // if the line stayed in the same plan
    if (event.oldDayIndex == event.newDayIndex) {
      Plan plan = this.plans[event.oldDayIndex];
      var lines = PlanParser.getPlanAsObjects(plan.planText);
      lines.insert(event.newItemIndex, lines.removeAt(event.oldItemIndex));
      this.plans[event.oldDayIndex] =
          plan.copyWith(planText: lines.map((e) => e.rawText).join('\n'));
    } else {
      Plan oldPlan = this.plans[event.oldDayIndex];
      Plan newPlan = this.plans[event.newDayIndex];
      var oldLines = PlanParser.getPlanAsObjects(oldPlan.planText);
      var newLines = PlanParser.getPlanAsObjects(newPlan.planText);

      var line = oldLines.removeAt(event.oldItemIndex);
      if (newPlan.planText == "") {
        // prevents extraneous newline
        newLines = [line];
      } else {
        newLines.insert(event.newItemIndex, line);
      }

      this.plans[event.oldDayIndex] =
          oldPlan.copyWith(planText: oldLines.map((e) => e.rawText).join('\n'));
      this.plans[event.newDayIndex] =
          newPlan.copyWith(planText: newLines.map((e) => e.rawText).join('\n'));

      // reschedule reminders for old and new days. ForceUpdate the old one because
      // we don't know if it used to have reminders or not. Could maybe be smarter
      //  about this in the future
      this.editorBloc.updateReminders(
          plan: this.plans[event.oldDayIndex], forceUpdate: true);
      this.editorBloc.updateReminders(plan: this.plans[event.newDayIndex]);
    }
    _savePlans();
    yield MultiDayViewLoadSuccess();
  }

  @override
  Future<void> close() {
    _appStateSubscription.cancel();
    _plansSubscription?.cancel();
    return super.close();
  }

  void _savePlans() {
    for (Plan plan in this.plans) {
      localRepository.updatePlan(plan);
    }
  }

  void _loadPlanRange(DateTime startDate, int days) {
    _plansSubscription?.cancel();
    _plansSubscription =
        localRepository.getPlanRange(startDate, days).listen((plans) {
      if (plans != null) {
        add(PlansLoaded(plans));
      } else {
        add(PlansLoaded([Plan("", startDate)]));
      }
    });
  }
}
