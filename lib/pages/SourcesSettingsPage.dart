import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planv3/blocs/bloc.dart';
import 'package:planv3/blocs/sources_settings_bloc.dart';
import 'package:planv3/blocs/task_source_view_settings_bloc.dart';
import 'package:planv3/models/CalendarSourceSettingsViewItem.dart';
import 'package:planv3/models/SnackBarData.dart';
import 'package:planv3/models/TaskSourceSettingsViewItem.dart';

import 'CalendarSourceViewSettingsPage.dart';
import 'CanvasTokenPage.dart';
import 'TaskSourceViewSettingsPage.dart';

class SourcesSettingsPage extends StatefulWidget {
  SourcesSettingsPageState createState() => SourcesSettingsPageState();
}

class SourcesSettingsPageState extends State<SourcesSettingsPage> {
  SourcesSettingsBloc sourcesSettingsBloc;
  Map _viewItemCache = Map();

  String _token = "";

  @override
  void initState() {
    super.initState();

    sourcesSettingsBloc = BlocProvider.of<SourcesSettingsBloc>(context);
  }

  @override
  void dispose() {
    sourcesSettingsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
        appBar: AppBar(
          title:
              Text("Sources Settings", style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          actionsIconTheme: IconThemeData(color: Colors.black),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: BlocListener<SourcesSettingsBloc, SourcesSettingsState>(
          listener: (context, state) {
            if (state is DisplayingSourcesSettingsErrorMessage) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.messageData.messageText),
                  action: state.messageData.hasActionData()
                      ? SnackBarAction(
                          label: state.messageData.actionLabel,
                          onPressed: state.messageData.onPressed)
                      : null));
            } else if (state is SettingUpCanvas) {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return CanvasTokenPage();
              })).then((success) {
                if (success ?? false) {
                  sourcesSettingsBloc.add(ShowSourcesSettingsError(SnackBarData(
                      messageText: "Your token has been stored securely.")));
                  sourcesSettingsBloc.add(SetUpSourceSettings("canvas_tasks"));
                } else {
                  sourcesSettingsBloc.add(ShowSourcesSettingsError(SnackBarData(
                      messageText: "Canvas setup was cancelled.")));
                  sourcesSettingsBloc.add(SourceSetupCancelled("canvas_tasks"));
                }
              });
            } else if (state is OpeningCalendarSourceViewSettings) {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return BlocProvider(
                  create: (BuildContext context) =>
                      CalendarSourceViewSettingsBloc(),
                  child: CalendarSourceViewSettingsPage(),
                );
              })).then((var result) {
                sourcesSettingsBloc.add(ViewSettingsChanged());
              });
            } else if (state is OpeningTaskSourceViewSettings) {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return BlocProvider(
                  create: (BuildContext context) =>
                      TaskSourceViewSettingsBloc(state.taskSource),
                  child: TaskSourceViewSettingsPage(),
                );
              })).then((var result) {
                sourcesSettingsBloc.add(ViewSettingsChanged());
              });
            }
          },
          child: SafeArea(
            child: BlocBuilder<SourcesSettingsBloc, SourcesSettingsState>(
                builder: (context, state) {
              return Column(
                children: _mapStateToView(),
              );
            }),
          ),
        ));
  }

  List<Widget> _mapStateToView() {
    SourcesSettingsState currentState = sourcesSettingsBloc.state;
    List<Widget> returnWidgetList = [];

    // if state is initial, just show nothing
    if (currentState is InitialSourcesSettingsState) {
      returnWidgetList.add(Container());
    } else if (currentState is SourcesSettingsLoaded) {
      returnWidgetList.addAll(_mapSourcesSettingsLoadedToView(currentState));

      if (this._token != "") {
        returnWidgetList
            .add(TextButton(child: Text(this._token), onPressed: () {}));
      }
    } else {
      returnWidgetList.add(Text(
          "Currently in an unknown state...welcome to the twilight zone :/"));
    }

    return returnWidgetList;
  }

  List<Widget> _mapSourcesSettingsLoadedToView(SourcesSettingsLoaded state) {
    List<Widget> returnWidgetList = [];
    ListTile header = ListTile(
      title: Text("Source"),
      trailing: Text("Show in drawer"),
    );
    returnWidgetList.add(header);

    // update the local cache
    for (var sourceSettingsViewItem in state.sourceViews) {
      this._viewItemCache[sourceSettingsViewItem.id] = sourceSettingsViewItem;
    }

    // update the widget from the cache
    for (var sourceSettingsViewItem in _viewItemCache.values) {
      if (sourceSettingsViewItem is CalendarSourceSettingsViewItem) {
        returnWidgetList.add(
            _buildCalendarSourceSettingsViewWidget(sourceSettingsViewItem));
      } else if (sourceSettingsViewItem is TaskSourceSettingsViewItem) {
        returnWidgetList
            .add(_buildTaskSourceSettingsViewWidget(sourceSettingsViewItem));
      } else {
        throw Exception("Don't recognize the type of view item this is: "
            "${sourceSettingsViewItem.runtimeType}");
      }
    }

    return returnWidgetList;
  }

  Widget _buildCalendarSourceSettingsViewWidget(
      CalendarSourceSettingsViewItem viewItem) {
    return Card(
      child: SwitchListTile(
        contentPadding: EdgeInsets.only(top: 8, left: 16, right: 16),
        value: viewItem.isVisible ?? false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(Icons.smartphone,
                  color:
                      viewItem.isSetUp ?? false ? Colors.black : Colors.grey),
            ),
            Text(viewItem.title,
                style: TextStyle(
                    color:
                        viewItem.isSetUp ?? false ? Colors.black : Colors.grey,
                    fontSize: 22,
                    fontWeight: FontWeight.bold))
          ],
        ),
        subtitle: Row(children: [
          _buildSourceSettingsActionButton(viewItem),
        ]),
        onChanged: viewItem.isSetUp ?? false
            ? (bool newValue) {
                setState(() {
                  viewItem.isVisible = newValue;
                  sourcesSettingsBloc
                      .add(SourceVisibilityChanged(viewItem.id, newValue));
                });
              }
            : null,
      ),
    );
  }

  Widget _buildTaskSourceSettingsViewWidget(
      TaskSourceSettingsViewItem viewItem) {
    return Card(
      child: SwitchListTile(
        contentPadding: EdgeInsets.only(top: 8, left: 16, right: 16),
        value: viewItem.isVisible ?? false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(Icons.check_circle,
                  color:
                      viewItem.isSetUp ?? false ? Colors.black : Colors.grey),
            ),
            Text(viewItem.title,
                style: TextStyle(
                    color:
                        viewItem.isSetUp ?? false ? Colors.black : Colors.grey,
                    fontSize: 22,
                    fontWeight: FontWeight.bold))
          ],
        ),
        subtitle: Row(
          children: <Widget>[
            _buildSourceSettingsActionButton(viewItem),
          ],
        ),
        onChanged: viewItem.isSetUp ?? false
            ? (bool newValue) {
                setState(() {
                  viewItem.isVisible = newValue;
                  sourcesSettingsBloc
                      .add(SourceVisibilityChanged(viewItem.id, newValue));
                });
              }
            : null,
      ),
    );
  }

  Widget _buildSourceSettingsActionButton(var sourceViewData) {
    bool isSetUp;
    bool isSyncing;
    bool isSettingUp;

    if (sourceViewData is CalendarSourceSettingsViewItem ||
        sourceViewData is TaskSourceSettingsViewItem) {
      isSetUp = sourceViewData.isSetUp ?? false;
      isSyncing = sourceViewData.isSyncing ?? false;
      isSettingUp = sourceViewData.isSettingUp ?? false;
    } else {
      throw Exception(
          "sourceViewData is not a Calendar or Task source item. It's a "
          "${sourceViewData.runtimeType}");
    }

    if (isSetUp) {
      if (isSyncing) {
        return TextButton(
            child: Text("Syncing... (tap to cancel)",
                style: TextStyle(color: Colors.grey)),
            onPressed: () {
              sourcesSettingsBloc.add(SourceSyncCancelled(sourceViewData.id));
            });
      } else {
        return TextButton(
            child: Text("Manage views", style: TextStyle(color: Colors.black)),
            onPressed: () {
              sourcesSettingsBloc.add(ManageViews(sourceViewData.id));
            });
      }
    } else {
      if (isSettingUp) {
        return TextButton(
            child: Text("Setting up... (tap to cancel)"),
            onPressed: () {
              sourcesSettingsBloc.add(SourceSetupCancelled(sourceViewData.id));
            });
      } else {
        return OutlinedButton(
            child: Text("Set up", style: TextStyle(color: Colors.black)),
            onPressed: () {
              sourcesSettingsBloc.add(SetUpSourceSettings(sourceViewData.id));
            });
      }
    }
  }
}
