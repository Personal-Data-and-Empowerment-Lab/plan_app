import 'package:equatable/equatable.dart';
import 'package:planv3/models/GoogleTasksSource.dart';
import 'package:planv3/models/SnackBarData.dart';

abstract class SourceConfigState extends Equatable {
  final GoogleTasksSource source;

  const SourceConfigState(this.source);

  @override
  List<Object> get props => [this.source];
}

class InitialSourceConfigState extends SourceConfigState {
  const InitialSourceConfigState(GoogleTasksSource source) : super(source);

  @override
  List<Object> get props => [this.source];
}

class Loaded extends SourceConfigState {
  const Loaded(GoogleTasksSource source) : super(source);

  @override
  List<Object> get props => [this.source];
}

class NotSetUp extends SourceConfigState {
  const NotSetUp(GoogleTasksSource source) : super(source);

  @override
  List<Object> get props => [this.source];
}

class SourceConfigError extends SourceConfigState {
  final String errorMessage;

  const SourceConfigError(GoogleTasksSource source, this.errorMessage)
      : super(source);

  @override
  List<Object> get props => [this.source, this.errorMessage];
}

// for showing snack bars with various messages
class SourceConfigDisplayingMessage extends SourceConfigState {
  final SnackBarData data;

  const SourceConfigDisplayingMessage(GoogleTasksSource source, this.data)
      : super(source);

  @override
  List<Object> get props => [this.source, this.data];
}
