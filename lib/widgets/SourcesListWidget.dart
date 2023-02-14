import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:planv3/blocs/bloc.dart';
import 'package:planv3/models/CalendarSourceViewItem.dart';
import 'package:planv3/models/CalendarViewViewItem.dart';
import 'package:planv3/models/EventViewItem.dart';
import 'package:planv3/models/SourcesListViewData.dart';
import 'package:planv3/models/TaskSourceViewItem.dart';
import 'package:planv3/models/TaskViewItem.dart';
import 'package:planv3/models/TaskViewViewItem.dart';
import 'package:planv3/pages/SourcesSettingsPage.dart';
import 'package:tutorial_coach_mark/animated_focus_light.dart';
import 'package:tutorial_coach_mark/content_target.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import 'AnimatedSync.dart';

class SourcesListWidget extends StatefulWidget {
  @override
  SourcesListWidgetState createState() => SourcesListWidgetState();
}

class SourcesListWidgetState extends State<SourcesListWidget>
    with SingleTickerProviderStateMixin {
  SourcesListBloc sourcesListBloc;
  SourcesListViewData viewData;
  SourcesListViewData tutorialViewData;
  AnimationController controller;
  Animation colorAnimation;
  Animation rotateAnimation;

  List<TargetFocus> targets = <TargetFocus>[];

  initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 200));
    rotateAnimation = Tween<double>(begin: 0, end: -360.0).animate(controller);
    sourcesListBloc = BlocProvider.of<SourcesListBloc>(context);
    initTutorialViewData();
    initTargets();
    WidgetsBinding.instance.addPostFrameCallback((_) {
//      ShowCaseWidget.of(context).startShowCase([fullSourcesDrawer]);
      _afterLayout(_);
    });
  }

  void initTutorialViewData() {
    List<EventViewItem> eventItems = [];
    DateTime now = DateTime.now();
    EventViewItem item1 = EventViewItem(
        "Event 1",
        DateTime(now.year, now.month, now.day, 11),
        DateTime(now.year, now.month, now.day, 12),
        "tutorial_event_1");
    eventItems.add(item1);
    List<CalendarViewViewItem> calendarList = [];
    CalendarViewViewItem tutorialToday =
        CalendarViewViewItem("Today", true, eventItems);
    calendarList.add(tutorialToday);

    CalendarSourceViewItem deviceCalendarViewData = CalendarSourceViewItem(
        "Device Calendars",
        true,
        true,
        calendarList,
        "device_calendars",
        true,
        0,
        false);

    List<TaskViewItem> taskItems = [];
    TaskViewItem taskItem1 =
        TaskViewItem("really hard task", null, null, "tutorial_task_1");
    taskItems.add(taskItem1);
    List<TaskViewViewItem> taskViewsList = [];
    TaskViewViewItem taskList1 = TaskViewViewItem(
        "Todo", "tutorial_taskview_1", true, taskItems, null, true);
    taskViewsList.add(taskList1);
    TaskSourceViewItem taskSourceViewData = TaskSourceViewItem("Google Tasks",
        true, true, taskViewsList, "google_tasks", true, 1, false);

    this.tutorialViewData = SourcesListViewData(
        deviceCalendarViewData, {taskSourceViewData.id: taskSourceViewData});
  }

  void initTargets() {
    targets.add(TargetFocus(
      keyTarget: fullSourcesDrawer,
      contents: [
        ContentTarget(
            align: AlignContent.bottom,
            child: Container(
                child: Padding(
              padding: const EdgeInsets.only(top: 0.0, left: 0, right: 0),
              child: Column(
//                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    AutoSizeText(
                      "Sources drawer",
                      wrapWords: false,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      maxLines: 30,
                      minFontSize: 10,
                    ),
                    AutoSizeText(
                      "The sources drawer contains lists of events or tasks from other applications",
                      wrapWords: false,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      maxLines: 30,
                      minFontSize: 10,
                    ),
                  ]),
            )))
      ],
      shape: ShapeLightFocus.RRect,
    ));

    targets.add(TargetFocus(
      keyTarget: calendarBadge,
      contents: [
        ContentTarget(
            align: AlignContent.bottom,
            child: Container(
                child: Padding(
              padding: const EdgeInsets.only(top: 0.0, left: 0, right: 0),
              child: Column(
//                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    AutoSizeText(
                      "Let's select all the events happening today",
                      wrapWords: false,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      maxLines: 30,
                      minFontSize: 10,
                    ),
//                            AutoSizeText("The sources drawer contains lists of events or tasks from other applications",
//                              wrapWords: false,
//                              style: TextStyle(color: Colors.white,),
//                              maxLines: 30,
//                              minFontSize: 10,
//                            ),
                  ]),
            )))
      ],
      shape: ShapeLightFocus.RRect,
    ));

    targets.add(TargetFocus(
      keyTarget: singleTask,
      contents: [
        ContentTarget(
            align: AlignContent.bottom,
            child: Container(
                child: Padding(
              padding: const EdgeInsets.only(top: 0.0, left: 0, right: 0),
              child: Column(
//                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    AutoSizeText(
                      "Let's also get started on this really hard task",
                      wrapWords: false,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      maxLines: 30,
                      minFontSize: 10,
                    ),
//                            AutoSizeText("The sources drawer contains lists of events or tasks from other applications",
//                              wrapWords: false,
//                              style: TextStyle(color: Colors.white,),
//                              maxLines: 30,
//                              minFontSize: 10,
//                            ),
                  ]),
            )))
      ],
      shape: ShapeLightFocus.RRect,
    ));

    targets.add(TargetFocus(
      keyTarget: selectedFooter,
      contents: [
        ContentTarget(
            align: AlignContent.top,
            child: Container(
                child: Padding(
              padding: const EdgeInsets.only(top: 0.0, left: 0, right: 0),
              child: Column(
//                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    AutoSizeText(
                      "Add the events and task we selected to the plan by tapping Add",
                      wrapWords: false,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      maxLines: 30,
                      minFontSize: 10,
                    ),
                  ]),
            )))
      ],
      shape: ShapeLightFocus.RRect,
    ));
  }

  void showTutorial() {
    TutorialCoachMark(context,
        targets: targets,
        colorShadow: Colors.black,
        paddingFocus: 10,
        textSkip: "",
        finish: () {}, clickTarget: (target) {
      if (target.keyTarget == calendarBadge) {
        setState(() {
          this
              .tutorialViewData
              .deviceCalendarViewData
              .views[0]
              .selectAllItems();
        });
      } else if (target.keyTarget == singleTask) {
        setState(() {
          this
              .tutorialViewData
              .taskSourceViewItems
              .values
              .toList()[0]
              .views[0]
              .items[0]
              .selected = true;
        });
      } else if (target.keyTarget == selectedFooter) {
        String textToAdd = "";
        for (EventViewItem eventItem
            in this.tutorialViewData.getSelectedEventItems()) {
          textToAdd += eventItem.getDisplayText() + "\n";
        }

        for (TaskViewItem taskItem
            in this.tutorialViewData.getSelectedTaskItems()) {
          textToAdd += "[ ] " + taskItem.getDisplayText() + "\n";
        }

        sourcesListBloc.add(AddTutorialSelectionToPlan(textToAdd));
        Navigator.pop(context);
      }
    }, clickSkip: () {})
      ..show();
  }

  void _afterLayout(_) {
    Future.delayed(Duration(milliseconds: 200), () {
      showTutorial();
    });
  }

  @override
  void dispose() {
    this.sourcesListBloc.add(SaveSourcesListLayout(this.viewData));
    controller.dispose();
    super.dispose();
  }

  void updateViewData(SourcesListViewData newViewData) {
    if (this.viewData == null) {
      this.viewData = newViewData;
      return;
    }
    if (newViewData.deviceCalendarViewData != null) {
      this.viewData.deviceCalendarViewData = newViewData.deviceCalendarViewData;
    }

    if (newViewData.taskSourceViewItems != null) {
      for (TaskSourceViewItem taskSourceViewItem
          in newViewData.taskSourceViewItems.values) {
        if (taskSourceViewItem != null) {
          this.viewData.taskSourceViewItems[taskSourceViewItem.id] =
              taskSourceViewItem;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SourcesListBloc, SourcesListState>(
        builder: (context, state) {
      return _mapStateToPage(context);
    });
  }

  Widget _mapStateToPage(BuildContext context) {
    List<Widget> widgetList = [];

    Widget footer = _buildFooter();

    List<Widget> listChildren = [];
    SourcesListState currentState = sourcesListBloc.state;
    if (currentState is SourcesListLoading) {
      Widget loading =
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Text("Loading...",
              style: TextStyle(fontSize: 16, color: Colors.black)),
        )
      ]);
      listChildren.add(loading);
    } else if (currentState is SourcesListLoaded ||
        currentState is SourcesListSyncing) {
      if (currentState is SourcesListLoaded) {
        this.updateViewData(currentState.viewData);
      }

      if (this.viewData == null) {
        Widget loading =
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Text("Loading...",
                style: TextStyle(fontSize: 16, color: Colors.black)),
          )
        ]);
        listChildren.add(loading);
      } else {
        List sourceViewItems = [this.viewData.deviceCalendarViewData];
        sourceViewItems.addAll(this.viewData.taskSourceViewItems.values);
        sourceViewItems =
            sourceViewItems.where((var item) => item != null).toList();
        sourceViewItems
            .sort((var a, var b) => a.position < b.position ? -1 : 1);
        for (var sourceViewItem in sourceViewItems) {
          if (sourceViewItem is CalendarSourceViewItem) {
            if (sourceViewItem.isVisible ?? false) {
              Widget deviceCalendarItem = _buildCalendarItem(sourceViewItem);
              listChildren.add(deviceCalendarItem);
            }
          } else if (sourceViewItem is TaskSourceViewItem) {
            if (sourceViewItem?.isVisible ?? false) {
              Widget taskSourceItem = _buildTaskSourceItem(sourceViewItem);
              listChildren.add(taskSourceItem);
            }
          }
        }
      }
    } else if (currentState is SetUpFirstSource) {
      listChildren.add(Padding(
        padding: const EdgeInsets.only(top: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text("You haven't set up any sources!",
                  style: TextStyle(fontSize: 18)),
            ),
            OutlinedButton(
                child: Text("Add one", style: TextStyle(color: Colors.black)),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return BlocProvider(
                        create: (BuildContext context) => SourcesSettingsBloc(),
                        child: SourcesSettingsPage());
                  })).then((var result) =>
                      sourcesListBloc.add(SourceSettingsChanged()));
                })
          ],
        ),
      ));
    } else if (currentState is MakeSourcesVisible) {
      listChildren.add(Padding(
        padding: const EdgeInsets.only(top: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text("None of your sources are visible!",
                  style: TextStyle(fontSize: 18)),
            ),
            OutlinedButton(
                child: Text("Make one visible",
                    style: TextStyle(color: Colors.black)),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return BlocProvider(
                        create: (BuildContext context) => SourcesSettingsBloc(),
                        child: SourcesSettingsPage());
                  })).then((var result) =>
                      sourcesListBloc.add(SourceSettingsChanged()));
                })
          ],
        ),
      ));
    } else if (currentState is SourcesListTutorial) {
      List<Widget> actualSources = [];

      Widget deviceCalendarItem =
          _buildCalendarItem(this.tutorialViewData.deviceCalendarViewData);
//      listChildren.add(deviceCalendarItem);
      actualSources.add(deviceCalendarItem);

      for (TaskSourceViewItem taskSourceViewItem
          in this.tutorialViewData.taskSourceViewItems.values) {
        Widget taskSourceItem = _buildTaskSourceItem(taskSourceViewItem);
//      listChildren.add(taskSourceItem);
        actualSources.add(taskSourceItem);
        listChildren
            .add(Column(key: fullSourcesDrawer, children: actualSources));
      }
    } else {
      print("${currentState.toString()}");
    }

    Widget sourcesList = ListView(children: listChildren);
    widgetList.add(Expanded(child: sourcesList));
    widgetList.add(footer);
    Widget header = _buildHeader();
    widgetList.insert(0, header);
    return Column(
      children: widgetList,
    );
  }

  Widget _buildHeader() {
    return Material(
        color: Colors.black,
        child: Padding(
          padding: EdgeInsets.only(top: 5, bottom: 5, left: 12, right: 4),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Sources",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Row(
                  children: <Widget>[
                    BlocListener<SourcesListBloc, SourcesListState>(
                      listener: (context, state) {
                        if (state is SourcesListSyncing) {
//                          controller.forward();
                        } else if (state is SourcesListLoaded) {
                          this.updateViewData(state.viewData);
                          if (!(this.viewData?.anySourcesSyncing() ?? true)) {
                            controller.stop();
                            controller.reset();
                          } else {
//                            controller.forward();
                          }
                        } else {
                          controller.stop();
                          controller.reset();
                        }
                      },
                      child: AnimatedSync(
                        key: syncSources,
                        animation: rotateAnimation,
                        callback: (sourcesListBloc.state is SourcesListSyncing)
                            ? null
                            : () {
                                controller.forward();
                                sourcesListBloc.add(SyncAll(this.viewData));
                              },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.settings, color: Colors.white),
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return BlocProvider(
                              create: (BuildContext context) =>
                                  SourcesSettingsBloc(),
                              child: SourcesSettingsPage());
                        })).then((var result) =>
                            sourcesListBloc.add(SourceSettingsChanged()));
                      },
                    )
                  ],
                ),
              ]),
        ));
  }

  Widget _buildFooter() {
    SourcesListViewData viewData;
    if (sourcesListBloc.state is SourcesListTutorial) {
      viewData = this.tutorialViewData;
    } else {
      viewData = this.viewData;
    }

    if (viewData != null && viewData.getSelectedItemsCount() > 0) {
      return Container(
        key: selectedFooter,
        color: Colors.black,
        child: Column(children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 15.0, bottom: 15),
            child: Text("${viewData.getSelectedItemsCount()} selected",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    style: TextButton.styleFrom(
                      primary: Colors.black,
                      backgroundColor: Colors.white,
                    ),
                    // color: Colors.white,
                    child: Text("Clear", style: TextStyle(color: Colors.black)),
                    onPressed: () {
                      setState(() {
                        viewData.clearSelections();
                      });
                    },
                  ),
                  TextButton(
                      style: TextButton.styleFrom(
                          primary: Colors.black, backgroundColor: Colors.white),
                      // color: Colors.white,
                      child: Text("Add",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                      onPressed: () {
                        sourcesListBloc.add(AddSelectionToPlan(viewData));
                        Navigator.pop(context);
                      })
                ]),
          )
        ]),
      );
    } else {
      return Container();
    }
  }

  Widget _buildCalendarItem(CalendarSourceViewItem sourceViewItem) {
    return !(sourceViewItem.isSetUp ?? false)
        ? Container()
        : ExpansionTile(
            key: calendarSource,
            //              leading: Image(image: AssetImage("assets/google_logo.png")),
            title: Row(children: <Widget>[
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.grey, width: 1.5)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 2.0, horizontal: 5.0),
                  child: Text(sourceViewItem.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
//                          decoration: TextDecoration.underline,
                        fontSize: 22,
                      )),
                ),
              ),
              //                  Checkbox(
              //                      value: false,
              //                      onChanged: (state) {
              //                        print("selectall from ${source["title"]} is now ${state ? "selected" : "not selected"}");
              //                      }
              //                  ),
              //                  Icon(Icons.settings)
            ]),
            onExpansionChanged: (bool newValue) {
              setState(() {
                sourceViewItem.expanded = newValue;
                _updateSourceExpansion(sourceViewItem.id, newValue);
              });
            },
            initiallyExpanded: sourceViewItem.expanded ?? true,
            children: sourceViewItem.isSetUp ?? false
                ? _buildCalendarViewsList(sourceViewItem.views)
//            : _buildUnSetUpViewSection(sourceViewItem.id));
                : [Container()]);
  }

  List<Widget> _buildUnSetUpViewSection(String sourceID) {
    return [
      OutlinedButton(
          child: Text("Set up"),
          onPressed: () {
            sourcesListBloc.add(SetUpSource(sourceID, this.viewData));
          })
    ];
  }

  List<Widget> _buildCalendarViewsList(List<CalendarViewViewItem> viewItems) {
    List<Widget> viewsList = [];
    bool first = true;
    for (var view in viewItems) {
      Widget newTile = Theme(
          data: ThemeData(
            accentColor: Colors.grey,
          ),
          child: ExpansionTile(
              key: PageStorageKey(
                  "${view.title + Random().nextInt(10000).toString()}"),
              title: Row(children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, top: 0.0, bottom: 0.0),
                  child: Text(view.title,
                      style: TextStyle(color: Colors.grey, fontSize: 18)),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (view.hasAllSelected()) {
                        view.clearSelections();
                      } else {
                        view.selectAllItems();
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 14.0, top: 2),
                    child: Badge(
                        key: first ? calendarBadge : GlobalKey(),
                        badgeContent: Row(
                          children: <Widget>[
                            Text(
                                view.items.length > 0
                                    ? '${view.getSelectedItemCount()} / ${view.items.length}'
                                    : '${view.items.length}',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                            Visibility(
                              visible: view.items.length > 0,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: Icon(
                                    view.hasAllSelected()
                                        ? Icons.clear
                                        : Icons.add,
                                    color: Colors.white,
                                    size: 22),
                              ),
                            )
                          ],
                        ),
                        badgeColor: view.hasSomeSelected()
                            ? Colors.black
                            : Colors.grey[350],
                        shape: BadgeShape.square,
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        elevation: 0,
                        toAnimate: false,
                        animationType: BadgeAnimationType.scale,
                        animationDuration: Duration(milliseconds: 100),
                        padding:
                            EdgeInsets.symmetric(vertical: 2, horizontal: 4)),
                  ),
                )
              ]),
              initiallyExpanded: view.expanded ?? true,
              onExpansionChanged: (bool newValue) {
                setState(() {
                  view.expanded = newValue;
                  //TODO: fix this once device calendars actually have dynamic views :\
//                  _updateViewExpansion(view.id, newValue);
                });
              },
              children: _buildEventItemViewsList(view.items)));
      first = false;
      viewsList.add(newTile);
    }
    return viewsList;
  }

  List<Widget> _buildEventItemViewsList(List<EventViewItem> items) {
    List<Widget> itemsList = [];
    var containerDecoration;

    for (var item in items) {
      Widget newTile = Container(
          decoration: containerDecoration,
          child: InkWell(
              onTap: () {
                setState(() {
                  item.selected = !item.selected;
                });
              },
              child: Row(children: <Widget>[
                Visibility(
                  visible: item.selected,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: Transform.rotate(
                    angle: 180 * pi / 180,
                    child: IconButton(
                        onPressed: () {
                          setState(() {
                            item.selected = !item.selected;
                          });
                        },
                        icon: Icon(Icons.exit_to_app, color: Colors.black)),
                  ),
                ),
//                    Checkbox(
//                      value: item.selected,
//                      onChanged: (bool newValue) {
//                        setState(() {
//                          item.selected = newValue;
//                        });
//                      }
//                    ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 0, right: 8.0, top: 8.0, bottom: 8.0),
                    child: Text(
                      item.getDisplayText(),
                      style: TextStyle(
                          color:
                              item.selected ? Colors.black : Colors.grey[850],
                          fontWeight: item.selected ? FontWeight.bold : null,
                          fontSize: 16),
                      maxLines: null,
                      softWrap: true,
                    ),
                  ),
                ),
              ])));
      itemsList.add(newTile);
    }
    itemsList.add(Padding(padding: EdgeInsets.only(bottom: 8.0)));
    return itemsList;
  }

  Widget _buildTaskSourceItem(TaskSourceViewItem sourceViewItem) {
    return !(sourceViewItem.isSetUp ?? false)
        ? Container()
        : ExpansionTile(
            //              leading: Image(image: AssetImage("assets/google_logo.png")),
            title: Row(children: <Widget>[
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.grey, width: 1.5)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 2.0, horizontal: 5.0),
                  child: Text(sourceViewItem.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
//                          decoration: TextDecoration.underline,
                        fontSize: 22,
                      )),
                ),
              ),
              //                  Checkbox(
              //                      value: false,
              //                      onChanged: (state) {
              //                        print("selectall from ${source["title"]} is now ${state ? "selected" : "not selected"}");
              //                      }
              //                  ),
              //                  Icon(Icons.settings)
            ]),
            onExpansionChanged: (bool newValue) {
              setState(() {
                sourceViewItem.expanded = newValue;
                _updateSourceExpansion(sourceViewItem.id, newValue);
              });
            },
            initiallyExpanded: sourceViewItem.expanded ?? true,
            children: sourceViewItem.isSetUp
                ? _buildTaskViewsList(sourceViewItem.id, sourceViewItem.views)
//            : _buildUnSetUpViewSection(sourceViewItem.id));
                : [Container()]);
  }

  List<Widget> _buildTaskViewsList(
      String sourceID, List<TaskViewViewItem> viewItems) {
    List<Widget> viewsList = [];

    for (TaskViewViewItem view in viewItems) {
      if (!view.visible) {
        continue;
      }
      Widget newTile = Theme(
          data: ThemeData(
            accentColor: Colors.grey,
          ),
          child: ExpansionTile(
            key: PageStorageKey(
                "${view.title + Random().nextInt(10000).toString()}"),
            title: Row(children: <Widget>[
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, top: 0.0, bottom: 0.0),
                  child: AutoSizeText(view.title,
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      minFontSize: 14,
                      style: TextStyle(
                          color: view.hasSomeSelected()
                              ? Colors.black
                              : Colors.grey,
                          fontSize: 18)),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (view.hasAllSelected()) {
                      view.clearSelections();
                    } else {
                      view.selectAllItems();
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 14.0, top: 2),
                  child: Badge(
                      badgeContent: Row(
                        children: <Widget>[
                          Text(
                              view.items.length > 0
                                  ? '${view.getSelectedItemCount()} / ${view.items.length}'
                                  : '${view.items.length}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          Visibility(
                            visible: view.items.length > 0,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: Icon(
                                  view.hasAllSelected()
                                      ? Icons.clear
                                      : Icons.add,
                                  color: Colors.white,
                                  size: 22),
                            ),
                          )
                        ],
                      ),
                      badgeColor: view.hasSomeSelected()
                          ? Colors.black
                          : Colors.grey[350],
                      shape: BadgeShape.square,
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      elevation: 0,
                      toAnimate: false,
                      animationType: BadgeAnimationType.scale,
                      animationDuration: Duration(milliseconds: 100),
                      padding:
                          EdgeInsets.symmetric(vertical: 2, horizontal: 4)),
                ),
              ),
              Visibility(
                visible: view.expanded,
                child: IconButton(
                    icon: Icon(MdiIcons.sortVariant, color: Colors.grey),
                    onPressed: () {
                      _selectSortType(view.sortedBy).then((SortType newType) {
                        setState(() {
                          view.sortedBy = newType ?? view.sortedBy;
                          sourcesListBloc.add(ViewSortTypeChanged(
                              view.id, view.sortedBy, sourceID));
                        });
//                          _updateViewSorting(view.id, newType);
                      });
                    }),
              )
            ]),
            initiallyExpanded: view.expanded ?? true,
            children: _buildTaskItemViewsList(
                _sortTaskViewItemsBy(view.items, view.sortedBy)),
            onExpansionChanged: (bool newValue) {
              setState(() {
                view.expanded = newValue;
                _updateViewExpansion(sourceID, view.id, newValue);
              });
            },
          ));
      viewsList.add(newTile);
    }

    return viewsList;
  }

  List<Widget> _buildTaskItemViewsList(List<TaskViewItem> items) {
    List<Widget> itemsList = [];
    var containerDecoration;
    for (var item in items) {
      Widget newTile = Container(
          key: GlobalKey(),
          decoration: containerDecoration,
          child: InkWell(
              onTap: () {
                setState(() {
                  item.selected = !item.selected;
                });
              },
              child: Row(children: <Widget>[
                Visibility(
                  visible: item.selected,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: Transform.rotate(
                    angle: 180 * pi / 180,
                    child: IconButton(
                        onPressed: () {},
//                                () {
////                              setState(() {
////                                item.selected = !item.selected;
////                              });
//                            },
                        icon: item.selected
                            ? Icon(Icons.exit_to_app, color: Colors.black)
                            : Icon(Icons.exit_to_app, color: Colors.grey[350])),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 0, right: 8.0, top: 8.0, bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          item.getDisplayText(),
                          style: TextStyle(
                              color: item.selected
                                  ? Colors.black
                                  : Colors.grey[850],
                              fontWeight:
                                  item.selected ? FontWeight.bold : null,
                              fontSize: 16),
                          maxLines: null,
                          softWrap: true,
                        ),
                        Visibility(
                          visible: item.dueDate != null,
                          child: Text("Due: ${item.getDueDateText()}",
                              style: TextStyle(
                                  color: item.selected
                                      ? Colors.black
                                      : Colors.grey[250],
                                  fontStyle: FontStyle.italic,
                                  fontWeight:
                                      item.selected ? FontWeight.bold : null,
                                  fontSize: 13)),
                        )
                      ],
                    ),
                  ),
                ),
              ])));
      itemsList.add(newTile);
    }
    itemsList.add(Padding(padding: EdgeInsets.only(bottom: 8.0)));
    return itemsList;
  }

  // call when something needs to be updated in persistence
  void _updateViewExpansion(String sourceID, String viewID, bool newValue) {
    sourcesListBloc.add(ViewExpansionChanged(viewID, newValue, sourceID));
  }

  void _updateSourceExpansion(String sourceID, bool newValue) {
    sourcesListBloc.add(SourceExpansionChanged(sourceID, newValue));
  }

  Future<SortType> _selectSortType(SortType currentlySelected) async {
    return showDialog<SortType>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
            title: Text('Sort by'),
            children: _buildSortDialogOptions(currentlySelected));
      },
    );
  }

  List<SimpleDialogOption> _buildSortDialogOptions(SortType currentlySelected) {
    return SortType.values
        .map((SortType type) => _buildSortDialogOption(type, currentlySelected))
        .toList();
  }

  SimpleDialogOption _buildSortDialogOption(
      SortType type, SortType currentlySelected) {
    String mainText = "";
    IconData icon;

    switch (type) {
      case SortType.DueDate_A:
        mainText = "Due date";
        icon = Icons.arrow_drop_up;
        break;
      case SortType.DueDate_D:
        mainText = "Due date";
        icon = Icons.arrow_drop_down;
        break;
      case SortType.Alphabetical_A:
        mainText = "Title";
        icon = Icons.arrow_drop_up;
        break;
      case SortType.Alphabetical_D:
        mainText = "Title";
        icon = Icons.arrow_drop_down;
        break;
      case SortType.Original:
        mainText = "Original";
        break;
    }

    return SimpleDialogOption(
        onPressed: type == currentlySelected
            ? null
            : () {
                Navigator.pop(context, type);
              },
        child: Row(children: <Widget>[
          Text(mainText,
              style: TextStyle(
                  color:
                      type == currentlySelected ? Colors.grey : Colors.black)),
          Visibility(
              visible: type != SortType.Original,
              child: Icon(icon ?? null,
                  color:
                      type == currentlySelected ? Colors.grey : Colors.black)),
          Visibility(
              visible: type == currentlySelected,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  "(currently selected)",
                  style: TextStyle(color: Colors.grey),
                ),
              ))
        ]));
  }

  List<TaskViewItem> _sortTaskViewItemsBy(
      List<TaskViewItem> items, SortType sortType) {
    switch (sortType) {
      case SortType.DueDate_A:
        items.sort((TaskViewItem a, TaskViewItem b) {
          if (a.dueDate == null && b.dueDate != null) {
            return 1;
          } else if (a.dueDate != null && b.dueDate == null) {
            return -1;
          } else if (a.dueDate == null && b.dueDate == null) {
            return 0;
          } else {
            return a.dueDate.isBefore(b.dueDate) ? -1 : 1;
          }
        });
        break;
      case SortType.DueDate_D:
        items.sort((TaskViewItem a, TaskViewItem b) {
          if (a.dueDate == null && b.dueDate != null) {
            return 1;
          } else if (a.dueDate != null && b.dueDate == null) {
            return -1;
          } else if (a.dueDate == null && b.dueDate == null) {
            return 0;
          } else {
            return a.dueDate.isAfter(b.dueDate) ? -1 : 1;
          }
        });
        break;
      case SortType.Alphabetical_A:
        items.sort((a, b) => a.text.compareTo(b.text));
        break;
      case SortType.Alphabetical_D:
        items.sort((a, b) => b.text.compareTo(a.text));
        break;
      case SortType.Original:
        items.sort((a, b) => a.position.compareTo(b.position));
        break;
    }

    return items;
  }
}
