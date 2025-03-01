import 'package:hive_ce_flutter/hive_flutter.dart';

class HistoryData extends HiveObject {
  HistoryData(this.name, this.timestamp);

  final String name;
  final int timestamp;

  @override
  bool operator ==(Object other) {
    return other is HistoryData &&
        other.name == name &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => Object.hashAll([
        name,
        timestamp,
      ]);
}
