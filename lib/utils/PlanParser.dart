import 'dart:math';

import 'package:planv3/models/PlanLine.dart';
import 'package:planv3/utils/TimeParser.dart';

class PlanParser {
  PlanParser();

  static String checkboxFlagRegex = r"\[[ \t]?\]$";
  static String completedCheckboxFlagRegex = r"\[x\]$";
  static String checkboxString = "[ ]";
  static String completedCheckboxString = "[x]";
  static String reminderString = "\u{1F514}";

  // static String reminderString = "\u{1F56D}";

  //Time stuff
  static String startTimeFlagRegex =
      r"([1][0-2]|[1-9])(?:(?::([0-5][0-9])(AM|PM|A|P)(?![\S]))|(?::([0-5][0-9]))|(?:(AM|PM|A|P)(?![\S])))$";
  static String endTimeFlagRegex =
      r"-([1][0-2]|[1-9])(?:(?::([0-5][0-9])(AM|PM|A|P)(?![\S]))|(?::([0-5][0-9]))|(?:(AM|PM|A|P)(?![\S])))$";
  static String startAndEndTimeFlagRegex =
      r"(?:([1][0-2]|[1-9]):?([0-5][0-9])?(?:(AM|PM|A|P))?-([1][0-2]|[1-9]):?([0-5][0-9])?(?:(AM|PM|A|P)(?![\S]))?)$";

  static String getLineFromPosition(String planText, int cursorPosition) {
    if (planText.contains('\n')) {
      // split text at position
      String beforePos = planText.substring(0, cursorPosition);
      String afterPos = planText.substring(cursorPosition);

      // grab text between last newline and end of before string
      int lastNewline = beforePos.lastIndexOf('\n');
      lastNewline = lastNewline != -1 ? lastNewline + 1 : 0;
      String firstHalf = beforePos.substring(lastNewline);

      // grab text between beginning of string and first newline
      int firstNewline = afterPos.indexOf('\n');
      String lastHalf =
          firstNewline != -1 ? afterPos.substring(0, firstNewline) : afterPos;

      return firstHalf + lastHalf;
    } else {
      return planText;
    }
    // return planText.substring(cursorPosition);
  }

  static int getLineStartIndexFromPosition(
      String planText, int cursorPosition) {
    if (planText.contains('\n')) {
      String beforePos = planText.substring(0, cursorPosition);
      int lastNewline = beforePos.lastIndexOf('\n');
      return lastNewline != -1 ? lastNewline + 1 : 0;
    } else {
      return 0;
    }
  }

  // returns the new planText with the line that contains this cursorPosition removed
  static String removeLineFromTextFromPosition(
      String planText, int cursorPosition) {
    int lineStartIndex =
        getLineStartIndexFromPosition(planText, cursorPosition);
    String line = getLineFromPosition(planText, cursorPosition);
    String beforeLine = planText.substring(0, lineStartIndex);

    // Add one to remove blank line, if not the last line
    int endIndex = min(lineStartIndex + line.length + 1, planText.length);
    String afterLine = planText.substring(endIndex);

    return beforeLine + afterLine;
  }

  static bool lineHasCheckbox(String lineText) {
    return lineText.contains(checkboxString) ||
        lineText.contains(completedCheckboxString);
  }

  static bool lineAtPosHasCheckbox(String planText, int cursorPosition) {
    String line = getLineFromPosition(planText, cursorPosition);
    return lineHasCheckbox(line);
  }

  static bool lineAtPosHasIncompleteCheckbox(
      String planText, int cursorPosition) {
    String line = getLineFromPosition(planText, cursorPosition);
    return line.contains(checkboxString);
  }

  static bool lineAtPosHasCompleteCheckbox(
      String planText, int cursorPosition) {
    String line = getLineFromPosition(planText, cursorPosition);
    return line.contains(completedCheckboxString);
  }

  static bool lineAtPosHasStartTime(String planText, int cursorPosition) {
    String line = getLineFromPosition(planText, cursorPosition);
    return TimeParser.hasValidStartTime(line);
  }

  static bool lineAtPosHasTime(String planText, int cursorPosition) {
    String line = getLineFromPosition(planText, cursorPosition);
    return TimeParser.isValidTimeString(line);
  }

  static bool lineAtPosHasReminder(String planText, int cursorPosition) {
    String line = getLineFromPosition(planText, cursorPosition);
    return line.contains(reminderString);
  }

  static bool planHasReminders(String planText) {
    return planText.contains(reminderString);
  }

  static int getGlobalIndexOfStringFromLinePos(
      String target, String planText, int cursorPosition) {
    String currentLine = getLineFromPosition(planText, cursorPosition);
    int lineStartPos = getLineStartIndexFromPosition(planText, cursorPosition);

    int targetLocalPos = currentLine.indexOf(target);
    return targetLocalPos + lineStartPos;
  }

// static bool isValidCheckboxStart(String text) {
//    RegExp checkboxPattern = new RegExp(checkboxFlagRegex, caseSensitive: false, multiLine: false);
//    RegExpMatch match = checkboxPattern.firstMatch(text);
//    return checkboxPattern.hasMatch(text);
// }

// static String getCheckboxFlag(String text) {
//   try {
//     RegExp checkboxPattern = new RegExp(checkboxFlagRegex, caseSensitive: false, multiLine: false);
//     RegExpMatch match = checkboxPattern.firstMatch(text);
//     return match?.group(0) ?? null;
//   }
//   catch (error) {
//     print(error.toString());
//     throw(error);
//   }
//
// }

  static String getFlag(String regex, String text) {
    try {
      RegExp pattern =
          new RegExp(regex, caseSensitive: false, multiLine: false);
      if (pattern.hasMatch(text)) {
        return pattern.firstMatch(text).group(0);
      } else {
        return null;
      }
    } catch (error) {
      print(error.toString());
      throw error;
    }
  }

  static getLineAtPosAsObject(String planText, int cursorPosition) {
    String lineText = PlanParser.getLineFromPosition(planText, cursorPosition);
    int lineStartPosition =
        PlanParser.getLineStartIndexFromPosition(planText, cursorPosition);

    List<String> lines = planText.split("\n");
  }

/*
This method generates a line objects list by parsing the plan in text form (lines are separated by '\n').
 */
  static List<PlanLine> getPlanAsObjects(String planText, {DateTime planDate}) {
    List<String> lines =
        planText.split("\n"); //create a list of lines by splitting planText
    int currentPos = 0;
    List<PlanLine> lineObjects = [];
    for (int i = 0; i < lines.length; i++) {
      int linePosition = i;
      int lineStartPosition =
          currentPos; //set beginning of line to current position
      int lineEndPosition = lineStartPosition +
          lines[i]
              .length; //end of line is the length of the line string in the list 'lines'
      // update current position for next line. Have to add one for the newline
      //   we removed in split
      currentPos = lineEndPosition + 1; //increment current position
      // now create the PlanLine object
      PlanLine lineObject = PlanLine(
          lines[i], linePosition, lineStartPosition, lineEndPosition,
          planDate: planDate);
      lineObjects.add(lineObject);
    }

    return lineObjects;
  }

  static PlanLine getLineObjectFromPosition(
      List<PlanLine> planLines, int cursorPosition) {
    for (PlanLine line in planLines) {
      if (cursorPosition >= line.lineStartIndex &&
          cursorPosition <= line.lineEndIndex) {
        return line;
      }
    }

    throw Exception(
        "cursorPosition not found in line, but that's 'impossible'");
  }

  static List<PlanLine> getSurroundingLines(
      List<PlanLine> planLines, int linePosition) {
    List<PlanLine> surroundingLines = [];
    if (planLines.length > 0) {
      //get elements after it in list
      List<PlanLine> linesAfter = planLines.sublist(linePosition + 1);
      //save first one with start time or end time that's not null
      PlanLine nextLine = _getFirstLineWithTime(linesAfter);

      //get elements before it in list
      List<PlanLine> linesBefore =
          planLines.sublist(0, linePosition).reversed.toList();
      //save first one with start date or end date that's not null
      PlanLine previousLine = _getFirstLineWithTime(linesBefore);

      surroundingLines.add(previousLine);
      surroundingLines.add(nextLine);
    }

    return surroundingLines;
  }

  static PlanLine _getFirstLineWithTime(List<PlanLine> lines) {
    int index = lines.indexWhere((PlanLine line) {
      return line.startTime != null || line.endTime != null;
    });

    return index != -1 ? lines[index] : null;
  }

  static bool isNextCharSpace(String planText, int position) {
    if (position >= planText.length) {
      return false;
    } else {
      return planText.substring(position, position + 1) == " ";
    }
  }
}
