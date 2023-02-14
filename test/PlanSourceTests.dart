import 'package:flutter_test/flutter_test.dart';
import 'package:planv3/models/GoogleTasksSource.dart';
import 'package:planv3/models/PlanSource.dart';
import 'package:planv3/models/TaskView.dart';
import 'package:planv3/models/TaskViewFilter.dart';
import 'package:planv3/providers/GoogleTasksProvider.dart';
import 'package:planv3/repositories/GoogleTasksRepository.dart';

void main() {
  group('plain object tests', () {
    test('getID test 1', () {
      GoogleTasksProvider provider = GoogleTasksProvider();
//      GoogleTasksRepository taskRepository = GoogleTasksRepository(provider);
      PlanSource googleTasksSource = PlanSource("Google Tasks");
      expect("google_tasks", googleTasksSource.getID());
    });

    test('getID test 2', () {
      GoogleTasksProvider provider = GoogleTasksProvider();
//      GoogleTasksRepository taskRepository = GoogleTasksRepository(provider);
      PlanSource googleTasksSource = PlanSource("Todoist");
      expect("todoist", googleTasksSource.getID());
    });

    test('get lists', () {
      GoogleTasksProvider provider = GoogleTasksProvider();
      GoogleTasksRepository().syncSource(GoogleTasksSource(), DateTime.now());
    });

    test('save some initial views', () async {
      GoogleTasksSource source = GoogleTasksSource();
      TaskView view = TaskView("Due By Today");
      TaskViewFilter viewFilter =
          TaskViewFilter.withDaysFromNow(Operand.lessThanEqual, 0, false);
      view.addFilter(viewFilter);
      source.addView(view);
//      await GoogleTasksSourceRepository.writeGoogleTasksSource(source);
//      GoogleTasksSource savedSource = await GoogleTasksSourceRepository.readGoogleTasksSource();
//      print("${savedSource.views}");
    });
  });
}
