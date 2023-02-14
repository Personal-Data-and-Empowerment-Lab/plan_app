import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planv3/blocs/bloc.dart';
import 'package:planv3/models/Plan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipedetector/swipedetector.dart';
import 'package:tutorial_coach_mark/animated_focus_light.dart';
import 'package:tutorial_coach_mark/target_focus.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:uuid/uuid.dart';

class EditorHeaderWidget extends StatefulWidget {
  @override
  _EditorHeaderWidgetState createState() => _EditorHeaderWidgetState();
}

class _EditorHeaderWidgetState extends State<EditorHeaderWidget> {
  List<TargetFocus> targets = [];
  bool copied = false;

  @override
  void initState() {
    initTargets();
    super.initState();
  }

  void initTargets() {
    targets.add(TargetFocus(
      keyTarget: calendarSource,
      contents: [
        ContentTarget(
            align: AlignContent.bottom,
            child: Container(
                child: Padding(
              padding: const EdgeInsets.only(top: 0, left: 0, right: 0),
              child: Column(mainAxisAlignment: MainAxisAlignment.center,
//                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    AutoSizeText(
                      "The sources drawer contains lists of events or tasks from other applications",
                      wrapWords: false,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      maxLines: 30,
                      minFontSize: 2,
                    ),
                  ]),
            )))
      ],
      shape: ShapeLightFocus.RRect,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0.0, bottom: 0.0),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 0.0),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Tooltip(
                        message: "Previous",
                        child: IconButton(
                            icon: Icon(Icons.chevron_left),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              BlocProvider.of<EditorBloc>(context)
                                  .add(LoadPreviousPlan());
                            }),
                      ),
                      SwipeDetector(
                          //changed from GestureDetector

                          //GestureDetector
                          //onTap: () {
//                          showDatePicker(
//                              context: context,
//                              initialDate: DateTime.now(),
//                              firstDate: DateTime(DateTime.now().year),
//                              lastDate: DateTime.now().add(Duration(days: 365)),
//                              builder: (BuildContext context, Widget child) {
//                                return Theme(
//                                  data: ThemeData.dark(),
//                                  child: child,
//                                );
//                              }
//                          ).then((DateTime newDate) {
//                            if (newDate != null) {
////                              editorBloc.add(LoadSpecificPlan(newDate));
//                            }
//                          });
                          //},

                          //SwipeDetector
//                           onSwipeLeft: () {
//                             setState(() {
//                               showDatePicker(
//                              context: context,
//                              initialDate: DateTime.now(),
//                              firstDate: DateTime(DateTime.now().year),
//                              lastDate: DateTime.now().add(Duration(days: 365)),
//                              builder: (BuildContext context, Widget child) {
//                                return Theme(
//                                  data: ThemeData.dark(),
//                                  child: child,
//                                );
//                              }
//                          ).then((DateTime newDate) {
//                            if (newDate != null) {
// //                              editorBloc.add(LoadSpecificPlan(newDate));
//                            }
//                          });
//                             });
//                           },
                          child: _mapStateToDateText(
                              BlocProvider.of<EditorBloc>(context))),
                      Tooltip(
                        message: "Next",
                        child: IconButton(
                            icon: Icon(Icons.chevron_right),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              BlocProvider.of<EditorBloc>(context)
                                  .add(LoadNextPlan());
                            }),
                      ),
//                      false
//                          ? Container()
//                          : Tooltip(
//                              message: "Jump to Today",
//                              child: IconButton(
//                                icon: Icon(Icons.today),
//                                onPressed: () => {}
////                                onPressed: () => bloc.openSpecificPlan
////                                    .add(new DateTime.now().toLocal()),
//                              ),
//                            ),
                    ],
                  ),
                ],
              ),
            ),
//            Padding(
//              padding: EdgeInsets.only(right: 12.0),
//              child: Row(children: <Widget>[
//                Tooltip(
//                    message: "Copy plan",
//                    child: IconButton(
//                      icon: Icon(Icons.content_copy),
//                      onPressed: () =>
//                          BlocProvider.of<EditorBloc>(context).add(CopyPlan()),
//                    )),
////                headerViewModel.isToday
////                    ? Tooltip(
////                        message: "Plaintext",
////                        child: IconButton(
////                          icon: Icon(Icons.format_clear),
////                          onPressed: () => bloc.plainTextButton.add(true),
////                        ),
////                      )
////                    : Container(),
////                headerViewModel.inMoveMode
////                    ? Tooltip(
////                        message: "Done rearranging",
////                        child: IconButton(
////                          icon: Icon(Icons.done),
////                          onPressed: () => bloc.toggleMoveLines.add(true),
////                        ))
////                    : Tooltip(
////                        message: "Rearrange lines",
////                        child: IconButton(
////                          icon: Icon(Icons.format_line_spacing),
//////                            icon: Icon(Icons.keyboard_hide),
////                          onPressed: () => bloc.toggleMoveLines.add(true),
////                        ),
////                      ),
////                PopupMenuButton(
////                    onSelected: (value) {
////                      switch (value) {
////                        case OverFlowMenuItem.clear:
////                          BlocProvider.of<EditorBloc>(context).add(ClearPlan());
////                          break;
////                        case OverFlowMenuItem.intro:
////                          Navigator.of(context)
////                              .push(MaterialPageRoute(builder: (context) {
////                            return IntroPage();
////                          }));
////                          break;
//////                        case OverFlowMenuItem.startTutorial:
//////                          BlocProvider.of<EditorBloc>(context).add(StartTutorial());
//////                          break;
//////                        case OverFlowMenuItem.stopTutorial:
//////                          BlocProvider.of<EditorBloc>(context).add(StopTutorial());
//////                          break;
////                        case OverFlowMenuItem.userID:
////                          _handleGetUserID();
////                          break;
////                        default:
////                          break;
////                      }
////                    },
////                    child: Icon(Icons.more_vert),
////                    itemBuilder: (BuildContext popupContext) {
////                      //TODO: add logic here to prevent weird toolbar behavior (remove line focus)
//////                      bloc.inFocusLine.add(-1);
////                      return <PopupMenuItem>[
////                        PopupMenuItem(
////                            value: OverFlowMenuItem.clear,
////                            child: Text("Clear plan")),
////                        PopupMenuItem(
////                            value: OverFlowMenuItem.intro,
////                            child: Text("Show intro")),
//////                        PopupMenuItem(
//////                          value: OverFlowMenuItem.startTutorial,
//////                          child: Text("Show tutorial")
//////                        ),
//////                        PopupMenuItem(
//////                          value: OverFlowMenuItem.stopTutorial,
//////                          child: Text("Stop tutorial")
//////                        ),
////                        PopupMenuItem(
////                            value: OverFlowMenuItem.userID,
////                            child: Text("Get User ID"))
////                      ];
////                    })
//              ]),
//            )
          ]),
    );
  }

  void _handleGetUserID() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String userID = prefs.getString("userID");
    if (userID == null) {
      userID = Uuid().v4();
      prefs.setString("userID", Uuid().v4());
    }
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('User ID'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
//                Text('Your user ID is:', style: TextStyle(fontWeight: FontWeight.bold)),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: SelectableText(userID),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
                child: Text('Copy'),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Clipboard.setData(ClipboardData(text: userID));
                }),
            TextButton(
              child: Text('Done'),
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _mapStateToDateText(EditorBloc editorBloc) {
    EditorState currentState = editorBloc.state;

    if (currentState is ActiveEditing) {
      return _mapActiveEditingStateToDateText(editorBloc, currentState.plan);
    } else if (currentState is BeforeDrawerTutorial) {
      return _mapActiveEditingStateToDateText(editorBloc, currentState.plan);
    } else if (currentState is AfterDrawerTutorial) {
      return _mapActiveEditingStateToDateText(editorBloc, currentState.plan);
    } else if (currentState is DisplayingMessage) {
      return _mapDisplayingMessageStateToDateText(editorBloc, currentState);
    } else {
      return Container();
    }
  }

  Widget _mapActiveEditingStateToDateText(EditorBloc editorBloc, Plan plan) {
    // for today's plan
    if (plan.isToday()) {
      return Container(
        width: 165,
        padding: EdgeInsets.symmetric(horizontal: 3.0),
//        decoration: BoxDecoration(
//            borderRadius: BorderRadius.circular(5),
//            border: Border.all(
//                color: Colors.black, width: 0.5)),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 0.0),
                    child: Text(plan.getDateTitleText(),
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                  ),
                  Text(plan.getDateSubText(),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.normal))
                ],
              ),
            )
          ],
        ),
      );
    }
    // for NOT today's plan
    else {
      return Container(
        width: 165,
        padding: EdgeInsets.symmetric(horizontal: 3.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 0.0),
                    child: Text(plan.getDateTitleText(),
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                  ),
                  Text(plan.getDateSubText(),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.normal))
                ],
              ),
            )
          ],
        ),
      );
    }
  }

  Widget _mapDisplayingMessageStateToDateText(
      EditorBloc editorBloc, DisplayingMessage state) {
    // for today's plan
    if (state.plan.isToday()) {
      return Container(
        width: 175,
        padding: EdgeInsets.symmetric(horizontal: 3.0),
//        decoration: BoxDecoration(
//            borderRadius: BorderRadius.circular(5),
//            border: Border.all(
//                color: Colors.black, width: 0.5)),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 0.0),
                    child: Text(state.plan.getDateTitleText(),
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                  ),
                  Text(state.plan.getDateSubText(),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.normal))
                ],
              ),
            )
          ],
        ),
      );
    }
    // for NOT today's plan
    else {
      return Container(
        width: 175,
        padding: EdgeInsets.symmetric(horizontal: 3.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 0.0),
                    child: Text(state.plan.getDateTitleText(),
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                  ),
                  Text(state.plan.getDateSubText(),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.normal))
                ],
              ),
            )
          ],
        ),
      );
    }
  }
}
