import 'package:a_terminal/pages/scaffold/logic.dart';
import 'package:a_terminal/utils/extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UnknownLogic {
  UnknownLogic(this.context);

  final BuildContext context;

  ScaffoldLogic get scaffoldLogic => context.read<ScaffoldLogic>();

  void onBack() {
    scaffoldLogic.navigator?.pushUri('/home', replace: true);
  }

  void dispose() {}
}
