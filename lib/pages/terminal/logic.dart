import 'package:a_terminal/hive_object/client.dart';
import 'package:a_terminal/pages/scaffold/logic.dart';
import 'package:a_terminal/utils/extension.dart';
import 'package:a_terminal/utils/listenable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TerminalLogic with DiagnosticableTreeMixin {
  TerminalLogic(this.context);

  final BuildContext context;

  ScaffoldLogic get scaffoldLogic => context.read<ScaffoldLogic>();

  ListenableList<ActivatedClient> get activated => scaffoldLogic.activated;
  ValueNotifier<int> get tabIndex => scaffoldLogic.tabIndex;
  NavigatorState? get navigator => scaffoldLogic.navigator;

  void onClose(int index) {
    final client = activated.removeAt(index);
    client.closeAll();
    final newIndex = index - 1;
    tabIndex.value = newIndex >= 0 ? newIndex : 0;
  }

  void onPush(int index) {
    tabIndex.value = index;
    navigator?.pushUri('/view');
  }

  void dispose() {}
}
