import 'package:planv3/interfaces/TaskSource.dart';
import 'package:planv3/models/CanvasTasksSource.dart';
import 'package:planv3/models/GoogleTasksSource.dart';
import 'package:planv3/repositories/CanvasTasksSourceRepository.dart';
import 'package:planv3/repositories/GoogleTasksSourceRepository.dart';

// store a list of all the possible sources here
class TaskSourcesManager {
  // return list of sources that are currently marked as visible
  static Future<Map<String, TaskSource>> getVisibleTaskSources() async {
    Map<String, TaskSource> allSources = await getAllTaskSources();

    return Map<String, TaskSource>.from(allSources)
      ..removeWhere((String key, TaskSource value) => !value.isVisible);
  }

  // return list of all supported task sources
  static Future<Map<String, TaskSource>> getAllTaskSources() async {
    Map<String, TaskSource> returnMap = Map();
    // get google tasks instance
    TaskSource googleTasksSource =
        await GoogleTasksSourceRepository().readTasksSource() ??
            GoogleTasksSource();
    returnMap[googleTasksSource.id] = googleTasksSource;

    // get canvas tasks instance
    TaskSource canvasTasksSource =
        await CanvasTasksSourceRepository().readTasksSource() ??
            CanvasTasksSource();
    returnMap[canvasTasksSource.id] = canvasTasksSource;

    return returnMap;
  }

  // return list of all task sources that are not set up
  static Future<Map<String, TaskSource>> getUnSetupSources() async {
    Map<String, TaskSource> allSources = await getAllTaskSources();

    return Map<String, TaskSource>.from(allSources)
      ..removeWhere((String key, TaskSource value) => !value.isSetUp);
  }
}
