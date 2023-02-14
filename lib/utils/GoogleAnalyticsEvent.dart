import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:planv3/blocs/bloc.dart';
import 'package:planv3/models/PlanLine.dart';

import 'PlanParser.dart';
import 'TimeParser.dart';

part 'GoogleAnalyticsEvent.g.dart';

@JsonSerializable()
class GoogleAnalyticsEvent {
  final String name;
  final Map<String, dynamic> parameters;
  final DateTime timestamp = DateTime.now();

  GoogleAnalyticsEvent(this.name, this.parameters);

  factory GoogleAnalyticsEvent.fromJson(Map<String, dynamic> json) =>
      _$GoogleAnalyticsEventFromJson(json);

  Map<String, dynamic> toJson() => _$GoogleAnalyticsEventToJson(this);
}

class GoogleAnalyticsEventAdapter {
  static GoogleAnalyticsEvent convertToEvent(
      Bloc bloc, var eventObject, String userID) {
    String name;

    print("EVENT OBJECT TO STRING: ${eventObject.props.toString()}");
    // String contents = eventObject.props.toString();
    List<dynamic> propStrings = [];
    for (var prop in eventObject.props) {
      propStrings.add(prop.toString());
    }
    String contents = propStrings.join(" ||| ");

    if (eventObject is AddSourceItemsToPlan) {
      contents =
          "Added ${eventObject.eventItems.length} events and ${eventObject.taskItems.length} tasks.";
    }

    if (eventObject is AddSelectionToPlan) {
      contents = eventObject.viewData.toLogString();
    }

    // if (contents.length > 99) {
    //   contents = contents.substring(0, 99);
    // }
    contents = contents.replaceAll("\n", "\\n");

    name = eventObject.runtimeType.toString();
    Map<String, dynamic> parameters = Map();
    parameters["userID"] = userID;
    parameters["contents"] = contents;
    // parameters["timestamp"] = DateTime.now().toString();

    return GoogleAnalyticsEvent(name, parameters);
  }

//  static Future<String> getUserID() async {
//    final SharedPreferences prefs = await SharedPreferences.getInstance();
//    String userID = prefs.getString("userID") ?? "null";
//    return userID;
//  }

  static GoogleAnalyticsEvent buildPlanSnapshot(
      ActiveEditing state, String userID) {
    Map<String, dynamic> parameters = Map();
    parameters["userID"] = userID;
    parameters["date"] = state.plan.date.toString();
    parameters["length"] = state.plan.planText.length;
    List<PlanLine> lineObjects =
        PlanParser.getPlanAsObjects(state.plan.planText);
    parameters["numLines"] = lineObjects.length;
    parameters["numCompleteWithTimeLines"] = lineObjects.where((PlanLine line) {
      return line.hasCheckbox &&
          line.isCompleted &&
          (line.startTime != null || line.endTime != null);
    }).length;
    parameters["numIncompleteWithTimeLines"] =
        lineObjects.where((PlanLine line) {
      return line.hasCheckbox &&
          !line.isCompleted &&
          (line.startTime != null || line.endTime != null);
    }).length;
    parameters["numCompleteLines"] = lineObjects.where((PlanLine line) {
      return line.hasCheckbox &&
          line.isCompleted &&
          !(line.startTime != null || line.endTime != null);
    }).length;
    parameters["numIncompleteLines"] = lineObjects.where((PlanLine line) {
      return line.hasCheckbox &&
          !line.isCompleted &&
          !(line.startTime != null || line.endTime != null);
    }).length;

    return GoogleAnalyticsEvent("PlanSnapshot", parameters);
  }

  static GoogleAnalyticsEvent buildPlanSnapshotLocal(
      ActiveEditing state, String userID) {
    Map<String, dynamic> parameters = Map();
    parameters["userID"] = userID;
    parameters["date"] = state.plan.date.toString();
    parameters["length"] = state.plan.planText.length;

    List<PlanLine> lineObjects =
        PlanParser.getPlanAsObjects(state.plan.planText);
    parameters["numLines"] = lineObjects.length;
    String planRepresentation = "";
    for (PlanLine line in lineObjects) {
      String planLineRep = "";
      // add checkboxes
      if (line.hasCheckbox) {
        // add checkbox to representation
        if (line.isCompleted) {
          planLineRep += "[x] ";
          line.rawText = line.rawText
              .replaceFirst(PlanParser.completedCheckboxString + " ", "");
        } else {
          planLineRep += "[] ";

          // remove checkbox from line text
          line.rawText =
              line.rawText.replaceFirst(PlanParser.checkboxString + " ", "");
        }
      }
      // add times
      ParsedTimeData timeData = TimeParser.extractDatesFromText(line.rawText);
      int replacePosStart = 0;
      int replacePosEnd = timeData.endPosition ?? 0;
      if (PlanParser.isNextCharSpace(line.rawText, replacePosEnd)) {
        replacePosEnd += 1;
      }
      line.rawText =
          line.rawText.replaceRange(replacePosStart, replacePosEnd, "");

      if (line.startTime != null && line.endTime != null) {
        planLineRep +=
            TimeParser.getFullTimeAsString(line.startTime, line.endTime) + " ";
      } else if (line.startTime != null) {
        planLineRep += TimeParser.getTimeAsString(line.startTime) + " ";
      } else if (line.endTime != null) {
        planLineRep += TimeParser.getTimeAsString(line.endTime) + " ";
      }

      String anonymizedRawText = line.rawText.replaceAll(RegExp(r'[^\s]'), "*");
      planLineRep += anonymizedRawText + "\\n";

      planRepresentation += planLineRep;
    }

    parameters["numCompleteWithTimeLines"] = lineObjects.where((PlanLine line) {
      return line.hasCheckbox &&
          line.isCompleted &&
          (line.startTime != null || line.endTime != null);
    }).length;
    parameters["numIncompleteWithTimeLines"] =
        lineObjects.where((PlanLine line) {
      return line.hasCheckbox &&
          !line.isCompleted &&
          (line.startTime != null || line.endTime != null);
    }).length;
    parameters["numCompleteLines"] = lineObjects.where((PlanLine line) {
      return line.hasCheckbox &&
          line.isCompleted &&
          !(line.startTime != null || line.endTime != null);
    }).length;
    parameters["numIncompleteLines"] = lineObjects.where((PlanLine line) {
      return line.hasCheckbox &&
          !line.isCompleted &&
          !(line.startTime != null || line.endTime != null);
    }).length;
    parameters["planStructure"] = planRepresentation;
    return GoogleAnalyticsEvent("PlanSnapshot", parameters);
  }
}
