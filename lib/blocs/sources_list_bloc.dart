import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:f_logs/model/flog/flog.dart';
import 'package:f_logs/model/flog/log_level.dart';
import 'package:planv3/interfaces/TaskSource.dart';
import 'package:planv3/models/CalendarSourceViewItem.dart';
import 'package:planv3/models/CalendarViewViewItem.dart';
import 'package:planv3/models/DeviceCalendarsSource.dart';
import 'package:planv3/models/EventItem.dart';
import 'package:planv3/models/EventViewItem.dart';
import 'package:planv3/models/SourcesListViewData.dart';
import 'package:planv3/models/TaskSourceViewItem.dart';
import 'package:planv3/models/TaskView.dart';
import 'package:planv3/repositories/DeviceCalendarsSourceRepository.dart';
import 'package:planv3/repositories/TaskSourcesManager.dart';

import './bloc.dart';

enum SortType { DueDate_A, DueDate_D, Alphabetical_A, Alphabetical_D, Original }

class SourcesListBloc extends Bloc<SourcesListEvent, SourcesListState> {
  EditorBloc editorBloc;

  Map<String, TaskSource> _taskSources = Map();

  // Google Tasks settings
//  GoogleTasksSource googleTasksSource;
  // Calendar settings
  DeviceCalendarsSource deviceCalendarsSource;

  // Calendar repo

  SourcesListBloc(this.editorBloc) {
    if (this.editorBloc.inTutorial) {
      this.add(LoadTutorialSources());
    } else {
      this.add(LoadInitialSources());
    }
  }

  @override
  SourcesListState get initialState => InitialSourcesListState();

  @override
  Stream<SourcesListState> mapEventToState(
    SourcesListEvent event,
  ) async* {
//    if (event is Sync) {
//      yield* _mapSyncToState(event);
//    }
    if (event is SyncAll) {
      yield* _mapSyncAllToState(event);
    } else if (event is LoadInitialSources) {
      yield* _mapLoadInitialSourcesToState(event);
    } else if (event is AddSelectionToPlan) {
      yield* _mapAddSelectionToPlanToState(event);
    } else if (event is SaveSourcesListLayout) {
      yield* _mapSaveSourcesListLayoutToState(event);
    } else if (event is SetUpSource) {
//      yield* _mapSetUpSourceToState(event);
      throw Exception("SetUpSource is not supported anymore");
    } else if (event is SourceExpansionChanged) {
      yield* _mapSourceExpansionChangedToState(event);
    } else if (event is ViewExpansionChanged) {
      yield* _mapViewExpansionChangedToState(event);
    } else if (event is ViewSortTypeChanged) {
      yield* _mapViewSortTypeChangedToState(event);
    } else if (event is SourceSettingsChanged) {
      yield* _mapSourceSettingsChangedToState(event);
    } else if (event is LoadTutorialSources) {
      yield* _mapLoadTutorialSourcesToState(event);
    } else if (event is AddTutorialSelectionToPlan) {
      yield* _mapAddTutorialSelectionToPlan(event);
    }
  }

  // TODO: for syncing individual sources
//  Stream<SourcesListState> _mapSyncToState(Sync event) async* {
//    yield SourcesListLoading();
//    // get source by ID
//    if (event.sourceID == googleTasksSource.id) {
//      // sync tasks
//      TaskSourceViewItem taskSourceViewItem = await _updateGoogleTasks();
//      yield SourcesListLoaded(event.viewData.copyWith(taskSourceViewData: taskSourceViewItem));
//    }
//    else if (event.sourceID == deviceCalendarsSource.id)
//    {
//      // update in list
//      CalendarSourceViewItem calendarSourceViewItem = await _updateDeviceCalendar();
//      yield SourcesListLoaded(event.viewData.copyWith(deviceCalendarViewData: calendarSourceViewItem));
//    }
//
//  }

  Stream<SourcesListState> _mapLoadInitialSourcesToState(
      LoadInitialSources event) async* {
    yield SourcesListLoading();

    // gather all sources that should be visible
    // maybe get these from some other manager that maintains a list
    this._taskSources = await TaskSourcesManager.getVisibleTaskSources();
//    yield SourcesListSyncing();
//    googleTasksSource = await GoogleTasksSourceRepository().readTasksSource();
//    if (googleTasksSource == null) {
//      googleTasksSource = GoogleTasksSource();
//    }

//    TaskSourceViewItem taskSourceViewItem = _buildTaskSourceViewItem(googleTasksSource);

    deviceCalendarsSource =
        await DeviceCalendarsSourceRepository.readDeviceCalendarsSettings();
    if (deviceCalendarsSource == null) {
      deviceCalendarsSource = DeviceCalendarsSource([]);
    }

    // THIS COMMENTED OUT STUFF SHOULD BE HANDLED BY THE SENDSOURCELISTVIEWDATA FUNCTION
//    // if none of the sources are set up or have any contents, send SetUpFirstSourceState
//    if (!(googleTasksSource.isSetUp ?? false) &&
//        !(deviceCalendarsSource.isSetUp ?? false))
//      {
//        yield(SetUpFirstSource());
//        return;
//      }
//    // if there's sources set up, but none are visible, send MakeSourcesVisibleState
//    else if (!(googleTasksSource.isVisible ?? false) && !(deviceCalendarsSource.isVisible ?? false)) {
//      yield(MakeSourcesVisible());
//      return;
//    }
//    else {
////      String message = "task set: ${googleTasksSource.isSetUp} task empty: ${googleTasksSource.views.length}"
////          " cal set: ${deviceCalendarsSource.isSetUp} cal empty: ${deviceCalendarsSource.calendars.length}";
////
////      editorBloc.add(Error(Exception(message)));
//    }

    CalendarSourceViewItem calendarSourceViewItem =
        _buildCalendarViewItem(deviceCalendarsSource);

    SourcesListViewData sourceListViewData = SourcesListViewData(
        calendarSourceViewItem,
        this._buildTaskSourceViewItems(this._taskSources));

    // send what we initially got for speed
    yield* this._sendSourceListViewData(sourceListViewData);
//    yield SourcesListSyncing();
    if (deviceCalendarsSource.isSetUp) {
      // now check to see what we need to sync
      DateTime now = DateTime.now();
      DateTime beginningOfToday = DateTime(now.year, now.month, now.day);
      DateTime planDateBeginningOfDay = DateTime(editorBloc.plan.date.year,
          editorBloc.plan.date.month, editorBloc.plan.date.day);
      // if calendar source hasn't been updated today
      if (deviceCalendarsSource.lastUpdatedBefore(beginningOfToday)) {
        // sync with device
        await _updateDeviceCalendar();

        sourceListViewData = sourceListViewData.copyWith(
            deviceCalendarViewData:
                _buildCalendarViewItem(deviceCalendarsSource));
        yield* this._sendSourceListViewData(sourceListViewData);
        DeviceCalendarsSourceRepository.writeDeviceCalendarsSettings(
            deviceCalendarsSource);
      }
      // if the data isn't for the current day
      else if (!deviceCalendarsSource.updatedForDate(planDateBeginningOfDay)) {
        await _updateDeviceCalendar();
        sourceListViewData = sourceListViewData.copyWith(
            deviceCalendarViewData:
                _buildCalendarViewItem(deviceCalendarsSource));
        yield* this._sendSourceListViewData(sourceListViewData);
        DeviceCalendarsSourceRepository.writeDeviceCalendarsSettings(
            deviceCalendarsSource);
        // _updateDeviceCalendar().then((data) async* {
        //
        // });
      }
    }

    // for each task source in map, update, then TODO: yield new state as soon as it's done
    for (TaskSource taskSource in this._taskSources.values) {
      // update source
      try {
        if (_sourceShouldSync(taskSource)) {
          taskSource = await taskSource
              .getRepository()
              .updateSource(taskSource, editorBloc.plan.date);
        }
      } catch (error) {
        editorBloc.add(Error(error));
        taskSource.onFailedUpdate();
      } finally {
        await taskSource.getSourceRepository().writeTasksSource(taskSource);
      }
    }

//    if (googleTasksSource.isSetUp) {
//      await _updateGoogleTasks();
//    }

    sourceListViewData = sourceListViewData.copyWith(
        taskSourceViewItems: this._buildTaskSourceViewItems(this._taskSources));

//    yield SourcesListLoaded(sourceListViewData);
    yield* this._sendSourceListViewData(sourceListViewData);
  }

  /**
   * Might need to reference the next two commented out methods again later
   * */
//  Future<void> _updateGoogleTasks() async {
//    // get lists and update views
////    googleTasksSource = await googleTasksRepository.syncSource(googleTasksSource, editorBloc.plan.date);
//    // NEW METHOD
//    try {
//      googleTasksSource = await GoogleTasksRepository().updateSource(googleTasksSource, editorBloc.plan.date);
//    } catch (error) {
//      editorBloc.add(Error(error));
//      googleTasksSource.isSetUp = false;
//    }
//
//    // end new method
//
//    // update in file storage
//    await GoogleTasksSourceRepository().writeTasksSource(googleTasksSource);
//  }

//  Future<void> _manualSyncGoogleTasks() async {
//    try {
//      googleTasksSource = await GoogleTasksRepository().updateSource(googleTasksSource, editorBloc.plan.date, forceSync: true);
//    } catch (error) {
//      editorBloc.add(Error(error));
//      googleTasksSource.isSetUp = false;
//    }
//
//
//    await GoogleTasksSourceRepository().writeTasksSource(googleTasksSource);
//  }

//  List<TaskViewItem> _mapTasksToTaskViewItems(List<TaskItem> rawTasks) {
//    List<TaskViewItem> viewItems = rawTasks.map((TaskItem taskItem) => TaskViewItem(taskItem.title, taskItem.dueDate, null, taskItem.id)).toList();
//    for (int i = 0; i < viewItems.length; i++) {
//      viewItems[i].position = i;
//    }
//    return viewItems;
//  }

  Future<void> _updateDeviceCalendar() async {
    // sync with device calendar
    await deviceCalendarsSource.syncDeviceCalendarSource(editorBloc.plan.date);
  }

  bool _sourceShouldSync(var source) {
    return !(source == null || !source.isSetUp || !source.isVisible);
  }

  Future _setSourceSyncingValuesTo(bool syncing) async {
    deviceCalendarsSource.isSyncing = syncing;
    await DeviceCalendarsSourceRepository.writeDeviceCalendarsSettings(
        deviceCalendarsSource);

    for (TaskSource taskSource in this._taskSources.values) {
      taskSource.isSyncing = syncing;
      await taskSource.getSourceRepository().writeTasksSource(taskSource);
    }
  }

  SourcesListViewData _buildAllSourceViewItems() {
    CalendarSourceViewItem calendarSourceViewItem;
    if (_sourceShouldSync(deviceCalendarsSource)) {
      calendarSourceViewItem = _buildCalendarViewItem(deviceCalendarsSource);
    }

    Map<String, TaskSourceViewItem> taskSourceViewItems = {};
    for (TaskSource taskSource in this._taskSources.values) {
      if (_sourceShouldSync(taskSource)) {
        taskSourceViewItems[taskSource.id] = taskSource.toTaskSourceViewItem();
      }
    }

    return SourcesListViewData(calendarSourceViewItem, taskSourceViewItems);
  }

  Stream<SourcesListState> _mapSyncAllToState(SyncAll event) async* {
    yield SourcesListSyncing();
    await Future.delayed(Duration(milliseconds: 500));
    await this._setSourceSyncingValuesTo(true);
    yield* this._sendSourceListViewData(this._buildAllSourceViewItems());
    await Future.delayed(Duration(milliseconds: 500));
    CalendarSourceViewItem calendarSourceViewItem;

    if (_sourceShouldSync(deviceCalendarsSource)) {
      await _updateDeviceCalendar();
      SourcesListViewData sourceListViewData = SourcesListViewData(
          _buildCalendarViewItem(deviceCalendarsSource), null);
      yield* this._sendSourceListViewData(sourceListViewData);

      DeviceCalendarsSourceRepository.writeDeviceCalendarsSettings(
          deviceCalendarsSource);
    }
//    yield SourcesListSyncing();
    for (TaskSource taskSource in this._taskSources.values) {
      if (_sourceShouldSync(taskSource)) {
        try {
//          yield SourcesListSyncing();
          taskSource = await taskSource
              .getRepository()
              .updateSource(taskSource, editorBloc.plan.date, forceSync: true);
          taskSource.onSuccessfulUpdate();
        } catch (error) {
          editorBloc.add(Error(error));
          taskSource.onFailedUpdate();
        } finally {
          await taskSource.getSourceRepository().writeTasksSource(taskSource);
        }
      }
    }

//    if (_sourceShouldSync(googleTasksSource)) {
//      await _manualSyncGoogleTasks();
//      taskSourceViewItem = this._buildTaskSourceViewItem(googleTasksSource);
//    }
    SourcesListViewData sourcesListViewData = SourcesListViewData(
        null, this._buildTaskSourceViewItems(this._taskSources));
//    SourcesListViewData sourceListViewData = event.viewData?.copyWith(
//        deviceCalendarViewData: calendarSourceViewItem,
//        taskSourceViewItems: this._buildTaskSourceViewItems(this._taskSources))
//          ?? SourcesListViewData(calendarSourceViewItem,
//              this._buildTaskSourceViewItems(this._taskSources));

//    yield SourcesListLoaded(sourceListViewData);
    await this._setSourceSyncingValuesTo(false);
    yield* this._sendSourceListViewData(this._buildAllSourceViewItems());
  }

  Stream<SourcesListState> _mapAddSelectionToPlanToState(
      AddSelectionToPlan event) async* {
    editorBloc.add(AddSourceItemsToPlan(event.viewData.getSelectedEventItems(),
        event.viewData.getSelectedTaskItems()));
  }

  CalendarSourceViewItem _buildCalendarViewItem(DeviceCalendarsSource source) {
    if (!_sourceShouldSync(source)) {
      return null;
    }

    // convert relevant events to view items
    List<EventViewItem> eventViewItems = source.events
        .map((EventItem eventItem) => EventViewItem.fromEventItem(eventItem))
        .toList();

    // create and add to view
    CalendarViewViewItem calendarViewViewItem =
        CalendarViewViewItem("Today", true, eventViewItems);
    return CalendarSourceViewItem(
        source.title,
        source.expanded,
        source.isSetUp,
        [calendarViewViewItem],
        source.id,
        source.isVisible,
        source.position,
        source.isSyncing);
  }

  Map<String, TaskSourceViewItem> _buildTaskSourceViewItems(
      Map<String, TaskSource> taskSourceMap) {
    Map<String, TaskSourceViewItem> returnMap = taskSourceMap.map(
        (String id, TaskSource taskSource) =>
            MapEntry(id, taskSource.toTaskSourceViewItem()));

    return returnMap;
  }

//  TaskSourceViewItem _buildTaskSourceViewItem(TaskSource source) {
//    if (!_sourceShouldSync(source)) {
//      return null;
//    }
//
//    List<TaskViewViewItem> viewViewItems = [];
//    // build view view items
//
//    if (source.isSetUp) {
//      for (TaskView view in source.views) {
//        if (view.active) {
//          List<TaskViewItem> taskViewItems = _mapTasksToTaskViewItems(view.items);
//          TaskViewViewItem viewViewItem = TaskViewViewItem(view.title,
//              view.id, view.expanded, taskViewItems, view.sortedBy, view.active);
//          viewViewItems.add(viewViewItem);
//        }
//
//      }
//
//    }
//
//    return TaskSourceViewItem(source.title, source.expanded, source.isSetUp, viewViewItems, source.id, source.isVisible, source.position);
//  }

  Stream<SourcesListState> _mapSaveSourcesListLayoutToState(
      SaveSourcesListLayout event) async* {
    // TODO: save the settings to persistence
    // for each view view item, update the relevant fields in the actual view model
  }

  Stream<SourcesListState> _mapSourceExpansionChangedToState(
      SourceExpansionChanged event) async* {
    if (this._taskSources.containsKey(event.sourceID)) {
      this._taskSources[event.sourceID].expanded = event.newValue;
      this
          ._taskSources[event.sourceID]
          .getSourceRepository()
          .writeTasksSource(this._taskSources[event.sourceID]);
    }
//    else if (event.sourceID == googleTasksSource.id) {
//      googleTasksSource.expanded = event.newValue;
//      GoogleTasksSourceRepository().writeTasksSource(googleTasksSource);
//    }
    else if (event.sourceID == deviceCalendarsSource.id) {
      deviceCalendarsSource.expanded = event.newValue;
      DeviceCalendarsSourceRepository.writeDeviceCalendarsSettings(
          deviceCalendarsSource);
    }
  }

  Stream<SourcesListState> _mapViewExpansionChangedToState(
      ViewExpansionChanged event) async* {
    if (this._taskSources.containsKey(event.sourceID)) {
      this
          ._taskSources[event.sourceID]
          .views
          .firstWhere((TaskView view) => view.id == event.viewID)
          ?.expanded = event.newValue;
      this
          ._taskSources[event.sourceID]
          .getSourceRepository()
          .writeTasksSource(this._taskSources[event.sourceID]);
    }
  }

//  Stream<SourcesListState> _mapSetUpSourceToState(SetUpSource event) async* {
//    if (event.sourceID == googleTasksSource.id) {
//      try {
//        await GoogleTasksRepository.signIn();
//        googleTasksSource.isSetUp = true;
//        yield SourcesListLoading();
//        await this._manualSyncGoogleTasks();
//      } catch (error) {
//        editorBloc.add(Error(error));
//      }
//    }
//    else if (event.sourceID == deviceCalendarsSource.id) {
//      DeviceCalendarPlugin _deviceCalendarPlugin = new DeviceCalendarPlugin();
//
//      try {
//        var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
//        if (permissionsGranted.isSuccess && !permissionsGranted.data) {
//          permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
//          if (!permissionsGranted.isSuccess || !permissionsGranted.data) {
//
//          }
//          else {
//            deviceCalendarsSource.isSetUp = true;
//            await this._updateDeviceCalendar();
//          }
//
//        }
//      } catch(error) {
//        editorBloc.add(Error(error));
//        deviceCalendarsSource.isSetUp = false;
//      }
//    }
//
//    CalendarSourceViewItem calendarSourceViewItem = this._buildCalendarViewItem(deviceCalendarsSource);
//    TaskSourceViewItem taskSourceViewItem = this._buildTaskSourceViewItem(googleTasksSource);
//
//    SourcesListViewData sourceListViewData = event.viewData?.copyWith(
//        deviceCalendarViewData: calendarSourceViewItem,
//        taskSourceViewData: taskSourceViewItem
//    ) ?? SourcesListViewData(calendarSourceViewItem, taskSourceViewItem);
//
////    yield SourcesListLoaded(sourceListViewData);
//    this._sendSourceListViewData(sourceListViewData);
//  }

  Stream<SourcesListState> _mapViewSortTypeChangedToState(
      ViewSortTypeChanged event) async* {
    if (this._taskSources.containsKey(event.sourceID)) {
      TaskView view = this._taskSources[event.sourceID].views.firstWhere(
          (TaskView view) => view.id == event.viewID,
          orElse: () => null);
      view?.sortedBy = event.newValue;

      this
          ._taskSources[event.sourceID]
          .getSourceRepository()
          .writeTasksSource(this._taskSources[event.sourceID]);
    }
  }

  Stream<SourcesListState> _mapSourceSettingsChangedToState(
      SourceSettingsChanged event) async* {
    // update the sources
    yield SourcesListSyncing();
    this._taskSources = await TaskSourcesManager.getVisibleTaskSources();

//    googleTasksSource = await GoogleTasksSourceRepository().readTasksSource();
//    if (googleTasksSource == null) {
//      googleTasksSource = GoogleTasksSource();
//    }

    deviceCalendarsSource =
        await DeviceCalendarsSourceRepository.readDeviceCalendarsSettings();
    if (deviceCalendarsSource == null) {
      deviceCalendarsSource = DeviceCalendarsSource([]);
    }

//    TaskSourceViewItem taskSourceViewItem = _buildTaskSourceViewItem(googleTasksSource);

    CalendarSourceViewItem calendarSourceViewItem =
        _buildCalendarViewItem(deviceCalendarsSource);

    SourcesListViewData sourceListViewData = SourcesListViewData(
        calendarSourceViewItem,
        this._buildTaskSourceViewItems(this._taskSources));

//    yield SourcesListLoaded(sourceListViewData);
    yield* this._sendSourceListViewData(sourceListViewData);
  }

  Stream<SourcesListState> _mapLoadTutorialSourcesToState(
      LoadTutorialSources event) async* {
    yield SourcesListTutorial();
  }

  Stream<SourcesListState> _mapAddTutorialSelectionToPlan(
      AddTutorialSelectionToPlan event) {
    editorBloc.add(AddTutorialSourceItemsToPlan(event.textToAdd));
  }

  Stream<SourcesListState> _sendSourceListViewData(
      SourcesListViewData viewData) async* {
    // if none of the sources are set up or have any contents, send SetUpFirstSourceState
    bool noTaskSourcesAreSetUp = this
            ._taskSources
            .values
            .where((TaskSource taskSource) => taskSource?.isSetUp ?? false)
            .length ==
        0;
    bool noTaskSourcesAreVisible = this
            ._taskSources
            .values
            .where((TaskSource taskSource) => taskSource?.isVisible ?? false)
            .length ==
        0;

    bool noCalendarSourcesAreSetUp = !(deviceCalendarsSource?.isSetUp ?? false);
    bool noCalendarSourcesAreVisible =
        !(deviceCalendarsSource?.isVisible ?? false);

    if (noTaskSourcesAreSetUp && noCalendarSourcesAreSetUp) {
      yield SetUpFirstSource();
      return;
    } else if ((!noTaskSourcesAreSetUp && noTaskSourcesAreVisible) &&
        (!noCalendarSourcesAreSetUp && noCalendarSourcesAreVisible)) {
      yield MakeSourcesVisible();
      return;
    }

    FLog.logThis(
      text: viewData.toLogString(),
      type: LogLevel.INFO,
      methodName: "SourcesListLoaded",
    );
    print(viewData.toString());
    yield SourcesListLoaded(viewData);
  }
}
