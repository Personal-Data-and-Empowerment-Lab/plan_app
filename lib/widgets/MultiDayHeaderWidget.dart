import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planv3/blocs/multiday_view_bloc.dart';
import 'package:planv3/blocs/multiday_view_event.dart';
import 'package:planv3/models/Plan.dart';

class MultiDayHeaderWidget extends StatefulWidget {
  @override
  _MultiDayHeaderWidgetState createState() => _MultiDayHeaderWidgetState();
}

class _MultiDayHeaderWidgetState extends State<MultiDayHeaderWidget> {
  @override
  Widget build(BuildContext context) {
    // closed by parent widget
    // ignore: close_sinks
    var mdvBloc = BlocProvider.of<MultiDayViewBloc>(context);

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
                              var current = mdvBloc.plans[0].date;
                              HapticFeedback.lightImpact();
                              mdvBloc.add(StartDateChanged(DateTime(
                                  current.year,
                                  current.month,
                                  current.day - 7)));
                            }),
                      ),
                      _mapStateToDateText(
                          BlocProvider.of<MultiDayViewBloc>(context)),
                      Tooltip(
                        message: "Next",
                        child: IconButton(
                            icon: Icon(Icons.chevron_right),
                            onPressed: () {
                              var current = mdvBloc.plans[0].date;
                              HapticFeedback.lightImpact();
                              mdvBloc.add(StartDateChanged(DateTime(
                                  current.year,
                                  current.month,
                                  current.day + 7)));
                            }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ]),
    );
  }

  _mapStateToDateText(MultiDayViewBloc multiDayBloc) {
    if (multiDayBloc.plans.length == 0) {
      return;
    }

    Plan startPlan = multiDayBloc.plans.first;
    Plan endPlan = multiDayBloc.plans.last;
    return Container(
      width: 175,
      padding: EdgeInsets.symmetric(horizontal: 3.0),
      child: Column(
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0),
              child: Text(
                  '${startPlan.getWeekdayText()} - ${endPlan.getWeekdayText()}',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 28,
                      fontWeight: FontWeight.bold))),
          Text(
              '${startPlan.getMonthAndDayText()} - ${endPlan.getMonthAndDayText()}',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.normal))
        ],
      ),
    );
  }
}
