import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:planv3/blocs/intro_survey_bloc.dart';

class IntroSurveyWidget extends StatefulWidget {
  final GlobalKey<IntroductionScreenState> introPageKey;

  IntroSurveyWidget(this.introPageKey);

  IntroSurveyWidgetState createState() => IntroSurveyWidgetState();
}

class IntroSurveyWidgetState extends State<IntroSurveyWidget> {
  bool _demographicDataComplete = false;
  bool _contactInfoComplete = false;
  bool _tmpDataComplete = false;
  IntroSurveyBloc _introSurveyBloc;
  final _demographicFormKey = GlobalKey<FormBuilderState>();
  final _contactInfoFormKey = GlobalKey<FormBuilderState>();
  final _tmpFormKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    _introSurveyBloc = BlocProvider.of<IntroSurveyBloc>(context);
    _introSurveyBloc.add(LoadFirstIntroSurveyPage());
    super.initState();
  }

  @override
  void dispose() {
    _introSurveyBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IntroSurveyBloc, IntroSurveyState>(
        builder: (context, state) {
      return _mapStateToView(state);
    });
  }

  void _onDemographicDataChanged(dynamic newString) async {
    if (_demographicFormKey.currentState.saveAndValidate()) {
      setState(() {
        _demographicDataComplete = true;
      });
    } else {
      setState(() {
        _demographicDataComplete = false;
      });
    }
  }

  void _onContactInfoChanged(dynamic newString) async {
    if (_contactInfoFormKey.currentState.saveAndValidate()) {
      setState(() {
        _contactInfoComplete = true;
      });
    } else {
      setState(() {
        _contactInfoComplete = false;
      });
    }
  }

  void _onTMPDataChanged(dynamic newString) async {
    if (_tmpFormKey.currentState.saveAndValidate()) {
      setState(() {
        _tmpDataComplete = true;
      });
    } else {
      setState(() {
        _tmpDataComplete = false;
      });
    }
  }

  Widget _mapStateToView(IntroSurveyState state) {
    Widget returnWidget = Container();

    if (state is IntroContactInfoSurvey) {
      returnWidget = _buildContactInfoSurvey(state);
    } else if (state is IntroDemographicSurvey) {
      returnWidget = _buildDemographicSurvey(state);
    } else if (state is IntroTMPSurvey) {
      returnWidget = _buildTMPSurvey(state);
    }

    return returnWidget;
  }

  Widget _buildContactInfoSurvey(IntroContactInfoSurvey state) {
    Widget returnWidget = Column(children: <Widget>[
      // LinearProgressIndicator(
      //   value: 0.05,
      //   backgroundColor: Colors.grey[400],
      //   valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
      // ),
      // Padding(
      //   padding: const EdgeInsets.only(top: 8.0),
      //   child: Align(
      //       alignment: Alignment.centerRight, child: Text("2 pages left")),
      // ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Contact Info",
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.left,
              ),
              Text("(for scheduling interviews)",
                  style: TextStyle(fontSize: 16, color: Colors.grey))
            ],
          ),
        ),
      ),
      FormBuilder(
          key: _contactInfoFormKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: Column(children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: FormBuilderTextField(
                initialValue: state.contactInfoData["first_name"],
                onChanged: _onContactInfoChanged,
                attribute: "first_name",
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: "First name",
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                validators: [FormBuilderValidators.required()],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: FormBuilderTextField(
                  initialValue: state.contactInfoData["last_name"],
                  attribute: "last_name",
                  onChanged: _onContactInfoChanged,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                      labelText: "Last name",
                      border: OutlineInputBorder(),
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      floatingLabelBehavior: FloatingLabelBehavior.always),
                  validators: [FormBuilderValidators.required()]),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: FormBuilderTextField(
                  initialValue: state.contactInfoData["phone_number"],
                  attribute: "phone_number",
                  onChanged: _onContactInfoChanged,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                      labelText: 'Phone number',
                      border: OutlineInputBorder(),
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      floatingLabelBehavior: FloatingLabelBehavior.always),
                  validators: [FormBuilderValidators.required()]),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: FormBuilderTextField(
                  initialValue: state.contactInfoData["email_address"],
                  attribute: "email_address",
                  onChanged: _onContactInfoChanged,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email address',
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  validators: [
                    FormBuilderValidators.email(),
                    FormBuilderValidators.required()
                  ]),
            ),
            // SizedBox(height: 8),
            FormBuilderRadioGroup(
              initialValue:
                  state.contactInfoData["contact_method"]?.toString() ?? null,
              attribute: "contact_method",
              onChanged: _onContactInfoChanged,
              decoration: InputDecoration(
                labelStyle: TextStyle(fontWeight: FontWeight.bold),
                // floatingLabelBehavior: FloatingLabelBehavior.auto,
                labelText: 'Preferred contact method',
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding:
                    EdgeInsets.only(left: 0, bottom: 0, top: 4, right: 15),
              ),
              validators: [FormBuilderValidators.required()],
              options: [
                FormBuilderFieldOption(
                    value: "text_message",
                    child:
                        Text("Text message", style: TextStyle(fontSize: 16))),
                FormBuilderFieldOption(
                    value: "email",
                    child: Text("Email", style: TextStyle(fontSize: 16)))
              ],
            ),
          ])),
      SizedBox(height: 20),
      ElevatedButton(
        // style: ElevatedButton.styleFrom(primary: Colors.black),
        onPressed: !_contactInfoComplete
            ? null
            : () {
                // _introKey.currentState.next();
                // send survey data to bloc
          _contactInfoFormKey.currentState.save();
                print(_contactInfoFormKey.currentState.value);
                Map<String, dynamic> contactInfoData = _contactInfoFormKey
                    .currentState.fields
                    .map((String name, GlobalKey<FormFieldState> key) =>
                        MapEntry(name, key.currentState.value));
                print(contactInfoData);
                _introSurveyBloc.add(SaveContactInfoData(contactInfoData));
                _introSurveyBloc.add(MoveToDemographicPage());
              },
        child: Text("Next"),
      ),
      SizedBox(height: 20),
    ]);

    return returnWidget;
  }

  Widget _buildDemographicSurvey(IntroDemographicSurvey state) {
    Widget returnWidget = Column(children: <Widget>[
      // LinearProgressIndicator(
      //   value: 0.35,
      //   backgroundColor: Colors.grey[400],
      //   valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
      // ),
      // Padding(
      //   padding: const EdgeInsets.only(top: 8.0),
      //   child:
      //       Align(alignment: Alignment.centerRight, child: Text("1 page left")),
      // ),
      Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            child: Text(
              "About You",
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.left,
            ),
          ),
        ),
      ),
      FormBuilder(
          key: _demographicFormKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: FormBuilderTextField(
                  initialValue:
                      state.demographicData["age"]?.currentState?.value,
                  attribute: "age",
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  onChanged: _onDemographicDataChanged,
                  decoration: InputDecoration(
                      labelText: "Age",
                      border: OutlineInputBorder(),
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      floatingLabelBehavior: FloatingLabelBehavior.always),
                  validators: [
                    FormBuilderValidators.required(),
                    FormBuilderValidators.numeric(),
                    FormBuilderValidators.min(18,
                        errorText: "You must be 18 to participate"),
                    FormBuilderValidators.max(150,
                        errorText: "Please enter a valid age")
                  ]),
            ),
            FormBuilderRadioGroup(
                attribute: "gender",
                initialValue:
                    state.demographicData["gender"]?.toString() ?? null,
                onChanged: _onDemographicDataChanged,
                decoration: InputDecoration(
                  labelText: "Gender",
                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding:
                      EdgeInsets.only(left: 0, bottom: 0, top: 4, right: 15),
                ),
                validators: [
                  FormBuilderValidators.required()
                ],
                options: [
                  FormBuilderFieldOption(
                      value: "female", child: Text("Female")),
                  FormBuilderFieldOption(value: "male", child: Text("Male")),
                  FormBuilderFieldOption(
                      value: "non-binary",
                      child: Text("Non-binary / third gender")),
                  FormBuilderFieldOption(
                      value: "gender-prefer-not",
                      child: Text("Prefer not to say")),
                  FormBuilderFieldOption(
                      value: "gender-other", child: Text("Other"))
                ]),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: FormBuilderTextField(
                  onChanged: _onDemographicDataChanged,
                  initialValue: state.demographicData["gender-specify"],
                  attribute: "gender-specify",
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                      labelText: "If other, please specify",
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: OutlineInputBorder()),
                  validators: [
                    (val) {
                      if (_demographicFormKey.currentState.fields['gender']
                                  ?.currentState?.value ==
                              'gender-other' &&
                          (val == null || val.isEmpty)) {
                        return 'Please specify your gender';
                      }
                      return null;
                    }
                  ]),
            ),
            FormBuilderRadioGroup(
              onChanged: _onDemographicDataChanged,
              attribute: "uofu_student",
              initialValue:
                  state.demographicData["uofu_student"]?.toString() ?? null,
              // autovalidateMode: AutovalidateMode.onUserInteraction,

              decoration: InputDecoration(
                labelStyle: TextStyle(fontWeight: FontWeight.bold),
                // floatingLabelBehavior: FloatingLabelBehavior.auto,
                labelText: 'University of Utah student?',
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding:
                    EdgeInsets.only(left: 0, bottom: 0, top: 4, right: 15),
              ),
              validators: [FormBuilderValidators.required()],
              options: [
                FormBuilderFieldOption(
                    value: "uofu_student_yes",
                    child: Text("Yes", style: TextStyle(fontSize: 16))),
                FormBuilderFieldOption(
                    value: "uofu_student_no",
                    child: Text("No", style: TextStyle(fontSize: 16)))
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: FormBuilderTextField(
                  onChanged: _onDemographicDataChanged,
                  attribute: "major",
                  initialValue: state.demographicData["major"],
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                      labelText: "Current major, if any",
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: OutlineInputBorder()),
                  validators: [
                    FormBuilderValidators.required(
                        errorText: "If no current major, enter 'None'")
                  ]),
            ),
            FormBuilderRadioGroup(
              onChanged: _onDemographicDataChanged,
              attribute: "class_standing",
              initialValue:
                  state.demographicData["class_standing"]?.toString() ?? null,
              decoration: InputDecoration(
                labelStyle: TextStyle(fontWeight: FontWeight.bold),
                labelText: "Class standing",
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding:
                    EdgeInsets.only(left: 0, bottom: 11, top: 4, right: 15),
              ),
              validators: [FormBuilderValidators.required()],
              options: [
                FormBuilderFieldOption(
                    value: "first_year",
                    child: Text("First year", style: TextStyle(fontSize: 16))),
                FormBuilderFieldOption(
                    value: "second_year",
                    child: Text("Second year", style: TextStyle(fontSize: 16))),
                FormBuilderFieldOption(
                    value: "third_year_more",
                    child: Text("Third year or more",
                        style: TextStyle(fontSize: 16))),
                FormBuilderFieldOption(
                    value: "not_student",
                    child:
                        Text("Not a student", style: TextStyle(fontSize: 16)))
              ],
            )
          ])),
      SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Visibility(
            visible: state.interviewParticipant,
            child: TextButton(
              // style: ElevatedButton.styleFrom(primary: Colors.black),
              onPressed: () {
                _demographicFormKey.currentState.save();
                Map<String, dynamic> demographicData = _demographicFormKey
                    .currentState.fields
                    .map((String name, GlobalKey<FormFieldState> key) =>
                        MapEntry(name, key.currentState.value));
                print(demographicData);
                _introSurveyBloc.add(SaveDemographicData(demographicData));
                _introSurveyBloc.add(MoveToContactInfoPage());
              },
              child: Text("Back"),
            ),
          ),
          ElevatedButton(
            // style: ElevatedButton.styleFrom(primary: Colors.black),
            onPressed: !_demographicDataComplete
                ? null
                : () {
                    // _introKey.currentState.next();
                    // send survey data to bloc
              _demographicFormKey.currentState.save();
                    Map<String, dynamic> demographicData = _demographicFormKey
                        .currentState.fields
                        .map((String name, GlobalKey<FormFieldState> key) =>
                            MapEntry(name, key.currentState.value));
                    print(demographicData);
                    // _introSurveyBloc.add(SaveDemographicData(demographicData));
                    // _introSurveyBloc.add(MoveToTMPPage());
                    _introSurveyBloc.add(SaveIntroSurveyData(demographicData));
                    this.widget.introPageKey.currentState.next();
                  },
            child: Text("Submit"),
          ),
        ],
      ),
      SizedBox(height: 20),
    ]);

    return returnWidget;
  }

  Widget _buildTMPSurvey(IntroTMPSurvey state) {
    Widget returnWidget = Column(children: <Widget>[
      // LinearProgressIndicator(
      //   value: 0.66,
      //   backgroundColor: Colors.grey[400],
      //   valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
      // ),
      // Padding(
      //   padding: const EdgeInsets.only(top: 8.0),
      //   child:
      //       Align(alignment: Alignment.centerRight, child: Text("Last page")),
      // ),
      Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            child: Text(
              "Time Management",
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.left,
            ),
          ),
        ),
      ),
      FormBuilder(
          key: _tmpFormKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(children: <Widget>[
            Text(
                "How do you currently make plans for how you'll spend your time each day?",
                style: TextStyle(fontWeight: FontWeight.bold)),
            FormBuilderRadioGroup(
                attribute: "planning_method",
                initialValue:
                    state.tmpData["planning_method"]?.toString() ?? null,
                onChanged: _onTMPDataChanged,
                decoration: InputDecoration(
                  // labelText:
                  //     "How do you currently make plans for how you'll spend your time each day?",
                  // labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding:
                      EdgeInsets.only(left: 0, bottom: 0, top: 4, right: 15),
                ),
                validators: [
                  FormBuilderValidators.required()
                ],
                options: [
                  FormBuilderFieldOption(
                      value: "planning_specific",
                      child: Text(
                          "Write down a specific schedule including events and when to work on specific tasks")),
                  FormBuilderFieldOption(
                      value: "planning_todo",
                      child: Text(
                          "Write down a daily to-do list of tasks to complete")),
                  FormBuilderFieldOption(
                      value: "planning_mental",
                      child: Text(
                          "Review upcoming tasks and events and think through when things might happen")),
                  FormBuilderFieldOption(
                      value: "planning_nothing",
                      child: Text("Nothing specific")),
                  FormBuilderFieldOption(
                      value: "planning_other", child: Text("Other"))
                ]),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: FormBuilderTextField(
                  onChanged: _onTMPDataChanged,
                  initialValue: state.tmpData["planning_specify"],
                  attribute: "planning_specify",
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                      labelText: "If other, please specify",
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: OutlineInputBorder()),
                  validators: [
                    (val) {
                      if (_tmpFormKey.currentState.fields['planning_method']
                                  ?.currentState?.value ==
                              'planning_other' &&
                          (val == null || val.isEmpty)) {
                        return 'Please specify how you plan';
                      }
                      return null;
                    }
                  ]),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("I feel I manage my time well",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            FormBuilderRadioGroup(
                attribute: "atus_1",
                initialValue: state.tmpData["atus_1"]?.toString() ?? null,
                onChanged: _onTMPDataChanged,
                decoration: InputDecoration(
                  // labelText: "I feel I manage my time well",
                  // labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding:
                      EdgeInsets.only(left: 0, bottom: 0, top: 4, right: 15),
                ),
                validators: [
                  FormBuilderValidators.required()
                ],
                options: [
                  FormBuilderFieldOption(
                      value: "atus_never", child: Text("Almost never")),
                  FormBuilderFieldOption(
                      value: "atus_sometimes", child: Text("Sometimes")),
                  FormBuilderFieldOption(
                      value: "atus_most", child: Text("Most of the time")),
                  FormBuilderFieldOption(
                      value: "atus_always", child: Text("Almost always")),
                ]),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("I rush while completing my work",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            FormBuilderRadioGroup(
                attribute: "atus_2",
                initialValue: state.tmpData["atus_2"]?.toString() ?? null,
                onChanged: _onTMPDataChanged,
                decoration: InputDecoration(
                  // labelText: "I rush while completing my work",
                  // labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding:
                      EdgeInsets.only(left: 0, bottom: 0, top: 4, right: 15),
                ),
                validators: [
                  FormBuilderValidators.required()
                ],
                options: [
                  FormBuilderFieldOption(
                      value: "atus_never", child: Text("Almost never")),
                  FormBuilderFieldOption(
                      value: "atus_sometimes", child: Text("Sometimes")),
                  FormBuilderFieldOption(
                      value: "atus_most", child: Text("Most of the time")),
                  FormBuilderFieldOption(
                      value: "atus_always", child: Text("Almost always")),
                ]),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    "Even if I do not like to do something, I still complete it on time",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            FormBuilderRadioGroup(
                attribute: "atus_3",
                initialValue: state.tmpData["atus_3"]?.toString() ?? null,
                onChanged: _onTMPDataChanged,
                decoration: InputDecoration(
                  // labelText:
                  //     "Even if I do not like to do something, I still complete it on time",
                  // labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding:
                      EdgeInsets.only(left: 0, bottom: 0, top: 4, right: 15),
                ),
                validators: [
                  FormBuilderValidators.required()
                ],
                options: [
                  FormBuilderFieldOption(
                      value: "atus_never", child: Text("Almost never")),
                  FormBuilderFieldOption(
                      value: "atus_sometimes", child: Text("Sometimes")),
                  FormBuilderFieldOption(
                      value: "atus_most", child: Text("Most of the time")),
                  FormBuilderFieldOption(
                      value: "atus_always", child: Text("Almost always")),
                ]),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    "I put off things I do not like to do until the very last minute",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            FormBuilderRadioGroup(
                attribute: "atus_4",
                initialValue: state.tmpData["atus_4"]?.toString() ?? null,
                onChanged: _onTMPDataChanged,
                decoration: InputDecoration(
                  // labelText:
                  //     "I put off things I do not like to do until the very last minute",
                  // labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding:
                      EdgeInsets.only(left: 0, bottom: 0, top: 4, right: 15),
                ),
                validators: [
                  FormBuilderValidators.required()
                ],
                options: [
                  FormBuilderFieldOption(
                      value: "atus_never", child: Text("Almost never")),
                  FormBuilderFieldOption(
                      value: "atus_sometimes", child: Text("Sometimes")),
                  FormBuilderFieldOption(
                      value: "atus_most", child: Text("Most of the time")),
                  FormBuilderFieldOption(
                      value: "atus_always", child: Text("Almost always")),
                ]),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    "I feel confident that I can complete my daily routine",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            FormBuilderRadioGroup(
                attribute: "atus_5",
                initialValue: state.tmpData["atus_5"]?.toString() ?? null,
                onChanged: _onTMPDataChanged,
                decoration: InputDecoration(
                  // labelText:
                  //     "I feel confident that I can complete my daily routine",
                  // labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding:
                      EdgeInsets.only(left: 0, bottom: 0, top: 4, right: 15),
                ),
                validators: [
                  FormBuilderValidators.required()
                ],
                options: [
                  FormBuilderFieldOption(
                      value: "atus_never", child: Text("Almost never")),
                  FormBuilderFieldOption(
                      value: "atus_sometimes", child: Text("Sometimes")),
                  FormBuilderFieldOption(
                      value: "atus_most", child: Text("Most of the time")),
                  FormBuilderFieldOption(
                      value: "atus_always", child: Text("Almost always")),
                ]),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    "I run out of time before I finish important things",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            FormBuilderRadioGroup(
                attribute: "atus_6",
                initialValue: state.tmpData["atus_6"]?.toString() ?? null,
                onChanged: _onTMPDataChanged,
                decoration: InputDecoration(
                  // labelText:
                  //     "I run out of time before I finish important things",
                  // labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding:
                      EdgeInsets.only(left: 0, bottom: 0, top: 4, right: 15),
                ),
                validators: [
                  FormBuilderValidators.required()
                ],
                options: [
                  FormBuilderFieldOption(
                      value: "atus_never", child: Text("Almost never")),
                  FormBuilderFieldOption(
                      value: "atus_sometimes", child: Text("Sometimes")),
                  FormBuilderFieldOption(
                      value: "atus_most", child: Text("Most of the time")),
                  FormBuilderFieldOption(
                      value: "atus_always", child: Text("Almost always")),
                ]),
          ])),
      SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton(
            // style: ElevatedButton.styleFrom(primary: Colors.black),
            onPressed: () {
              _tmpFormKey.currentState.save();
              Map<String, dynamic> tmpData = _tmpFormKey.currentState.fields
                  .map((String name, GlobalKey<FormFieldState> key) =>
                      MapEntry(name, key.currentState.value));
              print(tmpData);
              _introSurveyBloc.add(SaveTMPData(tmpData));
              _introSurveyBloc.add(MoveToDemographicPage());
            },
            child: Text("Back"),
          ),
          ElevatedButton(
            // style: ElevatedButton.styleFrom(primary: Colors.black),
            onPressed: !_tmpDataComplete
                ? null
                : () async {
                    // _introKey.currentState.next();
                    // send survey data to bloc
              _tmpFormKey.currentState.save();
                    Map<String, dynamic> tmpData = _tmpFormKey
                        .currentState.fields
                        .map((String name, GlobalKey<FormFieldState> key) =>
                            MapEntry(name, key.currentState.value));

                    _introSurveyBloc.add(SaveIntroSurveyData(tmpData));
                    this.widget.introPageKey.currentState.next();
                  },
            child: Text("Submit"),
          ),
        ],
      ),
      SizedBox(height: 20),
    ]);

    return returnWidget;
  }
}
