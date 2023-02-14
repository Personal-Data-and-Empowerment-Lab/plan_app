import 'package:planv3/models/PlanSource.dart';
import 'package:planv3/models/SourceItem.dart';
import 'package:planv3/models/View.dart';

abstract class SourceRepository {
  const SourceRepository();

  Future<List<View>> syncSource(PlanSource source);

  Future<List<SourceItem>> syncView(View view);

  Future signIn();

  Future signOut();
}
