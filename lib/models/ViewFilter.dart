import 'package:json_annotation/json_annotation.dart';

part 'ViewFilter.g.dart';

enum Operand { lessThan, lessThanEqual, equal, greaterThanEqual, greaterThan }

@JsonSerializable()
class ViewFilter {
  Operand operand;
  DateTime date;
  Duration duration;

  ViewFilter(this.operand, this.date);

  Function toFilterFunction() {
    Function filterFunc;
    switch (this.operand) {
      case Operand.lessThan:
        filterFunc = (DateTime date) {
          return date.isBefore(this.date);
        };
        break;
      case Operand.lessThanEqual:
        filterFunc = (DateTime date) {
          return date.isBefore(this.date) || date.isAtSameMomentAs(this.date);
        };
        break;
      case Operand.equal:
        filterFunc = (DateTime date) {
          return date.isAtSameMomentAs(this.date);
        };
        break;
      case Operand.greaterThanEqual:
        filterFunc = (DateTime date) {
          return date.isAfter(this.date) || date.isAtSameMomentAs(this.date);
        };
        break;
      case Operand.greaterThan:
        filterFunc = (DateTime date) {
          return date.isAfter(this.date);
        };
        break;
    }

    return filterFunc;
  }

  factory ViewFilter.fromJson(Map<String, dynamic> json) =>
      _$ViewFilterFromJson(json);

  Map<String, dynamic> toJson() => _$ViewFilterToJson(this);
}
