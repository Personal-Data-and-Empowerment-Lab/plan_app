part of 'intro_permissions_bloc.dart';

abstract class IntroPermissionsEvent extends Equatable {
  const IntroPermissionsEvent();
}

class PermissionGranted extends IntroPermissionsEvent {
  final Map<PermissionGroup, PermissionView> permissionViews;
  final PermissionGroup permissionGroup;

  PermissionGranted(this.permissionViews, this.permissionGroup);

  @override
  List<Object> get props => [this.permissionViews, this.permissionGroup];
}

class LoadPermissions extends IntroPermissionsEvent {
  final Map<PermissionGroup, PermissionView> permissionViews;

  LoadPermissions(this.permissionViews);

  @override
  List<Object> get props => [this.permissionViews];
}
