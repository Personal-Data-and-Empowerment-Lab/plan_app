import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:planv3/blocs/intro_permissions_bloc.dart';

class IntroPermissionsWidget extends StatefulWidget {
  @override
  IntroPermissionsWidgetState createState() => IntroPermissionsWidgetState();
}

class IntroPermissionsWidgetState extends State<IntroPermissionsWidget> {
  IntroPermissionsBloc _introPermissionsBloc;

  @override
  void initState() {
    _introPermissionsBloc = BlocProvider.of<IntroPermissionsBloc>(context);
    _introPermissionsBloc
        .add(LoadPermissions(_introPermissionsBloc.state.permissionViews));
    super.initState();
  }

  @override
  void dispose() {
    _introPermissionsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).unfocus();
    return BlocBuilder<IntroPermissionsBloc, IntroPermissionsState>(
        builder: (context, state) {
      return _mapStateToView(state);
    });
  }

  Widget _mapStateToView(IntroPermissionsState state) {
    Widget returnWidget = Container();
    if (state is IntroPermissionsInitial) {
      returnWidget =
          Column(children: _buildPermissionsList(state.permissionViews));
    } else if (state is PermissionsLoaded) {
      returnWidget =
          Column(children: _buildPermissionsList(state.permissionViews));
    } else {
      throw Exception("IntroPermissionsWidget is in an unknown state: $state");
    }

    return returnWidget;
  }

  List<Widget> _buildPermissionsList(
      Map<PermissionGroup, PermissionView> permissionViews) {
    List<Widget> returnWidgetList = [];

    for (PermissionGroup permissionGroup in permissionViews.keys) {
      returnWidgetList.add(_buildPermissionView(
          permissionGroup, permissionViews[permissionGroup]));
    }

    return returnWidgetList;
  }

  Widget _buildPermissionView(
      PermissionGroup permissionGroup, PermissionView permissionView) {
    Widget returnWidget = Card(
        child: Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildStatusIndicator(
                permissionView.granted, permissionView.required),
          ],
        ),
        title: Row(
          children: <Widget>[
            Text(permissionView.title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(permissionView.required ? "" : "(optional)",
                  style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 16,
                      color: Colors.grey)),
            )
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(permissionView.description),
              ),
              Visibility(
                visible: !(permissionView.granted ?? false),
                child: ButtonBar(
                    buttonPadding: EdgeInsets.all(0),
                    children: <Widget>[
                      TextButton(
                          child: Text("Accept",
                              style: TextStyle(color: Colors.black)),
                          onPressed: () {
                            requestPermission(permissionGroup)
                                .then((var result) {
                              if (result == PermissionStatus.granted) {
                                Map<PermissionGroup, PermissionView>
                                    permissionViews =
                                    _introPermissionsBloc.state.permissionViews;
//                                  permissionViews[permissionGroup] = permissionViews[permissionGroup].copyWith(granted: true);
                                _introPermissionsBloc.add(PermissionGranted(
                                    permissionViews, permissionGroup));
                              }
                            });
                          })
                    ]),
              )
            ],
          ),
        ),
      ),
    ));

    return returnWidget;
  }

  Widget _buildStatusIndicator(var granted, bool required) {
    if (granted == null) {
      return SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black)));
    } else {
      return Icon(granted ? Icons.done : Icons.warning,
          color: _buildIconColor(granted, required));
    }
  }

  Color _buildIconColor(bool granted, bool required) {
    if (granted) {
      return Colors.green;
    } else {
      if (required) {
        return Colors.red;
      } else {
        return Colors.grey;
      }
    }
  }

  Future<PermissionStatus> requestPermission(PermissionGroup permission) async {
    final List<PermissionGroup> permissions = <PermissionGroup>[permission];
    final Map<PermissionGroup, PermissionStatus> permissionRequestResult =
        await PermissionHandler().requestPermissions(permissions);
    return permissionRequestResult[permission];
  }
}
