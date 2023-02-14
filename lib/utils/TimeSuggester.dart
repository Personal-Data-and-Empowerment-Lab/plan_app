import 'package:planv3/models/PlanLine.dart';

import 'TimeParser.dart';

abstract class TimeSuggesterInterface {}

enum ClosestTimeType { beforeStart, beforeEnd, afterStart, afterEnd, none }

class ClosestTimeData {
  ClosestTimeType type;
  DateTime time;

  ClosestTimeData(this.type, this.time);
}

class TimeSuggester implements TimeSuggesterInterface {
  Duration _intervalDuration = new Duration(minutes: 15);
  Duration _eventDuration = new Duration(minutes: 60);

  DateTime _dateOfPlan;

  TimeSuggester(this._dateOfPlan);

  DateTime incrementStartTime(
      PlanLine lineBefore, PlanLine lineAfter, PlanLine currentLine) {
    DateTime newTime;

    // if we already have a startTime to work with
    if (currentLine.startTime != null) {
      newTime = _incrementTimeByIntervalDuration(currentLine.startTime);
    }
    // we need to create a startTime
    else {
      // get closest line
      ClosestTimeData closestTimeData =
          _getClosestTimeDataToStart(lineBefore, lineAfter, currentLine);
      newTime = _generateStartTime(
          closestTimeData.type, closestTimeData.time, currentLine, true);
    }

    return newTime;
  }

  DateTime decrementStartTime(
      PlanLine lineBefore, PlanLine lineAfter, PlanLine currentLine) {
    DateTime newTime;

    // if we already have a startTime to work with
    if (currentLine.startTime != null) {
      newTime = _decrementTimeByIntervalDuration(currentLine.startTime);
    }
    // we need to create a startTime
    else {
      // get closest line
      ClosestTimeData closestTimeData =
          _getClosestTimeDataToStart(lineBefore, lineAfter, currentLine);
      newTime = _generateStartTime(
          closestTimeData.type, closestTimeData.time, currentLine, false);
    }

    return newTime;
  }

  DateTime incrementEndTime(
      PlanLine lineBefore, PlanLine lineAfter, PlanLine currentLine) {
    DateTime newTime;

    // if we already have a endTime to work with
    if (currentLine.endTime != null) {
      newTime = _incrementTimeByIntervalDuration(currentLine.endTime);
    }
    // we need to create a endTime
    else {
      // get closest line
      ClosestTimeData closestTimeData =
          _getClosestTimeDataToEnd(lineBefore, lineAfter, currentLine);
      newTime = _generateEndTime(
          closestTimeData.type, closestTimeData.time, currentLine, true);
    }

    return newTime;
  }

  DateTime decrementEndTime(
      PlanLine lineBefore, PlanLine lineAfter, PlanLine currentLine) {
    DateTime newTime;

    // if we already have a startTime to work with
    if (currentLine.endTime != null) {
      newTime = _decrementTimeByIntervalDuration(currentLine.endTime);
    }
    // we need to create a startTime
    else {
      // get closest line
      ClosestTimeData closestTimeData =
          _getClosestTimeDataToEnd(lineBefore, lineAfter, currentLine);
      newTime = _generateEndTime(
          closestTimeData.type, closestTimeData.time, currentLine, false);
    }

    return newTime;
  }

  DateTime _incrementTimeByIntervalDuration(DateTime currentTime) {
    DateTime newTime = _roundToNearestInterval(currentTime);

    // add interval
    newTime = newTime.add(_intervalDuration);

    // if the adjustment put it into the next day, fix it to be 11:59 pm
    if (newTime.day != currentTime.day) {
      newTime = new DateTime(
          currentTime.year, currentTime.month, currentTime.day, 23, 59);
    }

    return newTime;
  }

  DateTime _incrementTimeByEventDuration(DateTime currentTime) {
    DateTime newTime = _roundToNearestInterval(currentTime);

    newTime = newTime.add(_eventDuration);

    if (newTime.day != currentTime.day) {
      newTime = new DateTime(
          currentTime.year, currentTime.month, currentTime.day, 23, 59);
    }

    return newTime;
  }

  DateTime _decrementTimeByIntervalDuration(DateTime currentTime) {
    DateTime newTime = _roundToNearestInterval(currentTime);

    newTime = newTime.subtract(_intervalDuration);

    if (newTime.day != currentTime.day) {
      newTime = new DateTime(
          currentTime.year, currentTime.month, currentTime.day, 0, 0);
    }

    return newTime;
  }

  DateTime _decrementTimeByEventDuration(DateTime currentTime) {
    DateTime newTime = _roundToNearestInterval(currentTime);

    newTime = newTime.subtract(_eventDuration);

    if (newTime.day != currentTime.day) {
      newTime = new DateTime(
          currentTime.year, currentTime.month, currentTime.day, 0, 0);
    }

    return newTime;
  }

  DateTime _roundToNearestInterval(DateTime currentTime) {
    DateTime newTime;

    int diff = currentTime.minute % _intervalDuration.inMinutes;
    if (diff <= _intervalDuration.inMinutes / 2) {
      newTime = currentTime.subtract(Duration(minutes: diff));
    } else {
      newTime = currentTime
          .add(Duration(minutes: _intervalDuration.inMinutes - diff));
    }

    return newTime;
  }

  DateTime _generateStartTime(ClosestTimeType closestTimeType,
      DateTime closestTime, PlanLine currentLineTimeData, bool increment) {
    DateTime newTime;
    switch (closestTimeType) {
      case ClosestTimeType.beforeStart:
        newTime = _incrementTimeByEventDuration(closestTime);

        if (increment) {
          newTime = _incrementTimeByIntervalDuration(newTime);
        }
        break;
      case ClosestTimeType.beforeEnd:
        newTime = closestTime;
        if (increment) {
          newTime = _incrementTimeByIntervalDuration(closestTime);
        }
        break;
      case ClosestTimeType.afterStart:
        newTime = _decrementTimeByIntervalDuration(closestTime);
        newTime = _decrementTimeByEventDuration(newTime);
        break;
      case ClosestTimeType.afterEnd:
        newTime = _decrementTimeByEventDuration(closestTime);
        newTime = _decrementTimeByIntervalDuration(newTime);
        newTime = _decrementTimeByEventDuration(newTime);
        break;
      case ClosestTimeType.none:
        // if it's today, be a little smarter and suggest the closest time to now
        DateTime now = DateTime.now().toLocal();
        if (now.difference(_dateOfPlan).inDays == 0 &&
            now.day == _dateOfPlan.day) {
          newTime = _roundToNearestInterval(now);
//          newTime = _incrementTimeByIntervalDuration(newTime);
        } else {
          newTime = new DateTime(
              _dateOfPlan.year, _dateOfPlan.month, _dateOfPlan.day, 12, 0);
        }

        break;
    }

    //now that we've generated a suggested time, let's compare it with one event
    //  duration before the end time if it has one
    if (currentLineTimeData.endTime != null) {
      DateTime timeFromEndTime =
          _decrementTimeByEventDuration(currentLineTimeData.endTime);

      // if the suggested time is after the end time or is before the time suggested
      // by the end time, we should swap for the time suggested by the end time
      if (!newTime.isBefore(currentLineTimeData.endTime) ||
          newTime.isBefore(timeFromEndTime)) {
        newTime = timeFromEndTime;
      }
    }

    return newTime;
  }

  ClosestTimeData _getClosestTimeDataToStart(
      PlanLine lineBefore, PlanLine lineAfter, PlanLine currentLine) {
    ClosestTimeData closestTimeData;

    // if there's no line before this line with a time
    if (lineBefore == null && lineAfter != null) {
      if (lineAfter.startTime != null) {
        closestTimeData = new ClosestTimeData(
            ClosestTimeType.afterStart, lineAfter.startTime);
      } else if (lineAfter.endTime != null) {
        closestTimeData =
            new ClosestTimeData(ClosestTimeType.afterEnd, lineAfter.endTime);
      } else {
        throw new Exception("both start and end time of after line were null.");
      }
    }
    // if there's no line after this line with a time
    else if (lineAfter == null && lineBefore != null) {
      if (lineBefore.endTime != null) {
        closestTimeData =
            new ClosestTimeData(ClosestTimeType.beforeEnd, lineBefore.endTime);
      } else if (lineBefore.startTime != null) {
        closestTimeData = new ClosestTimeData(
            ClosestTimeType.beforeStart, lineBefore.startTime);
      } else {
        throw new Exception(
            "both start and end time of before line were null.");
      }
    }
    // if there's both a line before and after with a time
    else if (lineAfter != null && lineBefore != null) {
      int distToBefore =
          (lineBefore.linePosition - currentLine.linePosition).abs();
      int distToAfter =
          (lineAfter.linePosition - currentLine.linePosition).abs();

      if (distToBefore <= distToAfter) {
        if (lineBefore.endTime != null) {
          closestTimeData = new ClosestTimeData(
              ClosestTimeType.beforeEnd, lineBefore.endTime);
        } else if (lineBefore.startTime != null) {
          closestTimeData = new ClosestTimeData(
              ClosestTimeType.beforeStart, lineBefore.startTime);
        } else {
          throw new Exception(
              "both start and end time of before line were null.");
        }
      } else {
        if (lineAfter.startTime != null) {
          closestTimeData = new ClosestTimeData(
              ClosestTimeType.afterStart, lineAfter.startTime);
        } else if (lineAfter.endTime != null) {
          closestTimeData =
              new ClosestTimeData(ClosestTimeType.afterEnd, lineAfter.endTime);
        } else {
          throw new Exception(
              "both start and end time of after line were null");
        }
      }
    } else {
      closestTimeData = new ClosestTimeData(ClosestTimeType.none, null);
    }

    return closestTimeData;
  }

  DateTime _generateEndTime(ClosestTimeType closestTimeType,
      DateTime closestTime, PlanLine currentLine, bool increment) {
    DateTime newTime;

    switch (closestTimeType) {
      case ClosestTimeType.beforeStart:
        newTime = _incrementTimeByEventDuration(closestTime);
        newTime = _incrementTimeByIntervalDuration(newTime);
        newTime = _incrementTimeByEventDuration(newTime);
        break;
      case ClosestTimeType.beforeEnd:
        newTime = _incrementTimeByIntervalDuration(closestTime);
        newTime = _incrementTimeByEventDuration(newTime);
        break;
      case ClosestTimeType.afterStart:
        if (increment) {
          newTime = closestTime;
        } else {
          newTime = _decrementTimeByIntervalDuration(closestTime);
        }

        break;
      case ClosestTimeType.afterEnd:
        newTime = _decrementTimeByEventDuration(closestTime);
        if (!increment) {
          newTime = _decrementTimeByIntervalDuration(newTime);
        }

        break;
      case ClosestTimeType.none:
        newTime = new DateTime(
            _dateOfPlan.year, _dateOfPlan.month, _dateOfPlan.day, 12, 0);
        break;
    }

    //now that we've generated a suggested time, let's compare it with one event
    //  duration before the end time if it has one
    if (currentLine.startTime != null) {
      DateTime timeFromStartTime;
      if (increment) {
        timeFromStartTime =
            _incrementTimeByEventDuration(currentLine.startTime);
      } else {
        timeFromStartTime =
            _incrementTimeByEventDuration(currentLine.startTime);
        timeFromStartTime = _decrementTimeByIntervalDuration(timeFromStartTime);
      }

      // if the suggested time is not after the start time or is after the time suggested
      // by the start time, we should swap for the time suggested by the start time
      if (!newTime.isAfter(currentLine.startTime) ||
          newTime.isAfter(timeFromStartTime)) {
        newTime = timeFromStartTime;
      }
    }

    return newTime;
  }

  ClosestTimeData _getClosestTimeDataToEnd(
      PlanLine lineBefore, PlanLine lineAfter, PlanLine currentLine) {
    ClosestTimeData closestTimeData;

    // if there's no line before this line with a time
    if (lineBefore == null && lineAfter != null) {
      if (lineAfter.startTime != null) {
        closestTimeData = new ClosestTimeData(
            ClosestTimeType.afterStart, lineAfter.startTime);
      } else if (lineAfter.endTime != null) {
        closestTimeData =
            new ClosestTimeData(ClosestTimeType.afterEnd, lineAfter.endTime);
      } else {
        throw new Exception("both start and end time of after line were null.");
      }
    }
    // if there's no line after this line with a time
    else if (lineAfter == null && lineBefore != null) {
      if (lineBefore.endTime != null) {
        closestTimeData =
            new ClosestTimeData(ClosestTimeType.beforeEnd, lineBefore.endTime);
      } else if (lineBefore.startTime != null) {
        closestTimeData = new ClosestTimeData(
            ClosestTimeType.beforeStart, lineBefore.startTime);
      } else {
        throw new Exception(
            "both start and end time of before line were null.");
      }
    }
    // if there's both a line before and after with a time
    else if (lineAfter != null && lineBefore != null) {
      int distToBefore =
          (lineBefore.linePosition - currentLine.linePosition).abs();
      int distToAfter =
          (lineAfter.linePosition - currentLine.linePosition).abs();

      if (distToBefore < distToAfter) {
        if (lineBefore.endTime != null) {
          closestTimeData = new ClosestTimeData(
              ClosestTimeType.beforeEnd, lineBefore.endTime);
        } else if (lineBefore.startTime != null) {
          closestTimeData = new ClosestTimeData(
              ClosestTimeType.beforeStart, lineBefore.startTime);
        } else {
          throw new Exception(
              "both start and end time of before line were null.");
        }
      } else {
        if (lineAfter.startTime != null) {
          closestTimeData = new ClosestTimeData(
              ClosestTimeType.afterStart, lineAfter.startTime);
        } else if (lineAfter.endTime != null) {
          closestTimeData =
              new ClosestTimeData(ClosestTimeType.afterEnd, lineAfter.endTime);
        } else {
          throw new Exception(
              "both start and end time of after line were null");
        }
      }
    } else {
      closestTimeData = new ClosestTimeData(ClosestTimeType.none, null);
    }

    return closestTimeData;
  }
}
