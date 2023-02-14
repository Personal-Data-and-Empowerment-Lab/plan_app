import 'package:json_annotation/json_annotation.dart';

part 'CanvasCourseEntity.g.dart';

@JsonSerializable()
class CanvasCourseEntity {
  final String id;
  final String name;
  final DateTime startDate;
  final String enrollmentTermID;
  final DateTime endDate;

  CanvasCourseEntity(
      {this.id,
      this.name,
      this.startDate,
      this.enrollmentTermID,
      this.endDate});

  factory CanvasCourseEntity.fromAPIJson(Map<String, dynamic> json) {
    return CanvasCourseEntity(
        id: json["id"].toString(),
        name: json["name"],
        startDate: DateTime.parse(json["start_at"]),
        enrollmentTermID: json["enrollment_term_id"].toString(),
        endDate:
            (json["end_at"] != null) ? DateTime.parse(json["end_at"]) : null);
  }

  factory CanvasCourseEntity.fromJson(Map<String, dynamic> json) =>
      _$CanvasCourseEntityFromJson(json);

  Map<String, dynamic> toJson() => _$CanvasCourseEntityToJson(this);
}
