class CanvasEventEntity {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String url;
  final String courseID;

  CanvasEventEntity(
      {this.id,
      this.title,
      this.startTime,
      this.endTime,
      this.url,
      this.courseID});

  factory CanvasEventEntity.fromAPIJson(Map<String, dynamic> json) {
    return CanvasEventEntity(
        id: json["id"].toString(),
        title: json["title"],
        startTime: DateTime.parse(json["start_at"]),
        endTime: DateTime.parse(json["end_at"]),
        url: json["html_url"],
        courseID: json["context_code"].replaceAll("course_", ""));
  }
}
