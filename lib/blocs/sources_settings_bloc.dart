import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:planv3/models/CalendarSourceSettingsViewItem.dart';
import 'package:planv3/models/CanvasTasksSource.dart';
import 'package:planv3/models/DeviceCalendarsSource.dart';
import 'package:planv3/models/GoogleTasksSource.dart';
import 'package:planv3/models/SnackBarData.dart';
import 'package:planv3/models/TaskSourceSettingsViewItem.dart';
import 'package:planv3/repositories/CanvasTasksRepository.dart';
import 'package:planv3/repositories/CanvasTasksSourceRepository.dart';
import 'package:planv3/repositories/DeviceCalendarsSourceRepository.dart';
import 'package:planv3/repositories/GoogleTasksRepository.dart';
import 'package:planv3/repositories/GoogleTasksSourceRepository.dart';

import './bloc.dart';

class SourcesSettingsBloc
    extends Bloc<SourcesSettingsEvent, SourcesSettingsState> {
  DeviceCalendarsSource _deviceCalendarsSource;
  GoogleTasksSource _googleTasksSource;
  CanvasTasksSource _canvasTasksSource;

  SourcesSettingsBloc() {
    this.add(LoadSourcesSettings());
  }

  @override
  SourcesSettingsState get initialState => InitialSourcesSettingsState();

  @override
  Stream<SourcesSettingsState> mapEventToState(
    SourcesSettingsEvent event,
  ) async* {
    if (event is LoadSourcesSettings) {
      yield* _mapLoadSourcesSettingsToState(event);
    } else if (event is SetUpSourceSettings) {
      yield* _mapSetUpSourceSettingsToState(event);
    } else if (event is ManageViews) {
      yield* _mapManageViewsToState(event);
    } else if (event is SaveSourcesSettings) {
      yield* _mapSaveSourcesSettingsToState(event);
    } else if (event is CancelSourcesSettings) {
      yield* _mapCancelSourcesSettingsToState(event);
    } else if (event is SourceVisibilityChanged) {
      yield* _mapSourceVisibilityChanged(event);
    } else if (event is ViewSettingsChanged) {
      yield* _mapViewSettingsChangedToState(event);
    } else if (event is SourceSetupCancelled) {
      yield* _mapSourceSetupCancelledToState(event);
    } else if (event is SourceSyncCancelled) {
      yield* _mapSourceSyncCancelledToState(event);
    }
  }

  Stream<SourcesSettingsState> _mapLoadSourcesSettingsToState(
      LoadSourcesSettings event) async* {
    await _reloadSourcesFromStorage();

    CalendarSourceSettingsViewItem deviceCalendarViewItem =
        _deviceCalendarsSource.toCalendarSourceSettingsViewItem();

    TaskSourceSettingsViewItem googleTasksViewItem =
        _googleTasksSource.toTaskSourceSettingsViewItem();

    TaskSourceSettingsViewItem canvasTasksViewItem =
        _canvasTasksSource.toTaskSourceSettingsViewItem();

    List sourceSettingsViewItems = [
      deviceCalendarViewItem,
      googleTasksViewItem,
      canvasTasksViewItem
    ];

    yield SourcesSettingsLoaded(sourceSettingsViewItems);
  }

  Future<void> _reloadSourcesFromStorage() async {
    // get device calendar source
    _deviceCalendarsSource =
        await DeviceCalendarsSourceRepository.readDeviceCalendarsSettings();
    if (_deviceCalendarsSource == null) {
      _deviceCalendarsSource = DeviceCalendarsSource([]);
    }
    // get google tasks source
    _googleTasksSource = await GoogleTasksSourceRepository().readTasksSource();
    if (_googleTasksSource == null) {
      _googleTasksSource = GoogleTasksSource();
    }

    // get canvas tasks source
    _canvasTasksSource =
        await CanvasTasksSourceRepository().readTasksSource() ??
            CanvasTasksSource();
  }

  Stream<SourcesSettingsState> _mapSetUpSourceSettingsToState(
      SetUpSourceSettings event) async* {
    CalendarSourceSettingsViewItem deviceCalendarViewItem =
        _deviceCalendarsSource.toCalendarSourceSettingsViewItem();

    TaskSourceSettingsViewItem googleTasksViewItem =
        _googleTasksSource.toTaskSourceSettingsViewItem();

    List sourceSettingsViewItems = [];

    if (event.sourceID == _googleTasksSource.id) {
      yield* _setUpGoogleTasksSource(_googleTasksSource);
    } else if (event.sourceID == _canvasTasksSource.id) {
      yield* _setUpCanvasTasksSource(_canvasTasksSource);
    } else if (event.sourceID == _deviceCalendarsSource.id) {
      yield* _setUpDeviceCalendarsSource(_deviceCalendarsSource);
    }

//    deviceCalendarViewItem = _deviceCalendarsSource.toCalendarSourceSettingsViewItem();
//
//    googleTasksViewItem = _googleTasksSource.toTaskSourceSettingsViewItem();
//
//    sourceSettingsViewItems = [deviceCalendarViewItem, googleTasksViewItem];
//
//    yield SourcesSettingsLoaded(sourceSettingsViewItems);
  }

  Stream<SourcesSettingsState> _mapSourceSetupCancelledToState(event) async* {
    if (event.sourceID == _canvasTasksSource.id) {
      _canvasTasksSource.isSettingUp = false;
      _canvasTasksSource.isSetUp = false;
      _canvasTasksSource.isSyncing = false;
      await CanvasTasksSourceRepository().writeTasksSource(_canvasTasksSource);
      TaskSourceSettingsViewItem canvasTasksSourceViewItem =
          _canvasTasksSource.toTaskSourceSettingsViewItem();
      yield SourcesSettingsLoaded([canvasTasksSourceViewItem]);
    } else if (event.sourceID == _googleTasksSource.id) {
      _googleTasksSource.isSettingUp = false;
      _googleTasksSource.isSetUp = false;
      _googleTasksSource.isSyncing = false;
      await GoogleTasksSourceRepository().writeTasksSource(_googleTasksSource);
      TaskSourceSettingsViewItem googleTasksSourceViewItem =
          _googleTasksSource.toTaskSourceSettingsViewItem();
      yield SourcesSettingsLoaded([googleTasksSourceViewItem]);
    } else {
      throw UnimplementedError();
    }
  }

  Stream<SourcesSettingsState> _mapSourceSyncCancelledToState(event) async* {
    if (event.sourceID == _canvasTasksSource.id) {
      _canvasTasksSource.isSettingUp = false;
      _canvasTasksSource.isSetUp = true;
      _canvasTasksSource.isSyncing = false;
      await CanvasTasksSourceRepository().writeTasksSource(_canvasTasksSource);
      TaskSourceSettingsViewItem canvasTasksSourceViewItem =
          _canvasTasksSource.toTaskSourceSettingsViewItem();
      yield SourcesSettingsLoaded([canvasTasksSourceViewItem]);
    } else if (event.sourceID == _deviceCalendarsSource.id) {
      _deviceCalendarsSource.isSettingUp = false;
      _deviceCalendarsSource.isSetUp = true;
      _deviceCalendarsSource.isSyncing = false;
      await DeviceCalendarsSourceRepository.writeDeviceCalendarsSettings(
          _deviceCalendarsSource);
      CalendarSourceSettingsViewItem calendarSourceSettingsViewItem =
          _deviceCalendarsSource.toCalendarSourceSettingsViewItem();

      yield SourcesSettingsLoaded([calendarSourceSettingsViewItem]);
    } else if (event.sourceID == _googleTasksSource.id) {
      _googleTasksSource.isSettingUp = false;
      _googleTasksSource.isSetUp = true;
      _googleTasksSource.isSyncing = false;
      await _googleTasksSource
          .getSourceRepository()
          .writeTasksSource(_googleTasksSource);
      yield SourcesSettingsLoaded(
          [_googleTasksSource.toTaskSourceSettingsViewItem()]);
    } else {
      throw UnimplementedError();
    }
  }

  Stream<SourcesSettingsState> _setUpGoogleTasksSource(
      GoogleTasksSource googleTasksSource) async* {
    _googleTasksSource.isSettingUp = true;
    TaskSourceSettingsViewItem googleTasksViewItem =
        _googleTasksSource.toTaskSourceSettingsViewItem();

    await GoogleTasksSourceRepository().writeTasksSource(_googleTasksSource);
    yield SourcesSettingsLoaded([googleTasksViewItem]);

    try {
      await GoogleTasksRepository.signIn();
      _googleTasksSource.isSetUp = true;
      _googleTasksSource.isSettingUp = false;
      _googleTasksSource.isSyncing = true;

      googleTasksViewItem = _googleTasksSource.toTaskSourceSettingsViewItem();
      await GoogleTasksSourceRepository().writeTasksSource(_googleTasksSource);
      yield SourcesSettingsLoaded([googleTasksViewItem]);
      await this._manualSyncGoogleTasks();
      _googleTasksSource.isSyncing = false;
      await GoogleTasksSourceRepository().writeTasksSource(_googleTasksSource);
    } catch (error) {
      yield DisplayingSourcesSettingsErrorMessage(SnackBarData(
          messageText: "There was an error setting up Google Tasks"));
      _googleTasksSource.isSettingUp = false;
      _googleTasksSource.isSyncing = false;
      googleTasksViewItem = _googleTasksSource.toTaskSourceSettingsViewItem();
      await GoogleTasksSourceRepository().writeTasksSource(_googleTasksSource);
      yield SourcesSettingsLoaded([googleTasksViewItem]);
    }

    googleTasksViewItem = _googleTasksSource.toTaskSourceSettingsViewItem();
    yield SourcesSettingsLoaded([googleTasksViewItem]);
  }

  Stream<SourcesSettingsState> _setUpCanvasTasksSource(
      CanvasTasksSource canvasTasksSource) async* {
    _canvasTasksSource.isSettingUp = true;
    await CanvasTasksSourceRepository().writeTasksSource(_canvasTasksSource);
    TaskSourceSettingsViewItem canvasTasksViewItem =
        _canvasTasksSource.toTaskSourceSettingsViewItem();
    yield SourcesSettingsLoaded([canvasTasksViewItem]);

    final storage = new FlutterSecureStorage();

    String canvasToken = await storage.read(key: "canvasToken");
    if (canvasToken != null) {
      _canvasTasksSource.isSetUp = true;
      _canvasTasksSource.isSettingUp = false;
      _canvasTasksSource.isSyncing = true;
      _canvasTasksSource.isVisible = true;
      await CanvasTasksSourceRepository().writeTasksSource(_canvasTasksSource);
      canvasTasksViewItem = _canvasTasksSource.toTaskSourceSettingsViewItem();
      yield SourcesSettingsLoaded([canvasTasksViewItem]);

      try {
        await _updateCanvasTasks();
        _canvasTasksSource.isSettingUp = false;
        _canvasTasksSource.isSyncing = false;
        _canvasTasksSource.isSetUp = true;
        _canvasTasksSource.isVisible = true;
      } catch (error) {
        yield DisplayingSourcesSettingsErrorMessage(SnackBarData(
            messageText: "There was an error setting up Canvas Tasks"));
        _canvasTasksSource.isSettingUp = false;
        _canvasTasksSource.isSyncing = false;
        _canvasTasksSource.isSetUp = false;
        _canvasTasksSource.isVisible = false;
        canvasTasksViewItem = _googleTasksSource.toTaskSourceSettingsViewItem();
        await CanvasTasksSourceRepository()
            .writeTasksSource(_canvasTasksSource);
        yield SourcesSettingsLoaded([canvasTasksViewItem]);
      }

      await CanvasTasksSourceRepository().writeTasksSource(_canvasTasksSource);
      canvasTasksViewItem = _canvasTasksSource.toTaskSourceSettingsViewItem();
      yield SourcesSettingsLoaded([canvasTasksViewItem]);
    } else {
      yield SettingUpCanvas();
    }
  }

  Stream<SourcesSettingsState> _setUpDeviceCalendarsSource(
      DeviceCalendarsSource deviceCalendarsSource) async* {
    _deviceCalendarsSource.isSettingUp = true;
    await DeviceCalendarsSourceRepository.writeDeviceCalendarsSettings(
        _deviceCalendarsSource);
    CalendarSourceSettingsViewItem deviceCalendarViewItem =
        _deviceCalendarsSource.toCalendarSourceSettingsViewItem();

    yield SourcesSettingsLoaded([deviceCalendarViewItem]);

    DeviceCalendarPlugin _deviceCalendarPlugin = new DeviceCalendarPlugin();

    try {
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      if (permissionsGranted.isSuccess && !permissionsGranted.data) {
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        if (!permissionsGranted.isSuccess || !permissionsGranted.data) {
          _deviceCalendarsSource.isSetUp = false;
          _deviceCalendarsSource.isSettingUp = false;
          _deviceCalendarsSource.isSyncing = false;
          DeviceCalendarsSourceRepository.writeDeviceCalendarsSettings(
              _deviceCalendarsSource);
        } else {
          _deviceCalendarsSource.isSetUp = true;
          _deviceCalendarsSource.isSettingUp = false;
          _deviceCalendarsSource.isSyncing = true;
          DeviceCalendarsSourceRepository.writeDeviceCalendarsSettings(
              _deviceCalendarsSource);
          deviceCalendarViewItem =
              _deviceCalendarsSource.toCalendarSourceSettingsViewItem();
          yield SourcesSettingsLoaded([deviceCalendarViewItem]);
          await this._updateDeviceCalendar();
          this._deviceCalendarsSource.isSyncing = false;
          DeviceCalendarsSourceRepository.writeDeviceCalendarsSettings(
              _deviceCalendarsSource);
        }
      } else if (permissionsGranted.isSuccess) {
        _deviceCalendarsSource.isSetUp = true;
        _deviceCalendarsSource.isSettingUp = false;
        _deviceCalendarsSource.isSyncing = true;
        DeviceCalendarsSourceRepository.writeDeviceCalendarsSettings(
            _deviceCalendarsSource);
        deviceCalendarViewItem =
            _deviceCalendarsSource.toCalendarSourceSettingsViewItem();
        yield SourcesSettingsLoaded([deviceCalendarViewItem]);
        await this._updateDeviceCalendar();
        _deviceCalendarsSource.isSyncing = false;
        DeviceCalendarsSourceRepository.writeDeviceCalendarsSettings(
            _deviceCalendarsSource);
      }
    } catch (error) {
//        yield DisplayingSourcesSettingsErrorMessage(
//          SnackBarData(messageText: stacktrace.toString() + "\n" + error.toString())
//        );
      _deviceCalendarsSource.isSetUp = false;
      _deviceCalendarsSource.isSettingUp = false;
      _deviceCalendarsSource.isSyncing = false;
      DeviceCalendarsSourceRepository.writeDeviceCalendarsSettings(
          _deviceCalendarsSource);
      deviceCalendarViewItem =
          _deviceCalendarsSource.toCalendarSourceSettingsViewItem();
      yield SourcesSettingsLoaded([deviceCalendarViewItem]);
    }

    deviceCalendarViewItem =
        _deviceCalendarsSource.toCalendarSourceSettingsViewItem();
    yield SourcesSettingsLoaded([deviceCalendarViewItem]);
  }

  Stream<SourcesSettingsState> _mapManageViewsToState(
      ManageViews event) async* {
    if (event.sourceID == _deviceCalendarsSource.id) {
      yield OpeningCalendarSourceViewSettings(_deviceCalendarsSource);
      yield SourcesSettingsLoaded([]);
    } else if (event.sourceID == _googleTasksSource.id) {
      yield OpeningTaskSourceViewSettings(_googleTasksSource);
      yield SourcesSettingsLoaded([]);
    } else if (event.sourceID == _canvasTasksSource.id) {
      yield OpeningTaskSourceViewSettings(_canvasTasksSource);
      yield SourcesSettingsLoaded([]);
    } else {
      throw Exception("Manage views pressed on a source with an unknown id.");
    }
  }

  Stream<SourcesSettingsState> _mapSaveSourcesSettingsToState(
      SaveSourcesSettings event) async* {}

  Stream<SourcesSettingsState> _mapCancelSourcesSettingsToState(
      CancelSourcesSettings event) async* {}

  bool _sourceShouldSync(var source) {
    return !(source == null || !source.isSetUp || !source.isVisible);
  }

  Stream<SourcesSettingsState> _mapViewSettingsChangedToState(
      ViewSettingsChanged event) async* {
    await _reloadSourcesFromStorage();
    //    yield SourcesListSyncing();
    if (_sourceShouldSync(_deviceCalendarsSource)) {
      await _updateDeviceCalendar();
    }

    if (_sourceShouldSync(_googleTasksSource)) {
      await _updateGoogleTasks();
    }
  }

  Stream<SourcesSettingsState> _mapSourceVisibilityChanged(
      SourceVisibilityChanged event) async* {
    if (event.sourceID == _deviceCalendarsSource.id) {
      _deviceCalendarsSource.isVisible = event.newValue;
      DeviceCalendarsSourceRepository.writeDeviceCalendarsSettings(
          _deviceCalendarsSource);
    } else if (event.sourceID == _googleTasksSource.id) {
      _googleTasksSource.isVisible = event.newValue;
      GoogleTasksSourceRepository().writeTasksSource(_googleTasksSource);
    } else if (event.sourceID == _canvasTasksSource.id) {
      _canvasTasksSource.isVisible = event.newValue;
      CanvasTasksSourceRepository().writeTasksSource(_canvasTasksSource);
    } else {
      throw Exception(
          "The sourceID doesn't match a registered source. Maybe you forgot to add it here?");
    }
  }

  Stream<SourcesSettingsState> _sendViewData(List viewItems) {}

  // HELPER FUNCTIONS --- DO NOT YIELD STATE
  Future<void> _manualSyncGoogleTasks() async {
    try {
      _googleTasksSource = await GoogleTasksRepository()
          .updateSource(_googleTasksSource, DateTime.now(), forceSync: true);
    } catch (error) {
      this.add(ShowSourcesSettingsError(
          SnackBarData(messageText: "Could not connect to Google Tasks")));
      _googleTasksSource.isSetUp = false;
    }

    await GoogleTasksSourceRepository().writeTasksSource(_googleTasksSource);
  }

  Future<void> _updateGoogleTasks() async {
    // get lists and update views
//    googleTasksSource = await googleTasksRepository.syncSource(googleTasksSource, editorBloc.plan.date);
    // NEW METHOD
    try {
      _googleTasksSource = await GoogleTasksRepository()
          .updateSource(_googleTasksSource, DateTime.now());
    } catch (error) {
      this.add(ShowSourcesSettingsError(
          SnackBarData(messageText: "Could not connect to Google Tasks")));
      _googleTasksSource.isSetUp = false;
    }

    // end new method

    // update in file storage
    await GoogleTasksSourceRepository().writeTasksSource(_googleTasksSource);
  }

  Future<void> _updateCanvasTasks() async {
    try {
      _canvasTasksSource = await CanvasTasksRepository()
          .updateSource(_canvasTasksSource, DateTime.now());
    } catch (error) {
      this.add(ShowSourcesSettingsError(
          SnackBarData(messageText: "Could not connect to Canvas")));
      _canvasTasksSource.isSetUp = false;
    }

    await CanvasTasksSourceRepository().writeTasksSource(_canvasTasksSource);
  }

  Future<void> _updateDeviceCalendar() async {
    // sync with device calendar
    await _deviceCalendarsSource.syncDeviceCalendarSource(DateTime.now());
  }
}
