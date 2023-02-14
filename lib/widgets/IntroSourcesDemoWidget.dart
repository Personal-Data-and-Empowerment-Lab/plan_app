import 'package:flutter/material.dart';

class IntroSourcesDemoWidget extends StatefulWidget {
  @override
  IntroSourcesDemoWidgetState createState() => IntroSourcesDemoWidgetState();
}

class IntroSourcesDemoWidgetState extends State<IntroSourcesDemoWidget> {
  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      child: Image.asset(
        "assets/SourcesDemoAnimationFaster.gif",
        width: MediaQuery.of(context).size.width,
//          height: MediaQuery.of(context).size.height ,
      ),
    );
  }
}
