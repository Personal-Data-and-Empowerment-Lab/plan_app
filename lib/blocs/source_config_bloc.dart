import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:planv3/blocs/bloc.dart';
import 'package:planv3/models/GoogleTasksSource.dart';
import 'package:planv3/models/SnackBarData.dart';
import 'package:planv3/repositories/GoogleTasksRepository.dart';
import 'package:planv3/repositories/GoogleTasksSourceRepository.dart';

class SourceConfigBloc extends Bloc<SourceConfigEvent, SourceConfigState> {
  GoogleTasksSource source;

  SourceConfigBloc() {
    // load source from settings
    _initializeSource();
  }

  Future<bool> _initializeSource() async {
    source = await GoogleTasksSourceRepository().readTasksSource();
    if (source == null) {
      source = GoogleTasksSource();
    }

    return true;
  }

  @override
  SourceConfigState get initialState => InitialSourceConfigState(source);

  @override
  Stream<SourceConfigState> mapEventToState(
    SourceConfigEvent event,
  ) async* {
    if (event is SignIn) {
      yield* _mapSignInEventToState(event);
    } else if (event is SignOut) {
      yield* _mapSignOutEventToState(event);
    }
  }

  Stream<SourceConfigState> _mapSignInEventToState(SignIn event) async* {
    // access provided repository

    try {
      await GoogleTasksRepository.signIn();
      print("tried signing in");
      this.source.isSetUp = true;
      yield Loaded(source);
    } catch (error) {
      print("ERROR: $error");
      SnackBarData data = SnackBarData(
        messageText: "Sign in failed",
      );
      yield SourceConfigDisplayingMessage(source, data);
      yield NotSetUp(source);
    }
  }

  Stream<SourceConfigState> _mapSignOutEventToState(SignOut event) async* {
    try {
      await GoogleTasksRepository.signOut();
      this.source.isSetUp = false;
      yield NotSetUp(source);
    } catch (error) {
      print("ERROR: $error");
      SnackBarData data = SnackBarData(
        messageText: "Sign out failed",
      );
      yield SourceConfigDisplayingMessage(source, data);
      yield NotSetUp(source);
    }
  }
}
