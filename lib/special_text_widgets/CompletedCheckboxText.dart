import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/painting/inline_span.dart';
import 'package:flutter/src/painting/text_style.dart';
import 'package:planv3/blocs/bloc.dart';
import 'package:planv3/special_text_widgets/DateTextBuilder.dart';

class CompletedCheckboxText extends ValidatingSpecialText {
  final int start;
  final EditorBloc editorBloc;
  String flag = "";

  CompletedCheckboxText(
      this.flag, TextStyle textStyle, SpecialTextGestureTapCallback onTap,
      {this.start, this.editorBloc})
      : super(flag, " ", textStyle);

  @override
  bool isEnd(String value) {
//    String testText = "[ ] "

    return super.isEnd(value);
  }

  @override
  InlineSpan finishText() {
    String checkboxText = toString();

//    TextStyle style = textStyle.copyWith(
//      fontWeight: FontWeight.bold,
//      fontSize: textStyle.fontSize,
////      backgroundColor: Colors.black,
////      color: Colors.white,
//    );
//
//    return ExtendedWidgetSpan(
//      actualText: toString(),
//      start: start,
//      child: GestureDetector(
//        child: Text(
//            toString(),
//            style: style),
//        onTap: () {
//          editorBloc.add(MarkCheckboxIncomplete(start, toString()));
//        },
//      ),
//      deleteAll: false,
//    );

    final double size = 24;
    return ImageSpan(AssetImage("assets/baseline_check_box_black_48dp.png"),
        actualText: checkboxText,
        imageWidth: size,
        imageHeight: size,
        start: start,
        margin: EdgeInsets.only(right: 2),
        fit: BoxFit.fill,
        matchTextDirection: true, onTap: () {
      editorBloc.add(MarkCheckboxIncomplete(start, checkboxText));
    });

  }
}
