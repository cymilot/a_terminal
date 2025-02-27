import 'package:hive_ce_flutter/hive_flutter.dart';

class HistoryData extends HiveObject {
  HistoryData(this.name, this.timestamp);

  final String name;
  final int timestamp;
}
