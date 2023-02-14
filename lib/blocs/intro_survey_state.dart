part of 'intro_survey_bloc.dart';

abstract class IntroSurveyState extends Equatable {
  const IntroSurveyState();
}

class IntroSurveyInitial extends IntroSurveyState {
  const IntroSurveyInitial() : super();

  @override
  List<Object> get props => [];
}

class IntroContactInfoSurvey extends IntroSurveyState {
  final Map<String, dynamic> contactInfoData;
  final bool interviewParticipant;

  const IntroContactInfoSurvey(this.contactInfoData, this.interviewParticipant)
      : super();

  @override
  List<Object> get props => [this.contactInfoData];
}

class IntroDemographicSurvey extends IntroSurveyState {
  final Map<String, dynamic> demographicData;
  final bool interviewParticipant;

  const IntroDemographicSurvey(this.demographicData, this.interviewParticipant)
      : super();

  @override
  List<Object> get props => [this.demographicData];
}

class IntroTMPSurvey extends IntroSurveyState {
  final Map<String, dynamic> tmpData;

  const IntroTMPSurvey(this.tmpData) : super();

  @override
  List<Object> get props => [this.tmpData];
}

class SavingIntroSurveyData extends IntroSurveyState {
  const SavingIntroSurveyData() : super();

  @override
  List<Object> get props => [];
}
