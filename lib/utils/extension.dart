import 'package:a_terminal/l10n/output/l10n.dart';
import 'package:flutter/widgets.dart';

extension ExAppL10n on AppL10n {
  static final Map<String, String Function(List<dynamic>)> _translations = {};

  Map<String, String Function(List<dynamic>)> get translations {
    if (_translations.isEmpty) {
      _translations.addAll({
        'appTitle': (_) => appTitle,
        'exitTip': (_) => exitTip,
        'addNew': (_) => addNew,
        'inRequired': (args) {
          final v1 = args.elementAtOrNull(0) ?? '';
          return isRequired(v1);
        },
        'inSelecting': (args) {
          final v1 = args.elementAtOrNull(0) ?? 0;
          return inSelecting(v1);
        },
        'home': (_) => home,
        'terminal': (args) {
          final v1 = args.elementAtOrNull(0) ?? '';
          final v2 = args.elementAtOrNull(1) ?? '';
          final v3 = args.elementAtOrNull(2) ?? 0;
          return terminal(v1, v2, v3);
        },
        'terminalName': (_) => terminalName,
        'terminalShell': (_) => terminalShell,
        'terminalHost': (_) => terminalHost,
        'terminalPort': (_) => terminalPort,
        'terminalUser': (_) => terminalUser,
        'terminalPass': (_) => terminalPass,
        'emptyTerminal': (_) => emptyTerminal,
        'setting': (_) => setting,
        'general': (_) => general,
        'theme': (_) => theme,
        'systemTheme': (_) => systemTheme,
        'lightTheme': (_) => lightTheme,
        'darkTheme': (_) => darkTheme,
        'color': (_) => color,
        'systemColor': (_) => systemColor,
        'switchColor': (_) => switchColor,
        'maxLines': (_) => maxLines,
        'unknown': (_) => unknown,
      });
    }
    return Map.unmodifiable(_translations);
  }
}

extension ExString on String {
  String tr(BuildContext context, [List<dynamic> args = const []]) {
    final t = AppL10n.of(context).translations[this];
    return t != null ? t(args) : this;
  }

  String skipableReplaceAll(Pattern from, String replace, [int skipCount = 0]) {
    int skipped = 0;
    final buffer = StringBuffer();
    int lastIndex = 0;
    for (var match in from.allMatches(this)) {
      buffer.write(substring(lastIndex, match.start));
      if (skipped < skipCount) {
        buffer.write(match.group(0));
        skipped++;
      } else {
        buffer.write(replace);
      }
      lastIndex = match.end;
    }

    buffer.write(substring(lastIndex));
    return buffer.toString();
  }
}

extension ExBuildContext on BuildContext {
  bool get isWideScreen => MediaQuery.of(this).size.width >= 768;
  bool get isNarrowScreen => MediaQuery.of(this).size.width < 768;
}
