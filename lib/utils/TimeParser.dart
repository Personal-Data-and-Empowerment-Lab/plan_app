class ParsedTimeData {
  DateTime startTime;
  DateTime endTime;
  int startPosition;
  int endPosition;
}

class TimeParser {
  TimeParser();

  static RegExp startTimeOnlyPattern = new RegExp(
      r"([1][0-2]|[1-9])(?:(?::([0-5][0-9])(AM|PM|A|P)(?![\S]))|(?::([0-5][0-9]))|(?:(AM|PM|A|P)(?![\S])))",
      caseSensitive: false,
      multiLine: false);

  static RegExp endTimeOnlyPattern = new RegExp(
      r"-([1][0-2]|[1-9])(?:(?::([0-5][0-9])(AM|PM|A|P)(?![\S]))|(?::([0-5][0-9]))|(?:(AM|PM|A|P)(?![\S])))",
      caseSensitive: false,
      multiLine: false);

  static RegExp startAndEndTimePattern = new RegExp(
      r"([1][0-2]|[1-9]):?([0-5][0-9])?(?:(AM|PM|A|P))?-([1][0-2]|[1-9]):?([0-5][0-9])?(?:(AM|PM|A|P)(?![\S]))?",
      caseSensitive: false,
      multiLine: false);

  static String dateDivider = "-";

  static bool matchesStartTimeOnly(String text) {
    return startTimeOnlyPattern.hasMatch(text);
  }

  static bool matchesEndTimeOnly(String text) {
    return endTimeOnlyPattern.hasMatch(text);
  }

  static bool matchesStartAndEndTime(String text) {
    return startAndEndTimePattern.hasMatch(text);
  }

  static bool isValidTimeString(String text) {
    return matchesStartTimeOnly(text) ||
        matchesEndTimeOnly(text) ||
        matchesStartAndEndTime(text);
  }

  static bool hasValidStartTime(String text) {
    return matchesStartTimeOnly(text) || matchesStartAndEndTime(text);
  }

  static ParsedTimeData extractDatesFromText(String rawText,
      {DateTime planDate}) {
    ParsedTimeData returnData = new ParsedTimeData();

//    RegExp startTimeOnlyPattern = new RegExp(r"([1][0-2]|[1-9])(?:(?::([0-5][0-9])[ \t]*(AM|PM|A|P)(?![\S])[ \t]*)|(?::([0-5][0-9])[ \t]*)|(?:[ \t]*(AM|PM|A|P)(?![\S])[ \t]*))",
//        caseSensitive: false,
//        multiLine: false);
//
//    RegExp endTimeOnlyPattern = new RegExp(r"^\s*-\s*([1][0-2]|[1-9])(?:(?::([0-5][0-9])\s*(AM|PM|A|P)\s*)|(?::([0-5][0-9])\s*)|(?:\s*(AM|PM|A|P)\s*))",
//        caseSensitive: false,
//        multiLine: false);
//
//    RegExp startAndEndTimePattern = new RegExp(r"^\s*([1][0-2]|[1-9]):?([0-5][0-9])?\s*(?:(AM|PM|A|P))?\s*-\s*([1][0-2]|[1-9]):?([0-5][0-9])?\s*(?:(AM|PM|A|P))?\s*",
//        caseSensitive: false,
//        multiLine: false);

    if (startAndEndTimePattern.hasMatch(rawText)) {
      RegExpMatch match = startAndEndTimePattern.firstMatch(rawText);

      // extract group data from match
      int startHours = int.tryParse(match.group(1));
      int startMinutes;
      if (match.group(2) != null) {
        startMinutes = int.tryParse(match.group(2)) ?? 0;
      } else {
        startMinutes = 0;
      }
      String startPeriod = _parsePeriod(match.group(3));

      int endHours = int.tryParse(match.group(4));
      int endMinutes;
      if (match.group(5) != null) {
        endMinutes = int.tryParse(match.group(5)) ?? 0;
      } else {
        endMinutes = 0;
      }
      String endPeriod = _parsePeriod(match.group(6));

      // if start or end periods are missing, add them in
      if (startPeriod == null && endPeriod == null) {
        // set startPeriod
        startPeriod = guessPeriod(startPeriod, startHours);

        // set endPeriod
        if (endHours < startHours || endHours == 12) {
          endPeriod = "pm";
        } else {
          endPeriod = startPeriod;
        }
      }
      // if there's a startPeriod but no endPeriod
      else if (startPeriod != null && endPeriod == null) {
        if (startPeriod == "pm") {
          endPeriod = "pm";
        } else if (startPeriod == "am" &&
            (endHours < startHours || endHours == 12)) {
          endPeriod = "pm";
        } else {
          endPeriod = "am";
        }
      }
      // if there's an endPeriod but no startPeriod
      else if (startPeriod == null && endPeriod != null) {
        if (startHours <= endHours && endHours != 12) {
          startPeriod = endPeriod;
        } else if (startHours > endHours || endHours == 12) {
          startPeriod = "am";
        }
      } else {
        // do nothing because they're both set already
      }

      // adjust start and end hours to 23 hour time
      startHours = adjustHours(startPeriod, startHours);
      endHours = adjustHours(endPeriod, endHours);

      // set datetime objects
      DateTime startDate = planDate ?? new DateTime.now();
      startDate = startDate.toLocal();
      startDate = new DateTime(startDate.year, startDate.month, startDate.day,
          startHours, startMinutes);

      DateTime endDate = planDate ?? new DateTime.now();
      endDate = endDate.toLocal();
      endDate = new DateTime(
          endDate.year, endDate.month, endDate.day, endHours, endMinutes);

      // set return data
      returnData.startTime = startDate;
      returnData.endTime = endDate;
      returnData.startPosition = match.start;
      returnData.endPosition = match.end;
//      returnData.endPosition = match.group(0).length;
    } // end startAndEndTime match
    else if (startTimeOnlyPattern.hasMatch(rawText)) {
      RegExpMatch match = startTimeOnlyPattern.firstMatch(rawText);

      int hours = int.tryParse(match.group(1));
      int minutes;
      if (match.group(2) != null) {
        minutes = int.tryParse(match.group(2)) ?? 0;
      } else if (match.group(4) != null) {
        minutes = int.tryParse(match.group(4)) ?? 0;
      } else {
        minutes = 0;
      }

      String period =
          _parsePeriod(match.group(3)) ?? _parsePeriod(match.group(5));

      period = period ?? guessPeriod(period, hours);

      hours = adjustHours(period, hours);

      DateTime startDate = planDate ?? new DateTime.now();
      startDate = startDate.toLocal();
      startDate = new DateTime(
          startDate.year, startDate.month, startDate.day, hours, minutes);

      returnData.startTime = startDate;
      returnData.startPosition = match.start;
      returnData.endPosition = match.end;
//      returnData.endPosition = match.group(0).length;
    } // end startDateOnly match
    else if (endTimeOnlyPattern.hasMatch(rawText)) {
      RegExpMatch match = endTimeOnlyPattern.firstMatch(rawText);

      int hours = int.tryParse(match.group(1));
      int minutes;
      if (match.group(2) != null) {
        minutes = int.tryParse(match.group(2)) ?? 0;
      } else if (match.group(4) != null) {
        minutes = int.tryParse(match.group(4)) ?? 0;
      } else {
        minutes = 0;
      }

      String period =
          _parsePeriod(match.group(3)) ?? _parsePeriod(match.group(5));

      period = period ?? guessPeriod(period, hours);

      hours = adjustHours(period, hours);

      DateTime endDate = planDate ?? new DateTime.now();
      endDate = endDate.toLocal();
      endDate = new DateTime(
          endDate.year, endDate.month, endDate.day, hours, minutes);

      returnData.endTime = endDate;
      returnData.startPosition = match.start;
      returnData.endPosition = match.end;
//      returnData.endPosition = match.group(0).length;
    } // end endDateOnly match

    return returnData;
  }

  static int adjustHours(String period, int hours) {
    if (period.toLowerCase() == "pm" && hours < 12) {
      hours += 12;
    } else if (hours == 12 && period.toLowerCase() == "am") {
      hours = 0;
    }

    return hours;
  }

  static String guessPeriod(String period, int hours) {
    if (hours > 8 && hours < 12) {
      period = "am";
    } else if (hours == 12 || hours <= 7) {
      period = "pm";
    }
    // startHours is 8
    else {
      period = "am";
    }

    return period;
  }

  static String _parsePeriod(String rawPeriod) {
    if (rawPeriod == null) {
      return rawPeriod;
    }
    if (rawPeriod.toLowerCase() == "am" || rawPeriod.toLowerCase() == "a") {
      return "am";
    } else if (rawPeriod.toLowerCase() == "pm" ||
        rawPeriod.toLowerCase() == "p") {
      return "pm";
    } else {
      return rawPeriod;
    }
  }

  static String getFullTimeAsString(DateTime startTime, DateTime endTime) {
    String timeString = "";
    if (startTime != null) {
      timeString += getTimeAsString(startTime);
    }

    if (endTime != null) {
      timeString += dateDivider + getTimeAsString(endTime);
    }

    //add a space to make formatting nicer
//    if (timeString.length > 0) {
//      timeString += " ";
//    }

    return timeString;
  }

  static String getTimeAsString(DateTime dateTime) {
    String dateAsString = "";

    if (dateTime != null) {
      String hour;
      String period;

      //convert to clock time
      if (dateTime.hour > 12) {
        hour = (dateTime.hour % 12).toString();
        period = "pm";
      } else if (dateTime.hour == 12) {
        hour = dateTime.hour.toString();
        period = "pm";
      } else if (dateTime.hour == 0) {
        hour = "12";
        period = "am";
      } else {
        hour = dateTime.hour.toString();
        period = "am";
      }

      dateAsString +=
          hour + ":" + dateTime.minute.toString().padLeft(2, "0") + period;
    } //end if not null

    return dateAsString;
  }
}
