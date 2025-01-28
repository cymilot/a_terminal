import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class SettingModel extends HiveObject {
  SettingModel({
    required this.themeMode,
    required this.useSystemAccent,
    required this.accentColor,
    required this.termMaxLines,
  });

  final ThemeMode themeMode;
  final bool useSystemAccent;
  final Color accentColor;
  final int termMaxLines;

  SettingModel copyWith({
    ThemeMode? themeMode,
    bool? useSystemAccent,
    Color? accentColor,
    int? termMaxLines,
  }) {
    return SettingModel(
      themeMode: themeMode ?? this.themeMode,
      useSystemAccent: useSystemAccent ?? this.useSystemAccent,
      accentColor: accentColor ?? this.accentColor,
      termMaxLines: termMaxLines ?? this.termMaxLines,
    );
  }

  @override
  String toString() {
    return 'SettingModel(themeMode: $themeMode,'
        ' useSystemAccent: $useSystemAccent,'
        ' accentColor: $accentColor,'
        ' termMaxLines: $termMaxLines)';
  }

  @override
  bool operator ==(Object other) {
    return other is SettingModel &&
        other.themeMode == themeMode &&
        other.useSystemAccent == useSystemAccent &&
        other.accentColor == accentColor &&
        other.termMaxLines == termMaxLines;
  }

  @override
  int get hashCode => Object.hashAll([
        themeMode,
        useSystemAccent,
        accentColor,
        termMaxLines,
      ]);
}
