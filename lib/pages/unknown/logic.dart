import 'package:a_terminal/pages/scaffold/logic.dart';
import 'package:a_terminal/utils/extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UnknownLogic {
  UnknownLogic(this.context);

  final BuildContext context;

  ScaffoldLogic get scaffoldLogic => context.read<ScaffoldLogic>();
  NavigatorState? get navigator => scaffoldLogic.navigator;

  void onBack() => navigator?.pushUri('/home', replace: true);

  void dispose() {}
}
