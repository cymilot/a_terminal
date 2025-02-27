import 'package:a_terminal/consts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:system_theme/system_theme.dart';

class Settings {
  final _settings = Hive.box(boxApp);

  ValueListenable<Box> get listenable => _settings.listenable();

  ThemeMode get themeMode => _settings.get(
        'themeMode',
        defaultValue: ThemeMode.system,
      );
  set themeMode(ThemeMode themeMode) => _settings.put(
        'themeMode',
        themeMode,
      );

  bool get useDynamicColor => _settings.get(
        'useDynamicColor',
        defaultValue: defaultTargetPlatform.supportsAccentColor,
      );
  set useDynamicColor(bool useDynamicColor) => _settings.put(
        'useDynamicColor',
        useDynamicColor,
      );

  Color get fallBackColor => _settings.get(
        'fallBackColor',
        defaultValue: Colors.lightBlueAccent,
      );
  set fallBackColor(Color fallBackColor) => _settings.put(
        'fallBackColor',
        fallBackColor,
      );

  int get maxLines => _settings.get(
        'maxLines',
        defaultValue: 1000,
      );
  set maxLines(int maxLines) => _settings.put(
        'maxLines',
        maxLines,
      );

  void changeWith({
    ThemeMode? themeMode,
    bool? useDynamicColor,
    Color? fallBackColor,
    int? maxLines,
  }) {
    if (themeMode != null) this.themeMode = themeMode;
    if (useDynamicColor != null) this.useDynamicColor = useDynamicColor;
    if (fallBackColor != null) this.fallBackColor = fallBackColor;
    if (maxLines != null) this.maxLines = maxLines;
  }
}
