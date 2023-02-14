import 'package:planv3/models/Plan.dart';

abstract class PlansRepository {
  Future<void> addNewPlan(Plan plan);

  Future<void> deletePlan(Plan plan);

  Stream<Plan> getPlan(DateTime dateTime);

  Stream<List<Plan>> getPlanRange(DateTime startDate, int days);

  Future<Plan> getPlanFuture(DateTime dateTime);

  Stream<List<Plan>> getAllPlans();

  Future<void> updatePlan(Plan plan);
}
