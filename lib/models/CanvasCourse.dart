import 'package:json_annotation/json_annotation.dart';
import 'package:planv3/providers/canvas_task_support/CanvasCourseEntity.dart';

part 'CanvasCourse.g.dart';

@JsonSerializable()
class CanvasCourse {
  final String id;
  final String name;

  CanvasCourse({this.id, this.name});

  factory CanvasCourse.fromCanvasCourseEntity(CanvasCourseEntity entity) {
    return CanvasCourse(id: entity.id, name: entity.name);
  }

  factory CanvasCourse.fromJson(Map<String, dynamic> json) =>
      _$CanvasCourseFromJson(json);

  Map<String, dynamic> toJson() => _$CanvasCourseToJson(this);
}
