import 'package:flutter_test/flutter_test.dart';
import 'package:planv3/utils/PlanParser.dart';

void main() {
  group('PlanParser get line tests', () {
    test('initial test', () {
      String planText = "\nThis is a test";
      int cursorPosition = 5;

      String actual = PlanParser.getLineFromPosition(planText, cursorPosition);
    });

    test('only first line', () {
      String planText = "This is a test";
      int cursorPosition = 5;

      String expected = "This is a test";

      String actual = PlanParser.getLineFromPosition(planText, cursorPosition);

      expect(actual, expected);
    });

    test('empty first line', () {
      String planText = "\nThis is a test";
      int cursorPosition = 5;

      String expected = "This is a test";

      String actual = PlanParser.getLineFromPosition(planText, cursorPosition);
      expect(actual, expected);
    });

    test('empty second line', () {
      String planText = "This is a test\n";
      int cursorPosition = 5;

      String expected = "This is a test";

      String actual = PlanParser.getLineFromPosition(planText, cursorPosition);
      expect(actual, expected);
    });

    test('3 lines', () {
      String planText = "\nThis is a test\n";
      int cursorPosition = 5;

      String expected = "This is a test";

      String actual = PlanParser.getLineFromPosition(planText, cursorPosition);
      expect(actual, expected);
    });

    // tests cursor position just before the first newline
    test('multiple lines of text - 1', () {
      String planText = "first line\nsecond line\nthird line";
      int cursorPosition = 10;

      String expected = "first line";

      String actual = PlanParser.getLineFromPosition(planText, cursorPosition);
      expect(actual, expected);
    });

    // tests cursor position just after the first newline
    test('multiple lines of text - 2', () {
      String planText = "first line\nsecond line\nthird line";
      int cursorPosition = 11;

      String expected = "second line";

      String actual = PlanParser.getLineFromPosition(planText, cursorPosition);
      expect(actual, expected);
    });

    // tests cursor position in the middle of the second line
    test('multiple lines of text - 3', () {
      String planText = "first line\nsecond line\nthird line";
      int cursorPosition = 14;

      String expected = "second line";

      String actual = PlanParser.getLineFromPosition(planText, cursorPosition);
      expect(actual, expected);
    });

    // tests cursor position at 0
    test('multiple lines of text - 4', () {
      String planText = "first line\nsecond line\nthird line";
      int cursorPosition = 0;

      String expected = "first line";

      String actual = PlanParser.getLineFromPosition(planText, cursorPosition);
      expect(actual, expected);
    });

    // tests cursor position at last position
    test('multiple lines of text - 4', () {
      String planText = "first line\nsecond line\nthird line";
      int cursorPosition = planText.length - 1;

      String expected = "third line";

      String actual = PlanParser.getLineFromPosition(planText, cursorPosition);
      expect(actual, expected);
    });

    // tests cursor position in empty line
    test('between 2 newlines', () {
      String planText = "first line\nsecond line\n\nthird line";
      int cursorPosition = 23;

      String expected = "";

      String actual = PlanParser.getLineFromPosition(planText, cursorPosition);
      expect(actual, expected);
    });
  });

  group('PlanParser hasCheckbox tests', () {
    test('initial test', () {
      String lineText = "\u2611 This is a test";

      bool expected = true;

      bool actual = PlanParser.lineHasCheckbox(lineText);
      print(lineText);
      expect(actual, expected);
    });
  });

  group('PlanParser lineObject tests', () {
    test('initial test for line object', () {
      String planText = "[ ] 9am here's the plan\n" +
          "10am and another line\n" +
          "\n" +
          "My list of things to do\n" +
          "[] take over the world\n" +
          "[] finish this app";

      int cursorPosition = 0;

      PlanParser.getPlanAsObjects(planText);
      print("plan length: ${planText.length}");
    });
  });
}
