import 'package:json_annotation/json_annotation.dart';

part 'AccountInfo.g.dart';

@JsonSerializable()
class AccountInfo {
  String primaryInfo;
  String secondaryInfo;

  AccountInfo(this.primaryInfo, this.secondaryInfo);

  factory AccountInfo.fromJson(Map<String, dynamic> json) =>
      _$AccountInfoFromJson(json);

  Map<String, dynamic> toJson() => _$AccountInfoToJson(this);
}
