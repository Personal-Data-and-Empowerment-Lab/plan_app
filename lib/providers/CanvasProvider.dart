import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'canvas_task_support/CanvasCourseEntity.dart';
import 'canvas_task_support/CanvasEventEntity.dart';
import 'canvas_task_support/CanvasTaskEntity.dart';

// TODO: flesh this out later
//class CanvasClient extends http.BaseClient {
//  final String _authToken;
//  final http.Client _innerClient;
//
//  CanvasClient(this._authToken, this._innerClient);
//
//  @override
//  Future<http.StreamedResponse> send(http.BaseRequest request) {
//    request.headers["Context-Type"] = "application/json";
//    request.headers["Authorization"] = "Bearer $_authToken";
//    return _innerClient.send(request);
//  }
//
//}

class CanvasProvider {
  static String _canvasToken;
  static final String _canvasRequestURL =
      "https://utah.instructure.com/api/v1/";
  static final String _courseEndpoint = "courses";
  static final String _assignmentsEndpoint = "assignments";
  static final String _todoEndpoint = "todo";
  static final String _calendarEventsEndpoint = "calendar_events";

  // PRIMARY API FUNCTIONS -----------------------------------------------------
  static Future<List<CanvasCourseEntity>> getCourses(
      {String enrollmentType = "student",
      String enrollmentState = "active"}) async {
    List<CanvasCourseEntity> returnCourseList = [];

    _canvasToken = await _retrieveCanvasToken();

    final response = await http.get(
        "$_canvasRequestURL$_courseEndpoint?enrollment_type=$enrollmentType&enrollment_state=$enrollmentState",
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_canvasToken",
        });

    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);

      returnCourseList = responseJson
          .map<CanvasCourseEntity>(
              (json) => CanvasCourseEntity.fromAPIJson(json))
          .toList();
    } else {
      throw Exception("Failed to retrieve Canvas courses.");
    }

    return returnCourseList;
  }

  static Future<Map<String, List<CanvasTaskEntity>>> getTasks(
      List<String> courseIDs) async {
    Map<String, List<CanvasTaskEntity>> returnTaskMap = Map();
    _canvasToken = await _retrieveCanvasToken();
    // print(_canvasToken);
    var client = http.Client();
    try {
      // for each courseID, get assignments
      print(courseIDs);
      for (String courseID in courseIDs) {
        print(courseID);
        int pageNum = 1;
        var response;
        do {
          response = await client.get(
              _buildAssignmentsURL(courseID, pageNum: pageNum++),
              headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer $_canvasToken",
              });

          if (response.statusCode == 200) {
            var responseJson = json.decode(response.body);
            try {
              if (!returnTaskMap.containsKey(courseID)) {
                returnTaskMap[courseID] = [];
              }

              returnTaskMap[courseID].addAll(responseJson
                  .map<CanvasTaskEntity>(
                      (json) => CanvasTaskEntity.fromAPIJson(json))
                  .toList());
            } catch (error) {
              print(
                  "Failed to retrieve Canvas todo items for course $courseID. Error was: $error");
              break;
              // move on to the next course
            }
          } else {
            print(
                "Failed to retrieve Canvas todo items for course $courseID. Status code was ${response.statusCode}");
            // move on to the next course
            break;
          }
        } while (response.headers.containsKey("link") &&
            response.headers["link"].contains('rel="next"'));
      }
    } catch (error) {
      print(error);
      throw error;
    } finally {
      client.close();
    }

    return returnTaskMap;
  }

  static Future<Map<String, List<CanvasEventEntity>>> getEvents(
      List<String> courseIDs) async {
    Map<String, List<CanvasEventEntity>> returnEventMap = Map();

    _canvasToken = await _retrieveCanvasToken();

    if (courseIDs.isNotEmpty) {
      String separator = "&context_codes[]=course_";

      String contextCodes = courseIDs.join(separator);

      var response = await http.get(
          "$_canvasRequestURL$_calendarEventsEndpoint?context_codes[]=course_$contextCodes&all_events=true",
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $_canvasToken",
          });

      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);

        for (var json in responseJson) {
          CanvasEventEntity event = CanvasEventEntity.fromAPIJson(json);
          if (returnEventMap.containsKey(event.courseID)) {
            returnEventMap[event.courseID].add(event);
          } else {
            returnEventMap[event.courseID] = [event];
          }
        }
      } else {
        throw Exception("Failed to retrieve Canvas calendar event items.");
      }
    }

    return returnEventMap;
  }

  // HELPER FUNCTIONS ----------------------------------------------------------
  static Future<String> _retrieveCanvasToken() async {
    final storage = new FlutterSecureStorage();

    String token = await storage.read(key: "canvasToken");

    if (token == null) {
      throw Exception("The user's Canvas token is null");
    } else {
      token = token.replaceAll("\"", "");
      return token;
    }
  }

  static String _buildAssignmentsURL(String courseID,
      {int perPage = 10, int pageNum}) {
    String pageNumString =
        (pageNum != null && pageNum > 1) ? "?page=$pageNum&" : "";
    String perPageString = "?per_page=$perPage";

    return "$_canvasRequestURL/courses/$courseID/$_assignmentsEndpoint$pageNumString$perPageString";
  }
}
