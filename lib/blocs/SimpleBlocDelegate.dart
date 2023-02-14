import 'dart:io';

import 'package:f_logs/f_logs.dart';
import 'package:f_logs/model/flog/flog.dart';
import 'package:f_logs/model/flog/flog_config.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:planv3/blocs/bloc.dart';
import 'package:planv3/blocs/intro_permissions_bloc.dart';
import 'package:planv3/utils/GoogleAnalyticsEvent.dart';
import 'package:sembast/sembast.dart';

class SimpleBlocDelegate extends BlocDelegate {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);
  static int savePlanCounter = 0;
  final String userID;
  static LogsConfig config = LogsConfig()
    ..isDebuggable = true
    ..isDevelopmentDebuggingEnabled = true
    // ..customClosingDivider = "|"
    // ..customOpeningDivider = "|"
    ..csvDelimiter = ", "
    ..isLogsEnabled = true
    ..encryptionEnabled = false
    ..encryptionKey = "123"
    ..formatType = FormatType.FORMAT_CSV
    ..timestampFormat = TimestampFormat.TIME_FORMAT_FULL_2;

  SimpleBlocDelegate(this.userID) {
    FLog.applyConfigurations(config);
    analytics.setUserId(this.userID);
  }

  List<Type> eventsToIgnore = [
    EditText,
    SavePlan,
    PlanLoaded,
    AddSourceItemsToPlan,
    SaveSourcesListLayout,
    SourceExpansionChanged,
    ViewExpansionChanged,
    LoadPermissions
  ];

  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    if (!eventsToIgnore.contains(event.runtimeType)) {
      GoogleAnalyticsEvent analyticsEvent =
          GoogleAnalyticsEventAdapter.convertToEvent(bloc, event, this.userID);
//      analytics.logEvent(
//          name: analyticsEvent.name,
//          parameters: analyticsEvent.parameters
//      );
      logEvent(analyticsEvent);
    }

    if (bloc is EditorBloc && !(event is EditText)) {
      print("Event: $event");
    } else if (!(bloc is EditorBloc)) {
      print("Event: $event");
    }

    // This probably isn't the best way to do this
    if (event is ExportLogs) {}
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    // print("Transition: $transition");
    if (bloc is EditorBloc) {
      if (transition.currentState is ActiveEditing &&
          transition.nextState is ActiveEditing) {
        _onActiveEditingTransition(
            bloc, transition.currentState, transition.nextState);
      }
    }
//    print('onTransition $transition');
  }

  void _onActiveEditingTransition(EditorBloc editorBloc,
      ActiveEditing currentState, ActiveEditing nextState) {
    if (currentState.plan.planText != nextState.plan.planText ||
        currentState.plan.date != nextState.plan.date) {
      print("saving plan for ${nextState.plan.getDateMainText()}");
      editorBloc.add(SavePlan());
      savePlanCounter = (savePlanCounter + 1) % 5;
      if (savePlanCounter == 4) {
//        Map<String, dynamic> parameters = Map();
//        String content = nextState.plan.toString();
//        if (content.length > 99) {
//          content = content.substring(0,99);
//        }
//        parameters["content"] = content;
//        parameters["timestamp"] = DateTime.now().toString();
//        analytics.logEvent(
//            name: "BufferedEditText",
//            parameters: parameters
//        );
        GoogleAnalyticsEvent analyticsEvent =
            GoogleAnalyticsEventAdapter.buildPlanSnapshotLocal(
                nextState, this.userID);
        logEvent(analyticsEvent);

//        analytics.logEvent(name: analyticsEvent.name, parameters: analyticsEvent.parameters);

      }
    }
  }

  void logEvent(GoogleAnalyticsEvent event) async {
    // build analytics event

    // log to Google Analytics
    // TODO: turn back on if we want to use google analytics
    // analytics.logEvent(name: event.name, parameters: event.parameters);
    // save locally
    FLog.logThis(
      text: event.parameters.toString(),
      type: LogLevel.INFO,
      methodName: event.name,
    );

    int startTimeInMillis =
        DateTime.now().subtract(Duration(days: 300)).millisecondsSinceEpoch;
    Filter timestampFilter =
        Filter.lessThan(DBConstants.FIELD_TIME_IN_MILLIS, startTimeInMillis);
//    FLog.printLogs();
    try {
      FLog.deleteAllLogsByFilter(filters: [timestampFilter]).then((var result) {
//        FLog.printLogs();
//         exportLogs();
      });
    } catch (error) {
      print(error.toString().toUpperCase());
    }
  }

  void exportLogs() async {
    List<Log> logs = await FLog.getAllLogs();
    var buffer = StringBuffer();

    if (logs.length > 0) {
      logs.forEach((log) {
        buffer.write(Formatter.format(log, config));
      });
      String bufferString = buffer.toString();
      final directory = await getTemporaryDirectory();
      final path = directory.path;
      String dateString = _readableDateText(DateTime.now());
      File file = File('$path/logs_user_${userID}_date_$dateString.txt');
      await file.writeAsString(bufferString);

      StorageReference storageReference = FirebaseStorage.instance
          .ref()
          .child('user_$userID/logs_date_$dateString.txt');
      StorageUploadTask uploadTask = storageReference.putFile(file);
      try {
        await uploadTask.onComplete;
      } catch (error) {
        print(error);
        print("stop");
      }
    } else {
      // print("No logs found!");
    }
    buffer.clear();
  }

  String _readableDateText(DateTime date) {
    return date.year.toString() +
        "_" +
        date.month.toString().padLeft(2, '0') +
        "_" +
        date.day.toString().padLeft(2, '0');
  }
}
