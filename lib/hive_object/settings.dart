import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class SettingsData extends HiveObject {
  SettingsData({
    required this.themeMode,
    required this.useSystemAccent,
    required this.accentColor,
    required this.terminalMaxLines,
  });

  final ThemeMode themeMode;
  final bool useSystemAccent;
  final Color accentColor;
  final int terminalMaxLines;

  SettingsData copyWith({
    ThemeMode? themeMode,
    bool? useSystemAccent,
    Color? accentColor,
    int? terminalMaxLines,
  }) {
    return SettingsData(
      themeMode: themeMode ?? this.themeMode,
      useSystemAccent: useSystemAccent ?? this.useSystemAccent,
      accentColor: accentColor ?? this.accentColor,
      terminalMaxLines: terminalMaxLines ?? this.terminalMaxLines,
    );
  }

  @override
  String toString() {
    return 'SettingsData(themeMode: $themeMode,'
        ' useSystemAccent: $useSystemAccent,'
        ' accentColor: $accentColor,'
        ' terminalMaxLines: $terminalMaxLines)';
  }

  @override
  bool operator ==(Object other) {
    return other is SettingsData &&
        other.themeMode == themeMode &&
        other.useSystemAccent == useSystemAccent &&
        other.accentColor == accentColor &&
        other.terminalMaxLines == terminalMaxLines;
  }

  @override
  int get hashCode => Object.hashAll([
        themeMode,
        useSystemAccent,
        accentColor,
        terminalMaxLines,
      ]);
}
