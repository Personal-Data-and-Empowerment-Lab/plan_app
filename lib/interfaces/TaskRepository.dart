import 'package:planv3/models/TaskView.dart';

import 'TaskSource.dart';

abstract class TaskRepository {
//  Future<TaskSource> syncSource(TaskSource source, DateTime planDate);
  Future<TaskView> syncView(TaskView view, DateTime planDate);

  Future<TaskSource> updateSource(TaskSource source, DateTime planDate,
      {bool forceSync: false});
}
