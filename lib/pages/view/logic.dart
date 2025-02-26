import 'dart:math';

import 'package:a_terminal/hive_object/settings.dart';
import 'package:a_terminal/logic.dart';
import 'package:a_terminal/pages/scaffold/logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ViewLogic {
  ViewLogic(this.context);

  final BuildContext context;

  AppLogic get appLogic => context.read<AppLogic>();
  ScaffoldLogic get scaffoldLogic => context.read<ScaffoldLogic>();
  ValueNotifier<SettingsData> get settings => appLogic.currentSettings;

  final fontSize = ValueNotifier(16.0);
  final opened = ValueNotifier(false);

  void onOpenSidePanel() {
    opened.value = !opened.value;
  }

  KeyEventResult onTerminalViewKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      final logicalKeysPressed = HardwareKeyboard.instance.logicalKeysPressed;
      if (logicalKeysPressed.contains(LogicalKeyboardKey.controlLeft)) {
        if (event.logicalKey == LogicalKeyboardKey.equal) {
          fontSize.value = min(fontSize.value + 1.0, 32.0);
          return KeyEventResult.handled;
        } else if (event.logicalKey == LogicalKeyboardKey.minus) {
          fontSize.value = max(fontSize.value - 1.0, 8.0);
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
