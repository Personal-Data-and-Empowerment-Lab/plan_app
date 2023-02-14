import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planv3/utils/PlanParser.dart';
import 'package:planv3/utils/TimeParser.dart';

import '../blocs/bloc.dart';

class TimePickerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _mapStateToWidget(BlocProvider.of<EditorBloc>(context));
  }

  Widget _mapStateToWidget(EditorBloc editorBloc) {
    final EditorState currentState = editorBloc.state;

    if (currentState is ActiveEditing) {
      return _buildActiveEditingState(editorBloc, currentState);
    } else if (currentState is BeforeDrawerTutorial) {
      return _buildTutorialState(
          editorBloc, currentState.plan.planText, currentState.cursorPosition);
    } else if (currentState is AfterDrawerTutorial) {
      return _buildTutorialState(
          editorBloc, currentState.plan.planText, currentState.cursorPosition);
    }

    return Container();
  }

  Widget _buildActiveEditingState(
      EditorBloc editorBloc, ActiveEditing currentState) {
    if (PlanParser.lineAtPosHasTime(
        currentState.plan.planText, currentState.cursorPosition)) {
      String line = PlanParser.getLineFromPosition(
          currentState.plan.planText, currentState.cursorPosition);
      ParsedTimeData timeData = TimeParser.extractDatesFromText(line);
      String startTimeString = TimeParser.getTimeAsString(timeData.startTime);
      String endTimeString = TimeParser.getTimeAsString(timeData.endTime);

      return Container(
        padding: EdgeInsets.symmetric(vertical: 0),
//        decoration: BoxDecoration(
//            border: Border(
//              top: BorderSide(
//                width: 0.2,
//                color: Colors.grey,
//              ),
//            )
//        ),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            editorBloc.add(DecrementStartTime());
                          }),
                      Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: Text(
                            startTimeString.length > 0
                                ? startTimeString
                                : "None",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            editorBloc.add(IncrementStartTime());
                          }),
                    ],
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          //decrement end time
                          HapticFeedback.selectionClick();
                          editorBloc.add(DecrementEndTime());
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 0.0),
                        child: Text(
                            endTimeString.length > 0 ? endTimeString : "None",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          // increment end time
                          HapticFeedback.selectionClick();
                          editorBloc.add(IncrementEndTime());
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ]),
      );
    } else {
      return Container();
    }
  }

  Widget _buildTutorialState(
      EditorBloc editorBloc, String planText, int cursorPosition) {
    if (PlanParser.lineAtPosHasTime(planText, cursorPosition)) {
      String line = PlanParser.getLineFromPosition(planText, cursorPosition);
      ParsedTimeData timeData = TimeParser.extractDatesFromText(line);
      String startTimeString = TimeParser.getTimeAsString(timeData.startTime);
      String endTimeString = TimeParser.getTimeAsString(timeData.endTime);

      return Container(
        key: timePicker,
        padding: EdgeInsets.symmetric(vertical: 0),
//        decoration: BoxDecoration(
//            border: Border(
//              bottom: BorderSide(
//                width: 0.2,
//                color: Colors.grey,
//              ),
//            )
//        ),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
//                            HapticFeedback.selectionClick();
                            HapticFeedback.heavyImpact();
                            editorBloc.add(DecrementStartTime());
                          }),
                      Padding(
                        padding: const EdgeInsets.only(top: 0.0),
                        child: Text(
                            startTimeString.length > 0
                                ? startTimeString
                                : "None",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            editorBloc.add(IncrementStartTime());
                          }),
                    ],
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          //decrement end time
                          HapticFeedback.selectionClick();
                          editorBloc.add(DecrementEndTime());
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 0.0),
                        child: Text(
                            endTimeString.length > 0 ? endTimeString : "None",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          // increment end time
                          HapticFeedback.selectionClick();
                          editorBloc.add(IncrementEndTime());
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ]),
      );
    } else {
      return Container();
    }
  }
}
