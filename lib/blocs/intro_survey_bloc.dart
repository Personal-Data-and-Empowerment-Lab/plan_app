import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:planv3/utils/FirebaseFileUploader.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'intro_survey_event.dart';
part 'intro_survey_state.dart';

class IntroSurveyBloc extends Bloc<IntroSurveyEvent, IntroSurveyState> {
  Map<String, dynamic> _demographicData = Map<String, dynamic>();
  Map<String, dynamic> _contactInfoData = Map<String, dynamic>();
  Map<String, dynamic> _tmpData = Map<String, dynamic>();
  bool _interviewParticipant = false;

  IntroSurveyBloc() : super();

  @override
  IntroSurveyState get initialState => IntroSurveyInitial();

  @override
  Stream<IntroSurveyState> mapEventToState(IntroSurveyEvent event) async* {
    if (event is SaveDemographicData) {
      yield* _mapSaveDemographicDataToState(event);
    } else if (event is SaveContactInfoData) {
      yield* _mapSaveContactInfoDataToState(event);
    } else if (event is MoveToContactInfoPage) {
      yield* _mapMoveToContactInfoPageToState(event);
    } else if (event is MoveToDemographicPage) {
      yield* _mapMoveToDemographicPageToState(event);
    } else if (event is SaveTMPData) {
      yield* _mapSaveTMPDataToState(event);
    } else if (event is MoveToTMPPage) {
      yield* _mapMoveToTMPPageToState(event);
    } else if (event is LoadFirstIntroSurveyPage) {
      yield* _mapLoadFirstIntroSurveyPageToState(event);
    } else if (event is SaveIntroSurveyData) {
      yield* _mapSaveIntroSurveyDataToState(event);
    } else if (event is SaveIntroSurveyDataLocal) {
      yield* _mapSaveIntroSurveyDataLocalToState(event);
    }
  }

  Stream<IntroSurveyState> _mapLoadFirstIntroSurveyPageToState(
      LoadFirstIntroSurveyPage event) async* {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    this._interviewParticipant =
        prefs.getBool("interviewConsentGiven") ?? false;
    print(this._interviewParticipant);
    yield this._interviewParticipant
        ? IntroContactInfoSurvey(
            this._contactInfoData, this._interviewParticipant)
        : IntroDemographicSurvey(
            this._demographicData, this._interviewParticipant);
  }

  Stream<IntroSurveyState> _mapSaveDemographicDataToState(
      SaveDemographicData event) async* {
    this._demographicData = event.demographicData;
    print("DemographicData: ${this._demographicData}");
  }

  Stream<IntroSurveyState> _mapSaveContactInfoDataToState(
      SaveContactInfoData event) async* {
    this._contactInfoData = event.contactInfoData;
    print("ContactInfoData: ${this._contactInfoData}");
  }

  Stream<IntroSurveyState> _mapSaveTMPDataToState(SaveTMPData event) async* {
    this._tmpData = event.tmpData;
    print("TMPData: ${this._tmpData}");
  }

  Stream<IntroSurveyState> _mapMoveToContactInfoPageToState(
      MoveToContactInfoPage event) async* {
    yield IntroContactInfoSurvey(
        this._contactInfoData, this._interviewParticipant);
  }

  Stream<IntroSurveyState> _mapMoveToDemographicPageToState(
      MoveToDemographicPage event) async* {
    yield IntroDemographicSurvey(
        this._demographicData, this._interviewParticipant);
  }

  Stream<IntroSurveyState> _mapMoveToTMPPageToState(
      MoveToTMPPage event) async* {
    yield IntroTMPSurvey(this._tmpData);
  }

  Stream<IntroSurveyState> _mapSaveIntroSurveyDataToState(
      SaveIntroSurveyData event) async* {
    // save tmp data
    this._demographicData = event.tmpData;
    // then save all data to file
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // convert survey data to string
    Map<String, dynamic> introSurveyData = {
      "contact_info": this._contactInfoData,
      "demographic": this._demographicData,
      "tmp": this._tmpData
    };
    String introSurveyDataJson = jsonEncode(introSurveyData);

    String fileName =
        (this._interviewParticipant ? "INTERVIEW_" : "") + "intro_survey_data";
    FileUploadStatus fileUploadStatus = await FirebaseFileUploader.uploadData(
        data: introSurveyDataJson, fileName: fileName, fileExtension: "json");

    // mark that a survey was taken to clear the alert for them
    prefs.setString("lastSurveyTaken", DateTime.now().toIso8601String());

    switch (fileUploadStatus) {
      case FileUploadStatus.succeeded:
        prefs.setBool("introSurveyDataSaved", true);
        this.add(SaveIntroSurveyDataSuccess());
        break;
      case FileUploadStatus.failed_other:
        prefs.setBool("introSurveyDataSaved", false);
        this.add(SaveIntroSurveyDataLocal(introSurveyDataJson));
        break;
      case FileUploadStatus.failed_no_network:
        prefs.setBool("introSurveyDataSaved", false);
        this.add(SaveIntroSurveyDataLocal(introSurveyDataJson));
        break;
    }
  }

  Stream<IntroSurveyState> _mapSaveIntroSurveyDataLocalToState(
      SaveIntroSurveyDataLocal event) async* {
    // this doesn't actually do anything, but it will get saved in the logs now
  }

  // HELPER FUNCTIONS ----------------------------------------------------------

}
