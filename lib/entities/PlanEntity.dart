import 'package:equatable/equatable.dart';

class PlanEntity extends Equatable {
  final String planText;
  final DateTime date;

  const PlanEntity(this.planText, this.date);

  Map<String, Object> toJson() {
    return {"planText": planText, "date": date.toIso8601String()};
  }

  @override
  List<Object> get props => [planText, date];

  static PlanEntity fromJson(Map<String, Object> json) {
    return PlanEntity(
        json["planText"] as String, DateTime.parse(json["date"] as String));
  }
}
