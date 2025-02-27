import 'package:a_terminal/consts.dart';
import 'package:a_terminal/hive_object/history.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class HistoryLogic {
  HistoryLogic(this.context);

  final BuildContext context;

  final history = Hive.box<HistoryData>(boxHistory);

  void dispose() {}
}
