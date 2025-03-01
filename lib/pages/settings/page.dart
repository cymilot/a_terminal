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
        final theme = Theme.of(context);
        return ValueListenableBuilder(
          valueListenable: logic.settings.listenable,
          builder: (context, box, child) {
            return ListView(
              children: [
                ListTile(
                  title: Text(
                    'general'.tr(context),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildDivider(),
                ListTile(
                  title: Text('theme'.tr(context)),
                  trailing: MenuAnchor(
                    style: MenuStyle(alignment: Alignment(-0.65, 0.0)),
                    builder: (_, controller, __) {
                      return SizedBox(
                        width: 128.0,
                        height: 40.0,
                        child: FilledButton.tonal(
                          onPressed: () => logic.onDisplayMenu(controller),
                          child: Text(
                            logic.genThemeName,
                            maxLines: 1,
                            textScaler: const TextScaler.linear(0.9),
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                      );
                    },
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
                    value: logic.settings.useDynamicColor,
                    onChanged: defaultTargetPlatform.supportsAccentColor
                        ? (value) =>
                            logic.onUpdateSettings({'useDynamicColor': value})
                        : null,
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
                  child: logic.settings.useDynamicColor
                      ? const SizedBox.shrink()
                      : ListTile(
                          title: Text('color'.tr(context)),
                          trailing: SizedBox(
                            width: 96.0,
                            height: 40.0,
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
                ListTile(
                  title: Text(
                    'terminal'.tr(context),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildDivider(),
                ListTile(
                  title: Text('maxLines'.tr(context)),
                  trailing: SizedBox(
                    width: 96.0,
                    child: TextField(
                      focusNode: logic.maxLinesFocusNode,
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

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Divider(height: 12, thickness: 2),
    );
  }
}
