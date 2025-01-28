import 'dart:math';

import 'package:a_terminal/pages/scaffold/logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ActiveLogic with ChangeNotifier {
  ActiveLogic({required this.context});

  final BuildContext context;

  ScaffoldLogic get scaffoldLogic => context.read<ScaffoldLogic>();

  final fontSizeL = ValueNotifier(16.0);

  KeyEventResult onTerminalViewKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      final logicalKeysPressed = HardwareKeyboard.instance.logicalKeysPressed;

      if (logicalKeysPressed.contains(LogicalKeyboardKey.controlLeft)) {
        if (event.logicalKey == LogicalKeyboardKey.equal) {
          fontSizeL.value = min(fontSizeL.value + 1.0, 32.0);
          return KeyEventResult.handled;
        } else if (event.logicalKey == LogicalKeyboardKey.minus) {
          fontSizeL.value = max(fontSizeL.value - 1.0, 8.0);
          return KeyEventResult.handled;
        }
      }
    }

    return KeyEventResult.ignored;
  }
}
