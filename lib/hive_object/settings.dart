import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class SettingsData extends HiveObject {
  SettingsData({
    required this.themeMode,
    required this.useDynamicColor,
    required this.color,
    required this.terminalMaxLines,
  });

  final ThemeMode themeMode;
  final bool useDynamicColor;
  final Color color;
  final int terminalMaxLines;

  SettingsData copyWith({
    ThemeMode? themeMode,
    bool? useDynamicColor,
    Color? color,
    int? terminalMaxLines,
  }) {
    return SettingsData(
      themeMode: themeMode ?? this.themeMode,
      useDynamicColor: useDynamicColor ?? this.useDynamicColor,
      color: color ?? this.color,
      terminalMaxLines: terminalMaxLines ?? this.terminalMaxLines,
    );
  }

  @override
  String toString() {
    return 'SettingsData(themeMode: $themeMode,'
        ' useDynamicColor: $useDynamicColor,'
        ' color: $color,'
        ' terminalMaxLines: $terminalMaxLines)';
  }

  @override
  bool operator ==(Object other) {
    return other is SettingsData &&
        other.themeMode == themeMode &&
        other.useDynamicColor == useDynamicColor &&
        other.color == color &&
        other.terminalMaxLines == terminalMaxLines;
  }

  @override
  int get hashCode => Object.hashAll([
        themeMode,
        useDynamicColor,
        color,
        terminalMaxLines,
      ]);
}
