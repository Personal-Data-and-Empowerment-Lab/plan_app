import 'package:planv3/utils/TimeParser.dart';

import '../utils/PlanParser.dart';

class PlanLine {
  String rawText;
  DateTime startTime;
  DateTime endTime;
  int linePosition;
  int lineStartIndex;
  int lineEndIndex;
  bool hasCheckbox = false;
  bool isCompleted = false;
  bool hasReminder = false;

  PlanLine(
      this.rawText, this.linePosition, this.lineStartIndex, this.lineEndIndex,
      {DateTime planDate}) {
    _parseTextIntoLine(rawText, planDate: planDate);
  }

  void _parseTextIntoLine(String rawText, {DateTime planDate}) {
    ParsedTimeData timeData =
        TimeParser.extractDatesFromText(rawText, planDate: planDate);

    this.startTime = timeData.startTime;
    this.endTime = timeData.endTime;
    this.hasCheckbox = rawText.contains(PlanParser.checkboxString) ||
        rawText.contains(PlanParser.completedCheckboxString);
    if (this.hasCheckbox) {
      this.isCompleted = rawText.contains(PlanParser.completedCheckboxString);
    }
    this.hasReminder = rawText.contains(PlanParser.reminderString);
  }
}
