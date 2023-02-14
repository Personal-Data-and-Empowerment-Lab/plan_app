import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:planv3/blocs/bloc.dart';
import 'package:planv3/utils/PlanParser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../blocs/editor_bloc.dart';

enum ExtendedSnoozeOptions { snoozeUnchecked, snoozeToDay }

class LineToolbarWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.grey[400], width: 0.3)),
      child: Row(
          children: _mapStateToToolbar(
              BlocProvider.of<EditorBloc>(context), context)),
    );
  }

  List<Widget> _mapStateToToolbar(
      EditorBloc editorBloc, BuildContext toolbarContext) {
    final EditorState currentState = editorBloc.state;

    if (currentState is ActiveEditing) {
      return _buildActiveEditingState(editorBloc, currentState, toolbarContext);
    } else if (currentState is BeforeDrawerTutorial) {
      return _buildTutorialState(editorBloc, toolbarContext,
          currentState.plan.planText, currentState.cursorPosition);
    } else if (currentState is AfterDrawerTutorial) {
      return _buildTutorialState(editorBloc, toolbarContext,
          currentState.plan.planText, currentState.cursorPosition);
    } else {
      return [];
    }
  }

  List<Widget> _buildActiveEditingState(
      EditorBloc editorBloc, ActiveEditing state, BuildContext toolbarContext) {
    // Widget timeTool =
    //     _buildTimeTool(editorBloc, state.plan.planText, state.cursorPosition);
    Widget timeTool = _buildTimeToolImproved(
        editorBloc, state.plan.planText, state.cursorPosition);
    Widget checkboxTool = _buildCheckboxTool(
        editorBloc, state.plan.planText, state.cursorPosition);
    Widget snoozeTool = _buildSnoozeTool(editorBloc, toolbarContext);
    Widget reminderTool = _buildReminderTool(
        editorBloc, state.plan.planText, state.cursorPosition);
    Widget sourcesTool = _buildSourceDrawerTool(editorBloc);
    return [checkboxTool, timeTool, reminderTool, snoozeTool, sourcesTool];
  }

  Widget _buildCheckboxTool(
      EditorBloc editorBloc, String planText, int cursorPosition) {
    String lineText = PlanParser.getLineFromPosition(planText, cursorPosition);

    bool hasCheckbox = PlanParser.lineHasCheckbox(lineText);

    return Expanded(
        key: checkboxTool,
        child: Tooltip(
            preferBelow: false,
            message: hasCheckbox
                ? "Remove checkbox (removes the checkbox on this line)"
                : "Add checkbox (adds a checkbox to this line)",
            child: IconButton(
              icon: hasCheckbox
                  ? Icon(MdiIcons.checkboxBlank)
                  : Icon(Icons.check_box_outline_blank),
              onPressed: () async {
                HapticFeedback.lightImpact();
                // tutorial logic
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                if (prefs.get('hasAddedCheckbox') ?? false) {
                  hasCheckbox
                      ? editorBloc.add(RemoveCheckbox())
                      : editorBloc.add(AddCheckbox());
                } else {
                  editorBloc.add(CheckboxTutorial());
                  prefs.setBool(
                      "hasAddedCheckbox", true); // switch false to true
                }
                // end tutorial logic
              },
            )));
//     if (!PlanParser.lineHasCheckbox(lineText)) {
//       return Expanded(
//           key: checkboxTool,
//           child: new IconButton(
//             icon: new Icon(Icons.check_box_outline_blank),
//             onPressed: () {
//               HapticFeedback.lightImpact();
//               editorBloc.add(AddCheckbox());
//             },
//           ));
//     } else {
//       return Expanded(
// //          key: checkboxTool,
//           child: new IconButton(
//         // icon: new Icon(Icons.indeterminate_check_box),
//         icon: Icon(MdiIcons.checkboxBlank),
//         onPressed: () {
//           HapticFeedback.lightImpact();
//           editorBloc.add(RemoveCheckbox());
//         },
//       ));
//     }
  }

//   Widget _buildTimeTool(
//       EditorBloc editorBloc, String planText, int cursorPosition) {
//     if (PlanParser.lineAtPosHasTime(planText, cursorPosition)) {
//       return Expanded(
// //        key: timeTool,
//         child: Material(
//           child: InkWell(
//             onTap: () {
//               HapticFeedback.lightImpact();
//               editorBloc.add(RemoveTime());
//             },
//             child: new Ink(
//               padding: new EdgeInsets.symmetric(horizontal: 0.0, vertical: 5),
//               child: new Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   mainAxisSize: MainAxisSize.min,
//                   children: <Widget>[
//                     Icon(Icons.access_time, color: Colors.black),
//                     Icon(Icons.remove, color: Colors.black),
//                   ]),
//             ),
//           ),
//         ),
//       );
//     } else {
//       return Expanded(
//         key: timeTool,
//         child: Material(
//           child: InkWell(
//             onTap: () {
//               HapticFeedback.lightImpact();
//               editorBloc.add(IncrementStartTime());
//             },
//             child: new Ink(
//               padding: new EdgeInsets.symmetric(horizontal: 0.0, vertical: 5),
//               child: new Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   mainAxisSize: MainAxisSize.min,
//                   children: <Widget>[
//                     Icon(Icons.access_time, color: Colors.black),
//                     Icon(Icons.add, color: Colors.black),
//                   ]),
//             ),
//           ),
//         ),
//       );
//     }
//   }

  Widget _buildSourceDrawerTool(EditorBloc editorBloc) {
    return Expanded(
      key: openDrawerButton,
      child: Tooltip(
        message: "Open sources drawer",
        preferBelow: false,
        child: Transform.rotate(
            angle: 180 * pi / 180,
            child: new IconButton(
              icon: new Icon(MdiIcons.login),
              onPressed: () {
                HapticFeedback.lightImpact();
                editorBloc.add(OpenSourcesList());
              },
            )),
      ),
    );
  }

  Widget _buildSnoozeTool(EditorBloc editorBloc, BuildContext toolbarContext) {
    // closure variable to store tap location for popup menu
    Offset _tapPosition;
    return Expanded(
        key: snoozeTool,
        child: Tooltip(
            message: "Snooze (moves this line to tomorrow)",
            preferBelow: false,
            child: new Theme(
                data: Theme.of(toolbarContext).copyWith(
                    colorScheme:
                        ColorScheme.light().copyWith(primary: Colors.black)),
                child: Builder(
                  builder: (context) => GestureDetector(
                      child: new IconButton(
                        icon: new Icon(Icons.snooze),
                        onPressed: () async {
                          HapticFeedback.lightImpact();
                          final SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          if (prefs.get('hasSnoozed') ?? false) {
                            editorBloc.add(SnoozeItem());
                          } else {
                            editorBloc.add(SnoozeTutorial());
                            prefs.setBool(
                                "hasSnoozed", true); // switch false to true
                          }
                        },
                      ),
                      onLongPressStart: (LongPressStartDetails details) async {
                        HapticFeedback.mediumImpact();
                        int savedCursorPosition = editorBloc.cursorPosition;
                        var line = PlanParser.getLineFromPosition(
                            editorBloc.plan.planText, savedCursorPosition);
                        var selection = await showMenu<ExtendedSnoozeOptions>(
                            position: new RelativeRect.fromLTRB(
                                _tapPosition.dx,
                                MediaQuery.of(toolbarContext).size.height -
                                    4 * kMinInteractiveDimension -
                                    toolbarContext.size.height,
                                0,
                                3 * kMinInteractiveDimension),
                            context: toolbarContext,
                            items: [
                              PopupMenuItem(enabled: false, child: Text(line)),
                              PopupMenuDivider(),
                              PopupMenuItem(
                                  value: ExtendedSnoozeOptions.snoozeToDay,
                                  child: Text('Snooze to specific day')),
                              PopupMenuItem(
                                  value: ExtendedSnoozeOptions.snoozeUnchecked,
                                  child: Text('Snooze all unfinished tasks'))
                            ]);
                        if (selection ==
                            ExtendedSnoozeOptions.snoozeUnchecked) {
                          editorBloc.add(UncheckedItemsSnoozed());
                        } else if (selection ==
                            ExtendedSnoozeOptions.snoozeToDay) {
                          var now = DateTime.now();
                          var tomorrow =
                              DateTime(now.year, now.month, now.day + 1);
                          var snoozeDate = await showDatePicker(
                              context: context,
                              initialDate: tomorrow,
                              firstDate: tomorrow,
                              lastDate:
                                  DateTime.now().add(new Duration(days: 28)));
                          if (snoozeDate != null) {
                            editorBloc.add(ItemSnoozedToDay(
                                snoozeDate, savedCursorPosition));
                          }
                        }
                      },
                      onTapDown: (TapDownDetails details) {
                        _tapPosition = details.globalPosition;
                      }),
                ))));
  }

  Widget _buildTimeToolImproved(
      EditorBloc editorBloc, String planText, int cursorPosition) {
    bool hasTime = PlanParser.lineAtPosHasTime(planText, cursorPosition);

    return Expanded(
        child: Tooltip(
            message: hasTime
                ? "Remove time (removes the time assigned to this line)"
                : "Add time (adds a time to the beginning of this line)",
            preferBelow: false,
            child: new IconButton(
              // icon: Icon(MdiIcons.clockOutline),
              icon:
                  hasTime ? Icon(MdiIcons.clock) : Icon(MdiIcons.clockOutline),
              onPressed: () async {
                HapticFeedback.lightImpact();
                // tutorial logic
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                if (prefs.get('hasAddedTime') ?? false) {
                  hasTime
                      ? editorBloc.add(RemoveTime())
                      : editorBloc.add(AddTime());
                } else {
                  editorBloc.add(TimeTutorial());
                  prefs.setBool("hasAddedTime", true); // switch false to true
                }
                // end tutorial logic
              },
            )));
  }

  Widget _buildReminderTool(
      EditorBloc editorBloc, String planText, int cursorPosition) {
    bool hasReminder =
        PlanParser.lineAtPosHasReminder(planText, cursorPosition);
    bool hasStartTime =
        PlanParser.lineAtPosHasStartTime(planText, cursorPosition);

    return Expanded(
        child: Tooltip(
            message: hasReminder && hasStartTime
                ? "Remove reminder (cancels the reminder for this line)"
                : "Add reminder (schedules a reminder for this line)",
            preferBelow: false,
            child: new IconButton(
                // icon: Icon(MdiIcons.bell),
                icon: hasReminder && hasStartTime
                    ? Icon(MdiIcons.bell)
                    : Icon(MdiIcons.bellOutline),
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  // tutorial logic
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  if (prefs.get('hasAddedReminder') ?? false) {
                    hasReminder && hasStartTime
                        ? editorBloc.add(RemoveReminder())
                        : editorBloc.add(AddReminder());
                  } else {
                    editorBloc.add(ReminderTutorial());
                    prefs.setBool(
                        "hasAddedReminder", true); // switch false to true
                  }
                  // end tutorial logic
                })));
  }

  List<Widget> _buildTutorialState(EditorBloc editorBloc,
      BuildContext toolbarContext, String planText, int cursorPosition) {
    // Widget timeTool = _buildTimeTool(editorBloc, planText, cursorPosition);
    Widget timeTool =
        _buildTimeToolImproved(editorBloc, planText, cursorPosition);
    Widget checkboxTool =
        _buildCheckboxTool(editorBloc, planText, cursorPosition);

    Widget snoozeTool = _buildSnoozeTool(editorBloc, toolbarContext);

    Widget reminderTool =
        _buildReminderTool(editorBloc, planText, cursorPosition);
    Widget sourcesTool = _buildSourceDrawerTool(editorBloc);
    return [checkboxTool, timeTool, reminderTool, snoozeTool, sourcesTool];
  }
}
