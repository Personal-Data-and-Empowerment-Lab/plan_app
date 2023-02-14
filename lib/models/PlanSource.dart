import 'package:planv3/models/AccountInfo.dart';
import 'package:planv3/models/View.dart';
import 'package:json_annotation/json_annotation.dart';

part 'PlanSource.g.dart';

@JsonSerializable()
class PlanSource {
  String title;
  String iconPath;
  bool isEnabled;
  bool isSetUp;
  List<View> views;
  AccountInfo accountInfo;

  PlanSource(this.title,
      {this.iconPath, this.isEnabled, this.isSetUp, this.views});

  String getID() {
    return title.replaceAll(" ", "_").toLowerCase();
  }
}
