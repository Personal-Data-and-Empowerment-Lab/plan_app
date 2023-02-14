import 'dart:io' show Platform;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/cupertino.dart';

// import 'package:extended_text_library/extended_text_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:planv3/blocs/multiday_view_bloc.dart';
import 'package:planv3/blocs/multiday_view_event.dart';
import 'package:planv3/blocs/multiday_view_state.dart';
import 'package:planv3/pages/MultiDayViewPage.dart';
import 'package:planv3/repositories/FileStoragePlansRepository.dart';
import 'package:planv3/special_text_widgets/DateTextBuilder.dart';
import 'package:planv3/widgets/EditorHeaderWidget.dart';
import 'package:planv3/widgets/SourcesListWidget.dart';
import 'package:planv3/widgets/TimePickerWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcase.dart';
import 'package:showcaseview/showcase_widget.dart';
import 'package:swipedetector/swipedetector.dart';
import 'package:tutorial_coach_mark/animated_focus_light.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:uuid/uuid.dart';

import '../blocs/bloc.dart';
import '../widgets/LineToolbarWidget.dart';
import 'IntroPage.dart';

class EditorPage extends StatefulWidget {
  @override
  EditorPageState createState() => EditorPageState();
}

class EditorPageState extends State<EditorPage> {
  TextEditingController _controller;
  EditorBloc editorBloc;
  TextEditingController _extendedController;
  FocusNode _editorFocusNode;

  bool _showSurveyAlert = false;

  List<TargetFocus> beforeDrawerTargets = [];
  List<TargetFocus> afterDrawerTargets = [];

  bool layoutReady = false;

  GlobalKey _multiDayViewButtonKey = GlobalKey();
  BuildContext showCaseContext;

  @override
  void initState() {
    super.initState();
    // Here we must load the document and pass it to Zefyr controller.
    editorBloc = BlocProvider.of<EditorBloc>(context);
    _extendedController = TextEditingController();
//    _pageController = PageController();
    _extendedController.addListener(() {
      if (!(editorBloc.state is BeforeDrawerTutorial) &&
          !(editorBloc.state is AfterDrawerTutorial)) {
        if (_extendedController.selection.isCollapsed &&
            editorBloc.cursorPosition !=
                _extendedController.selection.baseOffset) {
//          print("updating cursor: ${_extendedController.selection.baseOffset}");
          editorBloc.add(EditText(_extendedController.text,
              _extendedController.selection.baseOffset));
        }
      }
    });
    _editorFocusNode = FocusNode();
    initTargets();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      this.layoutReady = true;
      SharedPreferences.getInstance().then((prefs) {
        String lastSurveyTakenString = prefs.getString("lastSurveyTaken");
        String lastSurveyReminderShownString =
            prefs.getString("lastSurveyReminderShown");
        DateTime now = DateTime.now();
        if (lastSurveyTakenString == null &&
            now.isBefore(DateTime(2022, 5, 1))) {
          setState(() {
            _showSurveyAlert = true;
          });
        } else {
          DateTime lastSurveyTaken = DateTime.parse(lastSurveyTakenString);
          int difference = now.difference(lastSurveyTaken).inDays;

          // if they haven't taken the survey in over 15 days and we haven't shown a popup in 15 days
          setState(() {
            if (difference > 15 && now.isBefore(DateTime(2022, 5, 1))) {
              _showSurveyAlert = true;
              DateTime lastReminderShown =
                  (lastSurveyReminderShownString == null)
                      ? null
                      : DateTime.parse(lastSurveyReminderShownString);
              if (lastReminderShown == null ||
                  now.difference(lastReminderShown).inDays > 15) {
                _handleShowSurvey();
                prefs.setString("lastSurveyReminderShown",
                    DateTime.now().toIso8601String());
              }
            } else {
              _showSurveyAlert = false;
            }
          });
        }

        if (prefs.getInt("appUsesBeforeMdvUsed") == null) {
          prefs.setInt("appUsesBeforeMdvUsed", 0);
        }

        var appUsesBeforeMdv = prefs.getInt("appUsesBeforeMdvUsed");

        if (!(prefs.getBool("seenMdvShowcase") ?? false) &&
            appUsesBeforeMdv >= 5) {
          Future.delayed(Duration(milliseconds: 250), () {
            ShowCaseWidget.of(showCaseContext)
                .startShowCase([_multiDayViewButtonKey]);
            prefs.setBool("seenMdvShowcase", true);
          });
        } else if (appUsesBeforeMdv < 5) {
          prefs.setInt("appUsesBeforeMdvUsed", appUsesBeforeMdv + 1);
        }
      });
    });
  }

  void showAfterDrawerTutorial() {
    TutorialCoachMark(context,
        targets: afterDrawerTargets,
        colorShadow: Colors.black,
        paddingFocus: 10,
        textSkip: "", finish: () async {
      await _markTutorialViewed();
      editorBloc.add(StopTutorial());
    }, clickTarget: (target) {
      if (target.keyTarget == timePicker) {
        editorBloc.add(SetUpTimeToolTutorial());
      } else if (target.keyTarget == timeTool) {
        editorBloc.add(IncrementTimeTutorial());
      } else if (target.keyTarget == checkboxTool) {
        editorBloc.add(AddCheckboxTutorial());
      } else if (target.keyTarget == snoozeTool) {
        editorBloc.add(SnoozeLineTutorial());
      }
    }, clickSkip: null)
      ..show();
  }

  void _markTutorialViewed() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('tutorialViewed', true);
  }

  void showBeforeDrawerTutorial() {
    TutorialCoachMark(context,
        targets: beforeDrawerTargets,
        colorShadow: Colors.black,
        paddingFocus: 10,
        textSkip: "",
        finish: () {}, clickTarget: (target) {
      if (target.keyTarget == editor) {
        //nothing for now

      } else if (target.keyTarget == openDrawerButton) {
        editorBloc.add(OpenSourcesList(inTutorialMode: true));
      }
    }, clickSkip: null)
      ..show();
  }

  void initTargets() {
    afterDrawerTargets.add(TargetFocus(
      identify: "editorAfterDrawer",
      keyTarget: editor,
      contents: [
        ContentTarget(
            align: AlignContent.top,
            child: Container(
                child: Padding(
              padding: const EdgeInsets.only(top: 0, left: 0, right: 0),
              child: Column(mainAxisAlignment: MainAxisAlignment.end,
//                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    AutoSizeText(
                      "Once items are copied into the plan, you can move them around, edit, or delete them as you please",
                      wrapWords: false,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      maxLines: 30,
                      minFontSize: 2,
                    ),
//                            AutoSizeText("You can type whatever you want here and edit events or tasks you copy in",
//                              wrapWords: false,
//                              style: TextStyle(color: Colors.white, ),
//                              maxLines: 30,
//                              minFontSize: 2,
//                            ),
                  ]),
            )))
      ],
      shape: ShapeLightFocus.RRect,
    ));

    afterDrawerTargets.add(TargetFocus(
      keyTarget: timePicker,
      contents: [
        ContentTarget(
            align: AlignContent.top,
            child: Container(
                child: Padding(
              padding: const EdgeInsets.only(top: 0, left: 0, right: 0),
              child: Column(mainAxisAlignment: MainAxisAlignment.end,
//                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    AutoSizeText(
                      "You can use the time picker to adjust the time on a line",
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

    afterDrawerTargets.add(TargetFocus(
      identify: "timeTool",
      keyTarget: editor,
      contents: [
        ContentTarget(
            align: AlignContent.top,
            child: Container(
                child: Padding(
              padding: const EdgeInsets.only(top: 0, left: 0, right: 0),
              child: Column(mainAxisAlignment: MainAxisAlignment.end,
//                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    AutoSizeText(
                      "Let's assign a time to this new task at the bottom of the plan",
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

    afterDrawerTargets.add(TargetFocus(
      keyTarget: timeTool,
      contents: [
        ContentTarget(
            align: AlignContent.top,
            child: Container(
                child: Padding(
              padding: const EdgeInsets.only(top: 0, left: 0, right: 0),
              child: Column(mainAxisAlignment: MainAxisAlignment.end,
//                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    AutoSizeText(
                      "Use the time button to assign a time to a line",
                      wrapWords: false,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      maxLines: 30,
                      minFontSize: 2,
                    ),
                    AutoSizeText(
                      "The initial time will be close to the nearest planned times, but you can always adjust them yourself",
                      wrapWords: false,
                      style: TextStyle(color: Colors.white),
                      maxLines: 30,
                      minFontSize: 2,
                    ),
                  ]),
            )))
      ],
      shape: ShapeLightFocus.RRect,
    ));

    afterDrawerTargets.add(TargetFocus(
      keyTarget: editor,
      contents: [
        ContentTarget(
            align: AlignContent.top,
            child: Container(
                child: Padding(
              padding: const EdgeInsets.only(top: 0, left: 0, right: 0),
              child: Column(mainAxisAlignment: MainAxisAlignment.end,
//                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    AutoSizeText(
                      "Since this line is a task, let's add a checkbox to it",
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

    afterDrawerTargets.add(TargetFocus(
      keyTarget: checkboxTool,
      contents: [
        ContentTarget(
            align: AlignContent.top,
            child: Container(
                child: Padding(
              padding: const EdgeInsets.only(top: 0, left: 0, right: 0),
              child: Column(mainAxisAlignment: MainAxisAlignment.end,
//                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    AutoSizeText(
                      "Use the checkbox tool to add a checkbox to the beginning of the current line",
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

    afterDrawerTargets.add(TargetFocus(
      keyTarget: editor,
      contents: [
        ContentTarget(
            align: AlignContent.top,
            child: Container(
                child: Padding(
              padding: const EdgeInsets.only(top: 0, left: 0, right: 0),
              child: Column(mainAxisAlignment: MainAxisAlignment.end,
//                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    AutoSizeText(
                      "Finally, at the end of the day, you haven't been able to get that really hard task from earlier",
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

    afterDrawerTargets.add(TargetFocus(
      keyTarget: snoozeTool,
      contents: [
        ContentTarget(
            align: AlignContent.top,
            child: Container(
                child: Padding(
              padding: const EdgeInsets.only(top: 0, left: 0, right: 0),
              child: Column(mainAxisAlignment: MainAxisAlignment.end,
//                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    AutoSizeText(
                      "Use the snooze button to move it to tomorrow's plan to work on then",
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

    afterDrawerTargets.add(TargetFocus(
      keyTarget: planNavigation,
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
                      "That task is now on tomorrow's plan",
                      wrapWords: false,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      maxLines: 30,
                      minFontSize: 2,
                    ),
                    AutoSizeText(
                      "Use the arrows on either side of the date to move to the previous or next day's plan",
                      wrapWords: false,
                      style: TextStyle(color: Colors.white),
                      maxLines: 30,
                      minFontSize: 2,
                    ),
                  ]),
            )))
      ],
      shape: ShapeLightFocus.RRect,
    ));

    afterDrawerTargets.add(TargetFocus(
      keyTarget: copyPlan,
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
                      "Tap the copy button to copy the entire plan as text into the clipboard",
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

    afterDrawerTargets.add(TargetFocus(
      keyTarget: editor,
      contents: [
        ContentTarget(
            align: AlignContent.top,
            child: Container(
                child: Padding(
              padding: const EdgeInsets.only(top: 0, left: 0, right: 0),
              child: Column(mainAxisAlignment: MainAxisAlignment.center,
//                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    AutoSizeText(
                      "That's it!",
                      wrapWords: false,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      maxLines: 30,
                      minFontSize: 2,
                    ),
                    AutoSizeText(
                        "Now you know how to make a plan, so go ahead a get started",
                        wrapWords: false,
                        style: TextStyle(color: Colors.white),
                        maxLines: 30,
                        minFontSize: 2),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: AutoSizeText(
                        "Tap anywhere to exit",
                        wrapWords: false,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                        maxLines: 30,
                        minFontSize: 2,
                      ),
                    ),
                  ]),
            )))
      ],
      shape: ShapeLightFocus.RRect,
    ));

    beforeDrawerTargets.add(TargetFocus(
      keyTarget: editor,
      contents: [
        ContentTarget(
            align: AlignContent.top,
            child: Container(
                child: Padding(
              padding: const EdgeInsets.only(top: 0, left: 0, right: 0),
              child: Column(mainAxisAlignment: MainAxisAlignment.end,
//                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    AutoSizeText(
                      "Welcome to plan!",
                      wrapWords: false,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                      maxLines: 30,
                      minFontSize: 2,
                    ),
                    AutoSizeText(
                      "This tutorial will show you how to make a plan using the app",
                      wrapWords: false,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      maxLines: 30,
                      minFontSize: 2,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: AutoSizeText(
                        "Tap anywhere to move on",
                        wrapWords: false,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                        maxLines: 30,
                        minFontSize: 2,
                      ),
                    )
                  ]),
            )))
      ],
      shape: ShapeLightFocus.RRect,
    ));

    beforeDrawerTargets.add(TargetFocus(
      keyTarget: editor,
      contents: [
        ContentTarget(
            align: AlignContent.top,
            child: Container(
                child: Padding(
              padding: const EdgeInsets.only(top: 0, left: 0, right: 0),
              child: Column(mainAxisAlignment: MainAxisAlignment.end,
//                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    AutoSizeText(
                      "Your plan goes here",
                      wrapWords: false,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      maxLines: 30,
                      minFontSize: 2,
                    ),
                    AutoSizeText(
                      "You can type whatever you want here and edit events or tasks you copy in",
                      wrapWords: false,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      maxLines: 30,
                      minFontSize: 2,
                    ),
                  ]),
            )))
      ],
      shape: ShapeLightFocus.RRect,
    ));

    beforeDrawerTargets.add(TargetFocus(
      keyTarget: openDrawerButton,
      contents: [
        ContentTarget(
            align: AlignContent.top,
            child: Container(
                child: Padding(
              padding: const EdgeInsets.only(top: 0, left: 0, right: 0),
              child: Column(mainAxisAlignment: MainAxisAlignment.end,
//                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    AutoSizeText(
                      "Let's add some events and tasks from other apps",
                      wrapWords: false,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      maxLines: 30,
                      minFontSize: 2,
                    ),
                    AutoSizeText(
                      "Use this button to open the sources drawer",
                      wrapWords: false,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      maxLines: 30,
                      minFontSize: 2,
                    ),
                  ]),
            )))
      ],
      shape: ShapeLightFocus.Circle,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _extendedController.dispose();
    _editorFocusNode.dispose();
    super.dispose();
  }

  PreferredSize _buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(60),
      child: Container(
        decoration: BoxDecoration(
            border: Border(
          bottom: BorderSide(
            width: 0.2,
            color: Colors.grey,
          ),
        )),
        child: AppBar(
          key: GlobalKey(),
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          backgroundColor: Colors.transparent,
          elevation: 0,
          brightness: Brightness.light,
          title: BlocBuilder<EditorBloc, EditorState>(
            builder: (context, state) => EditorHeaderWidget(),
          ),
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          centerTitle: false,
          actions: <Widget>[
            Tooltip(
                message: "Show multi-day view",
                child: Showcase(
                    title: 'Multi-day view',
                    description: 'Tap here to see your whole week',
                    key: _multiDayViewButtonKey,
                    child: IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          _handleShowMultiDayPage();
                        }))),
            Stack(
              children: <Widget>[
                Positioned(
                    left: 26,
                    top: 8,
                    child: Visibility(
                        visible: _showSurveyAlert,
                        child:
                            Icon(Icons.circle, color: Colors.red, size: 12))),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: RotatedBox(
                    quarterTurns: Platform.isIOS ? 1 : 0,
                    child: PopupMenuButton(onSelected: (value) {
                      switch (value) {
                        case OverFlowMenuItem.clear:
                          HapticFeedback.lightImpact();
                          BlocProvider.of<EditorBloc>(context).add(ClearPlan());
                          break;
                        case OverFlowMenuItem.intro:
                          HapticFeedback.lightImpact();
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return IntroPage();
                          }));
                          break;
//                        case OverFlowMenuItem.startTutorial:
//                          BlocProvider.of<EditorBloc>(context).add(StartTutorial());
//                          break;
//                        case OverFlowMenuItem.stopTutorial:
//                          BlocProvider.of<EditorBloc>(context).add(StopTutorial());
//                          break;
                        case OverFlowMenuItem.userID:
                          HapticFeedback.lightImpact();
                          _handleGetUserID();
                          break;
                        case OverFlowMenuItem.exportPlans:
                          HapticFeedback.lightImpact();
                          _handleExportPlans();
                          break;
                        case OverFlowMenuItem.exportLogs:
                          HapticFeedback.lightImpact();
                          BlocProvider.of<EditorBloc>(context)
                              .add(ExportLogs());
                          break;
                        case OverFlowMenuItem.showSurvey:
                          HapticFeedback.lightImpact();
                          _handleShowSurvey();
                          break;
                        case OverFlowMenuItem.feedback:
                          HapticFeedback.lightImpact();
                          _handleShowFeedback();
                          break;
                        case OverFlowMenuItem.copy:
                          HapticFeedback.lightImpact();
                          BlocProvider.of<EditorBloc>(context).add(CopyPlan());
                          break;
                        default:
                          break;
                      }
                    },
                        // child: Icon(Icons.more_vert),
                        itemBuilder: (BuildContext popupContext) {
                      //TODO: add logic here to prevent weird toolbar behavior (remove line focus)
//                      bloc.inFocusLine.add(-1);
                      return <PopupMenuEntry>[
                        PopupMenuItem(
                            value: OverFlowMenuItem.copy,
                            child: Text("Copy plan")),
                        PopupMenuItem(
                            value: OverFlowMenuItem.clear,
                            child: Text("Clear plan")),
                        PopupMenuDivider(),
                        // PopupMenuItem(
                        //     value: OverFlowMenuItem.intro,
                        //     child: Text("Show intro")),
                        // PopupMenuItem(
                        //   value: OverFlowMenuItem.startTutorial,
                        //   child: Text("Show tutorial")
                        // ),
//                        PopupMenuItem(
//                          value: OverFlowMenuItem.stopTutorial,
//                          child: Text("Stop tutorial")
//                        ),
                        PopupMenuItem(
                            value: OverFlowMenuItem.userID,
                            child: Text("View user ID")),
                        PopupMenuItem(
                            value: OverFlowMenuItem.exportPlans,
                            child: Text("Export plans")),
                        // PopupMenuItem(
                        //     value: OverFlowMenuItem.exportLogs,
                        //     child: Text("Export logs")),
                        PopupMenuItem(
                          value: OverFlowMenuItem.feedback,
                          child: Text("Give feedback"),
                        ),
                        PopupMenuItem(
                            value: OverFlowMenuItem.showSurvey,
                            child: Row(
                              children: [
                                Text("Take survey"),
                                Visibility(
                                  visible: _showSurveyAlert,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Icon(Icons.circle,
                                        color: Colors.red, size: 14),
                                  ),
                                )
                              ],
                            )),
                      ];
                    }),
                  ),
                ),
              ],
            ),

//        Tooltip(
//            message: "View Sources",
//            child: IconButton(
//              icon: Icon(Icons.menu),
//              onPressed: () => BlocProvider.of<EditorBloc>(context).add(OpenSourcesList()),
//            )
//        ),
          ],
        ),
      ),
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

  void _handleExportPlans() async {
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    // String userID = prefs.getString("userID");
    // if (userID == null) {
    //   userID = Uuid().v4();
    //   prefs.setString("userID", Uuid().v4());
    // }
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Export plans'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Pressing "Export" will send a copy of the plans for the day currently in the editor and several days prior.'),
                // Padding(
                //   padding: const EdgeInsets.only(top: 8.0),
                //   child: SelectableText(userID),
                // ),
                SizedBox(height: 16),
                Text(
                    'You should not use this feature unless instructed to do so by the research team.',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                Text(
                  'After pressing exporting, please wait until you see a message that says "Plans successfully exported"',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop();
                }),
            TextButton(
              child: Text('Export'),
              onPressed: () {
                HapticFeedback.lightImpact();
                editorBloc.add(ExportPlans());
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _handleShowFeedback() async {
    // show dialog box
    GlobalKey<FormBuilderState> feedbackKey = GlobalKey<FormBuilderState>();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Feedback'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
//                Text('Your user ID is:', style: TextStyle(fontWeight: FontWeight.bold)),
                FormBuilder(
                    key: feedbackKey,
                    child: Column(children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('What type of feedback is this?',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      FormBuilderRadioGroup(
                        attribute: "feedback_type",
                        decoration: InputDecoration(
                          labelStyle: TextStyle(fontWeight: FontWeight.bold),
                          // floatingLabelBehavior: FloatingLabelBehavior.auto,
                          // labelText: 'Is "Plan" helping you use your time more effectively?',
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.only(
                              left: 0, bottom: 0, top: 4, right: 15),
                        ),
                        validators: [FormBuilderValidators.required()],
                        options: [
                          FormBuilderFieldOption(
                              value: "bug",
                              child:
                                  Text("Bug", style: TextStyle(fontSize: 16))),
                          FormBuilderFieldOption(
                              value: "suggestion",
                              child: Text("Suggestion",
                                  style: TextStyle(fontSize: 16))),
                          FormBuilderFieldOption(
                              value: "comment",
                              child: Text("Comment",
                                  style: TextStyle(fontSize: 16))),
                          FormBuilderFieldOption(
                              value: "other",
                              child: Text("Other",
                                  style: TextStyle(fontSize: 16))),
                        ],
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.only(top: 8.0),
                      //   child: Align(
                      //     alignment: Alignment.centerLeft,
                      //     child: Text(
                      //         '2) What is helpful or unhelpful about "Plan"? (1 sentence)',
                      //         style: TextStyle(fontWeight: FontWeight.bold)
                      //     ),
                      //   ),
                      // ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: FormBuilderTextField(
                          attribute: "feedback_text",
                          minLines: 5,
                          maxLines: null,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            labelText: 'Feedback',
                            border: OutlineInputBorder(),
                            labelStyle: TextStyle(fontWeight: FontWeight.bold),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                          ),
                        ),
                      ),
                    ]))
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  this.editorBloc.add(CancelFeedback());
                  Navigator.of(context).pop();
                  // Clipboard.setData(ClipboardData(text: userID));
                }),
            SizedBox(width: 10),
            ElevatedButton(
              child: Text('Submit'),
              onPressed: () async {
                HapticFeedback.lightImpact();
                // send data to bloc
                if (feedbackKey.currentState.saveAndValidate()) {
                  print(feedbackKey.currentState.value);
                  this
                      .editorBloc
                      .add(SubmitFeedback(feedbackKey.currentState.value));
                  // editorBloc.add(SubmitSurvey(feedbackKey.currentState.value));

                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
    // show multiple choice
    // bug, suggestion, comment, other
    // submit
    // cancel
  }

  void _handleShowSurvey() async {
    // if there's an active survey they haven't filled out
    GlobalKey<FormBuilderState> surveyKey = GlobalKey<FormBuilderState>();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Survey check-in (1 min)'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
//                Text('Your user ID is:', style: TextStyle(fontWeight: FontWeight.bold)),
                FormBuilder(
                    key: surveyKey,
                    child: Column(children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                              '1) Is “Plan” helping you use your time more effectively?',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      FormBuilderRadioGroup(
                        attribute: "plan_helping",
                        decoration: InputDecoration(
                          labelStyle: TextStyle(fontWeight: FontWeight.bold),
                          // floatingLabelBehavior: FloatingLabelBehavior.auto,
                          // labelText: 'Is "Plan" helping you use your time more effectively?',
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.only(
                              left: 0, bottom: 0, top: 4, right: 15),
                        ),
                        validators: [
                          FormBuilderValidators.required(),
                        ],
                        options: [
                          FormBuilderFieldOption(
                              value: "definitely_no",
                              child: Text("Definitely no",
                                  style: TextStyle(fontSize: 16))),
                          FormBuilderFieldOption(
                              value: "somewhat_no",
                              child: Text("Somewhat no",
                                  style: TextStyle(fontSize: 16))),
                          FormBuilderFieldOption(
                              value: "neutral",
                              child: Text("Neutral",
                                  style: TextStyle(fontSize: 16))),
                          FormBuilderFieldOption(
                              value: "somewhat_yes",
                              child: Text("Somewhat yes",
                                  style: TextStyle(fontSize: 16))),
                          FormBuilderFieldOption(
                              value: "definitely_yes",
                              child: Text("Definitely yes",
                                  style: TextStyle(fontSize: 16))),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                              '2) What is helpful or unhelpful about "Plan"? (1 sentence)',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: FormBuilderTextField(
                          minLines: 5,
                          maxLines: 5,
                          attribute: "helpful_reason",
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            // labelText: 'What is helpful or unhelpful about "Plan" (1 sentence)',
                            border: OutlineInputBorder(),
                            labelStyle: TextStyle(fontWeight: FontWeight.bold),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                          ),
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.only(top: 8.0),
                      //   child: Align(
                      //     alignment: Alignment.centerLeft,
                      //     child: Text("2) I feel I manage my time well",
                      //         style: TextStyle(fontWeight: FontWeight.bold)),
                      //   ),
                      // ),
                      // FormBuilderRadioGroup(
                      //     name: "atus_1",
                      //     decoration: InputDecoration(
                      //       // labelText: "I feel I manage my time well",
                      //       // labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      //       border: InputBorder.none,
                      //       focusedBorder: InputBorder.none,
                      //       enabledBorder: InputBorder.none,
                      //       errorBorder: InputBorder.none,
                      //       disabledBorder: InputBorder.none,
                      //       contentPadding: EdgeInsets.only(
                      //           left: 0, bottom: 0, top: 4, right: 15),
                      //     ),
                      //     // validator: FormBuilderValidators.required(context),
                      //     options: [
                      //       FormBuilderFieldOption(
                      //           value: "atus_never",
                      //           child: Text("Almost never")),
                      //       FormBuilderFieldOption(
                      //           value: "atus_sometimes",
                      //           child: Text("Sometimes")),
                      //       FormBuilderFieldOption(
                      //           value: "atus_most",
                      //           child: Text("Most of the time")),
                      //       FormBuilderFieldOption(
                      //           value: "atus_always",
                      //           child: Text("Almost always")),
                      //     ]),
                      // Padding(
                      //   padding: const EdgeInsets.only(top: 8.0),
                      //   child: Align(
                      //     alignment: Alignment.centerLeft,
                      //     child: Text("3) I rush while completing my work",
                      //         style: TextStyle(fontWeight: FontWeight.bold)),
                      //   ),
                      // ),
                      // FormBuilderRadioGroup(
                      //     name: "atus_2",
                      //     decoration: InputDecoration(
                      //       // labelText: "I rush while completing my work",
                      //       // labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      //       border: InputBorder.none,
                      //       focusedBorder: InputBorder.none,
                      //       enabledBorder: InputBorder.none,
                      //       errorBorder: InputBorder.none,
                      //       disabledBorder: InputBorder.none,
                      //       contentPadding: EdgeInsets.only(
                      //           left: 0, bottom: 0, top: 4, right: 15),
                      //     ),
                      //     // validator: FormBuilderValidators.required(context),
                      //     options: [
                      //       FormBuilderFieldOption(
                      //           value: "atus_never",
                      //           child: Text("Almost never")),
                      //       FormBuilderFieldOption(
                      //           value: "atus_sometimes",
                      //           child: Text("Sometimes")),
                      //       FormBuilderFieldOption(
                      //           value: "atus_most",
                      //           child: Text("Most of the time")),
                      //       FormBuilderFieldOption(
                      //           value: "atus_always",
                      //           child: Text("Almost always")),
                      //     ]),
                      // Padding(
                      //   padding: const EdgeInsets.only(top: 8.0),
                      //   child: Align(
                      //     alignment: Alignment.centerLeft,
                      //     child: Text(
                      //         "4) Even if I do not like to do something, I still complete it on time",
                      //         style: TextStyle(fontWeight: FontWeight.bold)),
                      //   ),
                      // ),
                      // FormBuilderRadioGroup(
                      //     name: "atus_3",
                      //     decoration: InputDecoration(
                      //       // labelText:
                      //       //     "Even if I do not like to do something, I still complete it on time",
                      //       // labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      //       border: InputBorder.none,
                      //       focusedBorder: InputBorder.none,
                      //       enabledBorder: InputBorder.none,
                      //       errorBorder: InputBorder.none,
                      //       disabledBorder: InputBorder.none,
                      //       contentPadding: EdgeInsets.only(
                      //           left: 0, bottom: 0, top: 4, right: 15),
                      //     ),
                      //     // validator: FormBuilderValidators.required(context),
                      //     options: [
                      //       FormBuilderFieldOption(
                      //           value: "atus_never",
                      //           child: Text("Almost never")),
                      //       FormBuilderFieldOption(
                      //           value: "atus_sometimes",
                      //           child: Text("Sometimes")),
                      //       FormBuilderFieldOption(
                      //           value: "atus_most",
                      //           child: Text("Most of the time")),
                      //       FormBuilderFieldOption(
                      //           value: "atus_always",
                      //           child: Text("Almost always")),
                      //     ]),
                      // Padding(
                      //   padding: const EdgeInsets.only(top: 8.0),
                      //   child: Align(
                      //     alignment: Alignment.centerLeft,
                      //     child: Text(
                      //         "5) I put off things I do not like to do until the very last minute",
                      //         style: TextStyle(fontWeight: FontWeight.bold)),
                      //   ),
                      // ),
                      // FormBuilderRadioGroup(
                      //     name: "atus_4",
                      //     decoration: InputDecoration(
                      //       // labelText:
                      //       //     "I put off things I do not like to do until the very last minute",
                      //       // labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      //       border: InputBorder.none,
                      //       focusedBorder: InputBorder.none,
                      //       enabledBorder: InputBorder.none,
                      //       errorBorder: InputBorder.none,
                      //       disabledBorder: InputBorder.none,
                      //       contentPadding: EdgeInsets.only(
                      //           left: 0, bottom: 0, top: 4, right: 15),
                      //     ),
                      //     // validator: FormBuilderValidators.required(context),
                      //     options: [
                      //       FormBuilderFieldOption(
                      //           value: "atus_never",
                      //           child: Text("Almost never")),
                      //       FormBuilderFieldOption(
                      //           value: "atus_sometimes",
                      //           child: Text("Sometimes")),
                      //       FormBuilderFieldOption(
                      //           value: "atus_most",
                      //           child: Text("Most of the time")),
                      //       FormBuilderFieldOption(
                      //           value: "atus_always",
                      //           child: Text("Almost always")),
                      //     ]),
                      // Padding(
                      //   padding: const EdgeInsets.only(top: 8.0),
                      //   child: Align(
                      //     alignment: Alignment.centerLeft,
                      //     child: Text(
                      //         "6) I feel confident that I can complete my daily routine",
                      //         style: TextStyle(fontWeight: FontWeight.bold)),
                      //   ),
                      // ),
                      // FormBuilderRadioGroup(
                      //     name: "atus_5",
                      //     decoration: InputDecoration(
                      //       // labelText:
                      //       //     "I feel confident that I can complete my daily routine",
                      //       // labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      //       border: InputBorder.none,
                      //       focusedBorder: InputBorder.none,
                      //       enabledBorder: InputBorder.none,
                      //       errorBorder: InputBorder.none,
                      //       disabledBorder: InputBorder.none,
                      //       contentPadding: EdgeInsets.only(
                      //           left: 0, bottom: 0, top: 4, right: 15),
                      //     ),
                      //     // validator: FormBuilderValidators.required(context),
                      //     options: [
                      //       FormBuilderFieldOption(
                      //           value: "atus_never",
                      //           child: Text("Almost never")),
                      //       FormBuilderFieldOption(
                      //           value: "atus_sometimes",
                      //           child: Text("Sometimes")),
                      //       FormBuilderFieldOption(
                      //           value: "atus_most",
                      //           child: Text("Most of the time")),
                      //       FormBuilderFieldOption(
                      //           value: "atus_always",
                      //           child: Text("Almost always")),
                      //     ]),
                      // Padding(
                      //   padding: const EdgeInsets.only(top: 8.0),
                      //   child: Align(
                      //     alignment: Alignment.centerLeft,
                      //     child: Text(
                      //         "7) I run out of time before I finish important things",
                      //         style: TextStyle(fontWeight: FontWeight.bold)),
                      //   ),
                      // ),
                      // FormBuilderRadioGroup(
                      //     name: "atus_6",
                      //     decoration: InputDecoration(
                      //       // labelText:
                      //       //     "I run out of time before I finish important things",
                      //       // labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      //       border: InputBorder.none,
                      //       focusedBorder: InputBorder.none,
                      //       enabledBorder: InputBorder.none,
                      //       errorBorder: InputBorder.none,
                      //       disabledBorder: InputBorder.none,
                      //       contentPadding: EdgeInsets.only(
                      //           left: 0, bottom: 0, top: 4, right: 15),
                      //     ),
                      //     // validator: FormBuilderValidators.required(context),
                      //     options: [
                      //       FormBuilderFieldOption(
                      //           value: "atus_never",
                      //           child: Text("Almost never")),
                      //       FormBuilderFieldOption(
                      //           value: "atus_sometimes",
                      //           child: Text("Sometimes")),
                      //       FormBuilderFieldOption(
                      //           value: "atus_most",
                      //           child: Text("Most of the time")),
                      //       FormBuilderFieldOption(
                      //           value: "atus_always",
                      //           child: Text("Almost always")),
                      //     ]),
                    ]))
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  this.editorBloc.add(CancelSurvey());
                  Navigator.of(context).pop();
                  // Clipboard.setData(ClipboardData(text: userID));
                }),
            SizedBox(width: 10),
            ElevatedButton(
              child: Text('Submit'),
              onPressed: () async {
                HapticFeedback.lightImpact();
                // send data to bloc
                if (surveyKey.currentState.saveAndValidate()) {
                  editorBloc.add(SubmitSurvey(surveyKey.currentState.value));
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setString(
                      "lastSurveyTaken", DateTime.now().toIso8601String());
                  setState(() {
                    _showSurveyAlert = false;
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  _handleShowMultiDayPage() {
    var topContext = context;
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return BlocProvider(
        create: (BuildContext context) => MultiDayViewBloc(
            localRepository: FileStoragePlansRepository(),
            editorBloc: BlocProvider.of<EditorBloc>(topContext))
          ..add(MultiDayViewInitialized()),
        child: BlocBuilder<MultiDayViewBloc, MultiDayViewState>(
            builder: (context, state) {
          if (state is! MultiDayViewLoadInProgress) {
            SharedPreferences.getInstance().then((prefs) {
              prefs.setBool("seenMdvShowcase", true);
            });
            return MultiDayViewPage();
          }
          return Center(child: CircularProgressIndicator());
        }),
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      builder: Builder(
        builder: (context) {
          showCaseContext = context;
          return buildScaffold();
        },
      ),
    );
  }

  Scaffold buildScaffold() {
    return Scaffold(
//      appBar: AppBar(title: Text("Editor page")),
        appBar: _buildAppBar(),
        drawerScrimColor: Color.fromRGBO(204, 204, 204, 0.25),
        endDrawer: SafeArea(
            child: Drawer(
                elevation: 5,
                child: ShowCaseWidget(
                  builder: Builder(builder: (context) {
                    return BlocProvider(
                        create: (BuildContext context) => SourcesListBloc(
                            BlocProvider.of<EditorBloc>(context)),
                        child: SourcesListWidget());
                  }),
                ))),
        body: ShowCaseWidget(builder: Builder(builder: (context) {
          return BlocListener<EditorBloc, EditorState>(
            listener: (context, state) {
              if (state is DisplayingMessage) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                // Scaffold.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(state.messageData.messageText),
                    duration:
                        Duration(seconds: state.messageData.duration ?? 4),
                    action: state.messageData.hasActionData()
                        ? SnackBarAction(
                            label: state.messageData.actionLabel,
                            onPressed: state.messageData.onPressed)
                        : null));
              } else if (state is OpeningSourcesList) {
                Scaffold.of(context).openEndDrawer();
              } else if (state is BeforeDrawerTutorial) {
//                    _editorFocusNode.requestFocus();
                Future.delayed(Duration(milliseconds: 200), () {
                  while (!this.layoutReady) {}
                  showBeforeDrawerTutorial();
                });

//                    ShowCaseWidget.of(context).startShowCase([_editor, planNavigation, copyPlan, fullSourcesDrawer]);
              } else if (state is AfterDrawerTutorial) {
                if (state.startTutorial) {
                  showAfterDrawerTutorial();
                }
              }
            },
            child: Container(
              color: Colors.transparent,
              child: Column(children: <Widget>[
                Expanded(
                  child: BlocBuilder<EditorBloc, EditorState>(
                      condition: (previousState, state) {
                    if (state is ActiveEditing && state.toolBarChangeOnly) {
                      return false;
                    } else if (state is DisplayingMessage) {
                      return false;
                    } else {
                      return true;
                    }
                  }, builder: (context, state) {
                    if (state is ActiveEditing) {
//                    print("about to set text controller");
                      _extendedController.value =
                          _extendedController.value.copyWith(
                        text: state.plan.planText,
                        selection: TextSelection.collapsed(
                            offset: state.cursorPosition),
                        composing: TextRange(start: -1, end: -1),
                      );

                      print(
                          "cursorPosition: ${state.cursorPosition} planText: ${state.plan.planText}");

                      return Padding(
                          padding: const EdgeInsets.only(
                              top: 0.0, bottom: 12.0, left: 28, right: 20),
                          child: SwipeDetector(
                              //swipe left event handler
                              onSwipeLeft: () async {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();

                                HapticFeedback.lightImpact();
                                if (!(prefs.get('swipeLeftTutorialComplete') ??
                                    false)) {
                                  editorBloc.add(SwipeLeftTutorial());
                                  prefs.setBool(
                                      'swipeLeftTutorialComplete', true);
                                } else {
                                  editorBloc.add(EditorCursorSwipedLeft());
                                }
                              },
                              // swipe right event handler
                              onSwipeRight: () async {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();

                                HapticFeedback.lightImpact();
                                if (!(prefs.getBool(
                                        'swipeRightTutorialComplete') ??
                                    false)) {
                                  editorBloc.add(SwipeRightTutorial());
                                  prefs.setBool(
                                      'swipeRightTutorialComplete', true);
                                } else {
                                  editorBloc.add(EditorCursorSwipedRight());
                                }
                              },
                              child: ExtendedTextField(
                                focusNode: _editorFocusNode,
                                autocorrect: true,
                                specialTextSpanBuilder:
                                    DateTextSpanBuilder(bloc: editorBloc),
                                controller: _extendedController,
                                selectionControls: Platform.isIOS
                                    ? CupertinoTextSelectionControls()
                                    : MaterialTextSelectionControls(),
                                maxLines: null,
                                expands: true,
                                style: TextStyle(fontSize: 18, height: 1.4),
                                decoration: new InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  contentPadding: new EdgeInsets.only(
                                      top: -12,
                                      bottom: -12,
                                      left: -12,
                                      right: -12),
                                  labelText: "Start planning here",
                                  alignLabelWithHint: true,
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.never,
                                ),
                                onChanged: (String text) {
                                  print("fired onChanged");

//                            print(text);
//                              editorBloc.add(EditText(_extendedController.text,
//                                  _extendedController.selection.baseOffset, textChanged: true));
                                },
                              )));
                    } else if (state is BeforeDrawerTutorial) {
                      _extendedController.clear();
                      return Padding(
                        padding: const EdgeInsets.only(top: 100.0),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 8.0, bottom: 8.0, left: 16, right: 8),
                          child: ExtendedTextField(
                            focusNode: _editorFocusNode..requestFocus(),
                            autocorrect: true,
                            specialTextSpanBuilder:
                                DateTextSpanBuilder(bloc: editorBloc),
                            controller: _extendedController,
                            selectionControls: MaterialTextSelectionControls(),
                            maxLines: null,
                            expands: true,
                            style: TextStyle(fontSize: 18, height: 1.4),
                            decoration: new InputDecoration(
                              border: InputBorder.none,
                              contentPadding: new EdgeInsets.all(0.0),
                              fillColor: Colors.red,
                              filled: true,
                            ),
                            onChanged: (String text) {
//                                          print("fired onChanged");
//                                          editorBloc.add(EditText(_extendedController.text, _extendedController.selection.baseOffset));
                            },
                          ),
                        ),
                      );
                    } else if (state is AfterDrawerTutorial) {
                      _extendedController.value =
                          _extendedController.value.copyWith(
                        text: state.plan.planText,
                        selection: TextSelection.collapsed(
                            offset: state.cursorPosition),
                        composing: TextRange(start: -1, end: -1),
                      );

                      return Padding(
                        padding: const EdgeInsets.only(top: 100.0),
                        child: Showcase(
                          key: editor,
                          description: "Your plan goes here",
                          disableAnimation: true,
                          disposeOnTap: false,
                          showArrow: false,
                          onTargetClick: () {},
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 8.0, bottom: 8.0, left: 16, right: 8),
                            child: ExtendedTextField(
                              focusNode: _editorFocusNode,
                              autocorrect: true,
                              specialTextSpanBuilder:
                                  DateTextSpanBuilder(bloc: editorBloc),
                              controller: _extendedController,
                              selectionControls:
                                  MaterialTextSelectionControls(),
                              maxLines: null,
                              expands: true,
                              style: TextStyle(fontSize: 18, height: 1.4),
                              decoration: new InputDecoration(
                                border: InputBorder.none,
                                contentPadding: new EdgeInsets.all(0.0),
                                fillColor: Colors.red,
                              ),
                              onChanged: (String text) {
//                                          print("fired onChanged");
//                                          editorBloc.add(EditText(_extendedController.text, _extendedController.selection.baseOffset));
                              },
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  }),
                ),
                BlocBuilder<EditorBloc, EditorState>(
                  condition: (previousState, state) {
                    if (state is DisplayingMessage) {
                      return false;
                    } else {
                      return true;
                    }
                  },
                  builder: (context, state) => TimePickerWidget(),
                ),
                BlocBuilder<EditorBloc, EditorState>(
                  condition: (previousState, state) {
                    if (state is DisplayingMessage) {
                      return false;
                    } else {
                      return true;
                    }
                  },
                  builder: (context, state) => LineToolbarWidget(),
                ),
              ]),
            ),
          );
        })));
  }
}
