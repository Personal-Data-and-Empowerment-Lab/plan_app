import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planv3/blocs/SimpleBlocDelegate.dart';
import 'package:planv3/pages/EditorPage.dart';
import 'package:planv3/pages/IntroPage.dart';
import 'package:planv3/repositories/FileStoragePlansRepository.dart';
import 'package:planv3/repositories/PlansRepository.dart';
import 'package:planv3/utils/NotificationManager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'blocs/bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationManager.initializeNotifications();

  final PlansRepository localRepository = FileStoragePlansRepository();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  // use this line below to ensure skipping onboarding besides permissions
  await prefs.setBool("studyVersion", true);
  bool skipIntro = await _checkForIntro(prefs);
  // use this line below to make intro always appear if testing intro stuff
  // skipIntro = false;
  String userID = await _getUserID(prefs);
  BlocSupervisor.delegate = SimpleBlocDelegate(userID);
  runApp(skipIntro ? App(localRepository: localRepository) : IntroTestApp());
}

Future<bool> _checkForIntro(SharedPreferences prefs) async {
  try {
    bool introViewed = prefs.getBool('introViewed') ?? false;

    return introViewed;
  } catch (error) {
    print(error.toString());
    return null;
  }
}

Future<String> _getUserID(SharedPreferences prefs) async {
  try {} catch (error) {
    print(error.toString());
    return null;
  }

  String userID = prefs.getString("userID") ?? Uuid().v4();
  prefs.setString("userID", userID);
  return userID;
}

class App extends StatelessWidget {
  final PlansRepository localRepository;

  App({Key key, @required this.localRepository})
      : assert(localRepository != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'plan',
        home: BlocProvider(
            create: (context) => EditorBloc(localRepository: localRepository)
              ..add(LoadInitialPlan()),
            child: EditorPage()));
  }
}

class IntroTestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'plan',
      home: IntroPage(),
    );
  }
}
