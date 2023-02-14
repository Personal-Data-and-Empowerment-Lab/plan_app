import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CanvasTokenPage extends StatefulWidget {
  _CanvasTokenPageState createState() => _CanvasTokenPageState();
}

enum CanvasTutorialStep {
  Login,
  Settings,
  GenerateTokenFailed,
  TokenPage,
  CopyTokenFailed,
  TokenCopied
}

class _CanvasTokenPageState extends State<CanvasTokenPage> {
  final List<String> allowedUrls = [
    'https://utah.instructure.com/profile/settings',
    "https://utah.instructure.com/login",
    "https://utah.instructure.com/login/saml",
  ];
  WebViewController _webViewController;
  BuildContext _snackBarContext;

  String _token = "";
  bool _browserLoaded = false;
  TextStyle subtitleStyle = TextStyle(color: Colors.white);
  TextStyle titleStyle =
      TextStyle(color: Colors.white, fontWeight: FontWeight.bold);
  TextStyle buttonStyle =
      TextStyle(color: Colors.white, fontWeight: FontWeight.bold);
  TextStyle exitButtonStyle =
      TextStyle(color: Colors.red, fontWeight: FontWeight.bold);
  CanvasTutorialStep _currentStep = CanvasTutorialStep.Login;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }

  Future<void> _generateToken() async {
    await _webViewController.evaluateJavascript(
        "document.querySelector('.add_access_token_link').click()");
    // fill in info
    await _webViewController.evaluateJavascript(
        "document.querySelector('#access_token_purpose').value = 'plan'");
    // generate token
    await _webViewController.evaluateJavascript(
        "for (mySpan of document.querySelectorAll('span.ui-button-text')) {"
        "if (mySpan.innerText == 'Generate Token') {"
            "mySpan.parentElement.click();"
            "}"
            "}");
  }

//  Future<bool> _checkForToken() async {
//    String canvasToken = await _webViewController.evaluateJavascript(
//        ""
//            "let visible_token_objs = document.getElementsByClassName('visible_token');"
//            "let canvas_token_text = '';"
//            "if (visible_token_objs.length > 0) {"
//            " canvas_token_text = visible_token_objs[0].innerHTML;"
//            "}"
//            "canvas_token_text"
//
//    );
//
//  }

  Future<String> _extractToken() async {
    // extract token
    String canvasToken = await _webViewController.evaluateJavascript(""
        "let visible_token_objs = document.getElementsByClassName('visible_token');"
        "let canvas_token_text = '';"
        "if (visible_token_objs.length > 0) {"
        " canvas_token_text = visible_token_objs[0].innerHTML;"
        "}"
        "canvas_token_text");

    return canvasToken;
  }

  Widget _buildTutorialCard() {
    Widget stepContent;
    List<Widget> buttons = [];
    Widget exitButton = TextButton(
      child: Text("CANCEL", style: exitButtonStyle),
      onPressed: () {
        Navigator.pop(context, false);
      },
    );

    switch (this._currentStep) {
      case CanvasTutorialStep.Login:
        stepContent = Text("First, log in to canvas", style: subtitleStyle);
        buttons.add(exitButton);
//        buttons.add(FlatButton(
//          child: Text("I'M LOGGED IN", style: buttonStyle),
//          onPressed: () {
//            setState(() {
//              this._currentStep = CanvasTutorialStep.Settings;
//            });
//          }
//        ));
        break;
      case CanvasTutorialStep.Settings:
        stepContent = Text(
            "Next, we need your permission to generate a token to access your Canvas events and assignments."
                "\n\n"
                "If you agree, press ACCEPT.",
            style: subtitleStyle);
        buttons.add(exitButton);
        buttons.add(TextButton(
            child: Text("DENY", style: buttonStyle),
            onPressed: () {
              Navigator.pop(context, "");
            }));
        buttons.add(TextButton(
            child: Text("ACCEPT", style: buttonStyle),
            onPressed: () async {
              await _generateToken();
              setState(() {
                this._currentStep = CanvasTutorialStep.TokenPage;
              });
            }));

        break;
      case CanvasTutorialStep.GenerateTokenFailed:
      // TODO: Handle this case.
        break;
      case CanvasTutorialStep.TokenPage:
        stepContent = Text(
            "If you see your token info below, press FINISH to continue setting up Canvas.\n"
                "\nIf you do not see your token info, press TRY AGAIN.",
            style: subtitleStyle);
        buttons.add(exitButton);
        buttons.add(TextButton(
            child: Text("TRY AGAIN", style: buttonStyle),
            onPressed: () {
              // refresh page
              this._webViewController.reload();
            }));
        buttons.add(TextButton(
          child: Text("FINISH", style: buttonStyle),
          onPressed: () async {
            this._token = await this._extractToken();
            if (this._token.length < 25) {
              // the token isn't right
              _showSnackBar("The token couldn't be extracted.");
            } else {
              final storage = new FlutterSecureStorage();
              await storage.write(key: "canvasToken", value: this._token);
//              this._token = await storage.read(key: "canvasToken");
              Navigator.pop(context, true);
            }
          },
        ));
        break;
      case CanvasTutorialStep.CopyTokenFailed:
      // TODO: Handle this case.
        break;
      case CanvasTutorialStep.TokenCopied:
      // TODO: Handle this case.
        break;
    }

    return Card(
        color: Colors.black,
        child: ListTile(
//                    trailing: Icon(Icons.close, color: Colors.white),
            title: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text("Canvas Setup", style: titleStyle),
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  stepContent,
                  ButtonBar(
                    layoutBehavior: ButtonBarLayoutBehavior.constrained,
                    buttonTextTheme: ButtonTextTheme.normal,
                    children: buttons,
                    buttonPadding: EdgeInsets.only(bottom: 0, left: 8),
                  )
                ],
              ),
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: true,
        backgroundColor: Colors.grey[400],
        body: SafeArea(
          child: Builder(builder: (BuildContext context) {
            _snackBarContext = context;
            return Container(
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _buildTutorialCard(),
                  Visibility(
                    visible: !this._browserLoaded,
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: <Widget>[
                          CircularProgressIndicator(),
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Text("Loading Canvas"),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Visibility(
                      visible: this._browserLoaded,
                      maintainState: true,
                      child: WebView(
                        initialUrl:
                        'https://utah.instructure.com/profile/settings',
                        javascriptMode: JavascriptMode.unrestricted,
                        gestureNavigationEnabled: false,
                        onWebViewCreated: (controller) {
                          _webViewController = controller;
                        },
                        onPageStarted: (pageStarted) {
                          if (pageStarted ==
                              "https://utah.instructure.com/profile/settings") {
//                          _showSnackBar("started");
                          }
                        },
                        onPageFinished: (pageFinished) {
                          print("pageFinished");
                          print("$pageFinished");
                          setState(() {
                            this._browserLoaded = true;
                          });

                          if (pageFinished ==
                              "https://utah.instructure.com/profile/settings") {
                            setState(() {
                              this._currentStep = CanvasTutorialStep.Settings;
                            });
                          } else {
                            _webViewController.evaluateJavascript(""
                                "let footer = document.getElementsByTagName('footer');"
                                "if (footer.length > 0) {"
                                "footer[0].classList.remove('d-flex');"
                                "footer[0].style.display = 'none';"
                                "}");
                          }
                        },
                        javascriptChannels: <JavascriptChannel>[
                          _toasterJavascriptChannel(context)
                        ].toSet(),
                      ),
                    ),
                  ),
                ],
              ),
            );

//        return InAppWebView(
//          initialUrl: 'https://utah.instructure.com/profile/settings',
//
//        );
          }),
        ));
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(_snackBarContext)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
      name: 'Toaster',
      onMessageReceived: (JavascriptMessage message) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message.message)));
      },
    );
  }
}
