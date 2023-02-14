import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:planv3/blocs/bloc.dart';
import 'package:planv3/blocs/editor_bloc.dart';
import 'package:planv3/blocs/intro_permissions_bloc.dart';
import 'package:planv3/blocs/intro_survey_bloc.dart';
import 'package:planv3/repositories/FileStoragePlansRepository.dart';
import 'package:planv3/widgets/IntroPermissionsWidget.dart';
import 'package:planv3/widgets/IntroSourcesDemoWidget.dart';
import 'package:planv3/widgets/IntroSurveyWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'EditorPage.dart';

class IntroPage extends StatefulWidget {
  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  SharedPreferences prefs;
  final String consentText =
      '''The purpose of the study is to understand how students approach managing their time and how using custom software affects the process. This research is being done to provide insights into the time management needs of students and if technology might be able to be used to help meet those needs. Dr. Jason Wiese, an Assistant Professor at the University of Utah, is conducting this study.

  Participating by using the application
  If you agree to participate by using the application, anonymized usage logs about how you use the app will be sent automatically to our research team. Upon installing the application, some demographic questions regarding your age, gender, major, etc. will also be collected via a brief, in-app survey. Finally, you may receive brief, in-app surveys about how the application is helpful or unhelpful to your time management periodically as you use the application. You are free to use the application for as long as you wish, including after the study is over.

  Participating by using the application and completing an interview
  Some participants may be contacted by a member of our research team about completing a short interview. If that is the case, we will schedule a time to conduct an interview with you about your experience using the application and your planning practices.

  The interviews would take place remotely via video-conferencing software (Zoom). Video recordings of the interviews will be stored on password-protected computers and deleted at the conclusion of the study. Your name and any personal information will be stored separately from the interview transcripts. You will not be personally identified in any publications. The information collected about you for this study (e.g. contact information, name, etc.) will not be used for future research studies.

  For all participants
  There will be no costs to you for participating.

  The prototype application used will offer the ability for you to connect with digital calendars on your device, Google Tasks, and Canvas if you choose. If you choose to use these integrations, the application will have access to your data from these services, but will NOT share any of this data with members of our research team. Your data will remain locally on your device. The application will send usage logs of some of your activity to our research team through Google Analytics. This includes some metadata about your plans such as how many lines of text they contain, if items have assigned times, or how often you open the application. The data will not be personally identifiable.

  Your participation is completely voluntary. You can start the study and then choose to stop the study later. This will not affect your relationship with the investigator. This will also not be reported to your academic institution.

  The risks of this study are minimal. You may feel upset thinking about or talking about personal information related to accomplishing or failing to accomplish certain tasks. These risks are similar to those you experience when discussing personal information with others.

  We cannot promise any direct benefit for taking part in this study. However, possible benefits include an increased awareness of your personal time management practices and the reasons for them. You will also be allowed to keep a copy of the prototype software if you wish. We hope information we get from this study may help develop a greater understanding of the time management needs of students and what might be done to meet them in the future.

  If you have questions, complaints or concerns about this study, or if you feel you have been harmed as a result of participation you can contact Jason Wiese at 801-581-6711.

  Contact the Institutional Review Board (IRB) if you have questions regarding your rights as a research participant. Also, contact the IRB if you have questions, complaints or concerns which you do not feel you can discuss with the investigator. The University of Utah IRB may be reached by phone at (801) 581-3655 or by e-mail at irb@hsc.utah.edu.

  By using this application, you are giving your consent to participate in this research. Thank you for your willingness to participate!
  ''';
  bool _allowSwiping = true;
  bool _nextButtonShown = true;
  bool _consentGiven = false;
  bool _interviewConsentGiven = false;
  bool _studyVersion = false;

  final _introKey = GlobalKey<IntroductionScreenState>();

  Future<PermissionStatus> requestPermission(PermissionGroup permission) async {
    final List<PermissionGroup> permissions = <PermissionGroup>[permission];
    final Map<PermissionGroup, PermissionStatus> permissionRequestResult =
        await PermissionHandler().requestPermissions(permissions);
    return permissionRequestResult[permission];
  }

  @override
  void initState() {
    // set consent values
    SharedPreferences.getInstance().then((prefs) {
      this.prefs = prefs;
      setState(() {
        _consentGiven = this.prefs.getBool("consentGiven") ?? false;
        _interviewConsentGiven =
            this.prefs.getBool("interviewConsentGiven") ?? false;
        _studyVersion = this.prefs.getBool("studyVersion") ?? false;
      });
    });
    super.initState();
  }

  void _navigateToEditor(BuildContext context) {
    Navigator.of(context)
        .pushReplacement(new CupertinoPageRoute(builder: (context) {
      return BlocProvider(
          create: (context) {
            return EditorBloc(localRepository: FileStoragePlansRepository())
              ..add(LoadInitialPlan());
          },
          child: EditorPage());
    }));
  }

  @override
  Widget build(BuildContext context) {
    List<PageViewModel> pageViewModels = [];
    pageViewModels.add(PageViewModel(
        titleWidget: Padding(
          padding: const EdgeInsets.only(top: 32.0),
          child: Column(
            children: <Widget>[
              Text("plan",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 16),
                child: Text("a smart, connected editor for planning",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                    )),
              ),
//              Padding(
//                padding: const EdgeInsets.only(top: 16.0),
//                child: Text(
//                    "connect to your calendar, canvas, and task list",
//                    textAlign: TextAlign.center,
//                    style: TextStyle(
//                      fontSize: 20,
//                    )),
//              ),
              IntroSourcesDemoWidget()
            ],
          ),
        ),
        body: ""));
    //TEMPORARILY REMOVED THESE FOR ADDING CONSENT
    // PageViewModel(
    //     titleWidget: Padding(
    //       padding: const EdgeInsets.only(top: 32.0),
    //       child: Text("Add events and tasks directly from other apps",
    //           style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
    //     ),
    //     bodyWidget: Image.asset("assets/SourcesDemoTaps.gif",
    //         height: MediaQuery.of(context).size.height - 200)),
    // PageViewModel(
    //     titleWidget: Padding(
    //       padding: const EdgeInsets.only(top: 32.0),
    //       child: Text("Edit quickly with built-in shortcuts",
    //           style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
    //     ),
    //     bodyWidget: Image.asset("assets/EditingDemoTaps.gif",
    //         height: MediaQuery.of(context).size.height - 200)),

    // if study version, add the consent and demographic info collection
    if (_studyVersion) {
      pageViewModels.add(
        PageViewModel(
            title: "Consent to participate (scroll)",
            bodyWidget: Column(
              children: <Widget>[
                SelectableText(consentText),
                SizedBox(height: 40),
                Divider(height: 0, thickness: 2),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text("Summary",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline)),
                ),
                Text(
                    "1) Usage logs will be automatically collected and sent to our research team",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(
                    "2) Brief surveys about your experience using this app will be sent periodically",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(
                    "3) You may be invited to participate in an optional interview about your experience with the app",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                SelectableText("Questions? Contact john.r.lund@utah.edu",
                    style: TextStyle(fontSize: 16)),
                SizedBox(height: 20),
                Divider(height: 0, thickness: 2),
                SizedBox(height: 20),
                // SelectableText("Direct any questions or concerns about this information to john.r.lund@utah.edu ", style: TextStyle(fontSize: 16)),
                CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    value: _consentGiven,
                    selected: _consentGiven,
                    activeColor: Colors.green[800],
                    title: Text(
                        "I have read and understood the above information and agree to participate"),
                    onChanged: (newValue) async {
                      this.prefs =
                          this.prefs ?? await SharedPreferences.getInstance();
                      prefs.setBool("consentGiven", newValue);
                      setState(() {
                        _consentGiven = newValue;
                        _allowSwiping = _consentGiven;
                        _nextButtonShown = _consentGiven;
                      });
                    }),
                // CheckboxListTile(
                //     controlAffinity: ListTileControlAffinity.leading,
                //     value: _interviewConsentGiven,
                //     selected: _interviewConsentGiven,
                //     activeColor: Colors.green[800],
                //     // checkColor: Colors.green,
                //     title: Text(
                //         "I am willing to participate in 2 video interviews about my experience using this app (\$30.00 compensation) "),
                //     onChanged: (newValue) async {
                //       print("interviews value is $newValue");
                //       this.prefs =
                //           this.prefs ?? await SharedPreferences.getInstance();
                //       prefs.setBool("interviewConsentGiven", newValue);
                //       setState(() {
                //         _interviewConsentGiven = newValue;
                //       });
                //     }),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.black),
                  onPressed: !_consentGiven
                      ? null
                      : () {
                          _introKey.currentState.next();
                        },
                  child: Text("Next"),
                ),
                SizedBox(height: 20),
              ],
            )),
      );

      pageViewModels.add(PageViewModel(
          title: "A few questions",
          bodyWidget: BlocProvider(
              create: (BuildContext context) => IntroSurveyBloc(),
              child: IntroSurveyWidget(_introKey))));
    }

    pageViewModels.add(
      PageViewModel(
        titleWidget: Padding(
          padding: const EdgeInsets.only(top: 32.0),
          child: Text("Set up permissions",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),
        bodyWidget: BlocProvider(
            create: (BuildContext context) => IntroPermissionsBloc(),
            child: IntroPermissionsWidget()),
      ),
    );

    return Scaffold(
        body: SafeArea(
      child: IntroductionScreen(
        key: _introKey,
        isProgressTap: false,
        onChange: (int pageIndex) {
          switch (pageIndex) {
            // sources gif splashscreen
            case 0:
              setState(() {
                _allowSwiping = true;
                _nextButtonShown = true;
              });
              break;
            // in study version, this is consent page (default to whether or not consent's been given)
            // in other versions, this is permissions (default to yes swiping)
            case 1:
              setState(() {
                _allowSwiping = _studyVersion ? _consentGiven : true;
                _nextButtonShown = _studyVersion ? _consentGiven : true;
              });
              break;
            // in study version, this is survey page (default to no swiping)
            // in other version, this page is currently unused (default to true)
            case 2:
              setState(() {
                _allowSwiping = _studyVersion ? false : true;
                _nextButtonShown = _studyVersion ? false : true;
              });
              break;
            // in study version, this is permissions (default to yes swiping)
            // in other version, this page is currently unused (default to true)
            case 3:
              setState(() {
                _allowSwiping = _studyVersion ? false : true;
                _nextButtonShown = _studyVersion ? false : true;
              });
          }
        },
        pages: pageViewModels,
        skip: Text("Skip"),
        done: Text("Done"),
        next: Icon(Icons.navigate_next),
        showNextButton: _nextButtonShown,
        freeze: !_allowSwiping,
        showSkipButton: false,
        onDone: () {
          _checkForPermissions().then((bool granted) {
            if (granted) {
              _markIntroViewed();
              _navigateToEditor(context);
            } else {
              _showNeedPermissionsAlert(context);
            }
          });
        },
        onSkip: () {
          _markIntroViewed();
          _navigateToEditor(context);
        },
        dotsDecorator: DotsDecorator(
            size: const Size.square(10.0),
            activeSize: const Size(20.0, 10.0),
            activeColor: Colors.black,
            color: Colors.black26,
            spacing: const EdgeInsets.symmetric(horizontal: 3.0),
            activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0))),
      ),
    ));
  }

  void _markIntroViewed() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('introViewed', true);
  }

  Future<bool> _checkForPermissions() async {
    List<PermissionGroup> requiredPermissions = [
      PermissionGroup.storage,
    ];

    for (PermissionGroup permissionGroup in requiredPermissions) {
      if (!(await isPermissionGranted(permissionGroup))) {
        return false;
      }
    }

    return true;
  }

  Future<bool> isPermissionGranted(PermissionGroup permission) async {
    var status = await PermissionHandler().checkPermissionStatus(permission);
    return status == PermissionStatus.granted;
  }

  void _showNeedPermissionsAlert(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("You're missing permissions!"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Required permissions that need to be approved have this icon next to them:'),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Icon(Icons.warning, color: Colors.red),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
