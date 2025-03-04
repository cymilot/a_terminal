import 'package:a_terminal/consts.dart';
import 'package:a_terminal/pages/settings/logic.dart';
import 'package:a_terminal/utils/extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:system_theme/system_theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => SettingsLogic(context),
      dispose: (context, logic) => logic.dispose(),
      lazy: true,
      builder: (context, _) {
        final logic = context.read<SettingsLogic>();

        return ListenableBuilder(
          listenable: logic.settings.listenable,
          builder: (context, _) {
            return ListView(
              children: [
                ListTile(title: _buildGroupTitle('general'.tr(context))),
                _buildDivider(),
                ListTile(
                  title: Text('theme'.tr(context)),
                  trailing: MenuAnchor(
                    builder: (_, controller, __) => SizedBox(
                      width: kSelectionWidth,
                      height: kSelectionHeight,
                      child: FilledButton.tonal(
                        onPressed: () => logic.onDisplayMenu(controller),
                        child: Text(logic.genThemeName, maxLines: 1),
                      ),
                    ),
                    menuChildren: [
                      MenuItemButton(
                        onPressed: () => logic
                            .onUpdateSettings({'themeMode': ThemeMode.system}),
                        child: Text('systemTheme'.tr(context)),
                      ),
                      MenuItemButton(
                        onPressed: () => logic
                            .onUpdateSettings({'themeMode': ThemeMode.light}),
                        child: Text('lightTheme'.tr(context)),
                      ),
                      MenuItemButton(
                        onPressed: () => logic
                            .onUpdateSettings({'themeMode': ThemeMode.dark}),
                        child: Text('darkTheme'.tr(context)),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: Text('dynamicColor'.tr(context)),
                  trailing: Switch(
                    value: logic.settings.dynamicColor,
                    onChanged: defaultTargetPlatform.supportsAccentColor
                        ? (value) =>
                            logic.onUpdateSettings({'dynamicColor': value})
                        : null,
                    thumbIcon: WidgetStateMapper({
                      WidgetState.selected: Icon(Icons.check),
                      WidgetState.any: Icon(Icons.close),
                    }),
                  ),
                ),
                AnimatedSwitcher(
                  duration: kAnimationDuration,
                  layoutBuilder: (currentChild, previousChildren) {
                    return Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        ...previousChildren,
                        if (currentChild != null) currentChild,
                      ],
                    );
                  },
                  child: logic.settings.dynamicColor
                      ? const SizedBox.shrink()
                      : ListTile(
                          title: Text('color'.tr(context)),
                          trailing: SizedBox(
                            width: kSelectionWidth,
                            height: kSelectionHeight,
                            child: FilledButton.tonal(
                              onPressed: logic.onOpenColorSwitcher,
                              child: SizedBox(
                                width: 24.0,
                                height: 24.0,
                                child: ColoredBox(
                                  color: logic.settings.fallBackColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                  transitionBuilder: (child, animation) {
                    return SizeTransition(
                      sizeFactor: animation,
                      child: child,
                    );
                  },
                ),
                ListTile(title: _buildGroupTitle('terminal'.tr(context))),
                _buildDivider(),
                ListTile(
                  title: Text('timeout'.tr(context)),
                  trailing: SizedBox(
                    width: kInputWidth,
                    height: kSelectionHeight,
                    child: TextField(
                      // TODO: inputFormatters
                      focusNode: logic.timeoutNode,
                      controller: logic.timeoutController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      onEditingComplete: () => logic.onUpdateSettings(
                          {'timeout': logic.timeoutController.text}),
                    ),
                  ),
                ),
                ListTile(
                  title: Text('maxLines'.tr(context)),
                  trailing: SizedBox(
                    width: kInputWidth,
                    height: kSelectionHeight,
                    child: TextField(
                      // TODO: inputFormatters
                      focusNode: logic.maxLinesNode,
                      controller: logic.maxLinesController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      onEditingComplete: () => logic.onUpdateSettings(
                          {'maxLines': logic.maxLinesController.text}),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildGroupTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Divider(height: 12, thickness: 2),
    );
  }
}
