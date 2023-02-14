import 'package:intl/intl.dart';

class TaskViewItem {
  final String text;
  final DateTime dueDate;
  final DateTime startDate;
  final String id;
  bool selected = false;
  int position;

  TaskViewItem(this.text, this.dueDate, this.startDate, this.id);

  String getDisplayText() {
    return text;
  }

  @override
  String toString() {
    return "Task: {dueDate: ${this.dueDate?.toString()}, text: $text}";
  }

  String getDueDateText() {
    if (dueDate != null) {
      return new DateFormat.MMMd().format(dueDate);
    } else {
      return '';
    }
  }
}
