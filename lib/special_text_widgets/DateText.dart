import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/painting/inline_span.dart';
import 'package:planv3/special_text_widgets/DateTextBuilder.dart';
import 'package:planv3/utils/TimeParser.dart';

class DateText extends ValidatingSpecialText {
  final int start;
  String flag = "";

  DateText(this.flag, TextStyle textStyle, SpecialTextGestureTapCallback onTap,
      {this.start})
      : super(flag, ' ', textStyle);

  @override
  bool isValidContent() {
    String completeString = startFlag + getContent();
    return TimeParser.isValidTimeString(completeString);
  }

  @override
  InlineSpan finishText() {
    TextStyle textStyle = this.textStyle?.copyWith(fontWeight: FontWeight.bold);

    final String dateText = toString();

    return SpecialTextSpan(
        text: dateText,
        actualText: dateText,
        start: start,
        deleteAll: false,
        style: textStyle,
        recognizer: (TapGestureRecognizer()
          ..onTap = () {
            if (onTap != null) {
              onTap(dateText);
            }
          }));
  }
}
