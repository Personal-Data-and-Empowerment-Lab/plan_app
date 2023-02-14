import 'package:planv3/models/Plan.dart';
import 'package:planv3/utils/PlanParser.dart';

/// This mixin file contains methods that are used to move the ExtendedTextField cursor upon a user's Swipe events.
/// SwipeDetector widget is declared in EditorPage.dart at ~line 1405.
/// Swipe event handlers are declared in editor_bloc.dart.
mixin CursorUtils {
  /// This method validates a new cursor position as valid by comparing its index to the length of the entire text file.
  static int validateCursorPosition(
      int cursorPosition, int newCursorPosition, Plan plan) {
    int planLength = plan.planText.length;

    //check to see if the new position goes beyond the bounds of the text
    if (newCursorPosition > planLength) return planLength;

    //check to see if the new position is a negative integer
    if (newCursorPosition < 0)
      return 0;

    //if valid, return the new cursor position
    else
      return newCursorPosition;
  }

  /// This helper method returns a boolean for whether or not a cursor is at the start of a line
  static bool cursorIsAtStartCurrentLine(int cursorPosition, Plan plan) {
    return cursorPosition == getIndexOfStartOfCurrentLine(cursorPosition, plan);
  }

  /// This method returns a boolean for whether or not a cursor is at the end of the current line
  static bool cursorIsAtEndOfCurrentLine(int cursorPosition, Plan plan) {
    return cursorPosition == getIndexOfEndOfCurrentLine(cursorPosition, plan);
  }

  /// This helper method returns the end of the line of the cursor's current position.
  static int getIndexOfEndOfCurrentLine(int cursorPosition, plan) {
    int inxOfCurrentStart = getIndexOfStartOfCurrentLine(cursorPosition, plan);
    return inxOfCurrentStart + getLineLength(cursorPosition, plan);
  }

  /// This helper method returns the end of the line of the cursor's current position.
  static int getIndexOfStartOfCurrentLine(int cursorPosition, plan) {
    return PlanParser.getLineStartIndexFromPosition(
        plan.planText, cursorPosition);
  }

  /// This helper method returns the length of the line that contains the cursor position.
  static int getLineLength(int cursorPosition, Plan plan) {
    return PlanParser.getLineFromPosition(plan.planText, cursorPosition).length;
  }

  /// This helper method returns the end of the line above the current cursor position, defined as the start of current line - 1.
  static int getIndexOfEndOfLineAbove(int cursorPosition, Plan plan) {
    return getIndexOfStartOfCurrentLine(cursorPosition, plan) - 1;
  }

  /// This helper method returns the start of the line above the current cursor position.
  /// The getLineStartIndexFromPosition function is used after getting the index of the end of the line above.
  static int getIndexOfStartOfLineAbove(int cursorPosition, Plan plan) {
    return PlanParser.getLineStartIndexFromPosition(
        plan.planText, getIndexOfEndOfLineAbove(cursorPosition, plan));
  }

  /// This helper method returns the end of the line above the current cursor position.
  /// The index is found by adding the starting index of the line below to its length.
  static int getIndexOfEndOfLineBelow(int cursorPosition, Plan plan) {
    int startOfLineBelow = getIndexOfStartOfLineBelow(cursorPosition, plan);
    int lengthOfLineBelow = getLineLength(startOfLineBelow, plan);
    return startOfLineBelow + lengthOfLineBelow;
  }

  /// This helper method returns the start of the line above the current cursor position
  /// The index is found by adding the start of the current line's index and its length and then adding 1 to that sum.
  static int getIndexOfStartOfLineBelow(int cursorPosition, Plan plan) {
    return getIndexOfEndOfCurrentLine(cursorPosition, plan) + 1;
  }

  /// This helper method returns the number of words in a Plan line
  static int getWordCountInLine(String line) {
    return line.split(" ").length;
  }

  /// This helper method gets the distance of the cursor from the start of its current line
  static int getDistanceFromStartOfCurrentLine(int cursorPosition, Plan plan) {
    int inxStart = getIndexOfStartOfCurrentLine(cursorPosition, plan);
    int result = cursorPosition - inxStart;
    return cursorPosition - inxStart;
  }

  /// This helper method returns true if the cursor position is between the start and end of its current line
  static bool cursorIsBetweenStartAndEndOfLine(int cursorPosition, Plan plan) {
    return cursorPosition >
            getIndexOfStartOfCurrentLine(cursorPosition, plan) &&
        cursorPosition > getIndexOfEndOfCurrentLine(cursorPosition, plan);
  }
}
