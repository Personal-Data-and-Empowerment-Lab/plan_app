class CanvasTaskEntity {
  final String courseID;
  final String id;
  final DateTime dueDate;
  final String url;
  final String name;

  CanvasTaskEntity({this.id, this.dueDate, this.url, this.name, this.courseID});

  factory CanvasTaskEntity.fromAPIJson(Map<String, dynamic> json) {
    return CanvasTaskEntity(
        courseID: json['course_id'].toString(),
        id: json['id'].toString(),
        dueDate: json['due_at'] == null ? null : DateTime.parse(json['due_at']),
        url: json['html_url'],
        name: json['name']);
  }
}
