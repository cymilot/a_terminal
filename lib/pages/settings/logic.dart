import 'package:a_terminal/hive_object/settings.dart';
import 'package:a_terminal/logic.dart';
import 'package:a_terminal/pages/scaffold/logic.dart';
import 'package:a_terminal/utils/extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

class SettingsLogic with DiagnosticableTreeMixin {
  SettingsLogic(this.context) {
    maxLinesFocusNode.addListener(() {
      if (!maxLinesFocusNode.hasFocus) {
        onUpdateSettings({'maxLines': maxLinesController.text});
      }
    });
    maxLinesController.text = settings.maxLines.toString();
  }

  final BuildContext context;

  AppLogic get appLogic => context.read<AppLogic>();
  ScaffoldLogic get scaffoldLogic => context.read<ScaffoldLogic>();
  Settings get settings => appLogic.settings;

  final maxLinesController = TextEditingController();
  final maxLinesFocusNode = FocusNode();

  void onDisplayMenu(MenuController controller) {
    if (controller.isOpen) {
      controller.close();
    } else {
      controller.open();
    }
  }

  void onOpenColorSwitcher() async {
    final result = await showDialog<Color>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('switchColor'.tr(context)),
          content: BlockPicker(
            pickerColor: settings.fallBackColor,
            onColorChanged: (color) {
              scaffoldLogic.rootNavigator?.pop(color);
            },
          ),
        );
      },
    );
    if (result != null) {
      onUpdateSettings({'fallBackColor': result});
    }
  }

  void onUpdateSettings(Map<String, dynamic> value) {
    settings.changeWith(
      themeMode: value['themeMode'],
      useDynamicColor: value['useDynamicColor'],
      fallBackColor: value['fallBackColor'],
      maxLines:
          value['maxLines'] != null ? int.tryParse(value['maxLines']) : null,
    );
  }

  String get genThemeName => '${settings.themeMode.name}Theme'.tr(context);

  void dispose() {
    maxLinesFocusNode.dispose();
    maxLinesController.dispose();
  }
}
