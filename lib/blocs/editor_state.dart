import 'package:equatable/equatable.dart';
import 'package:planv3/models/Plan.dart';
import 'package:planv3/models/SnackBarData.dart';

abstract class EditorState extends Equatable {
  const EditorState();
}

class InitialEditorState extends EditorState {
  @override
  List<Object> get props => [];
}

class Loading extends EditorState {
  @override
  List<Object> get props => [];
}

class ActiveEditing extends EditorState {
  final Plan plan;
  final int cursorPosition;
  final bool toolBarChangeOnly;

  const ActiveEditing(this.cursorPosition, this.toolBarChangeOnly, this.plan);

  @override
  List<Object> get props => [cursorPosition, toolBarChangeOnly, plan];

  @override
  String toString() {
    return "ActiveEditing {cursorPosition: $cursorPosition, plan: $plan}";
  }
}

class PausedEditing extends EditorState {
  final Plan plan;
  final int cursorPosition;

  const PausedEditing(this.plan, this.cursorPosition);

  @override
  List<Object> get props => [plan, cursorPosition];

  @override
  String toString() {
    return "PausedEditing {plan: $plan, cursorPosition: $cursorPosition}";
  }
}

class Viewing extends EditorState {
  final Plan plan;

  const Viewing(this.plan);

  @override
  List<Object> get props => [plan];

  @override
  String toString() {
    return "Viewing {plan: $plan}";
  }
}

class DisplayingMessage extends EditorState {
  final SnackBarData messageData;
  final Plan plan;

  const DisplayingMessage(this.messageData, this.plan);

  @override
  List<Object> get props => [this.messageData, this.plan];
}

class OpeningSourcesList extends EditorState {
  const OpeningSourcesList();

  @override
  List<Object> get props => [];
}

class BeforeDrawerTutorial extends EditorState {
  final Plan plan;
  final int cursorPosition;

  BeforeDrawerTutorial(this.plan, this.cursorPosition);

  @override
  List<Object> get props => throw UnimplementedError();
}

class AfterDrawerTutorial extends EditorState {
  final Plan plan;
  final int cursorPosition;
  final bool startTutorial;

  AfterDrawerTutorial(this.plan, this.cursorPosition,
      {this.startTutorial = false});

  @override
  List<Object> get props => [this.plan, this.cursorPosition];
}
