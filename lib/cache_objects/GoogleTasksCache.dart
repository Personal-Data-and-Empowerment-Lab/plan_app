import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:planv3/entities/GoogleTaskEntity.dart';
import 'package:planv3/entities/GoogleTaskListEntity.dart';

part 'GoogleTasksCache.g.dart';

@JsonSerializable()
class GoogleTasksCache {
  Map<String, List<GoogleTaskEntity>> tasks =
      Map<String, List<GoogleTaskEntity>>();
  List<GoogleTaskListEntity> taskLists = [];
  DateTime lastUpdated;

  GoogleTasksCache();

  static GoogleTasksCache _instance;
//  factory GoogleTasksCache() {
//    return _instance;
//  }

  static Future<GoogleTasksCache> getInstance() async {
    if (_instance == null) {
      _instance = await readGoogleTasksCache();
    }

    if (_instance == null) {
      _instance = GoogleTasksCache();
    }
    return _instance;
  }

  Future<List<GoogleTaskListEntity>> getGoogleTaskLists() async {
    return taskLists;
  }

  Future<List<GoogleTaskEntity>> getGoogleTasksFromList(String listID) async {
    List<GoogleTaskEntity> returnList = [];
    returnList = tasks[listID] ?? [];
    return returnList;
  }

  void updateCache(Map<String, List<GoogleTaskEntity>> tasks,
      List<GoogleTaskListEntity> taskLists) async {
    lastUpdated = DateTime.now();
    this.tasks = tasks;
    this.taskLists = taskLists;

    // write to file storage
    await writeGoogleTasksCache(this);
  }

  bool updatedBefore(DateTime date) {
    return lastUpdated == null || lastUpdated.isBefore(date);
  }

  // FILE STORAGE STUFF --------------------------------------------------------
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  static Future<File> get _googleTasksCacheFile async {
    final path = await _localPath;
    return File('$path/googleTasksCache.txt');
  }

  static Future<File> writeGoogleTasksCache(GoogleTasksCache data) async {
    final file = await _googleTasksCacheFile;
    return file.writeAsString(jsonEncode(data));
  }

  static Future<GoogleTasksCache> readGoogleTasksCache() async {
    try {
      final file = await _googleTasksCacheFile;

      // Read the file.
      String contents = await file.readAsString();

      return GoogleTasksCache.fromJson(jsonDecode(contents));
    } catch (e) {
      return null;
    }
  }

  // END FILE STORAGE ----------------------------------------------------------

  // START SERIALIZATION -------------------------------------------------------
  factory GoogleTasksCache.fromJson(Map<String, dynamic> json) =>
      _$GoogleTasksCacheFromJson(json);

  Map<String, dynamic> toJson() => _$GoogleTasksCacheToJson(this);
  // END SERIALIZATION ---------------------------------------------------------

}
