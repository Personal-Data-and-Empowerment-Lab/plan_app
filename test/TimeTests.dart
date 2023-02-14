import 'package:flutter_test/flutter_test.dart';
import 'package:planv3/models/PlanLine.dart';
import 'package:planv3/utils/TimeParser.dart';
import 'package:planv3/utils/PlanParser.dart';

void main() {
  group('TimeParser line tests', () {
    test('TimeParser extraction test', () {
      String lineText = "[] 9a This is a test";

      ParsedTimeData timeData = TimeParser.extractDatesFromText(lineText);
    });

    test("getLineObjectFromPosition test", () {
      String planText = "[ ] 10am some stuff\n" +
          "\n" +
          "some more stuff\n" +
          "11am-12pm yeah some more" +
          "yet another line 4pm ";

      List<PlanLine> planLines = PlanParser.getPlanAsObjects(planText);
      int cursorPosition = 25;
      PlanLine currentLine =
          PlanParser.getLineObjectFromPosition(planLines, cursorPosition);
      print("got current Line");
    });
  });
}
