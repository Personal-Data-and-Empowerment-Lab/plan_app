import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planv3/blocs/task_source_view_settings_bloc.dart';
import 'package:planv3/pages/view_settings_page_support/TaskViewSettingsViewItem.dart';

class TaskSourceViewSettingsPage extends StatefulWidget {
  TaskSourceViewSettingsPageState createState() =>
      TaskSourceViewSettingsPageState();
}

class TaskSourceViewSettingsPageState
    extends State<TaskSourceViewSettingsPage> {
  TaskSourceViewSettingsBloc taskSourceViewSettingsBloc;

  @override
  void initState() {
    taskSourceViewSettingsBloc =
        BlocProvider.of<TaskSourceViewSettingsBloc>(context);
    super.initState();
  }

  @override
  void dispose() {
    taskSourceViewSettingsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: BlocBuilder<TaskSourceViewSettingsBloc,
              TaskSourceViewSettingsState>(builder: (context, state) {
            if (state is TaskViewSettingsLoaded) {
              return Text(state.viewData.title + " View Settings",
                  style: TextStyle(color: Colors.black));
            } else {
              return Text("View Settings",
                  style: TextStyle(color: Colors.black));
            }
          }),
          backgroundColor: Colors.white,
          actionsIconTheme: IconThemeData(color: Colors.black),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: SafeArea(child: BlocBuilder<TaskSourceViewSettingsBloc,
            TaskSourceViewSettingsState>(builder: (context, state) {
          return ListView(
            children: _mapStateToView(),
          );
        })));
  }

  List<Widget> _mapStateToView() {
    List<Widget> returnWidgetList = [];
    TaskSourceViewSettingsState currentState = taskSourceViewSettingsBloc.state;

    if (currentState is TaskSourceViewSettingsInitial) {
      returnWidgetList.add(Container());
    } else if (currentState is TaskViewSettingsLoaded) {
      returnWidgetList.addAll(_mapTaskViewSettingsLoadedToView(currentState));
    } else {
      returnWidgetList.add(Text(
          "Currently in an unknown state called: $currentState. Welcome to the twilight zone :/"));
    }
    return returnWidgetList;
  }

  List<Widget> _mapTaskViewSettingsLoadedToView(TaskViewSettingsLoaded state) {
    List<Widget> returnWidgetList = [];
    ListTile header =
        ListTile(title: Text("View"), trailing: Text("Show in drawer"));
    returnWidgetList.add(header);

    for (TaskViewSettingsViewItem viewSettingsItem
        in state.viewData.viewSettings) {
      returnWidgetList.add(_buildTaskViewSettingsViewWidget(viewSettingsItem));
    }

    return returnWidgetList;
  }

  Widget _buildTaskViewSettingsViewWidget(
      TaskViewSettingsViewItem viewSettingsItem) {
    return Card(
        child: SwitchListTile(
            contentPadding: EdgeInsets.only(top: 0, left: 16, right: 16),
            value: viewSettingsItem.visible,
            title: Text(viewSettingsItem.title,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            onChanged: (bool newValue) {
              setState(() {
                viewSettingsItem.visible = newValue;
                taskSourceViewSettingsBloc.add(
                    TaskViewVisibilityChanged(viewSettingsItem.id, newValue));
              });
            }));
  }
}
