import 'package:json_annotation/json_annotation.dart';

part 'TaskViewFilter.g.dart';

enum Operand { lessThan, lessThanEqual, equal, greaterThanEqual, greaterThan }

@JsonSerializable()
class TaskViewFilter {
  Operand operand;
  Duration duration;
  bool defaultValue;

  TaskViewFilter(this.operand, this.defaultValue);

  TaskViewFilter.withDaysFromNow(
      this.operand, int daysFromNow, this.defaultValue) {
    this.duration = Duration(days: daysFromNow);
  }

  factory TaskViewFilter.fromJson(Map<String, dynamic> json) =>
      _$TaskViewFilterFromJson(json);

  Map<String, dynamic> toJson() => _$TaskViewFilterToJson(this);

  String toDisplayText() {
    String displayText = "";
    switch (this.operand) {
      case Operand.lessThan:
        displayText += "due before";
        break;
      case Operand.lessThanEqual:
        displayText += "due before or on";
        break;
      case Operand.equal:
        displayText += "due on";
        break;
      case Operand.greaterThanEqual:
        displayText += "due after or on";
        break;
      case Operand.greaterThan:
        displayText += "due after";
        break;
      default:
        displayText += this.defaultValue ? "has" : "does not have";
        displayText += " due date";
        // have to return early because duration is probably null
        return displayText;
    }
    displayText += " ";
    displayText += "${duration.inDays} from now";

    return displayText;
  }

  Function toFilterFunction(DateTime planDate) {
    Function filterFunc;
//    DateTime now = DateTime.now();
    DateTime now = planDate;
    if (this.operand != null && this.duration != null) {
      DateTime then = now.add(duration);
      switch (this.operand) {
        case Operand.lessThan:
          filterFunc = (DateTime date) {
            return date?.isBefore(then) ?? this.defaultValue;
          };
          break;
        case Operand.lessThanEqual:
          filterFunc = (DateTime date) {
            return (date?.isBefore(then) ?? this.defaultValue) ||
                (date?.isAtSameMomentAs(then) ?? this.defaultValue);
          };
          break;
        case Operand.equal:
          filterFunc = (DateTime date) {
            return date?.isAtSameMomentAs(then) ?? this.defaultValue;
          };
          break;
        case Operand.greaterThanEqual:
          filterFunc = (DateTime date) {
            return (date?.isAfter(then) ?? this.defaultValue) ||
                (date?.isAtSameMomentAs(then) ?? this.defaultValue);
          };
          break;
        case Operand.greaterThan:
          filterFunc = (DateTime date) {
            return date?.isAfter(then) ?? this.defaultValue;
          };
          break;
      }
    } else {
      filterFunc = (DateTime date) {
        return this.defaultValue;
      };
    }

    return filterFunc;
  }
}
