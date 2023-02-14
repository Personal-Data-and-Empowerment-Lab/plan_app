import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/painting/text_style.dart';
import 'package:planv3/blocs/bloc.dart';
import 'package:planv3/special_text_widgets/CheckboxText.dart';
import 'package:planv3/special_text_widgets/CompletedCheckboxText.dart';
import 'package:planv3/special_text_widgets/DateText.dart';
import 'package:planv3/utils/PlanParser.dart';

import '../blocs/editor_bloc.dart';

/// I copied this class from extended_text_field (package)'s special_text_span_builder
/// class to add some custom functionality (allowing for validation of text between
/// start and endFlag. This works, but means if there are issues you should check to
/// see if the package's implementation of SpecialTextSpanBuilder has changed -
/// specifically the `build` function

abstract class ValidatingSpecialText extends SpecialText {
  ValidatingSpecialText(String startFlag, String endFlag, TextStyle textStyle)
      : super(startFlag, endFlag, textStyle);

  /// allows for validation of text in between startFlag and endFlag.
  /// Defaults to any content being invalid.
  bool isValidContent() {
    return getContent() == null || getContent().length == 0;
  }
}

class DateTextSpanBuilder extends SpecialTextSpanBuilder {
  /// whether show background for @somebody
  final EditorBloc bloc;
  DateTextSpanBuilder({this.bloc});

  @override
  SpecialText createSpecialText(String flag,
      {TextStyle textStyle,
      SpecialTextGestureTapCallback onTap,
      @required int index}) {
    if (flag == null || flag == "") return null;

//    if (startDateOnlyPattern.hasMatch(flag)) {
//      print("got a match!");
//      RegExpMatch match = startDateOnlyPattern.firstMatch(flag);
//      String tempFlag = match.group(1).trim();
//      print(tempFlag);
//      print("flag: $flag");
//      print(index);
//      return DateText(tempFlag, textStyle, onTap, start: index - (tempFlag.length - 1));
//    }
    if (PlanParser.getFlag(PlanParser.startAndEndTimeFlagRegex, flag) != null) {
      String tempFlag =
          PlanParser.getFlag(PlanParser.startAndEndTimeFlagRegex, flag);
      return DateText(tempFlag, textStyle, onTap,
          start: index - (tempFlag.length - 1));
    }
//    else if (PlanParser.getFlag(PlanParser.endTimeFlagRegex, flag) != null) {
//      String tempFlag = PlanParser.getFlag(PlanParser.endTimeFlagRegex, flag);
//      return DateText(tempFlag, textStyle, onTap, start: index - (tempFlag.length - 1));
//    }
    else if (PlanParser.getFlag(PlanParser.startTimeFlagRegex, flag) != null) {
      String tempFlag = PlanParser.getFlag(PlanParser.startTimeFlagRegex, flag);
      return DateText(tempFlag, textStyle, onTap,
          start: index - (tempFlag.length - 1));
    } else if (PlanParser.getFlag(PlanParser.checkboxFlagRegex, flag) != null) {
      String tempFlag = PlanParser.getFlag(PlanParser.checkboxFlagRegex, flag);

      return CheckboxText(tempFlag, textStyle, onTap,
          start: index - (tempFlag.length - 1), editorBloc: bloc);
    } else if (PlanParser.getFlag(
            PlanParser.completedCheckboxFlagRegex, flag) !=
        null) {
      String tempFlag =
          PlanParser.getFlag(PlanParser.completedCheckboxFlagRegex, flag);

      return CompletedCheckboxText(tempFlag, textStyle, onTap,
          start: index - (tempFlag.length - 1), editorBloc: bloc);
    }
//    else if (isStart(flag, "\u2611")) {
//      String tempFlag = "\u2611";
//      return CompletedCheckboxText(tempFlag, textStyle, onTap, start: index - (tempFlag.length - 1), editorBloc: bloc);
//    }
//    else if (isStart(flag, "[ ]")) {
//      String tempFlag = "[ ]";
//      return CheckboxText(tempFlag, textStyle, onTap, start: index - (tempFlag.length - 1), editorBloc: bloc);
//    }

//    if (isStart(flag, DateText.flag)) {
//      return DateText(textStyle, onTap, start: index - (DateText.flag.length - 1));
//    }
    return null;
  }

  TextSpan build(String data,
      {TextStyle textStyle, SpecialTextGestureTapCallback onTap}) {
    try {
      if (data == null || data == "") {
        return const TextSpan(text: '');
      }

      List<InlineSpan> inlineList = <InlineSpan>[];
      if (data.length > 0) {
        ValidatingSpecialText specialText;
        String textStack = "";
        //String text
        for (int i = 0; i < data.length; i++) {
          String char = data[i];
          textStack += char;
          if (specialText != null) {
            if (!specialText.isEnd(textStack)) {
              //validate content
              // add character to content
              specialText.appendContent(char);
              bool isValid = specialText.isValidContent();
              //if valid content
              if (isValid) {
              }
              //if not valid
              else {
                //special text is null
                //put text so far back on stack
//                print("content not good!");
                textStack = specialText.startFlag + specialText.getContent();
                specialText = null;
              }
            } else {
              inlineList.add(specialText.finishText());
              specialText = null;
              textStack = "";
            }
          } else {
            // try to build special text
            specialText = createSpecialText(textStack,
                textStyle: textStyle, onTap: onTap, index: i);
            if (specialText != null) {
              if (textStack.length - specialText.startFlag.length >= 0) {
                textStack = textStack.substring(
                    0, textStack.length - specialText.startFlag.length);
                if (textStack.length > 0) {
                  inlineList.add(TextSpan(text: textStack, style: textStyle));
                }
              }
              textStack = "";
            }
          }
        } // end for loop

        if (specialText != null) {
          inlineList.add(TextSpan(
              text: specialText.startFlag + specialText.getContent(),
              style: textStyle));
        } else if (textStack.length > 0) {
          inlineList.add(TextSpan(text: textStack, style: textStyle));
        }
      } else {
        inlineList.add(TextSpan(text: data, style: textStyle));
      }

      return TextSpan(children: inlineList, style: textStyle);
    } catch (error) {
      print("ERROR: ${error.toString()}");
    }
  }
}
