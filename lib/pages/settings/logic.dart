import 'package:a_terminal/consts.dart';
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
    timeoutController.text = settings.timeout.toString();
    timeoutNode.addListener(
        () => _listenNode(timeoutNode, 'timeout', timeoutController));
    maxLinesController.text = settings.maxLines.toString();
    maxLinesNode.addListener(
        () => _listenNode(maxLinesNode, 'maxLines', maxLinesController));
  }

  final BuildContext context;

  AppLogic get appLogic => context.read<AppLogic>();
  ScaffoldLogic get scaffoldLogic => context.read<ScaffoldLogic>();

  Settings get settings => appLogic.settings;

  NavigatorState? get rootNavigator => scaffoldLogic.rootNavigator;

  final timeoutController = TextEditingController();
  final timeoutNode = FocusNode();

  final maxLinesController = TextEditingController();
  final maxLinesNode = FocusNode();

  void onDisplayMenu(MenuController controller) {
    if (controller.isOpen) {
      controller.close();
    } else {
      controller.open();
    }
  }

  void onOpenColorSwitcher() async {
    Color? tempColor;
    final result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('switchColor'.tr(context)),
          content: SizedBox(
            width: kDialogWidth,
            height: kDialogHeight,
            child: ColorPicker(
              colorPickerWidth: kDialogWidth,
              pickerAreaHeightPercent: 0.54,
              pickerColor: settings.fallBackColor,
              onColorChanged: (color) => tempColor = color,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => rootNavigator?.pop(),
              child: Text('cancel'.tr(context)),
            ),
            FilledButton.tonal(
              onPressed: () => rootNavigator?.pop(true),
              child: Text('submit'.tr(context)),
            ),
          ],
        );
      },
    );
    if (result != null) onUpdateSettings({'fallBackColor': tempColor});
  }

  void onUpdateSettings(Map<String, dynamic> value) {
    settings.changeWith(
      themeMode: value['themeMode'],
      dynamicColor: value['dynamicColor'],
      fallBackColor: value['fallBackColor'],
      timeout: _strToInt(value['timeout']),
      maxLines: _strToInt(value['maxLines']),
    );
  }

  String get genThemeName => '${settings.themeMode.name}Theme'.tr(context);

  void _listenNode(
    FocusNode self,
    String key,
    TextEditingController controller,
  ) {
    if (!self.hasFocus) onUpdateSettings({key: controller.text});
  }

  int? _strToInt(String? value) => value != null ? int.tryParse(value) : null;

  void dispose() {
    timeoutController.dispose();
    timeoutNode.dispose();
    maxLinesController.dispose();
    maxLinesNode.dispose();
  }

  @override
  String toStringShort() => '''
SettingsLogic(
  timeoutController: ${timeoutController.value},
  maxLinesController: ${maxLinesController.value},
)''';
}
