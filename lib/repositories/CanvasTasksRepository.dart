import 'package:flutter/material.dart';
import 'package:planv3/interfaces/TaskRepository.dart';
import 'package:planv3/interfaces/TaskSource.dart';
import 'package:planv3/models/CanvasCourse.dart';
import 'package:planv3/models/CanvasTasksSource.dart';
import 'package:planv3/models/TaskItem.dart';
import 'package:planv3/models/TaskView.dart';
import 'package:planv3/models/TaskViewFilter.dart';
import 'package:planv3/providers/CanvasProvider.dart';
import 'package:planv3/providers/canvas_task_support/CanvasCourseEntity.dart';
import 'package:planv3/providers/canvas_task_support/CanvasTaskEntity.dart';

class CanvasTasksRepository implements TaskRepository {
  Future<CanvasTasksSource> updateSource(TaskSource source, DateTime planDate,
      {bool forceSync: false}) async {
    if (source is CanvasTasksSource) {
      List<CanvasCourseEntity> courseEntities =
          await CanvasProvider.getCourses();
      List<CanvasCourse> newCoursesList = courseEntities
          .map((entity) => CanvasCourse.fromCanvasCourseEntity(entity))
          .toList();

      List<CanvasCourse> removedCourses = source.courses
          .where((CanvasCourse course) =>
              newCoursesList.indexWhere(
                  (CanvasCourse otherCourse) => course.id == otherCourse.id) ==
              -1)
          .toList();

      // remove lists
      source.courses = newCoursesList;

      // remove missing lists from any subsource lists for views
      for (TaskView view in source.views) {
        List<String> idsToRemove =
            removedCourses.map((CanvasCourse course) => course.id).toList();
        view.removeSubSources(idsToRemove);
      }

      // THE BELOW THINGS ONLY NEED TO HAPPEN BECAUSE WE'RE HARDCODING VIEWS TO LISTS

      // remove any views that don't have a subSource (i.e. no associated list)
      source.views = source.views.where((TaskView view) {
        return view.subSourceIDs.isNotEmpty || view.title == "All";
      }).toList();

      if (source.views.isEmpty) {
        // make a view for each course
        for (CanvasCourse course in source.courses) {
          TaskView newView = TaskView(course.name);
          newView.addSubSourceID([course.id]);
          TaskViewFilter newFilter = TaskViewFilter(null, true);
          newView.addFilter(newFilter);
          source.views.add(newView);
        }

        // make an "All" view
        TaskView newView = TaskView("All");
        TaskViewFilter newFilter = TaskViewFilter(null, true);
        newView.addFilter(newFilter);
        source.views.add(newView);
      }

      // check if there's any lists that don't have a view
      for (CanvasCourse course in source.courses) {
        List<TaskView> viewsWithCourse = source.views.where((TaskView view) {
          return view.subSourceIDs.contains(course.id);
        }).toList();

        // if no views reference it, create a view for it
        if (viewsWithCourse.isEmpty) {
          TaskView newView = TaskView(course.name);
          newView.addSubSourceID([course.id]);
          // allow tasks with or without due dates
          TaskViewFilter newFilter = TaskViewFilter(null, true);
          newView.addFilter(newFilter);
          source.views.add(newView);
        }
      }

      // if any views have a list as its id, but not the same name, rename the view to be the list's
      for (TaskView view in source.views) {
        if (view.subSourceIDs.length > 0) {
          CanvasCourse associatedCourse =
              source.courses.firstWhere((CanvasCourse course) {
            return course.id == view.subSourceIDs[0];
          });
          if (view.title != associatedCourse.name) {
            view.title = associatedCourse.name;
          }
        }
      }

      // THE ABOVE THINGS ONLY NEED TO HAPPEN BECAUSE WE'RE HARDCODING VIEWS TO LISTS

      // sync views
      if (source.views.isNotEmpty) {
        // build a quick cache of tasks to reduce calls to the API
        List<String> courseIDs = courseEntities
            .map((CanvasCourseEntity course) => course.id)
            .toList();
        Map<String, List<CanvasTaskEntity>> retrievedTasks =
            await CanvasProvider.getTasks(courseIDs);

        for (TaskView view in source.views) {
          view = await syncView(view, planDate, cache: retrievedTasks);
        }
      }

      source.updateDateUpdatedFor(planDate);
      return source;
    } else {
      throw Exception(
          "Called updateSource in CanvasTasksRepository on source with "
          "type: ${source.runtimeType} instead of CanvasTasksSource");
    }
  }

  Future<TaskView> syncView(TaskView view, DateTime planDate,
      {@required Map<String, List<CanvasTaskEntity>> cache}) async {
    List<CanvasTaskEntity> tasks = [];

    if (view.subSourceIDs == null || view.subSourceIDs.isEmpty) {
      // get from all lists
      for (List<CanvasTaskEntity> canvasTaskList in cache.values) {
        // TODO: left off here. Need to make sure the cache is populated if it comes in as null
        tasks.addAll(canvasTaskList);
      }
    } else {
      // get from specified lists
      for (String id in view.subSourceIDs) {
        tasks.addAll(cache[id]);
      }
    }

    // filter gathered tasks by view filters
    for (TaskViewFilter filter in view.filters) {
      tasks = tasks.where((CanvasTaskEntity aTask) {
        return filter.toFilterFunction(planDate)(aTask.dueDate);
      }).toList();
    }

    // TODO: TAKE THIS OUT ONCE WE SUPPORT CUSTOM VIEWS
    // This will remove any tasks with due dates more than 1 day ago
    DateTime now = DateTime.now();
    DateTime threeDaysAgo = now.subtract(const Duration(days: 1));
    tasks = tasks.where((CanvasTaskEntity aTask) {
      return (aTask.dueDate == null || aTask.dueDate.isAfter(threeDaysAgo));
    }).toList();

    List<TaskItem> taskItems = tasks
        .map((CanvasTaskEntity canvasTaskEntity) =>
            TaskItem.fromCanvasTaskEntity(canvasTaskEntity))
        .toList();

    view.items = taskItems;
    return view;
  }
}
