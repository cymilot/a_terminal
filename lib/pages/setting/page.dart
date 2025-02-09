import 'package:a_terminal/consts.dart';
import 'package:a_terminal/pages/setting/logic.dart';
import 'package:a_terminal/utils/extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:system_theme/system_theme.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SettingLogic(context: context),
      lazy: true,
      builder: (context, _) {
        final logic = context.read<SettingLogic>();
        final theme = Theme.of(context);

        logic.init();

        return ValueListenableBuilder(
          valueListenable: logic.settingL,
          builder: (context, setting, child) {
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
                    alignmentOffset: context.isWideScreen
                        ? const Offset(88.0, 0.0)
                        : const Offset(16.0, 0.0),
                    style: const MenuStyle(alignment: Alignment.centerLeft),
                    builder: (_, controller, __) {
                      return SizedBox(
                        width: 96.0,
                        height: 40.0,
                        child: FilledButton.tonal(
                          onPressed: () => logic.onDisplayMenu(controller),
                          child: Text(
                            logic.genThemeName(setting),
                            maxLines: 1,
                            textScaler: const TextScaler.linear(0.9),
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                      );
                    },
                    menuChildren: [
                      MenuItemButton(
                        onPressed: () => logic.onUpdateTheme(ThemeMode.system),
                        child: Text('systemTheme'.tr(context)),
                      ),
                      MenuItemButton(
                        onPressed: () => logic.onUpdateTheme(ThemeMode.light),
                        child: Text('lightTheme'.tr(context)),
                      ),
                      MenuItemButton(
                        onPressed: () => logic.onUpdateTheme(ThemeMode.dark),
                        child: Text('darkTheme'.tr(context)),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: Text('systemColor'.tr(context)),
                  trailing: Switch(
                    value: setting.useSystemAccent,
                    onChanged: defaultTargetPlatform.supportsAccentColor
                        ? logic.onSwitchUseSystemAccent
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
                  child: setting.useSystemAccent
                      ? const SizedBox.shrink()
                      : ListTile(
                          title: Text('color'.tr(context)),
                          trailing: SizedBox(
                            width: 96.0,
                            height: 40.0,
                            child: FilledButton.tonal(
                              onPressed: logic.onUpdateColor,
                              child: SizedBox(
                                width: 24.0,
                                height: 24.0,
                                child: ColoredBox(color: setting.accentColor),
                              ),
                            ),
                          ),
                        ),
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
                    height: 40.0,
                    child: TextField(
                      focusNode: logic.maxLinesFocusNode,
                      controller: logic.maxLinesController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      onEditingComplete: logic.onUpdateMaxLines,
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
