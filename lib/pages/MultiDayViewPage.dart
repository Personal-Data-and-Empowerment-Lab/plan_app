import 'dart:async';

import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planv3/blocs/editor_event.dart';
import 'package:planv3/blocs/editor_state.dart';
import 'package:planv3/blocs/multiday_view_bloc.dart';
import 'package:planv3/blocs/multiday_view_event.dart';
import 'package:planv3/blocs/multiday_view_state.dart';
import 'package:planv3/models/Plan.dart';
import 'package:planv3/models/PlanLine.dart';
import 'package:planv3/utils/PlanParser.dart';
import 'package:planv3/widgets/MultidayHeaderWidget.dart';
import 'package:planv3/widgets/TappableDragAndDropList.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class NoOverscrollGlowBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class MultiDayViewPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MultiDayViewPageState();
}

class _MultiDayViewPageState extends State<MultiDayViewPage> {
  BuildContext mdvContext;
  MultiDayViewBloc mdvBloc;
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    mdvBloc = BlocProvider.of<MultiDayViewBloc>(context);
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      SharedPreferences.getInstance().then((prefs) {
        if (!(prefs.getBool("seenMultiDayTutorial") ?? false)) {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) {
                // Close keyboard to make space for tutorial
                FocusScope.of(dialogContext).unfocus();

                return _buildMultiDayTutorial(dialogContext);
              });
          prefs.setBool("seenMultiDayTutorial", true);
        }
      });
    });
  }

  @override
  void dispose() {
    mdvBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    this.mdvContext = context;
    var days = mdvBloc.plans.map((plan) {
      return _buildDay(plan);
    }).toList();
    return Scaffold(
        key: _scaffoldKey,
        appBar: _buildAppBar(),
        body: Padding(
            padding: EdgeInsets.only(top: 12),
            child: ScrollConfiguration(
                behavior: NoOverscrollGlowBehavior(),
                child: DragAndDropLists(
                  children: days,
                  listDivider: Divider(),
                  onItemReorder: (int oldItemIndex, int oldListIndex,
                      int newItemIndex, int newListIndex) {
                    mdvBloc.add(PlanItemsReordered(oldListIndex, newListIndex,
                        oldItemIndex, newItemIndex));
                  },
                  onListReorder: (int oldListIndex, int newListIndex) {},
                  // dragHandle: Padding(
                  //   padding: const EdgeInsets.only(right: 5.0),
                  //   child: Icon(Icons.menu),
                  // ),
                  itemDragOnLongPress: true,
                  onItemDraggingChanged: (_item, _startedDrag) {
                    HapticFeedback.lightImpact();
                  },
                  itemDecorationWhileDragging: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ))));
  }

  DragAndDropList _buildDay(Plan plan) {
    List<PlanLine> lines = PlanParser.getPlanAsObjects(plan.planText);
    List<DragAndDropItem> tiles;
    if (lines.length == 1 && lines.first.rawText.isEmpty) {
      tiles = [];
    } else {
      tiles = lines.map((line) {
        return DragAndDropItem(
            child: InkWell(
          onTap: () {
            // do nothing, but we need this function body so it will show
            // long pressing on it does something
          },
          child: Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Padding(
                    // prevents text overlapping the drag handle
                    padding: const EdgeInsets.only(right: 30),
                    child: Text(line.rawText, style: TextStyle(fontSize: 16)),
                  )),
                  Icon(Icons.menu)
                ],
              )),
        ));
      }).toList();
    }

    var headerStyle = TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        decoration: plan.isToday() ? TextDecoration.underline : null);

    return TappableDragAndDropList(
      header: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          _showEditorPage(date: plan.date);
        },
        child: Container(
          padding: EdgeInsets.only(left: 5, right: 5, top: 0, bottom: 0),
          child: Text(plan.getDateMainText(), style: headerStyle),
        ),
      ),
      children: tiles,
      canDrag: false,
      contentsWhenEmpty: Text(' '),

      padding: EdgeInsets.fromLTRB(15, 5, 15, 0),
      // onTap: () {
      //   _showEditorPage(date: plan.date);
      // },
      // onLongPress: () {
      //   _showEditorPage(date: plan.date);
      // }
    );
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
                title: BlocBuilder<MultiDayViewBloc, MultiDayViewState>(
                  builder: (context, state) {
                    if (state is MultiDayViewLoadInProgress) {
                      return Center(child: CircularProgressIndicator());
                    } else if (state is MultiDayViewLoadSuccess) {
                      return MultiDayHeaderWidget();
                    }
                    return Container();
                  },
                ),
                iconTheme: IconThemeData(
                  color: Colors.black,
                ),
                centerTitle: false,
                actions: <Widget>[
                  Tooltip(
                      message: "Show plan editor",
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: IconButton(
                            icon: Icon(Icons.home),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              _showEditorPage();
                            }),
                      )),
                ])));
  }

  _showEditorPage({DateTime date}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.white,
        content: _buildSyncEditorSnackBar(context)));
    // _scaffoldKey.currentState.showSnackBar(SnackBar(
    //     backgroundColor: Colors.white,
    //     content: _buildSyncEditorSnackBar(context)));

    // bloc will be closed in dispose method anyways
    // ignore: close_sinks
    var mdvBloc = BlocProvider.of<MultiDayViewBloc>(context);
    // ignore: close_sinks
    var editorBloc = mdvBloc.editorBloc;
    if (date == null) {
      date = editorBloc.plan.date;
    }

    var plansToday = mdvBloc.plans.where((plan) => plan.date == date);
    if (plansToday.isEmpty) {
      // No plans exist, so just pop
      Navigator.pop(this.mdvContext);
    }
    var currentPlan = plansToday.first;

    StreamSubscription<EditorState> listener;

    listener = editorBloc.listen((state) {
      if (editorBloc.plan.planText == currentPlan.planText) {
        Navigator.pop(this.mdvContext);
        listener.cancel();
      }
    });

    editorBloc.add(LoadSpecificPlan(date, refreshCurrentPlan: true));
  }

  Widget _buildSyncEditorSnackBar(BuildContext context) {
    return Container(
        padding: EdgeInsets.zero,
        height: kMinInteractiveDimension,
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Theme(
              data: Theme.of(context).copyWith(accentColor: Colors.black),
              child: LinearProgressIndicator(backgroundColor: Colors.grey)),
          Padding(
              padding: EdgeInsets.only(top: 5, bottom: 5),
              child: Text('Syncing with editor...',
                  style: TextStyle(fontSize: 18, color: Colors.black)))
        ]));
  }

  Widget _buildMultiDayTutorial(BuildContext tutorialContext) {
    var tutorialPageController = PageController();
    List<Widget> tutorialPages = [
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('Multi-day view',
              textAlign: TextAlign.left,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
        ),
        Text('Reorder plan items with the drag handles',
            style: TextStyle(fontSize: 18)),
        Expanded(child: Image.asset("assets/MultiDayRearrangeDemo.gif")),
      ]),
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('Multi-day view',
              textAlign: TextAlign.left,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
        ),
        Text(
            'Change weeks with the arrows in the header\n\nEdit a day\'s plan by tapping on its date\n',
            style: TextStyle(fontSize: 18)),
        Expanded(child: Image.asset("assets/MultiDayTapToDayDemo.gif")),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          TextButton(
            child: const Text('Got it!', style: TextStyle(fontSize: 18)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ]),
      ]),
    ];

    return AlertDialog(
      content: Container(
          width: 500,
          height: 500,
          child: Stack(children: <Widget>[
            PageView(
              controller: tutorialPageController,
              physics: BouncingScrollPhysics(),
              children: tutorialPages,
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: SmoothPageIndicator(
                      controller: tutorialPageController,
                      count: tutorialPages.length,
                      effect: ColorTransitionEffect(
                          activeDotColor: Colors.black,
                          dotHeight: 12,
                          dotWidth: 12)),
                ))
          ])),
    );
  }
}
