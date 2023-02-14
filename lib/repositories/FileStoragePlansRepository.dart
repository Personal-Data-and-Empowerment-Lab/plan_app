import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:planv3/entities/entities.dart';
import 'package:planv3/models/Plan.dart';
import 'package:planv3/repositories/PlansRepository.dart';

class FileStoragePlansRepository implements PlansRepository {
  @override
  Future<void> addNewPlan(Plan plan) {
    return null;
  }

  @override
  Future<void> deletePlan(Plan plan) {
    return _deletePlanFile(plan);
  }

  @override
  Stream<List<Plan>> getAllPlans() {
    throw UnimplementedError();
  }

  @override
  Stream<Plan> getPlan(DateTime dateTime) {
    return Stream.fromFuture(readPlanFor(dateTime));
  }

  @override
  Stream<List<Plan>> getPlanRange(DateTime startDate, int days) {
    List<Future<Plan>> plans = <Future<Plan>>[];
    for (int i = 0; i < days; i++) {
      DateTime day =
          new DateTime(startDate.year, startDate.month, startDate.day + i);
      Future<Plan> plan = readPlanFor(day)
          .then((plan) => plan != null ? plan : new Plan('', day));
      plans.add(plan);
    }
    return Stream.fromFuture(Future.wait(plans));
  }

  @override
  Future<Plan> getPlanFuture(DateTime dateTime) {
    return readPlanFor(dateTime);
  }

  @override
  Future<void> updatePlan(Plan plan) {
    return writePlan(plan);
  }

  // HELPER FUNCTIONS
  static Future<File> writePlan(Plan plan) async {
    final file = await _getPlanFileFor(plan.date);

    return file.writeAsString(jsonEncode(plan.toEntity()));
  }

  static Future<Plan> readPlanFor(DateTime date) async {
    try {
      final file = await _getPlanFileFor(date);

      String contents = await file.readAsString();
      return Plan.fromEntity(PlanEntity.fromJson(jsonDecode(contents)));
    } catch (e) {
      return null;
    }
  }

  static Future<void> _deletePlanFile(Plan plan) async {
    final file = await _getPlanFileFor(plan.date);
    file.delete();
  }

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  static Future<File> _getPlanFileFor(DateTime date) async {
    final path = await _localPath;
    final String filename = _getPlanFilenameFor(date);
    return File('$path/$filename');
  }

  static String _getPlanFilenameFor(DateTime date) {
    return "plan" +
        date.year.toString() +
        "_" +
        date.month.toString().padLeft(2, '0') +
        "_" +
        date.day.toString().padLeft(2, '0');
  }
}
