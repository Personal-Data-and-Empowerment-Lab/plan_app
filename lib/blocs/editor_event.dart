import 'package:equatable/equatable.dart';
import 'package:planv3/models/EventViewItem.dart';
import 'package:planv3/models/Plan.dart';
import 'package:planv3/models/TaskViewItem.dart';

abstract class EditorEvent extends Equatable {
  const EditorEvent();

  @override
  List<Object> get props => [];
}

class LoadInitialPlan extends EditorEvent {
  @override
  List<Object> get props => [];

  Map<String, dynamic> getParameters() {
    return Map();
  }
}

class LoadNextPlan extends EditorEvent {
  @override
  List<Object> get props => [];

  Map<String, dynamic> getParameters() {
    return Map();
  }
}

class LoadPreviousPlan extends EditorEvent {
  Map<String, dynamic> getParameters() {
    return Map();
  }
}

class LoadSpecificPlan extends EditorEvent {
  final DateTime dateTime;
  final bool refreshCurrentPlan;

  const LoadSpecificPlan(this.dateTime, {this.refreshCurrentPlan: false});

  @override
  List<Object> get props => [this.dateTime, this.refreshCurrentPlan];

  Map<String, dynamic> getParameters() {
    Map<String, dynamic> parameters = Map();
    parameters["dateTime"] = dateTime.toString();
    return parameters;
  }
}

class PlanLoaded extends EditorEvent {
  final Plan plan;

  const PlanLoaded(this.plan);

  @override
  List<Object> get props => [this.plan];
}

class EditText extends EditorEvent {
  final String editorText;
  final int cursorPosition;

  const EditText(this.editorText, this.cursorPosition);

  @override
  List<Object> get props => [editorText, cursorPosition];
}

class SavePlan extends EditorEvent {}

class AddCheckbox extends EditorEvent {
  const AddCheckbox();

  @override
  List<Object> get props => [];
}

class RemoveCheckbox extends EditorEvent {
  const RemoveCheckbox();
}

class MarkCheckboxComplete extends EditorEvent {
  final int cursorPosition;
  final String actualText;

  const MarkCheckboxComplete(this.cursorPosition, this.actualText);

  @override
  List<Object> get props => [cursorPosition, actualText];
}

class MarkCheckboxIncomplete extends EditorEvent {
  final int cursorPosition;
  final String actualText;

  const MarkCheckboxIncomplete(this.cursorPosition, this.actualText);

  @override
  List<Object> get props => [this.cursorPosition, this.actualText];
}

class IncrementStartTime extends EditorEvent {
  const IncrementStartTime();

  @override
  List<Object> get props => [];
}

class AddTime extends EditorEvent {
  const AddTime();

  @override
  List<Object> get props => [];
}

class RemoveTime extends EditorEvent {
  const RemoveTime();
}

class DecrementStartTime extends EditorEvent {
  const DecrementStartTime();
}

class IncrementEndTime extends EditorEvent {
  const IncrementEndTime();
}

class DecrementEndTime extends EditorEvent {
  const DecrementEndTime();
}

class CopyPlan extends EditorEvent {}

class ClearPlan extends EditorEvent {}

class AddNewLine extends EditorEvent {}

class UndoClearPlan extends EditorEvent {
  final Plan plan;
  final int cursorPosition;

  const UndoClearPlan(this.plan, this.cursorPosition);

  @override
  List<Object> get props => [this.plan, this.cursorPosition];
}

class AddSourceItemsToPlan extends EditorEvent {
  final List<EventViewItem> eventItems;
  final List<TaskViewItem> taskItems;

  const AddSourceItemsToPlan(this.eventItems, this.taskItems);

  @override
  List<Object> get props => [this.eventItems, this.taskItems];
}

class OpenSourcesList extends EditorEvent {
  // could put in the line they were on
  final bool inTutorialMode;

  const OpenSourcesList({this.inTutorialMode = false});

  @override
  List<Object> get props => [];
}

class Error extends EditorEvent {
  final Exception exception;

  Error(this.exception);

  @override
  List<Object> get props => [exception];
}

class StartTutorial extends EditorEvent {}

class StopTutorial extends EditorEvent {}

class SnoozeItem extends EditorEvent {}

class UncheckedItemsSnoozed extends EditorEvent {}

class ItemSnoozedToDay extends EditorEvent {
  final DateTime snoozeDate;

  // Using showMenu resets cursor position, so we cache it here
  final int savedCursorPosition;

  ItemSnoozedToDay(this.snoozeDate, this.savedCursorPosition);
}

class UndoSnoozeItem extends EditorEvent {
  final Plan oldPlan;
  final int oldCursorPosition;
  final Plan oldNextPlan;

  UndoSnoozeItem(this.oldPlan, this.oldCursorPosition, this.oldNextPlan);

  @override
  List<Object> get props => [oldPlan, oldCursorPosition, this.oldNextPlan];
}

class AddTutorialSourceItemsToPlan extends EditorEvent {
  final String textToAdd;

  AddTutorialSourceItemsToPlan(this.textToAdd);

  @override
  List<Object> get props => [this.textToAdd];
}

class SetUpTimeToolTutorial extends EditorEvent {
  @override
  List<Object> get props => [];
}

class IncrementTimeTutorial extends EditorEvent {
  @override
  List<Object> get props => [];
}

class AddCheckboxTutorial extends EditorEvent {
  @override
  List<Object> get props => [];
}

class SwipeLeftTutorial extends EditorEvent {
  @override
  List<Object> get props => [];
}

class SwipeRightTutorial extends EditorEvent {
  @override
  List<Object> get props => [];
}

class SnoozeLineTutorial extends EditorEvent {
  @override
  List<Object> get props => super.props;
}

class ExportPlans extends EditorEvent {
  @override
  List<Object> get props => [];
}

class ExportLogs extends EditorEvent {
  @override
  List<Object> get props => [];
}

class ExportLogsBackground extends EditorEvent {
  @override
  List<Object> get props => [];
}

class AppForeground extends EditorEvent {
  @override
  List<Object> get props => [];
}

class AppBackground extends EditorEvent {
  @override
  List<Object> get props => [];
}

class ExportLogsSucceeded extends EditorEvent {
  @override
  List<Object> get props => [];
}

class ExportLogsFailed extends EditorEvent {
  @override
  List<Object> get props => [];
}

class SnoozeTutorial extends EditorEvent {
  @override
  List<Object> get props => [];
}

class AddReminder extends EditorEvent {
  @override
  List<Object> get props => [];
}

class RemoveReminder extends EditorEvent {
  @override
  List<Object> get props => [];
}

class ReminderTutorial extends EditorEvent {
  @override
  List<Object> get props => [];
}

class TimeTutorial extends EditorEvent {
  @override
  List<Object> get props => [];
}

class CheckboxTutorial extends EditorEvent {
  @override
  List<Object> get props => [];
}

class CancelSurvey extends EditorEvent {
  @override
  List<Object> get props => [];
}

class SubmitSurvey extends EditorEvent {
  final Map<String, dynamic> surveyData;

  SubmitSurvey(this.surveyData) : super();

  @override
  List<Object> get props => [this.surveyData];
}

class UploadSurveySuccess extends EditorEvent {
  @override
  List<Object> get props => [];
}

class SaveSurveyLocal extends EditorEvent {
  final String data;

  SaveSurveyLocal(this.data);

  @override
  List<Object> get props => [this.data];
}

class CancelFeedback extends EditorEvent {}

class SubmitFeedback extends EditorEvent {
  final Map<String, dynamic> feedbackData;

  SubmitFeedback(this.feedbackData);

  @override
  List<Object> get props => [this.feedbackData];
}

class UploadFeedbackSuccess extends EditorEvent {}

class SaveFeedbackLocal extends EditorEvent {
  final String data;

  SaveFeedbackLocal(this.data);

  @override
  List<Object> get props => [this.data];
}

//Cursor Swipe Events
class EditorCursorSwipedRight extends EditorEvent {}

class EditorCursorSwipedLeft extends EditorEvent {}

class EditorCursorSwipedUp extends EditorEvent {}

class EditorCursorSwipedDown extends EditorEvent {}
