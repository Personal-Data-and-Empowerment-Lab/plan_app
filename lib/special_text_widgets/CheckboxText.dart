import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/painting/inline_span.dart';
import 'package:flutter/src/painting/text_style.dart';
import 'package:planv3/blocs/bloc.dart';
import 'package:planv3/special_text_widgets/DateTextBuilder.dart';

import '../blocs/editor_bloc.dart';

class CheckboxText extends ValidatingSpecialText {
  final int start;
  final EditorBloc editorBloc;
  String flag = "";

  CheckboxText(
      this.flag, TextStyle textStyle, SpecialTextGestureTapCallback onTap,
      {this.start, this.editorBloc})
      : super(flag, " ", textStyle);

  @override
  InlineSpan finishText() {
    String checkboxText = toString();

    // BELOW IS PREVIOUS
    final double size = 24;
    return ImageSpan(
        AssetImage("assets/outline_check_box_outline_blank_black_48dp.png"),
        actualText: checkboxText,
        imageWidth: size,
        imageHeight: size,
        start: start,
        margin: EdgeInsets.only(right: 2),
        fit: BoxFit.fill,
        matchTextDirection: true, onTap: () {
      editorBloc.add(MarkCheckboxComplete(start, checkboxText));
    });
  }
}
