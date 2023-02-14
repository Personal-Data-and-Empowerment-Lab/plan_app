import 'package:planv3/cache_objects/GoogleTasksCache.dart';
import 'package:planv3/entities/GoogleTaskEntity.dart';
import 'package:planv3/entities/GoogleTaskListEntity.dart';
import 'package:planv3/interfaces/TaskRepository.dart';
import 'package:planv3/interfaces/TaskSource.dart';
import 'package:planv3/models/GoogleTaskList.dart';
import 'package:planv3/models/GoogleTasksSource.dart';
import 'package:planv3/models/TaskItem.dart';
import 'package:planv3/models/TaskView.dart';
import 'package:planv3/models/TaskViewFilter.dart';
import 'package:planv3/providers/GoogleTasksProvider.dart';

class GoogleTasksRepository implements TaskRepository {
  Future<GoogleTasksSource> syncSource(
      TaskSource source, DateTime planDate) async {
    if (source is GoogleTasksSource) {
      // get all lists
      List<GoogleTaskListEntity> rawTaskLists = [];

      try {
        rawTaskLists = await GoogleTasksProvider.getGoogleTaskLists();
      } catch (error) {
        throw error;
      }
      // if there's a list we don't have, add it to the source
      for (GoogleTaskListEntity entity in rawTaskLists) {
        if (source.lists
                .indexWhere((GoogleTaskList list) => list.id == entity.id) ==
            -1) {
          source.lists.add(GoogleTaskList.fromEntity(entity));
        }
      }
      // if there's a list that doesn't exist anymore, add to list of lists to remove
      List<GoogleTaskList> removedLists =
          source.lists.where((GoogleTaskList list) {
        return rawTaskLists.indexWhere(
                (GoogleTaskListEntity entity) => entity.id == list.id) ==
            -1;
      }).toList();

      // actually remove from list
      source.lists = source.lists.where((GoogleTaskList list) {
        return rawTaskLists.indexWhere(
                (GoogleTaskListEntity entity) => entity.id == list.id) !=
            -1;
      }).toList();

      // remove missing lists from any subsource lists for views
      for (TaskView view in source.views) {
        List<String> idsToRemove = removedLists
            .map((GoogleTaskList googleTaskList) => googleTaskList.id)
            .toList();
        view.removeSubSources(idsToRemove);
      }

      // THE BELOW THINGS ONLY NEED TO HAPPEN BECAUSE WE'RE HARDCODING VIEWS TO LISTS

      // remove any views that don't have a subSource (i.e. no associated list)
      source.views = source.views.where((TaskView view) {
        return view.subSourceIDs.isNotEmpty;
      }).toList();

      // check if there's any lists that don't have a view
      for (GoogleTaskList list in source.lists) {
        List<TaskView> viewsWithList = source.views.where((TaskView view) {
          return view.subSourceIDs.contains(list.id);
        }).toList();

        // if no views reference it, create a view for it
        if (viewsWithList.isEmpty) {
          TaskView newView = TaskView(list.title);
          newView.addSubSourceID([list.id]);
          // allow tasks with or without due dates
          TaskViewFilter newFilter = TaskViewFilter(null, true);
          newView.addFilter(newFilter);
          source.views.add(newView);
        }
      }

      // if any views have a list as its id, but not the same name, rename the view to be the list's
      for (TaskView view in source.views) {
        if (view.subSourceIDs.length > 0) {
          GoogleTaskList associatedList =
              source.lists.firstWhere((GoogleTaskList list) {
            return list.id == view.subSourceIDs[0];
          });
          if (view.title != associatedList.title) {
            view.title = associatedList.title;
          }
        }
      }

      // TODO:  remove this once adding view within app is possible
      // temporarily build a view for each list
      if (source.views.isEmpty) {
        for (GoogleTaskList list in source.lists) {
          // give the same name as the list we're pulling from
          TaskView newView = TaskView(list.title);
          newView.addSubSourceID([list.id]);
          // allow tasks with or without due dates
          TaskViewFilter newFilter = TaskViewFilter(null, true);
          newView.addFilter(newFilter);
          source.views.add(newView);
        }
      }

      // THE ABOVE THINGS ONLY NEED TO HAPPEN BECAUSE WE'RE HARDCODING VIEWS TO LISTS

      // sync views
      for (TaskView view in source.views) {
        view = await syncView(view, planDate);
      }
      source.updateDateUpdatedFor(planDate);
      source.isSetUp = true;
      return source;
    } else {
      throw Exception(
          "Called syncSource in GoogleTasksRepository on source with "
          "type: ${source.runtimeType} instead of GoogleTasksSource");
    }
  }

  Future<TaskView> syncView(TaskView view, DateTime planDate) async {
    // gather tasks from sources
    List<GoogleTaskEntity> tasks = [];

    if (view.subSourceIDs == null || view.subSourceIDs.isEmpty) {
      // get from all lists
      List<GoogleTaskListEntity> taskLists =
          await GoogleTasksProvider.getGoogleTaskLists();
      for (GoogleTaskListEntity taskList in taskLists) {
        List<GoogleTaskEntity> retrievedTasks =
            await GoogleTasksProvider.getGoogleTasksFromList(taskList.id);
        tasks.addAll(retrievedTasks);
      }
    } else {
      // get from specified lists
      for (String id in view.subSourceIDs) {
        List<GoogleTaskEntity> retrievedTasks =
            await GoogleTasksProvider.getGoogleTasksFromList(id);
        tasks.addAll(retrievedTasks);
      }
    }

    // filter gathered tasks by view filters
    for (TaskViewFilter filter in view.filters) {
      tasks = tasks.where((GoogleTaskEntity aTask) {
        return filter.toFilterFunction(planDate)(aTask.dueDate);
      }).toList();
    }

    List<TaskItem> taskItems = [];
    for (GoogleTaskEntity taskEntity in tasks) {
      taskItems.add(taskEntity.toTaskItem());
    }

    view.items = taskItems;
    return view;
  }

  static Future<Map<String, String>> signIn() async {
    return GoogleTasksProvider.signIn();
  }

  static Future signOut() async {
    return GoogleTasksProvider.signOut();
  }

  Future<GoogleTasksSource> updateSource(TaskSource source, DateTime planDate,
      {bool forceSync: false}) async {
    GoogleTasksCache cache = await GoogleTasksCache.getInstance();
    DateTime now = DateTime.now();
    DateTime beginningOfToday = DateTime(now.year, now.month, now.day);

    if (cache.updatedBefore(beginningOfToday) || forceSync) {
      // update cache from API
      await updateCache();
      source.updateLastUpdatedTimestamp();
    }

    // update source from cache
    return await updateSourceFromCache(source, planDate);
  }

  static Future<void> updateCache() async {
    // pull from API
    Map<String, List<GoogleTaskEntity>> newCacheData = new Map();
    // get lists
    List<GoogleTaskListEntity> taskLists =
        await GoogleTasksProvider.getGoogleTaskLists();

    for (GoogleTaskListEntity taskList in taskLists) {
      List<GoogleTaskEntity> retrievedTasks =
          await GoogleTasksProvider.getGoogleTasksFromList(taskList.id);
      newCacheData[taskList.id] = retrievedTasks ?? [];
    }

    // update cache
    (await GoogleTasksCache.getInstance()).updateCache(newCacheData, taskLists);
    GoogleTasksCache cache = await GoogleTasksCache.getInstance();
  }

  static Future<GoogleTasksSource> updateSourceFromCache(
      TaskSource source, DateTime planDate) async {
    if (source is GoogleTasksSource) {
      // get all lists
      List<GoogleTaskListEntity> rawTaskLists =
          await (await GoogleTasksCache.getInstance()).getGoogleTaskLists();
      // if there's a list we don't have, add it to the source
      for (GoogleTaskListEntity entity in rawTaskLists) {
        if (source.lists
                .indexWhere((GoogleTaskList list) => list.id == entity.id) ==
            -1) {
          source.lists.add(GoogleTaskList.fromEntity(entity));
        }
      }
      // if there's a list that doesn't exist anymore, add to list of lists to remove
      List<GoogleTaskList> removedLists =
          source.lists.where((GoogleTaskList list) {
        return rawTaskLists.indexWhere(
                (GoogleTaskListEntity entity) => entity.id == list.id) ==
            -1;
      }).toList();

      // actually remove from list
      source.lists = source.lists.where((GoogleTaskList list) {
        return rawTaskLists.indexWhere(
                (GoogleTaskListEntity entity) => entity.id == list.id) !=
            -1;
      }).toList();

      // remove missing lists from any subsource lists for views
      for (TaskView view in source.views) {
        List<String> idsToRemove = removedLists
            .map((GoogleTaskList googleTaskList) => googleTaskList.id)
            .toList();
        view.removeSubSources(idsToRemove);
      }

      // THE BELOW THINGS ONLY NEED TO HAPPEN BECAUSE WE'RE HARDCODING VIEWS TO LISTS

      // remove any views that don't have a subSource (i.e. no associated list)
      source.views = source.views.where((TaskView view) {
        return view.subSourceIDs.isNotEmpty;
      }).toList();

      // check if there's any lists that don't have a view
      for (GoogleTaskList list in source.lists) {
        List<TaskView> viewsWithList = source.views.where((TaskView view) {
          return view.subSourceIDs.contains(list.id);
        }).toList();

        // if no views reference it, create a view for it
        if (viewsWithList.isEmpty) {
          TaskView newView = TaskView(list.title);
          newView.addSubSourceID([list.id]);
          // allow tasks with or without due dates
          TaskViewFilter newFilter = TaskViewFilter(null, true);
          newView.addFilter(newFilter);
          source.views.add(newView);
        }
      }

      // if any views have a list as its id, but not the same name, rename the view to be the list's
      for (TaskView view in source.views) {
        if (view.subSourceIDs.length > 0) {
          GoogleTaskList associatedList =
              source.lists.firstWhere((GoogleTaskList list) {
            return list.id == view.subSourceIDs[0];
          });
          if (view.title != associatedList.title) {
            view.title = associatedList.title;
          }
        }
      }

      // TODO:  remove this once adding view within app is possible
      // temporarily build a view for each list
      if (source.views.isEmpty) {
        for (GoogleTaskList list in source.lists) {
          // give the same name as the list we're pulling from
          TaskView newView = TaskView(list.title);
          newView.addSubSourceID([list.id]);
          // allow tasks with or without due dates
          TaskViewFilter newFilter = TaskViewFilter(null, true);
          newView.addFilter(newFilter);
          source.views.add(newView);
        }
      }

      // THE ABOVE THINGS ONLY NEED TO HAPPEN BECAUSE WE'RE HARDCODING VIEWS TO LISTS

      // sync views
      for (TaskView view in source.views) {
        view = await updateViewFromCache(view, planDate);
      }

      source.updateDateUpdatedFor(planDate);
      source.isSetUp = true;
      return source;
    } else {
      throw new Exception(
          "Tried to call updateSourceFromCache on GoogleTasksRepository"
          " for a source with type: ${source.runtimeType} rather than GoogleTasksSource");
    }
  }

  static Future<TaskView> updateViewFromCache(
      TaskView view, DateTime planDate) async {
    // gather tasks from sources
    List<GoogleTaskEntity> tasks = [];
    GoogleTasksCache cache = await GoogleTasksCache.getInstance();

    if (view.subSourceIDs == null || view.subSourceIDs.isEmpty) {
      // get from all lists
      List<GoogleTaskListEntity> taskLists = await cache.getGoogleTaskLists();
      for (GoogleTaskListEntity taskList in taskLists) {
        List<GoogleTaskEntity> retrievedTasks =
            await GoogleTasksProvider.getGoogleTasksFromList(taskList.id);
        tasks.addAll(retrievedTasks);
      }
    } else {
      // get from specified lists
      for (String id in view.subSourceIDs) {
        List<GoogleTaskEntity> retrievedTasks =
            await cache.getGoogleTasksFromList(id);
        tasks.addAll(retrievedTasks);
      }
    }

    // filter gathered tasks by view filters
    for (TaskViewFilter filter in view.filters) {
      tasks = tasks.where((GoogleTaskEntity aTask) {
        return filter.toFilterFunction(planDate)(aTask.dueDate);
      }).toList();
    }

    List<TaskItem> taskItems = [];
    for (GoogleTaskEntity taskEntity in tasks) {
      taskItems.add(taskEntity.toTaskItem());
    }

    view.items = taskItems;
    return view;
  }
}
