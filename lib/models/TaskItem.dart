import 'package:json_annotation/json_annotation.dart';
import 'package:planv3/models/SourceItem.dart';
import 'package:planv3/providers/canvas_task_support/CanvasTaskEntity.dart';

part 'TaskItem.g.dart';

@JsonSerializable()
class TaskItem extends SourceItem {
  String title;
  String id;
  DateTime dueDate;

  TaskItem(this.title, this.id, {this.dueDate});

  factory TaskItem.fromCanvasTaskEntity(CanvasTaskEntity canvasTaskEntity) {
    return TaskItem(canvasTaskEntity.name, canvasTaskEntity.id,
        dueDate: canvasTaskEntity.dueDate);
  }

  factory TaskItem.fromJson(Map<String, dynamic> json) =>
      _$TaskItemFromJson(json);

  Map<String, dynamic> toJson() => _$TaskItemToJson(this);
}
