import 'package:a_terminal/logic.dart';
import 'package:a_terminal/hive_object/settings.dart';
import 'package:a_terminal/pages/scaffold/logic.dart';
import 'package:a_terminal/utils/extension.dart';
import 'package:a_terminal/utils/listenable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

class SettingsLogic with DiagnosticableTreeMixin {
  SettingsLogic(this.context) {
    maxLinesFocusNode.addListener(_maxLinesFocusListener);
    maxLinesController.text = settingsL.value.terminalMaxLines.toString();
  }

  final BuildContext context;

  ScaffoldLogic get scaffoldLogic => context.read<ScaffoldLogic>();
  ListenableData<SettingsData> get settingsL =>
      context.read<AppLogic>().currentSettings;

  final maxLinesController = TextEditingController();
  final maxLinesFocusNode = FocusNode();

  void onDisplayMenu(MenuController controller) {
    if (controller.isOpen) {
      controller.close();
    } else {
      controller.open();
    }
  }

  void onUpdateTheme(ThemeMode mode) {
    settingsL.value = settingsL.value.copyWith(themeMode: mode);
  }

  void onSwitchUseSystemAccent(bool value) {
    settingsL.value = settingsL.value.copyWith(useSystemAccent: value);
  }

  void onUpdateColor() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('switchColor'.tr(context)),
          content: BlockPicker(
            pickerColor: settingsL.value.accentColor,
            onColorChanged: (color) {
              scaffoldLogic.navigator?.pop();
              settingsL.value = settingsL.value.copyWith(accentColor: color);
            },
          ),
        );
      },
    );
  }

  void onUpdateMaxLines() {
    final v = int.tryParse(maxLinesController.text);
    if (v != null) {
      settingsL.value = settingsL.value.copyWith(terminalMaxLines: v);
    }
  }

  String genThemeName(SettingsData settings) =>
      '${settings.themeMode.name}Theme'.tr(context);

  void _maxLinesFocusListener() {
    if (!maxLinesFocusNode.hasFocus) {
      onUpdateMaxLines();
    }
  }

  void dispose() {
    maxLinesFocusNode.removeListener(_maxLinesFocusListener);
    maxLinesController.dispose();
  }
}
