import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planv3/blocs/bloc.dart';
import 'package:planv3/pages/view_settings_page_support/CalendarViewSettingsViewItem.dart';

class CalendarSourceViewSettingsPage extends StatefulWidget {
  CalendarSourceViewSettingsPageState createState() =>
      CalendarSourceViewSettingsPageState();
}

class CalendarSourceViewSettingsPageState
    extends State<CalendarSourceViewSettingsPage> {
  CalendarSourceViewSettingsBloc calendarSourceViewSettingsBloc;

  @override
  void initState() {
    calendarSourceViewSettingsBloc =
        BlocProvider.of<CalendarSourceViewSettingsBloc>(context);
    super.initState();
  }

  @override
  void dispose() {
    calendarSourceViewSettingsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: BlocBuilder<CalendarSourceViewSettingsBloc,
              CalendarSourceViewSettingsState>(builder: (context, state) {
            if (state is CalendarViewSettingsLoaded) {
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
        body: SafeArea(child: BlocBuilder<CalendarSourceViewSettingsBloc,
            CalendarSourceViewSettingsState>(builder: (context, state) {
          return ListView(
            children: _mapStateToView(),
          );
        })));
  }

  List<Widget> _mapStateToView() {
    List<Widget> returnWidgetList = [];
    CalendarSourceViewSettingsState currentState =
        calendarSourceViewSettingsBloc.state;

    if (currentState is InitialCalendarSourceViewSettingsState) {
      returnWidgetList.add(Container());
    } else if (currentState is CalendarViewSettingsLoaded) {
      returnWidgetList
          .addAll(_mapCalendarViewSettingsLoadedToView(currentState));
    } else {
      returnWidgetList.add(Text(
          "Currently in an unknown state called: $currentState. Welcome to the twilight zone :/"));
    }
    return returnWidgetList;
  }

  List<Widget> _mapCalendarViewSettingsLoadedToView(
      CalendarViewSettingsLoaded state) {
    List<Widget> returnWidgetList = [];
    ListTile header =
        ListTile(title: Text("Calendar"), trailing: Text("Show in drawer"));
    returnWidgetList.add(header);

    for (CalendarViewSettingsViewItem viewSettingsItem
        in state.viewData.viewSettings) {
      returnWidgetList
          .add(_buildCalendarViewSettingsViewWidget(viewSettingsItem));
    }

    return returnWidgetList;
  }

  Widget _buildCalendarViewSettingsViewWidget(
      CalendarViewSettingsViewItem viewSettingsItem) {
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
                calendarSourceViewSettingsBloc.add(
                    CalendarViewVisibilityChanged(
                        viewSettingsItem.id, newValue));
              });
            }));
  }
}
