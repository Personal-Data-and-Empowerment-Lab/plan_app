import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:planv3/interfaces/TaskSource.dart';

abstract class TaskSourceRepository {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> settingsFile(String filename) async {
    final path = await _localPath;
    return File('$path/$filename.txt');
  }

  Future<File> writeTasksSource(TaskSource data);

  Future<TaskSource> readTasksSource();
}
