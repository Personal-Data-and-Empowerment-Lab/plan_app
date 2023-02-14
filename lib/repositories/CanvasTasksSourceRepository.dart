import 'dart:convert';
import 'dart:io';

import 'package:planv3/interfaces/TaskSource.dart';
import 'package:planv3/models/CanvasTasksSource.dart';

import 'TaskSourceRepository.dart';

class CanvasTasksSourceRepository implements TaskSourceRepository {
  static String _filename = "canvasTasksSettings";

  Future<File> writeTasksSource(TaskSource data) async {
    if (data is CanvasTasksSource) {
      final file = await TaskSourceRepository.settingsFile(_filename);

      return file.writeAsString(jsonEncode(data));
    } else {
      throw Exception("Tried to write an object with type: "
          "${data.runtimeType} to Canvas Tasks Settings.");
    }
  }

  Future<CanvasTasksSource> readTasksSource() async {
    try {
      final file = await TaskSourceRepository.settingsFile(_filename);

      // Read the file.
      String contents = await file.readAsString();

      return CanvasTasksSource.fromJson(jsonDecode(contents));
    } catch (e) {
      return null;
    }
  }
}
