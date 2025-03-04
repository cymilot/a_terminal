import 'package:a_terminal/consts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:system_theme/system_theme.dart';

class Settings {
  final _settings = Hive.box(boxApp);

  ValueListenable<Box> get listenable => _settings.listenable();

  ThemeMode get themeMode =>
      _settings.get('themeMode', defaultValue: ThemeMode.system);
  set themeMode(ThemeMode themeMode) => _settings.put('themeMode', themeMode);

  bool get dynamicColor => _settings.get('dynamicColor',
      defaultValue: defaultTargetPlatform.supportsAccentColor);
  set dynamicColor(bool dynamicColor) =>
      _settings.put('dynamicColor', dynamicColor);

  Color get fallBackColor =>
      _settings.get('fallBackColor', defaultValue: Colors.lightBlueAccent);
  set fallBackColor(Color fallBackColor) =>
      _settings.put('fallBackColor', fallBackColor);

  int get timeout => _settings.get('timeout', defaultValue: 10);
  set timeout(int timeout) => _settings.put('timeout', timeout);

  int get maxLines => _settings.get('maxLines', defaultValue: 1000);
  set maxLines(int maxLines) => _settings.put('maxLines', maxLines);

  void changeWith({
    ThemeMode? themeMode,
    bool? dynamicColor,
    Color? fallBackColor,
    int? timeout,
    int? maxLines,
  }) {
    if (themeMode != null) this.themeMode = themeMode;
    if (dynamicColor != null) this.dynamicColor = dynamicColor;
    if (fallBackColor != null) this.fallBackColor = fallBackColor;
    if (timeout != null) this.timeout = timeout;
    if (maxLines != null) this.maxLines = maxLines;
  }
}
