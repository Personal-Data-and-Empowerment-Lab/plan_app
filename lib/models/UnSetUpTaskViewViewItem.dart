import 'package:planv3/interfaces/TaskViewViewItemInterface.dart';
import 'package:planv3/models/TaskViewItem.dart';

class UnSetUpTaskViewViewItem implements TaskViewViewItemInterface {
  @override
  List items = [];
  String sourceID;

  UnSetUpTaskViewViewItem(this.sourceID);

  @override
  void clearSelections() {}

  @override
  int getSelectedItemCount() {
    return 0;
  }

  @override
  List<TaskViewItem> getSelectedItems() {
    return [];
  }

  @override
  bool hasAllSelected() {
    return false;
  }

  @override
  bool hasSomeSelected() {
    return false;
  }

  @override
  void selectAllItems() {}

  @override
  get id => throw UnimplementedError();

  @override
  get sortedBy => throw UnimplementedError();
}
