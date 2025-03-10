import 'dart:math';

import 'package:a_terminal/hive_object/client.dart';
import 'package:a_terminal/hive_object/settings.dart';
import 'package:a_terminal/logic.dart';
import 'package:a_terminal/pages/scaffold/logic.dart';
import 'package:a_terminal/utils/listenable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ViewLogic {
  ViewLogic(this.context);

  final BuildContext context;

  AppLogic get appLogic => context.read<AppLogic>();
  ScaffoldLogic get scaffoldLogic => context.read<ScaffoldLogic>();

  Settings get settings => appLogic.settings;

  ListenableList<ActivatedClient> get activated => scaffoldLogic.activated;

  final fontSize = ValueNotifier(16.0);
  final opened = ValueNotifier(false);

  void onOpenSidePanel() => opened.value = !opened.value;

  void onTapIncreaseFontSize() =>
      fontSize.value = min(fontSize.value + 1.0, 32.0);

  void onTapDecreaseFontSize() =>
      fontSize.value = max(fontSize.value - 1.0, 8.0);

  KeyEventResult onTerminalViewKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      final logicalKeysPressed = HardwareKeyboard.instance.logicalKeysPressed;
      if (logicalKeysPressed.contains(LogicalKeyboardKey.controlLeft)) {
        if (event.logicalKey == LogicalKeyboardKey.equal ||
            event.logicalKey == LogicalKeyboardKey.add) {
          onTapIncreaseFontSize();
          return KeyEventResult.handled;
        } else if (event.logicalKey == LogicalKeyboardKey.minus) {
          onTapDecreaseFontSize();
          return KeyEventResult.handled;
        }
      }
    }
    return KeyEventResult.ignored;
  }

  void dispose() {
    fontSize.dispose();
    opened.dispose();
  }
}
