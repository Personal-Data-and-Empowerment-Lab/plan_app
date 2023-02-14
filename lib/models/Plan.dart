import 'package:planv3/entities/entities.dart';

class Plan {
  String planText;
  DateTime date;

  Plan(this.planText, this.date);

  @override
  toString() {
    return "Plan {date: ${getDateMainText()} planText: $planText}";
  }

  Plan copyWith({String planText, DateTime date}) {
    return Plan(
      planText ?? this.planText,
      date ?? this.date,
    );
  }

  String getDateMainText() {
    return _getWeekdayNameFromNumber(date.weekday) +
        " - " +
        _getMonthNameFromNumber(date.month) +
        " " +
        date.day.toString();
  }

  String getDateTitleText() {
    DateTime now = DateTime.now();
    DateTime nowStart = DateTime(now.year, now.month, now.day);
    if (isToday()) {
      return "Today";
    } else if (isTomorrow()) {
      return "Tomorrow";
    } else if (isYesterday()) {
      return "Yesterday";
    } else if (nowStart.difference(date).inDays.abs() <= 7) {
      return _getWeekdayNameFullFromNumber(date.weekday);
    } else {
      return _getMonthNameFromNumber(date.month) + " " + date.day.toString();
    }
  }

  String getDateSubText() {
    DateTime now = DateTime.now();
    DateTime nowStart = DateTime(now.year, now.month, now.day);
    String dateSubText = "";
    if (nowStart.difference(date).inDays.abs() <= 7) {
      if (isToday() || isTomorrow() || isYesterday()) {
        dateSubText += _getWeekdayNameFromNumber(date.weekday) + " - ";
      }

      return dateSubText +=
          _getMonthNameFromNumber(date.month) + " " + date.day.toString();
    } else {
      return _getWeekdayNameFullFromNumber(date.weekday);
    }
  }

  String getMonthAndDayText() {
    return _getMonthNameFromNumber(date.month) + " " + date.day.toString();
  }

  String getWeekdayText() {
    return _getWeekdayNameFromNumber(date.weekday);
  }

  bool isToday() {
    DateTime now = DateTime.now();
    return now.difference(date).inDays == 0 && now.day == date.day;
  }

  bool isTomorrow() {
    DateTime now = DateTime.now();
    final DateTime tomorrow = DateTime(now.year, now.month, now.day + 1);
    final DateTime dateToCompare =
        DateTime(this.date.year, this.date.month, this.date.day);
    return dateToCompare == tomorrow;
  }

  bool isYesterday() {
    DateTime now = DateTime.now();
    final DateTime yesterday = DateTime(now.year, now.month, now.day - 1);
    final DateTime dateToCompare =
        DateTime(this.date.year, this.date.month, this.date.day);
    return dateToCompare == yesterday;
  }

  PlanEntity toEntity() {
    return PlanEntity(this.planText, this.date);
  }

  static Plan fromEntity(PlanEntity entity) {
    return Plan(entity.planText, entity.date);
  }

  String _getMonthNameFromNumber(int monthIndex) {
    switch (monthIndex) {
      case 1:
        return "Jan";
        break;
      case 2:
        return "Feb";
        break;
      case 3:
        return "Mar";
        break;
      case 4:
        return "Apr";
        break;
      case 5:
        return "May";
        break;
      case 6:
        return "Jun";
        break;
      case 7:
        return "Jul";
        break;
      case 8:
        return "Aug";
        break;
      case 9:
        return "Sep";
        break;
      case 10:
        return "Oct";
        break;
      case 11:
        return "Nov";
        break;
      case 12:
        return "Dec";
        break;
    }
    return "";
  }

  String _getWeekdayNameFromNumber(int weekdayIndex) {
    switch (weekdayIndex) {
      case 1:
        return "Mon";
        break;
      case 2:
        return "Tue";
        break;
      case 3:
        return "Wed";
        break;
      case 4:
        return "Thu";
        break;
      case 5:
        return "Fri";
        break;
      case 6:
        return "Sat";
        break;
      case 7:
        return "Sun";
        break;
    }
    return "";
  }

  String _getWeekdayNameFullFromNumber(int weekdayIndex) {
    switch (weekdayIndex) {
      case 1:
        return "Monday";
        break;
      case 2:
        return "Tuesday";
        break;
      case 3:
        return "Wednesday";
        break;
      case 4:
        return "Thursday";
        break;
      case 5:
        return "Friday";
        break;
      case 6:
        return "Saturday";
        break;
      case 7:
        return "Sunday";
        break;
    }
    return "";
  }
}
