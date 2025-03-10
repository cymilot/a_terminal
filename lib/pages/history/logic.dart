import 'package:a_terminal/consts.dart';
import 'package:a_terminal/hive_object/history.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class HistoryLogic with DiagnosticableTreeMixin {
  HistoryLogic(this.context);

  final BuildContext context;

  Box<HistoryData> get history => Hive.box<HistoryData>(boxHistory);

  void dispose() {}
}
