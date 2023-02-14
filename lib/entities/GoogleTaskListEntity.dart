import 'package:googleapis/tasks/v1.dart';
import 'package:json_annotation/json_annotation.dart';

part 'GoogleTaskListEntity.g.dart';

@JsonSerializable()
class GoogleTaskListEntity {
  String id;
  String url;
  String title;

  GoogleTaskListEntity(this.id, this.url, this.title);

  static GoogleTaskListEntity fromAPIObject(TaskList taskList) {
    return GoogleTaskListEntity(taskList.id, taskList.selfLink, taskList.title);
  }

  factory GoogleTaskListEntity.fromJson(Map<String, dynamic> json) =>
      _$GoogleTaskListEntityFromJson(json);

  Map<String, dynamic> toJson() => _$GoogleTaskListEntityToJson(this);
}
