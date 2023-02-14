import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:f_logs/model/flog/flog.dart';
import 'package:f_logs/model/flog/log.dart';
import 'package:f_logs/utils/formatter/formatter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:planv3/blocs/SimpleBlocDelegate.dart';
import 'package:planv3/models/EventViewItem.dart';
import 'package:planv3/models/Plan.dart';
import 'package:planv3/models/PlanLine.dart';
import 'package:planv3/models/SnackBarData.dart';
import 'package:planv3/models/TaskViewItem.dart';
import 'package:planv3/repositories/PlansRepository.dart';
import 'package:planv3/utils/CursorUtils.dart';
import 'package:planv3/utils/FirebaseFileUploader.dart';
import 'package:planv3/utils/NotificationManager.dart';
import 'package:planv3/utils/PlanParser.dart';
import 'package:planv3/utils/TimeParser.dart';
import 'package:planv3/utils/TimeSuggester.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import './bloc.dart';

enum OverFlowMenuItem {
  calendar,
  copy,
  sources,
  clear,
  tasks,
  intro,
  startTutorial,
  stopTutorial,
  userID,
  exportPlans,
  exportLogs,
  scheduleLine,
  showSurvey,
  feedback,
  showMultiDay
}

final GlobalKey planNavigation = GlobalKey();
final GlobalKey fullSourcesDrawer = GlobalKey();
final GlobalKey copyPlan = GlobalKey();
final GlobalKey syncSources = GlobalKey();
final GlobalKey calendarSource = GlobalKey();
final GlobalKey openDrawerButton = GlobalKey();
final GlobalKey calendarBadge = GlobalKey();
final GlobalKey singleTask = GlobalKey();
final GlobalKey selectedFooter = GlobalKey();
final GlobalKey timePicker = GlobalKey();
final GlobalKey checkboxTool = GlobalKey();
final GlobalKey snoozeTool = GlobalKey();
final GlobalKey timeTool = GlobalKey();
final GlobalKey editor = GlobalKey();

//final GlobalKey editorAfterDrawer = GlobalKey();

class EditorBloc extends Bloc<EditorEvent, EditorState> {
  Plan plan; //= Plan("", DateTime.now());
  int cursorPosition = 0;

  //add spaces to them so they'll immediately get built into images (space is endFlag)
  String checkboxString = PlanParser.checkboxString + " ";
  String completedCheckboxString = PlanParser.completedCheckboxString + " ";
  String reminderString = PlanParser.reminderString + " ";

  Plan tutorialTodayPlan = Plan("", DateTime.now());
  int tutorialCursorPosition = 0;
  String tutorialTextToAdd;

  final PlansRepository localRepository;
  StreamSubscription _plansSubscription;
  StreamSubscription<FGBGType> _appStateSubscription;

  bool inTutorial = false;
  bool hasSeenSwipeTutorial = false;

  EditorBloc({@required this.localRepository})
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
  Future<void> close() {
    _appStateSubscription.cancel();
    return super.close();
  }

  @override
//  EditorState get initialState => ActiveEditing("", 0, false, plan: Plan(planText, DateTime.now()));
  EditorState get initialState => Loading();

  @override
  Stream<EditorState> mapEventToState(
    EditorEvent event,
  ) async* {
    var oldPlanText = this.plan?.planText ?? '';
    if (event is EditText) {
      yield* _mapEditTextToState(event);
    } else if (event is AddCheckbox) {
      yield* _mapAddCheckboxToState(event);
    } else if (event is LoadInitialPlan) {
      yield* _mapLoadInitialPlanToState(event);
    } else if (event is PlanLoaded) {
      yield* _mapPlanLoadedToState(event);
    } else if (event is LoadSpecificPlan) {
      yield* _mapLoadSpecificPlanToState(event);
    } else if (event is MarkCheckboxComplete) {
      yield* _mapMarkCheckboxCompleteToState(event);
    } else if (event is RemoveCheckbox) {
      yield* _mapRemoveCheckboxToState(event);
    } else if (event is MarkCheckboxIncomplete) {
      yield* _mapMarkCheckboxIncompleteToState(event);
    } else if (event is IncrementStartTime) {
      yield* _mapIncrementStartTimeToState(event);
    } else if (event is AddTime) {
      yield* _mapAddTimeToState(event);
    } else if (event is RemoveTime) {
      yield* _mapRemoveTimeToState(event);
    } else if (event is DecrementStartTime) {
      yield* _mapDecrementStartTimeToState(event);
    } else if (event is IncrementEndTime) {
      yield* _mapIncrementEndTimeToState(event);
    } else if (event is DecrementEndTime) {
      yield* _mapDecrementEndTimeToState(event);
    } else if (event is CopyPlan) {
      yield* _mapCopyPlanToState(event);
    } else if (event is SavePlan) {
      yield* _mapSavePlanToState(event);
    } else if (event is ClearPlan) {
      yield* _mapClearPlanToState(event);
    } else if (event is LoadPreviousPlan) {
      yield* _mapLoadPreviousPlanToState(event);
    } else if (event is LoadNextPlan) {
      yield* _mapLoadNextPlanToState(event);
    } else if (event is UndoClearPlan) {
      yield* _mapUndoClearPlanToState(event);
    } else if (event is AddSourceItemsToPlan) {
      yield* _mapAddSourceItemsToPlan(event);
    } else if (event is OpenSourcesList) {
      yield* _mapOpenSourcesListToState(event);
    } else if (event is Error) {
      yield* _mapErrorToState(event);
    } else if (event is StartTutorial) {
      yield* _mapStartTutorialToState(event);
    } else if (event is StopTutorial) {
      yield* _mapStopTutorialToState(event);
    } else if (event is SnoozeItem) {
      yield* _mapSnoozeItemToState(event);
    } else if (event is UndoSnoozeItem) {
      yield* _mapUndoSnoozeItemToState(event);
    } else if (event is UncheckedItemsSnoozed) {
      yield* _mapUncheckedItemsSnoozedToState(event);
    } else if (event is ItemSnoozedToDay) {
      yield* _mapItemSnoozedToDayToState(event);
    } else if (event is AddTutorialSourceItemsToPlan) {
      yield* _mapAddTutorialSourceItemsToPlan(event);
    } else if (event is SetUpTimeToolTutorial) {
      yield* _mapSetUpTimeToolTutorialToState(event);
    } else if (event is IncrementTimeTutorial) {
      yield* _mapIncrementTimeTutorialToState(event);
    } else if (event is AddCheckboxTutorial) {
      yield* _mapAddCheckboxTutorialToState(event);
    } else if (event is SnoozeLineTutorial) {
      yield* _mapSnoozeLineTutorialToState(event);
    } else if (event is ExportPlans) {
      yield* _mapExportPlansToState(event);
    } else if (event is ExportLogs) {
      yield* _mapExportLogsToState(event);
    } else if (event is SnoozeTutorial) {
      yield* _mapSnoozeTutorialToState(event);
    } else if (event is AddReminder) {
      yield* _mapAddReminderToState(event);
    } else if (event is RemoveReminder) {
      yield* _mapRemoveReminderToState(event);
    } else if (event is ReminderTutorial) {
      yield* _mapReminderTutorialToState(event);
    } else if (event is TimeTutorial) {
      yield* _mapTimeTutorialToState(event);
    } else if (event is CheckboxTutorial) {
      yield* _mapCheckboxTutorialToState(event);
    } else if (event is ExportLogsBackground) {
      yield* _mapExportLogsBackgroundToState(event);
    } else if (event is AppBackground) {
      yield* _mapAppBackgroundToState(event);
    } else if (event is AppForeground) {
      yield* _mapAppForegroundToState(event);
    } else if (event is ExportLogsSucceeded) {
      yield* _mapExportLogsSucceededToState(event);
    } else if (event is ExportLogsFailed) {
      yield* _mapExportLogsFailedToState(event);
    } else if (event is CancelSurvey) {
      yield* _mapCancelSurveyToState(event);
    } else if (event is SubmitSurvey) {
      yield* _mapSubmitSurveyToState(event);
    } else if (event is CancelFeedback) {
      yield* _mapCancelFeedbackToState(event);
    } else if (event is SubmitFeedback) {
      yield* _mapSubmitFeedbackToState(event);
    } else if (event is EditorCursorSwipedRight) {
      yield* _mapEditorCursorSwipedRight(event);
    } else if (event is EditorCursorSwipedLeft) {
      yield* _mapEditorCursorSwipedLeft(event);
    } else if (event is SwipeLeftTutorial) {
      yield* _mapSwipeLeftLineTutorialToState(event);
    } else if (event is SwipeRightTutorial) {
      yield* _mapSwipeRightLineTutorialToState(event);
    }

    //   } else if (event is EditorCursorSwipedUp) {
    //     yield* _mapEditorCursorSwipedUp(event);      KEEPING THESE UNTIL I KNOW I DON'T NEED THEM FOR TWO-FINGER SWIPE
    // } else if (event is EditorCursorSwipedDown) {
    //     yield* _mapEditorCursorSwipedDown(event);
    //   }

    if (this.plan != null && this.plan.planText != oldPlanText) {
      _savePlan();
    }
  }

  // / This method moves the cursor up to the line above when the user swipes up.
  // Stream<EditorState> _mapEditorCursorSwipedUp(EditorCursorSwipedUp event) async* {
  //   int newCursorPosition;
  //
  //   if(SwipeUtils.cursorIsAtStartOfLine(cursorPosition, plan))
  //     newCursorPosition = SwipeUtils.getIndexOfStartOfLineAbove(cursorPosition, plan);
  //
  //   else newCursorPosition = SwipeUtils.getIndexOfEndOfLineAbove(cursorPosition, plan);
  //
  //   yield ActiveEditing(SwipeUtils.validateCursorPosition(cursorPosition, newCursorPosition, "UP", plan), false, this.plan);
  // }
  //
  // /// This method moves the cursor down to the line above when the user swipes up.
  // Stream<EditorState> _mapEditorCursorSwipedDown(EditorCursorSwipedDown event) async* {
  //   int newCursorPosition;
  //
  //   if (SwipeUtils.cursorIsAtStartOfLine(cursorPosition, plan))
  //     newCursorPosition = SwipeUtils.getIndexOfStartOfLineBelow(cursorPosition, plan);
  //
  //   else newCursorPosition = SwipeUtils.getIndexOfEndOfLineBelow(cursorPosition, plan);
  //
  //   yield ActiveEditing(SwipeUtils.validateCursorPosition(cursorPosition, newCursorPosition, "DOWN", plan), false, this.plan);
  // }

  Stream<EditorState> _mapEditTextToState(EditText event) async* {
    // update planText
    bool textAdded =
        event.editorText.toString().length > this.plan.planText.length;
    this.plan = this.plan.copyWith(planText: event.editorText.toString());
    cursorPosition = event.cursorPosition;
    print("updating cursor to: $cursorPosition");
    bool updateToolbarsOnly = true;
    if (cursorPosition < 0) {
      cursorPosition = 0;
      updateToolbarsOnly = false;
    } else if (cursorPosition > this.plan.planText.length) {
      cursorPosition = this.plan.planText.length;
      updateToolbarsOnly = false;
    }

    // if a newline was just added
    if (textAdded &&
        this.plan.planText.length > cursorPosition - 1 && // stop out of bounds
        cursorPosition > 0 &&
        this.plan.planText[cursorPosition - 1] == "\n") {
      // if the previous line has a checkbox
      if (PlanParser.lineAtPosHasCheckbox(
          this.plan.planText, cursorPosition - 1)) {
        // if the previous line has any content
        if (PlanParser.getLineFromPosition(
                    this.plan.planText, cursorPosition - 1)
                .length >
            (PlanParser.checkboxString.length + 1)) {
          this.add(AddCheckbox());
        } else {
          this.plan.planText =
              this.plan.planText.replaceFirst("\n", "", cursorPosition - 1);
          cursorPosition = cursorPosition - 1;
          this.add(RemoveCheckbox());
        }

        return;
      }
    }

    // update reminders
    // clear all reminders
    // for each line, check if it has a reminder
    // if (PlanParser.planHasReminders(this.plan.planText)) {
    updateReminders();

    // }
    // if it does, extract the start time and it to the list
    // set all the reminders in the list

    yield ActiveEditing(cursorPosition, updateToolbarsOnly, this.plan);
    // generally I guess we won't mutate the state
  }

  Stream<EditorState> _mapLoadInitialPlanToState(LoadInitialPlan event) async* {
    DateTime now = DateTime.now().toLocal();
    _loadPlanData(now);
    this.add(ExportLogsBackground());
  }

  Stream<EditorState> _mapLoadSpecificPlanToState(
      LoadSpecificPlan event) async* {
    if (event.refreshCurrentPlan) {
      await _plansSubscription?.cancel();
      this.plan = await localRepository.getPlan(this.plan.date).last;
      this.cursorPosition = 0;
    }

    this.updateReminders();
    _savePlan();

    _loadPlanData(event.dateTime);
    this.add(ExportLogsBackground());
  }

  Stream<EditorState> _mapPlanLoadedToState(PlanLoaded event) async* {
    this.plan = event.plan;
    // since plan might have been updated in multi-day view
    this.updateReminders(forceUpdate: true);
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
//    bool tutorialViewed = prefs.getBool('tutorialViewed') ?? false;
    bool tutorialViewed = true;
    if (tutorialViewed) {
      yield ActiveEditing(0, false, plan);
    } else {
      yield BeforeDrawerTutorial(
          this.tutorialTodayPlan, this.tutorialCursorPosition);
    }
  }

  Stream<EditorState> _mapAddCheckboxToState(AddCheckbox event) async* {
    //add checkbox at beginning of line the cursor is on

    int lineBeginPos = PlanParser.getLineStartIndexFromPosition(
        this.plan.planText, cursorPosition);
    this.plan.planText = this
        .plan
        .planText
        .replaceRange(lineBeginPos, lineBeginPos, checkboxString);
    this.plan.planText = this.plan.planText.toString();
    yield ActiveEditing(
        this.cursorPosition + checkboxString.length, false, this.plan);
  }

  Stream<EditorState> _mapMarkCheckboxCompleteToState(
      MarkCheckboxComplete event) async* {
    if (PlanParser.lineAtPosHasIncompleteCheckbox(
        this.plan.planText, event.cursorPosition)) {
      int checkboxPos = PlanParser.getGlobalIndexOfStringFromLinePos(
          checkboxString, this.plan.planText, event.cursorPosition);

      this.plan.planText = this.plan.planText.replaceRange(checkboxPos,
          checkboxPos + checkboxString.length, completedCheckboxString);
      this.plan.planText = this.plan.planText.toString();
      yield ActiveEditing(
          this.cursorPosition +
              (completedCheckboxString.length - checkboxString.length).abs(),
          false,
          this.plan);
    }
  }

  Stream<EditorState> _mapMarkCheckboxIncompleteToState(
      MarkCheckboxIncomplete event) async* {
    if (PlanParser.lineAtPosHasCompleteCheckbox(
        this.plan.planText, event.cursorPosition)) {
      int checkboxPos = PlanParser.getGlobalIndexOfStringFromLinePos(
          completedCheckboxString, this.plan.planText, event.cursorPosition);
      this.plan.planText = this.plan.planText.replaceRange(checkboxPos,
          checkboxPos + completedCheckboxString.length, checkboxString);
      this.plan.planText = this.plan.planText.toString();
      yield ActiveEditing(
          this.cursorPosition +
              (completedCheckboxString.length - checkboxString.length).abs(),
          false,
          this.plan);
    }
  }

  Stream<EditorState> _mapRemoveCheckboxToState(RemoveCheckbox event) async* {
    String removedString = "";
    int removePos;
    if (PlanParser.lineAtPosHasIncompleteCheckbox(
        this.plan.planText, cursorPosition)) {
      //remove checkbox
      removePos = PlanParser.getGlobalIndexOfStringFromLinePos(
          checkboxString, this.plan.planText, cursorPosition);
      this.plan.planText =
          this.plan.planText.replaceFirst(checkboxString, "", removePos);
      removedString = checkboxString;
    } else if (PlanParser.lineAtPosHasCompleteCheckbox(
        this.plan.planText, cursorPosition)) {
      removePos = PlanParser.getGlobalIndexOfStringFromLinePos(
          completedCheckboxString, this.plan.planText, cursorPosition);
      this.plan.planText = this
          .plan
          .planText
          .replaceFirst(completedCheckboxString, "", removePos);
      removedString = completedCheckboxString;
    } else {
      return;
    }

    this.plan.planText = this.plan.planText.toString();
    int newCursorPos = 0;
    if (this.cursorPosition <= removePos) {
      newCursorPos = this.cursorPosition;
    } else {
      newCursorPos = this.cursorPosition - removedString.length;
    }

    yield ActiveEditing(newCursorPos, false, this.plan);
  }

  Stream<EditorState> _mapAddTimeToState(AddTime event) async* {
    int newCursorPos = _incrementCurrentLineStartTime();
    updateReminders();
    yield ActiveEditing(newCursorPos, false, this.plan);
  }

  Stream<EditorState> _mapIncrementStartTimeToState(
      IncrementStartTime event) async* {
    //get the line we're working with
    int newCursorPos = _incrementCurrentLineStartTime();
    updateReminders();
    yield ActiveEditing(newCursorPos, false, this.plan);
  }

  int _incrementCurrentLineStartTime() {
    String line =
        PlanParser.getLineFromPosition(this.plan.planText, cursorPosition);
    //check if there's a valid start time
    ParsedTimeData timeData = TimeParser.extractDatesFromText(line);

    TimeSuggester timeSuggester = TimeSuggester(this.plan.date);
    List<PlanLine> planLines = PlanParser.getPlanAsObjects(this.plan.planText);
    PlanLine currentLine =
        PlanParser.getLineObjectFromPosition(planLines, cursorPosition);
    List<PlanLine> surroundingLines =
        PlanParser.getSurroundingLines(planLines, currentLine.linePosition);
    if (currentLine.startTime == null) {
      currentLine.startTime = timeSuggester.decrementStartTime(
          surroundingLines[0], surroundingLines[1], currentLine);
    } else {
      currentLine.startTime = timeSuggester.incrementStartTime(
          surroundingLines[0], surroundingLines[1], currentLine);
    }
    //now we need update the text in the line to reflect the new time
    // generate the string
    String timeString = TimeParser.getFullTimeAsString(
        currentLine.startTime, currentLine.endTime);
    // replace the current string with it
    int replacePosStart =
        currentLine.lineStartIndex + (timeData.startPosition ?? 0);
    int replacePosEnd =
        currentLine.lineStartIndex + (timeData.endPosition ?? 0);

    // check to make sure there's a space after where the time's going. If not,
    // we need to add one to make sure the text building works nicely
    if (!PlanParser.isNextCharSpace(this.plan.planText, replacePosEnd)) {
      timeString += " ";
    }

    this.plan = this.plan.copyWith(
        planText: this
            .plan
            .planText
            .replaceRange(replacePosStart, replacePosEnd, timeString));
    // update cursor position
    int newCursorPos;
    if (this.cursorPosition < replacePosStart) {
      newCursorPos = this.cursorPosition;
    } else {
      newCursorPos = this.cursorPosition -
          (replacePosEnd - replacePosStart) +
          timeString.length;
      newCursorPos = newCursorPos >= 0 ? newCursorPos : 0;
    }

    return newCursorPos;
  }

  Stream<EditorState> _mapRemoveTimeToState(RemoveTime event) async* {
    //get the line we're working with
    String line =
        PlanParser.getLineFromPosition(this.plan.planText, cursorPosition);
    //check if there's a time
    ParsedTimeData timeData = TimeParser.extractDatesFromText(line);
    List<PlanLine> planLines = PlanParser.getPlanAsObjects(this.plan.planText);
    PlanLine currentLine =
        PlanParser.getLineObjectFromPosition(planLines, cursorPosition);

    int replacePosStart =
        currentLine.lineStartIndex + (timeData.startPosition ?? 0);
    int replacePosEnd =
        currentLine.lineStartIndex + (timeData.endPosition ?? 0);
    if (PlanParser.isNextCharSpace(this.plan.planText, replacePosEnd)) {
      replacePosEnd += 1;
    }
    this.plan.planText =
        this.plan.planText.replaceRange(replacePosStart, replacePosEnd, "");
    // update cursor position
    int newCursorPos;
    if (this.cursorPosition <= replacePosStart) {
      newCursorPos = this.cursorPosition;
    } else {
      newCursorPos = this.cursorPosition - (replacePosEnd - replacePosStart);
      newCursorPos = newCursorPos >= 0 ? newCursorPos : 0;
    }
    this.cursorPosition = newCursorPos;
    if (PlanParser.lineAtPosHasReminder(
        this.plan.planText, this.cursorPosition)) {
      newCursorPos = this._removeReminder(timeRemoved: true);
      this.cursorPosition = newCursorPos;
    }

    updateReminders();

    yield ActiveEditing(newCursorPos, false, this.plan);
  }

  Stream<EditorState> _mapDecrementStartTimeToState(
      DecrementStartTime event) async* {
    String line =
        PlanParser.getLineFromPosition(this.plan.planText, cursorPosition);
    ParsedTimeData timeData = TimeParser.extractDatesFromText(line);

    TimeSuggester timeSuggester = TimeSuggester(this.plan.date);
    List<PlanLine> planLines = PlanParser.getPlanAsObjects(this.plan.planText);
    PlanLine currentLine =
        PlanParser.getLineObjectFromPosition(planLines, cursorPosition);
    List<PlanLine> surroundingLines =
        PlanParser.getSurroundingLines(planLines, currentLine.linePosition);

    currentLine.startTime = timeSuggester.decrementStartTime(
        surroundingLines[0], surroundingLines[1], currentLine);

    String timeString = TimeParser.getFullTimeAsString(
        currentLine.startTime, currentLine.endTime);
    int replacePosStart =
        currentLine.lineStartIndex + (timeData.startPosition ?? 0);
    int replacePosEnd =
        currentLine.lineStartIndex + (timeData.endPosition ?? 0);

    if (!PlanParser.isNextCharSpace(this.plan.planText, replacePosEnd)) {
      timeString += " ";
    }

    this.plan = this.plan.copyWith(
        planText: this
            .plan
            .planText
            .replaceRange(replacePosStart, replacePosEnd, timeString));
    // update cursor position
    int newCursorPos;
    if (this.cursorPosition < replacePosStart) {
      newCursorPos = this.cursorPosition;
    } else {
      newCursorPos = this.cursorPosition -
          (replacePosEnd - replacePosStart) +
          timeString.length;
      newCursorPos = newCursorPos >= 0 ? newCursorPos : 0;
    }
    updateReminders();
    yield ActiveEditing(newCursorPos, false, this.plan);
  }

  Stream<EditorState> _mapIncrementEndTimeToState(
      IncrementEndTime event) async* {
    String line =
        PlanParser.getLineFromPosition(this.plan.planText, cursorPosition);
    ParsedTimeData timeData = TimeParser.extractDatesFromText(line);

    TimeSuggester timeSuggester = TimeSuggester(this.plan.date);
    List<PlanLine> planLines = PlanParser.getPlanAsObjects(this.plan.planText);
    PlanLine currentLine =
        PlanParser.getLineObjectFromPosition(planLines, cursorPosition);
    List<PlanLine> surroundingLines =
        PlanParser.getSurroundingLines(planLines, currentLine.linePosition);

    currentLine.endTime = timeSuggester.incrementEndTime(
        surroundingLines[0], surroundingLines[1], currentLine);

    String timeString = TimeParser.getFullTimeAsString(
        currentLine.startTime, currentLine.endTime);
    int replacePosStart =
        currentLine.lineStartIndex + (timeData.startPosition ?? 0);
    int replacePosEnd =
        currentLine.lineStartIndex + (timeData.endPosition ?? 0);

    if (!PlanParser.isNextCharSpace(this.plan.planText, replacePosEnd)) {
      timeString += " ";
    }

    this.plan = this.plan.copyWith(
        planText: this
            .plan
            .planText
            .replaceRange(replacePosStart, replacePosEnd, timeString));
    // update cursor position
    int newCursorPos;
    if (this.cursorPosition < replacePosStart) {
      newCursorPos = this.cursorPosition;
    } else {
      newCursorPos = this.cursorPosition -
          (replacePosEnd - replacePosStart) +
          timeString.length;
      newCursorPos = newCursorPos >= 0 ? newCursorPos : 0;
    }
    updateReminders();
    yield ActiveEditing(newCursorPos, false, this.plan);
  }

  Stream<EditorState> _mapDecrementEndTimeToState(
      DecrementEndTime event) async* {
    String line =
        PlanParser.getLineFromPosition(this.plan.planText, cursorPosition);
    ParsedTimeData timeData = TimeParser.extractDatesFromText(line);

    TimeSuggester timeSuggester = TimeSuggester(this.plan.date);
    List<PlanLine> planLines = PlanParser.getPlanAsObjects(this.plan.planText);
    PlanLine currentLine =
        PlanParser.getLineObjectFromPosition(planLines, cursorPosition);
    List<PlanLine> surroundingLines =
        PlanParser.getSurroundingLines(planLines, currentLine.linePosition);

    currentLine.endTime = timeSuggester.decrementEndTime(
        surroundingLines[0], surroundingLines[1], currentLine);

    String timeString = TimeParser.getFullTimeAsString(
        currentLine.startTime, currentLine.endTime);
    int replacePosStart =
        currentLine.lineStartIndex + (timeData.startPosition ?? 0);
    int replacePosEnd =
        currentLine.lineStartIndex + (timeData.endPosition ?? 0);

    if (!PlanParser.isNextCharSpace(this.plan.planText, replacePosEnd)) {
      timeString += " ";
    }

    this.plan = this.plan.copyWith(
        planText: this
            .plan
            .planText
            .replaceRange(replacePosStart, replacePosEnd, timeString));
    // update cursor position
    int newCursorPos;
    if (this.cursorPosition < replacePosStart) {
      newCursorPos = this.cursorPosition;
    } else {
      newCursorPos = this.cursorPosition -
          (replacePosEnd - replacePosStart) +
          timeString.length;
      newCursorPos = newCursorPos >= 0 ? newCursorPos : 0;
    }

    updateReminders();
    yield ActiveEditing(newCursorPos, false, this.plan);
  }

  Stream<EditorState> _mapCopyPlanToState(CopyPlan event) async* {
    Clipboard.setData(ClipboardData(text: this.plan.planText.trim()));
//    yield ActiveEditing(this.cursorPosition, true, this.plan);
    String messageText = "Plan copied";
    yield DisplayingMessage(SnackBarData(messageText: messageText), this.plan);
    yield ActiveEditing(this.cursorPosition, true, this.plan);
  }

  Stream<EditorState> _mapSavePlanToState(SavePlan event) async* {
    _savePlan();
  }

  Stream<EditorState> _mapClearPlanToState(ClearPlan event) async* {
    String messageText = "Cleared plan";
    String actionLabel = "Undo";
    Plan oldPlan = this.plan.copyWith();
    int oldCursorPosition = this.plan.planText.length;
    Function onPressed = () {
      this.add(UndoClearPlan(oldPlan, oldCursorPosition));
    };
    _clearPlanData();
    _savePlan();
    updateReminders();
    yield DisplayingMessage(
        SnackBarData(
            messageText: messageText,
            actionLabel: actionLabel,
            onPressed: onPressed,
            duration: 8),
        this.plan);
    yield ActiveEditing(this.cursorPosition, false, this.plan);
  }

  Stream<EditorState> _mapLoadPreviousPlanToState(
      LoadPreviousPlan event) async* {
    _savePlan();

    DateTime prevDate = this.plan.date.subtract(Duration(days: 1));
    _loadPlanData(prevDate);
  }

  Stream<EditorState> _mapLoadNextPlanToState(LoadNextPlan event) async* {
    _savePlan();

    DateTime nextDate = this.plan.date.add(new Duration(days: 1));
    _loadPlanData(nextDate);
  }

  Stream<EditorState> _mapUndoClearPlanToState(UndoClearPlan event) async* {
    this.plan = event.plan;
    this.cursorPosition = event.cursorPosition;
    this._savePlan();
    this.updateReminders();
    yield ActiveEditing(this.cursorPosition, false, this.plan);
  }

  Stream<EditorState> _mapAddSourceItemsToPlan(
      AddSourceItemsToPlan event) async* {
    String textToAdd = "";
    if (this.plan.planText.trim().length > 0) {
      textToAdd += "\n";
    }
    for (EventViewItem item in event.eventItems) {
      textToAdd += item.getDisplayText() + "\n";
    }

    for (TaskViewItem item in event.taskItems) {
      textToAdd += checkboxString + item.getDisplayText() + "\n";
    }

    this.plan = this.plan.copyWith(planText: this.plan.planText + textToAdd);
    this.cursorPosition = this.plan.planText.length;
    yield ActiveEditing(this.cursorPosition, false, this.plan);
  }

  Stream<EditorState> _mapOpenSourcesListToState(OpenSourcesList event) async* {
    yield OpeningSourcesList();
    this.inTutorial = event.inTutorialMode;

    yield ActiveEditing(this.cursorPosition, false, this.plan);
  }

  Stream<EditorState> _mapErrorToState(Error event) async* {
//    SnackBarData messageData = SnackBarData(messageText: event.exception.toString());
    SnackBarData messageData = SnackBarData(messageText: "An error occurred");
    yield DisplayingMessage(messageData, this.plan);
  }

  Stream<EditorState> _mapStartTutorialToState(StartTutorial event) async* {
    yield BeforeDrawerTutorial(tutorialTodayPlan, tutorialCursorPosition);
//    yield ActiveEditing(this.cursorPosition, false, this.plan);
  }

  Stream<EditorState> _mapStopTutorialToState(StopTutorial event) async* {
    this.inTutorial = false;
    this.tutorialTodayPlan = Plan("", DateTime.now());
    this.cursorPosition = 0;
    yield ActiveEditing(this.cursorPosition, false, this.plan);
  }

  Stream<EditorState> _mapSnoozeItemToState(SnoozeItem event) async* {
    // grab text for line the cursor's on for the current plan
    String line =
        PlanParser.getLineFromPosition(this.plan.planText, cursorPosition);
    //remove from current plan
    if (line.length == 0 || line == "\n") {
      // we won't snooze an empty line, because that's dumb
      SnackBarData messageData =
          SnackBarData(messageText: "Can't snooze an empty line");
      yield (DisplayingMessage(messageData, this.plan));
      yield (ActiveEditing(this.cursorPosition, false, this.plan));
    } else {
      String messageText =
          "Snoozed \"${line.length < 40 ? line : line.substring(0, 39) + "..."}\" to tomorrow";
      String actionLabel = "Undo";
      int oldCursorPosition = this.cursorPosition;
      Plan oldPlan = this.plan.copyWith();
      // get the next day's plan object
      Plan tomorrowsPlan = await localRepository
          .getPlanFuture(this.plan.date.add(Duration(days: 1)));
      if (tomorrowsPlan == null) {
        tomorrowsPlan = new Plan("", this.plan.date.add(Duration(days: 1)));
      }
      Function onPressed = () {
        this.add(UndoSnoozeItem(oldPlan, oldCursorPosition, tomorrowsPlan));
      };

      int newCursorPosition = PlanParser.getLineStartIndexFromPosition(
          plan.planText, cursorPosition);
      String newCurrentPlanText = PlanParser.removeLineFromTextFromPosition(
          plan.planText, cursorPosition);
      this.plan = this.plan.copyWith(planText: newCurrentPlanText);
      this.cursorPosition = newCursorPosition;

      // add the text to the bottom of that plan
      String newTomorrowPlanText = "";
      if (tomorrowsPlan.planText.endsWith("\n") ||
          tomorrowsPlan.planText.length == 0) {
        newTomorrowPlanText = tomorrowsPlan.planText + line;
      } else {
        newTomorrowPlanText = tomorrowsPlan.planText + "\n" + line;
      }
      Plan updatedTomorrowsPlan =
          tomorrowsPlan.copyWith(planText: newTomorrowPlanText);
      localRepository.updatePlan(updatedTomorrowsPlan);

      // update reminders for the current plan. Force update since we might have
      // moved a reminder line and the current function only updates if there's reminders
      updateReminders(forceUpdate: true);

      // update reminders for tomorrow's plan (since we may have moved a reminder there)
      updateReminders(plan: updatedTomorrowsPlan);

      // show snackbar that allows undoing
      yield DisplayingMessage(
          SnackBarData(
              messageText: messageText,
              actionLabel: actionLabel,
              onPressed: onPressed),
          this.plan);
      yield ActiveEditing(this.cursorPosition, false, this.plan);
    }
  }

  Stream<EditorState> _mapUndoSnoozeItemToState(UndoSnoozeItem event) async* {
    this.plan = event.oldPlan;
    this.cursorPosition = event.oldCursorPosition;

    localRepository.updatePlan(event.oldNextPlan);

    // update reminders for today since we might have brought back a reminder
    updateReminders();

    // update reminders for tomorrow since we might have removed a reminder
    // force update since if there aren't any other reminders it won't update them
    updateReminders(plan: event.oldNextPlan, forceUpdate: true);
    yield ActiveEditing(this.cursorPosition, false, this.plan);
  }

  Stream<EditorState> _mapUncheckedItemsSnoozedToState(
      UncheckedItemsSnoozed event) async* {
    String messageText = "Snoozed unchecked items to tomorrow";
    String actionLabel = "Undo";
    int oldCursorPosition = this.cursorPosition;
    Plan oldPlan = this.plan.copyWith();
    Plan tomorrowsPlan = await localRepository
        .getPlanFuture(this.plan.date.add(Duration(days: 1)));
    if (tomorrowsPlan == null) {
      tomorrowsPlan = new Plan("", this.plan.date.add(Duration(days: 1)));
    }
    Function onPressed = () {
      this.add(UndoSnoozeItem(oldPlan, oldCursorPosition, tomorrowsPlan));
    };

    var lines = PlanParser.getPlanAsObjects(this.plan.planText);

    var keptItems = lines
        .where((item) => !item.hasCheckbox || item.isCompleted)
        .map((item) => item.rawText);

    var snoozedItems = lines
        .where((item) => item.hasCheckbox && !item.isCompleted)
        .map((item) => item.rawText);

    this.plan = this.plan.copyWith(planText: keptItems.join('\n'));

    String newTomorrowPlanText = "";
    if (tomorrowsPlan.planText.endsWith("\n") ||
        tomorrowsPlan.planText.length == 0) {
      newTomorrowPlanText = tomorrowsPlan.planText + snoozedItems.join('\n');
    } else {
      newTomorrowPlanText =
          tomorrowsPlan.planText + "\n" + snoozedItems.join('\n');
    }

    Plan updatedTomorrowsPlan =
        tomorrowsPlan.copyWith(planText: newTomorrowPlanText);
    localRepository.updatePlan(updatedTomorrowsPlan);

    // Opening the popup menu resets cursor position, so no need to recalculate

    // update reminders for today since some may have been moved
    updateReminders(forceUpdate: true);

    // update reminders for tomorrow since some may have been moved there
    updateReminders(plan: updatedTomorrowsPlan);

    yield DisplayingMessage(
        SnackBarData(
            messageText: messageText,
            actionLabel: actionLabel,
            onPressed: onPressed),
        this.plan);
    yield ActiveEditing(this.cursorPosition, false, this.plan);
  }

  Stream<EditorState> _mapItemSnoozedToDayToState(
      ItemSnoozedToDay event) async* {
    String line = PlanParser.getLineFromPosition(
        this.plan.planText, event.savedCursorPosition);
    if (line.length == 0 || line == "\n") {
      SnackBarData messageData =
          SnackBarData(messageText: "Can't snooze an empty line");
      yield (DisplayingMessage(messageData, this.plan));
      yield (ActiveEditing(event.savedCursorPosition, false, this.plan));
    } else {
      String actionLabel = "Undo";
      int oldCursorPosition = event.savedCursorPosition;
      Plan oldPlan = this.plan.copyWith();
      Plan futurePlan = await localRepository.getPlanFuture(event.snoozeDate);
      if (futurePlan == null) {
        futurePlan = new Plan("", event.snoozeDate);
      }
      String messageText =
          "Snoozed \"${line.length < 40 ? line : line.substring(0, 39) + "..."}\" to ${futurePlan.getDateSubText()}";

      Function onPressed = () {
        this.add(UndoSnoozeItem(oldPlan, oldCursorPosition, futurePlan));
      };

      int newCursorPosition = PlanParser.getLineStartIndexFromPosition(
          plan.planText, event.savedCursorPosition);
      String newCurrentPlanText = PlanParser.removeLineFromTextFromPosition(
          plan.planText, event.savedCursorPosition);
      this.plan = this.plan.copyWith(planText: newCurrentPlanText);
      this.cursorPosition = newCursorPosition;

      // add the text to the bottom of that plan
      String futurePlanText = "";
      if (futurePlan.planText.endsWith("\n") ||
          futurePlan.planText.length == 0) {
        futurePlanText = futurePlan.planText + line;
      } else {
        futurePlanText = futurePlan.planText + "\n" + line;
      }

      Plan updatedFuturePlan = futurePlan.copyWith(planText: futurePlanText);
      localRepository.updatePlan(updatedFuturePlan);

      // update today's plan since reminders may have moved
      updateReminders(forceUpdate: true);

      // update future plan since reminders may have moved
      updateReminders(plan: updatedFuturePlan);

      // show snackbar that allows undoing
      yield DisplayingMessage(
          SnackBarData(
              messageText: messageText,
              actionLabel: actionLabel,
              onPressed: onPressed),
          this.plan);
      yield ActiveEditing(this.cursorPosition, false, this.plan);
    }
  }

  Stream<EditorState> _mapAddTutorialSourceItemsToPlan(
      AddTutorialSourceItemsToPlan event) async* {
    this.tutorialTextToAdd = event.textToAdd;
    this.tutorialTodayPlan =
        this.tutorialTodayPlan.copyWith(planText: event.textToAdd);
    yield AfterDrawerTutorial(
        this.tutorialTodayPlan, this.tutorialCursorPosition,
        startTutorial: true);
  }

  Stream<EditorState> _mapSetUpTimeToolTutorialToState(
      SetUpTimeToolTutorial event) async* {
    this.tutorialTodayPlan = this
        .tutorialTodayPlan
        .copyWith(planText: this.tutorialTodayPlan.planText + "another task");
    this.tutorialCursorPosition = this.tutorialTodayPlan.planText.length;
    yield AfterDrawerTutorial(
        this.tutorialTodayPlan, this.tutorialCursorPosition);
  }

  Stream<EditorState> _mapIncrementTimeTutorialToState(
      IncrementTimeTutorial event) async* {
    //get the line we're working with
    String line = PlanParser.getLineFromPosition(
        this.tutorialTodayPlan.planText, tutorialCursorPosition);
    //check if there's a valid start time
    ParsedTimeData timeData = TimeParser.extractDatesFromText(line);

    TimeSuggester timeSuggester = TimeSuggester(this.tutorialTodayPlan.date);
    List<PlanLine> planLines =
        PlanParser.getPlanAsObjects(this.tutorialTodayPlan.planText);
    PlanLine currentLine =
        PlanParser.getLineObjectFromPosition(planLines, tutorialCursorPosition);
    List<PlanLine> surroundingLines =
        PlanParser.getSurroundingLines(planLines, currentLine.linePosition);
    if (currentLine.startTime == null) {
      currentLine.startTime = timeSuggester.decrementStartTime(
          surroundingLines[0], surroundingLines[1], currentLine);
    } else {
      currentLine.startTime = timeSuggester.incrementStartTime(
          surroundingLines[0], surroundingLines[1], currentLine);
    }
    //now we need update the text in the line to reflect the new time
    // generate the string
    String timeString = TimeParser.getFullTimeAsString(
        currentLine.startTime, currentLine.endTime);
    // replace the current string with it
    int replacePosStart =
        currentLine.lineStartIndex + (timeData.startPosition ?? 0);
    int replacePosEnd =
        currentLine.lineStartIndex + (timeData.endPosition ?? 0);

    // check to make sure there's a space after where the time's going. If not,
    // we need to add one to make sure the text building works nicely
    if (!PlanParser.isNextCharSpace(
        this.tutorialTodayPlan.planText, replacePosEnd)) {
      timeString += " ";
    }

    this.tutorialTodayPlan = this.tutorialTodayPlan.copyWith(
        planText: this
            .tutorialTodayPlan
            .planText
            .replaceRange(replacePosStart, replacePosEnd, timeString));
    // update cursor position
    int newCursorPos;
    if (this.tutorialCursorPosition < replacePosStart) {
      newCursorPos = this.tutorialCursorPosition;
    } else {
      newCursorPos = this.tutorialCursorPosition -
          (replacePosEnd - replacePosStart) +
          timeString.length;
      newCursorPos = newCursorPos >= 0 ? newCursorPos : 0;
    }

    this.tutorialCursorPosition = this.tutorialTodayPlan.planText.length;

    yield (AfterDrawerTutorial(
        this.tutorialTodayPlan, this.tutorialCursorPosition));
  }

  Stream<EditorState> _mapAddCheckboxTutorialToState(
      AddCheckboxTutorial event) async* {
    int lineBeginPos = PlanParser.getLineStartIndexFromPosition(
        this.tutorialTodayPlan.planText, this.tutorialCursorPosition);
    this.tutorialTodayPlan.planText = this
        .tutorialTodayPlan
        .planText
        .replaceRange(lineBeginPos, lineBeginPos, checkboxString);
    this.tutorialTodayPlan.planText =
        this.tutorialTodayPlan.planText.toString();
    this.tutorialCursorPosition = this.tutorialTextToAdd.length - 1;
    yield AfterDrawerTutorial(
        this.tutorialTodayPlan, this.tutorialCursorPosition);
  }

  Stream<EditorState> _mapSnoozeLineTutorialToState(
      SnoozeLineTutorial event) async* {
    String newCurrentPlanText = PlanParser.removeLineFromTextFromPosition(
        this.tutorialTodayPlan.planText, this.tutorialCursorPosition);
    this.tutorialTodayPlan =
        this.tutorialTodayPlan.copyWith(planText: newCurrentPlanText);
    this.tutorialCursorPosition = this.tutorialTodayPlan.planText.length;

    yield AfterDrawerTutorial(
        this.tutorialTodayPlan, this.tutorialCursorPosition);
  }

  Stream<EditorState> _mapExportPlansToState(ExportPlans event) async* {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String userID = prefs.getString("userID");
    if (userID == null) {
      userID = Uuid().v4();
      prefs.setString("userID", Uuid().v4());
    }
    String combinedPlanText =
        "Plans for User $userID from ${_readableDateText(this.plan.date)}"
        " to ${_readableDateText(this.plan.date.subtract(Duration(days: 7)))}";
    combinedPlanText +=
        "\n\n-----------------------------------------------------\n\n";
    // get plans for previous 7 days
    Plan aPlan = await localRepository.getPlanFuture(this.plan.date) ??
        Plan("No plan created for this date.", this.plan.date);
    combinedPlanText += aPlan.getDateMainText() + "\n" + aPlan.planText;
    combinedPlanText +=
        "\n\n-----------------------------------------------------\n\n";
    DateTime planDate = this.plan.date;
    for (int i = 0; i < 50; i++) {
      planDate = planDate.subtract(Duration(days: 1));
      aPlan = await localRepository.getPlanFuture(planDate) ??
          Plan("No plan created for this date.", planDate);
      combinedPlanText += aPlan.getDateMainText() + "\n" + aPlan.planText;
      combinedPlanText +=
          "\n\n-----------------------------------------------------\n\n";
    }
    // combine into one text file
    final directory = await getTemporaryDirectory();
    final path = directory.path;
    String dateString = _readableDateText(this.plan.date);
    File file = File('$path/user_${userID}_date_$dateString.txt');
    await file.writeAsString(combinedPlanText);

    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('PHASE_2/user_$userID/planExports_date_$dateString.txt');
    StorageUploadTask uploadTask = storageReference.putFile(file);
    try {
      await uploadTask.onComplete;
    } catch (error) {
      print(error);
      print("stop");
    }
    String messageText = "Plans successfully exported!";
    yield DisplayingMessage(SnackBarData(messageText: messageText), this.plan);
    yield ActiveEditing(this.cursorPosition, true, this.plan);
  }

  Stream<EditorState> _mapExportLogsToState(ExportLogs event) async* {
    try {
      await _exportLogs();
      String messageText = "Logs successfully exported!";
      yield DisplayingMessage(
          SnackBarData(messageText: messageText), this.plan);
    } catch (error) {
      String messageText =
          "Logs failed to send, please check your internet connection.";
      yield DisplayingMessage(
          SnackBarData(messageText: messageText), this.plan);
    }

    yield ActiveEditing(this.cursorPosition, true, this.plan);
  }

  Stream<EditorState> _mapExportLogsBackgroundToState(
      ExportLogsBackground event) async* {
    try {
      _exportLogs();
    } catch (error) {
      print(error);
    }
  }

  Stream<EditorState> _mapExportLogsSucceededToState(
      ExportLogsSucceeded event) async* {}

  Stream<EditorState> _mapExportLogsFailedToState(
      ExportLogsFailed event) async* {}

  Stream<EditorState> _mapSnoozeTutorialToState(SnoozeTutorial event) async* {
    String messageText =
        "You found the snooze button! Pressing it moves the line the cursor is on to tomorrow's plan.\n\nLong press the button for more options";
    yield DisplayingMessage(
        SnackBarData(messageText: messageText, duration: 10), this.plan);
    yield ActiveEditing(this.cursorPosition, true, this.plan);
  }

  Stream<EditorState> _mapReminderTutorialToState(
      ReminderTutorial event) async* {
    String messageText =
        "You found the reminder button! Pressing it adds a ${PlanParser.reminderString} to the line the cursor is on."
        "\n\nYou'll receive a notification for lines with a time and a 🔔 icon at their specified time.";
    //"\n\nFor example, if you have a line that says '9:00pm 🔔 take out the trash', you'll receive a notification at 9 pm.";
    yield DisplayingMessage(
        SnackBarData(messageText: messageText, duration: 15), this.plan);
    yield ActiveEditing(this.cursorPosition, true, this.plan);
  }

  Stream<EditorState> _mapTimeTutorialToState(TimeTutorial event) async* {
    String messageText =
        "You found the time button! Pressing it adds a time to the line the cursor is on.";
    yield DisplayingMessage(
        SnackBarData(messageText: messageText, duration: 10), this.plan);
    yield ActiveEditing(this.cursorPosition, true, this.plan);
  }

  Stream<EditorState> _mapCheckboxTutorialToState(
      CheckboxTutorial event) async* {
    String messageText =
        "You found the checkbox button! Pressing it adds a checkbox to the line the cursor is on.";
    yield DisplayingMessage(
        SnackBarData(messageText: messageText, duration: 10), this.plan);
    yield ActiveEditing(this.cursorPosition, true, this.plan);
  }

  Stream<EditorState> _mapSwipeLeftLineTutorialToState(
      SwipeLeftTutorial event) async* {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String messageText =
        "Swipe left to go to the beginning of the line you're on. \n\nSwipe left again to go to the beginning of the line above it.";

    if (!(prefs.get('hasSeenSwipeTutorial') ?? false)) {
      prefs.setBool('hasSeenSwipeTutorial', true);
      yield DisplayingMessage(
          SnackBarData(
              messageText: messageText + "\n\nTry swiping right too!",
              duration: 10),
          this.plan);
    } else {
      yield DisplayingMessage(
          SnackBarData(messageText: messageText, duration: 10), this.plan);
    }
    yield ActiveEditing(this.cursorPosition, true, this.plan);
  }

  Stream<EditorState> _mapSwipeRightLineTutorialToState(
      SwipeRightTutorial event) async* {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String messageText =
        "Swipe right to go to the end of the line you're on. \n\nSwipe right again to go to the end of the line below it.";

    if (!(prefs.get('hasSeenSwipeTutorial') ?? false)) {
      prefs.setBool('hasSeenSwipeTutorial', true);
      yield DisplayingMessage(
          SnackBarData(
              messageText: messageText + "\n\nTry swiping left too!",
              duration: 10),
          this.plan);
    } else {
      yield DisplayingMessage(
          SnackBarData(messageText: messageText, duration: 10), this.plan);
    }
    yield ActiveEditing(this.cursorPosition, true, this.plan);
  }

  Stream<EditorState> _mapAddReminderToState(AddReminder event) async* {
    //get the line we're working with
    String line =
        PlanParser.getLineFromPosition(this.plan.planText, cursorPosition);
    ParsedTimeData timeData = TimeParser.extractDatesFromText(line);

    TimeSuggester timeSuggester = TimeSuggester(this.plan.date);
    List<PlanLine> planLines = PlanParser.getPlanAsObjects(this.plan.planText);
    PlanLine lineObject =
        PlanParser.getLineObjectFromPosition(planLines, cursorPosition);
    List<PlanLine> surroundingLines =
        PlanParser.getSurroundingLines(planLines, lineObject.linePosition);

    if (lineObject.startTime == null) {
      lineObject.startTime = timeSuggester.decrementStartTime(
          surroundingLines[0], surroundingLines[1], lineObject);
    }
    // else {
    //       lineObject.startTime = timeSuggester.incrementStartTime(surroundingLines[0], surroundingLines[1],
    //           lineObject);
    //     }

    String timeString = TimeParser.getFullTimeAsString(
        lineObject.startTime, lineObject.endTime);
    timeString += " " + PlanParser.reminderString;

    int replacePosStart =
        lineObject.lineStartIndex + (timeData.startPosition ?? 0);
    int replacePosEnd = lineObject.lineStartIndex + (timeData.endPosition ?? 0);

    // check to make sure there's a space after where the time's going. If not,
    // we need to add one to make sure the text building works nicely
    if (!PlanParser.isNextCharSpace(this.plan.planText, replacePosEnd)) {
      timeString += " ";
    }

    this.plan = this.plan.copyWith(
        planText: this
            .plan
            .planText
            .replaceRange(replacePosStart, replacePosEnd, timeString));
    // update cursor position
    int newCursorPos;
    if (this.cursorPosition < replacePosStart) {
      newCursorPos = this.cursorPosition;
    } else {
      newCursorPos = this.cursorPosition -
          (replacePosEnd - replacePosStart) +
          timeString.length;
      newCursorPos = newCursorPos >= 0 ? newCursorPos : 0;
    }

    yield ActiveEditing(newCursorPos, false, this.plan);
  }

  Stream<EditorState> _mapRemoveReminderToState(RemoveReminder event) async* {
    int newCursorPos;
    if (PlanParser.lineAtPosHasReminder(this.plan.planText, cursorPosition)) {
      newCursorPos = this._removeReminder();
    } else {
      return;
    }

    yield ActiveEditing(newCursorPos, false, this.plan);
  }

  Stream<EditorState> _mapAppForegroundToState(AppForeground event) async* {
    // update reminder to be for 3 days from now
    DateTime now = DateTime.now();
    DateTime in3Days = now.add(const Duration(days: 3));
    if (in3Days.hour < 8 || in3Days.hour >= 22) {
      in3Days =
          DateTime(in3Days.year, in3Days.month, in3Days.day, 10, 0, 0, 0, 0);
    }
    // print("updated usage notification to be at ${in3Days.toIso8601String()}");
    NotificationManager.scheduleUsageNotification(in3Days);
  }

  Stream<EditorState> _mapAppBackgroundToState(AppBackground event) async* {
    _savePlan();

    // update reminder to be for 3 days from now
    DateTime now = DateTime.now();
    DateTime in3Days = now.add(const Duration(days: 3));
    if (in3Days.hour < 8 || in3Days.hour >= 22) {
      in3Days =
          DateTime(in3Days.year, in3Days.month, in3Days.day, 10, 0, 0, 0, 0);
    }
    // print("updated usage notification to be at ${in3Days.toIso8601String()}");
    NotificationManager.scheduleUsageNotification(in3Days);
    this.updateReminders();
  }

  Stream<EditorState> _mapCancelSurveyToState(CancelSurvey event) async* {
    // don't need to anything, but now it'll be in the logs
  }

  Stream<EditorState> _mapSubmitSurveyToState(SubmitSurvey event) async* {
    // convert data to json
    String surveyDataJson = jsonEncode({"survey_data": event.surveyData});
    String fileName = "exp_survey";

    // save to file and upload to firebase storage
    FileUploadStatus fileUploadStatus = await FirebaseFileUploader.uploadData(
        data: surveyDataJson, fileName: fileName, fileExtension: "json");

    switch (fileUploadStatus) {
      case FileUploadStatus.succeeded:
        this.add(UploadSurveySuccess());
        yield DisplayingMessage(
            SnackBarData(messageText: "Survey submitted"), plan);
        yield ActiveEditing(cursorPosition, false, plan);
        break;
      case FileUploadStatus.failed_other:
        this.add(SaveSurveyLocal(surveyDataJson));
        break;
      case FileUploadStatus.failed_no_network:
        this.add(SaveSurveyLocal(surveyDataJson));
        break;
    }
  }

  Stream<EditorState> _mapCancelFeedbackToState(CancelFeedback event) async* {}

  Stream<EditorState> _mapSubmitFeedbackToState(SubmitFeedback event) async* {
    // convert data to json
    String feedbackDataJson = jsonEncode({"feedback_data": event.feedbackData});
    String fileName = "feedback";

    // save to file and upload to firebase storage
    FileUploadStatus fileUploadStatus = await FirebaseFileUploader.uploadData(
        data: feedbackDataJson, fileName: fileName, fileExtension: "json");

    switch (fileUploadStatus) {
      case FileUploadStatus.succeeded:
        this.add(UploadFeedbackSuccess());
        yield DisplayingMessage(
            SnackBarData(messageText: "Feedback submitted"), plan);
        yield ActiveEditing(cursorPosition, false, plan);
        break;
      case FileUploadStatus.failed_other:
        this.add(SaveFeedbackLocal(feedbackDataJson));
        yield DisplayingMessage(
            SnackBarData(messageText: "Feedback saved"), plan);
        yield ActiveEditing(cursorPosition, false, plan);
        break;
      case FileUploadStatus.failed_no_network:
        yield DisplayingMessage(
            SnackBarData(messageText: "Feedback saved"), plan);
        yield ActiveEditing(cursorPosition, false, plan);
        this.add(SaveFeedbackLocal(feedbackDataJson));
        break;
    }
  }

  // HELPER FUNCTIONS - THESE DO NOT YIELD STATE
  /// updates the reminders for a given `plan`.
  /// Defaults to using the current plan in the editor
  /// `forceUpdate` can be used to force an update of a plan even if it doesn't have
  /// any reminders. Needed for snoozing or other actions that move lines all at once
  ///
  /// i.e. use forceUpdate: true whenever a line with a reminder could have been
  /// moved from a plan that will no longer have reminders once it's gone.
  /// This could be improved by taking out the check for reminders on the given plan,
  /// but then we'd be cancelling and updating the reminders even more often
  void updateReminders({Plan plan, bool forceUpdate: false}) {
    if (plan == null) {
      plan = this.plan;
    }

    if (this.plan == null) {
      return;
    }

    List<PlanLine> planLines =
        PlanParser.getPlanAsObjects(plan.planText, planDate: plan.date);
    List<PlanLine> reminderLines = [];
    for (PlanLine planLine in planLines) {
      if (planLine.hasReminder || forceUpdate) {
        if (planLine.startTime != null &&
            planLine.startTime.isAfter(DateTime.now())) {
          reminderLines.add(planLine);
        }
      }
    }
    try {
      NotificationManager.updateNotificationList(reminderLines, plan.date);
    } catch (error) {
      print(error);
    }
  }

  int _removeReminder({bool timeRemoved: false}) {
    String removedString = "";
    int removePos;

    String stringToRemove = "";

    removePos = PlanParser.getGlobalIndexOfStringFromLinePos(
        PlanParser.reminderString, this.plan.planText, cursorPosition);

    if (removePos != 0 && this.plan.planText[removePos - 1] == " ") {
      stringToRemove = " " + PlanParser.reminderString;
    } else {
      stringToRemove = PlanParser.reminderString;
    }

    if (timeRemoved &&
        removePos != this.plan.planText.length - 1 &&
        this.plan.planText[removePos + PlanParser.reminderString.length] ==
            " ") {
      stringToRemove += " ";
    }

    removePos = PlanParser.getGlobalIndexOfStringFromLinePos(
        stringToRemove, this.plan.planText, cursorPosition);

    this.plan.planText =
        this.plan.planText.replaceFirst(stringToRemove, "", removePos);
    removedString = stringToRemove;

    this.plan.planText = this.plan.planText.toString();
    int newCursorPos = 0;
    if (this.cursorPosition <= removePos) {
      newCursorPos = this.cursorPosition;
    } else {
      newCursorPos = this.cursorPosition - removedString.length;
    }
    // NotificationManager.updateNotification("", null);
    this.updateReminders();
    return newCursorPos;
  }

  Future _exportLogs() async {
    FLog.applyConfigurations(SimpleBlocDelegate.config);

    List<Log> logs;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String lastSuccessfulLogExportString =
        prefs.getString("lastSuccessfulLogExport");
    DateTime lastSuccessfulLogExport = (lastSuccessfulLogExportString == null)
        ? null
        : DateTime.parse(lastSuccessfulLogExportString);
    String logExportCheckpoint = DateTime.now().toIso8601String();
    if (lastSuccessfulLogExport == null) {
      // get all logs
      logs = await FLog.getAllLogs();
    } else {
      // get logs since last successful export
      // this line just below can be used to get logs from the beginning of the
      //    day of the last successful log export
      // lastSuccessfulLogExport = DateTime(lastSuccessfulLogExport.year, lastSuccessfulLogExport.month, lastSuccessfulLogExport.day);
      logs = await FLog.getAllLogsByFilter(
          startTimeInMillis:
              lastSuccessfulLogExport.millisecondsSinceEpoch - (2 * 1000));
    }

    // instead of all logs, just get those since the last successful sync
    var buffer = StringBuffer();

    // only send if there's more than 5 so we don't spam cloud storage
    if (logs.length > 2) {
      logs.forEach((log) {
        buffer.write(Formatter.format(log, SimpleBlocDelegate.config));
      });
      String bufferString = buffer.toString();

      String userID = prefs.getString("userID");
      if (userID == null) {
        userID = Uuid().v4();
        prefs.setString("userID", Uuid().v4());
      }

      FileUploadStatus fileUploadStatus = await FirebaseFileUploader.uploadData(
          data: bufferString, fileExtension: "csv", fileName: "logs");

      switch (fileUploadStatus) {
        case FileUploadStatus.succeeded:
          prefs.setString("lastSuccessfulLogExport", logExportCheckpoint);
          this.add(ExportLogsSucceeded());
          break;
        case FileUploadStatus.failed_other:
          this.add(ExportLogsFailed());
          break;
        case FileUploadStatus.failed_no_network:
          this.add(ExportLogsFailed());
          break;
      }

      // final directory = await getTemporaryDirectory();
      // final path = directory.path;
      // String dateString = _readableDateText(DateTime.now());
      // File file = File('$path/logs_user_${userID}_date_$dateString.csv');
      // await file.writeAsString(bufferString);
      //
      // if (await isInternet()) {
      //   StorageReference storageReference = FirebaseStorage.instance
      //       .ref()
      //       .child('PHASE_2/user_$userID/logs_date_$dateString.csv');
      //   StorageUploadTask uploadTask = storageReference.putFile(file);
      //   await uploadTask.onComplete;

    } else {
      // print("No logs found!");
    }
    buffer.clear();
  }

  String _readableDateText(DateTime date) {
    return date.year.toString() +
        "_" +
        date.month.toString().padLeft(2, '0') +
        "_" +
        date.day.toString().padLeft(2, '0') +
        "T" +
        date.hour.toString().padLeft(2, '0') +
        ":" +
        date.minute.toString().padLeft(2, '0') +
        ":" +
        date.second.toString().padLeft(2, '0');
  }

  void _savePlan() {
    localRepository.updatePlan(this.plan);
  }

  void _clearPlanData() {
    this.plan = this.plan.copyWith(planText: "");
    this.cursorPosition = 0;
  }

  void _loadPlanData(DateTime date) {
    _plansSubscription?.cancel();
    _plansSubscription = localRepository.getPlan(date).listen((plan) {
      if (plan != null) {
        add(PlanLoaded(plan));
      } else {
        add(PlanLoaded(Plan("", date)));
      }
    });
  }

  /// This method moves the cursor to the beginning of the line when the user swipes left.
  /// This is good for testing: // yield DisplayingMessage(SnackBarData(messageText: "SWIPE LEFT"), this.plan);
  Stream<EditorState> _mapEditorCursorSwipedLeft(
      EditorCursorSwipedLeft event) async* {
    int newCursorPosition;
    //if cursor is at the beginning of its current line, go to end of line above
    if (CursorUtils.cursorIsAtStartCurrentLine(cursorPosition, plan))
      newCursorPosition =
          CursorUtils.getIndexOfStartOfLineAbove(cursorPosition, plan);
    //otherwise, go to the beginning of the current line
    else
      newCursorPosition =
          CursorUtils.getIndexOfStartOfCurrentLine(cursorPosition, plan);
    yield ActiveEditing(
        CursorUtils.validateCursorPosition(
            cursorPosition, newCursorPosition, plan),
        false,
        this.plan);
  }

  /// This method moves the cursor to the end of the line when the user swipes right.
  Stream<EditorState> _mapEditorCursorSwipedRight(
      EditorCursorSwipedRight event) async* {
    int newCursorPosition;
    //if cursor is at the end of its current line, go to start of line above
    if (CursorUtils.cursorIsAtEndOfCurrentLine(cursorPosition, plan))
      newCursorPosition =
          CursorUtils.getIndexOfEndOfLineBelow(cursorPosition, plan);
    //otherwise, go to the end of the current line
    else
      newCursorPosition =
          CursorUtils.getIndexOfEndOfCurrentLine(cursorPosition, plan);
    yield ActiveEditing(
        CursorUtils.validateCursorPosition(
            cursorPosition, newCursorPosition, plan),
        false,
        this.plan);
  }
}
