import 'package:hive_ce_flutter/hive_flutter.dart';

class HistoryData extends HiveObject {
  HistoryData(this.name, this.time);

  final String name;
  final int time;

  @override
  bool operator ==(Object other) {
    return other is HistoryData && other.name == name && other.time == time;
  }

  @override
  int get hashCode => Object.hashAll([
        name,
        time,
      ]);
}
