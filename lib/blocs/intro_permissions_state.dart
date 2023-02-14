part of 'intro_permissions_bloc.dart';

abstract class IntroPermissionsState extends Equatable {
  final Map<PermissionGroup, PermissionView> permissionViews;

  const IntroPermissionsState(this.permissionViews);

  @override
  List<Object> get props => [this.permissionViews];
}

class IntroPermissionsInitial extends IntroPermissionsState {
  IntroPermissionsInitial(permissionViews) : super(permissionViews);

  @override
  List<Object> get props => [this.permissionViews];
}

class PermissionsLoaded extends IntroPermissionsState {
  PermissionsLoaded(permissionViews) : super(permissionViews);

  @override
  List<Object> get props => [this.permissionViews];
}

class PermissionView {
  final String title;
  final bool granted;
  final String description;
  final bool required;

  PermissionView(this.title, this.granted, this.description, this.required);

  PermissionView copyWith(
      {String title, bool granted, String description, bool required}) {
    return PermissionView(title ?? this.title, granted ?? this.granted,
        description ?? this.description, required ?? this.required);
  }
}
