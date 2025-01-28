import 'package:a_terminal/pages/scaffold/logic.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UnknownLogic with ChangeNotifier, DiagnosticableTreeMixin {
  UnknownLogic({required this.context});

  final BuildContext context;

  ScaffoldLogic get scaffoldLogic => context.read<ScaffoldLogic>();

  void onBack() {
    scaffoldLogic.navigator?.maybePop();
  }
}
