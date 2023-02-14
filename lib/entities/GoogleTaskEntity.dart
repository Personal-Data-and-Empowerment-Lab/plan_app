import 'package:googleapis/tasks/v1.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:planv3/models/TaskItem.dart';

part 'GoogleTaskEntity.g.dart';

@JsonSerializable()
class GoogleTaskEntity {
  String id;
  String title;
  String url;
  String parent;
  String position;
  String notes;
  DateTime dueDate;
  bool completed;
  bool deleted;

  GoogleTaskEntity(this.id, this.title,
      {this.url,
      this.parent,
      this.position,
      this.notes,
      this.dueDate,
      this.completed,
      this.deleted});

  static GoogleTaskEntity fromAPIObject(Task task) {
    return GoogleTaskEntity(
      task.id,
      task.title,
      url: task.selfLink ?? null,
      parent: task.parent ?? null,
      position: task.position ?? null,
      notes: task.notes ?? null,
      dueDate: task.due ?? null,
      completed: task.status == "completed",
      deleted: task.deleted ?? null,
    );
  }

  TaskItem toTaskItem() {
    return TaskItem(this.title, this.id, dueDate: this.dueDate ?? null);
  }

  factory GoogleTaskEntity.fromJson(Map<String, dynamic> json) =>
      _$GoogleTaskEntityFromJson(json);

  Map<String, dynamic> toJson() => _$GoogleTaskEntityToJson(this);
}
