import 'package:equatable/equatable.dart';

abstract class SourceConfigEvent extends Equatable {
  const SourceConfigEvent();
}

class SignIn extends SourceConfigEvent {
  const SignIn();

  @override
  List<Object> get props => [];
}

class SignOut extends SourceConfigEvent {
  const SignOut();

  @override
  List<Object> get props => [];
}

class UpdateViews extends SourceConfigEvent {
  const UpdateViews();

  @override
  List<Object> get props => [];
}
