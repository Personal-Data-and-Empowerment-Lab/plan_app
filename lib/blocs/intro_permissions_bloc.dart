import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:permission_handler/permission_handler.dart';

part 'intro_permissions_event.dart';
part 'intro_permissions_state.dart';

class IntroPermissionsBloc
    extends Bloc<IntroPermissionsEvent, IntroPermissionsState> {
  IntroPermissionsBloc() : super();

  static final String storagePermissionID = "storage";

  @override
  Stream<IntroPermissionsState> mapEventToState(
    IntroPermissionsEvent event,
  ) async* {
    if (event is PermissionGranted) {
      yield* _mapPermissionGrantedToState(event);
    } else if (event is LoadPermissions) {
      yield* _mapLoadPermissionsToState(event);
    }
  }

  @override
  IntroPermissionsState get initialState {
    Map<PermissionGroup, PermissionView> permissionViews = Map();
    PermissionView storagePermissionView = PermissionView(
        "File storage",
        null,
        "We need access to file storage to save logs about how you plan.\n\n"
            "We only access files we have created.",
        true);
    permissionViews[PermissionGroup.storage] = storagePermissionView;
    PermissionView calendarPermissionView = PermissionView(
        "Calendars",
        null,
        "Providing access to the calendars on this device allows us to make copying in your events easier.",
        false);
    permissionViews[PermissionGroup.calendar] = calendarPermissionView;
    PermissionView notificationsPermissionView = PermissionView(
        "Notifications",
        null,
        "Allowing notifications lets you add reminders to items on your plan.",
        false);
    permissionViews[PermissionGroup.notification] = notificationsPermissionView;

    return IntroPermissionsInitial(permissionViews);
  }

  Stream<IntroPermissionsState> _mapPermissionGrantedToState(
      PermissionGranted event) async* {
    Map<PermissionGroup, PermissionView> newCopy =
        new Map.from(event.permissionViews);
    newCopy[event.permissionGroup] =
        newCopy[event.permissionGroup].copyWith(granted: true);
    yield PermissionsLoaded(newCopy);
  }

  Stream<IntroPermissionsState> _mapLoadPermissionsToState(
      LoadPermissions event) async* {
    Map<PermissionGroup, PermissionView> localCopy = event.permissionViews;
    for (PermissionGroup permissionGroup in localCopy.keys) {
      bool granted = await isPermissionGranted(permissionGroup);
      localCopy[permissionGroup] =
          localCopy[permissionGroup].copyWith(granted: granted);
      Map<PermissionGroup, PermissionView> newCopy = new Map.from(localCopy);
      yield PermissionsLoaded(newCopy);
    }
  }

  Future<bool> isPermissionGranted(PermissionGroup permission) async {
    var status = await PermissionHandler().checkPermissionStatus(permission);
    return status == PermissionStatus.granted;
  }
}
