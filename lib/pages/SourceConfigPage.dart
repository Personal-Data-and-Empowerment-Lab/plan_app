import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planv3/blocs/bloc.dart';
import 'package:planv3/models/TaskView.dart';
import 'package:planv3/view_models/SourceConfigViewData.dart';

class SourceConfigPage extends StatefulWidget {
  @override
  _SourceConfigPageState createState() => _SourceConfigPageState();
}

class _SourceConfigPageState extends State<SourceConfigPage> {
  SourceConfigBloc bloc;
  SourceConfigViewData viewData;

  initState() {
    super.initState();
    bloc = BlocProvider.of<SourceConfigBloc>(context);
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SourceConfigState currentState =
        BlocProvider.of<SourceConfigBloc>(context).state;
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.black,
            title: currentState is InitialEditorState
                ? Text("Loading...")
                : Text(currentState.source.title)),
        body: BlocListener<SourceConfigBloc, SourceConfigState>(
            listener: (context, state) {
              if (state is SourceConfigDisplayingMessage) {
                // add a snackbar or modal here for showing messages
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(state.data.messageText),
                    action: state.data.hasActionData()
                        ? SnackBarAction(
                            label: state.data.actionLabel,
                            onPressed: state.data.onPressed)
                        : null));
              }
            },
            child: SafeArea(
              child: Column(
                children: [
                  BlocBuilder<SourceConfigBloc, SourceConfigState>(
                      builder: (context, state) {
                    if (state is NotSetUp) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.black),
                              // color: Colors.black,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Sign in",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 24)),
                              ),
                              onPressed: () =>
                                  BlocProvider.of<SourceConfigBloc>(context)
                                      .add(SignIn())),
                        ],
                      );
                    } else if (state is InitialSourceConfigState) {
                      return Container();
                    } else if (state is Loaded) {
                      Widget viewConfig = _mapLoadedToViewConfig(bloc, state);
                      Widget sourceDetails =
                          _mapLoadedToSourceDetails(bloc, state);
                      return Column(children: [sourceDetails, viewConfig]);
                    } else {
                      return Container();
                    }
                  })
                ],
              ),
            )));
  }

  Widget _mapLoadedToSourceDetails(SourceConfigBloc bloc, Loaded state) {
    // show account info and sign out button
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Column(children: <Widget>[
            Text(state.source.primaryAccountInfo,
                style: TextStyle(
                  fontSize: 24,
                )),
//            Text(
//              state.source.accountInfo.secondaryInfo,
//              style: TextStyle(
//                fontSize: 18
//              )
//            )
          ]),
          TextButton(
              child: Text("Sign out", style: TextStyle(color: Colors.black)),
              onPressed: () => bloc.add(SignOut()))
        ]);
  }

  Widget _mapLoadedToViewConfig(SourceConfigBloc bloc, Loaded state) {
    Widget title = Text("Views");
    List<Widget> columnChildren = [title];
    for (TaskView view in state.source.views) {
      columnChildren.add(_buildViewItem(view));
    }

    Widget addButton = TextButton(
        child: Text("Create view", style: TextStyle(color: Colors.black)),
        onPressed: () {});

    return Column(children: columnChildren);
  }

  Widget _buildViewItem(TaskView view) {
    return Column(children: <Widget>[
      Row(children: <Widget>[
        Switch(
            value: view.active,
            onChanged: (bool newValue) {
              // TODO: callback to bloc
            }),
        Text(view.title),
      ]),
      Text("Shows tasks from"),
      // need some widget for selecting multiple lists
    ]);
  }
}
