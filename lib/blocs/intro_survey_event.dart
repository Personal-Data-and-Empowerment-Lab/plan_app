part of 'intro_survey_bloc.dart';

abstract class IntroSurveyEvent extends Equatable {
  const IntroSurveyEvent();
}

class LoadFirstIntroSurveyPage extends IntroSurveyEvent {
  const LoadFirstIntroSurveyPage() : super();

  @override
  List<Object> get props => [];
}

class SaveDemographicData extends IntroSurveyEvent {
  final Map<String, dynamic> demographicData;

  const SaveDemographicData(this.demographicData) : super();

  @override
  List<Object> get props => [this.demographicData];
}

class SaveContactInfoData extends IntroSurveyEvent {
  final Map<String, dynamic> contactInfoData;

  const SaveContactInfoData(this.contactInfoData) : super();

  @override
  List<Object> get props => [this.contactInfoData];
}

class SaveTMPData extends IntroSurveyEvent {
  final Map<String, dynamic> tmpData;

  const SaveTMPData(this.tmpData) : super();

  @override
  List<Object> get props => [this.tmpData];
}

class MoveToDemographicPage extends IntroSurveyEvent {
  const MoveToDemographicPage() : super();

  @override
  List<Object> get props => [];
}

class MoveToContactInfoPage extends IntroSurveyEvent {
  const MoveToContactInfoPage() : super();

  @override
  List<Object> get props => [];
}

class MoveToTMPPage extends IntroSurveyEvent {
  const MoveToTMPPage() : super();

  @override
  List<Object> get props => [];
}

class SaveIntroSurveyData extends IntroSurveyEvent {
  final Map<String, dynamic> tmpData;

  const SaveIntroSurveyData(this.tmpData) : super();

  @override
  List<Object> get props => [];
}

class SaveIntroSurveyDataLocal extends IntroSurveyEvent {
  final String data;

  SaveIntroSurveyDataLocal(this.data) : super();

  @override
  List<Object> get props => [this.data];
}

class SaveIntroSurveyDataSuccess extends IntroSurveyEvent {
  SaveIntroSurveyDataSuccess() : super();

  @override
  List<Object> get props => [];
}
