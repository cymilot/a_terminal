import 'package:a_terminal/logic.dart';
import 'package:a_terminal/models/setting.dart';
import 'package:a_terminal/pages/scaffold/logic.dart';
import 'package:a_terminal/utils/extension.dart';
import 'package:a_terminal/utils/listenable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

class SettingLogic with ChangeNotifier, DiagnosticableTreeMixin {
  SettingLogic({required this.context});

  final BuildContext context;

  ScaffoldLogic get scaffoldLogic => context.read<ScaffoldLogic>();
  ListenableData<SettingModel> get settingL =>
      context.read<AppLogic>().currentSetting;

  final maxLinesController = TextEditingController();
  final maxLinesFocusNode = FocusNode();

  void init() {
    if (!maxLinesFocusNode.hasListeners) {
      maxLinesFocusNode.addListener(_maxLinesFocusListener);
    }
    maxLinesController.text = settingL.value.termMaxLines.toString();
  }

  void onDisplayMenu(MenuController controller) {
    if (controller.isOpen) {
      controller.close();
    } else {
      controller.open();
    }
  }

  void onUpdateTheme(ThemeMode mode) {
    settingL.value = settingL.value.copyWith(themeMode: mode);
  }

  void onSwitchUseSystemAccent(bool value) {
    settingL.value = settingL.value.copyWith(useSystemAccent: value);
  }

  void onUpdateColor() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('selectColor'.tr(context)),
          content: BlockPicker(
            pickerColor: settingL.value.accentColor,
            onColorChanged: (color) {
              scaffoldLogic.navigator?.pop();
              settingL.value = settingL.value.copyWith(accentColor: color);
            },
          ),
        );
      },
    );
  }

  void onUpdateMaxLines() {
    final v = int.tryParse(maxLinesController.text);
    if (v != null) {
      settingL.value = settingL.value.copyWith(termMaxLines: v);
    }
  }

  String genThemeName(SettingModel setting) =>
      setting.themeMode.name.tr(context);

  void _maxLinesFocusListener() {
    if (!maxLinesFocusNode.hasFocus) {
      onUpdateMaxLines();
    }
  }
}
