import 'dart:convert';
import 'dart:io';

import 'package:planv3/interfaces/TaskSource.dart';
import 'package:planv3/models/GoogleTasksSource.dart';

import 'TaskSourceRepository.dart';

class GoogleTasksSourceRepository implements TaskSourceRepository {
  static String _filename = "googleTasksSettings";

//  static Future<File> get _googleTasksSettingsFile async {
//    final path = await TaskSourceRepository.localPath;
//    return File('$path/$_filename.txt');
//  }

  Future<File> writeTasksSource(TaskSource data) async {
    if (data is TaskSource) {
      final file = await TaskSourceRepository.settingsFile(_filename);

      return file.writeAsString(jsonEncode(data));
    } else {
      throw Exception("Tried to write an object with type: "
          "${data.runtimeType} to Google Tasks Settings.");
    }
  }

  Future<TaskSource> readTasksSource() async {
    try {
      final file = await TaskSourceRepository.settingsFile(_filename);

      // Read the file.
      String contents = await file.readAsString();

      return GoogleTasksSource.fromJson(jsonDecode(contents));
    } catch (e) {
      return null;
    }
  }
}
