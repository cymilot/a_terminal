import 'package:a_terminal/l10n/output/l10n.dart';
import 'package:a_terminal/utils/debug.dart';
import 'package:flutter/widgets.dart';

extension ExAppL10n on AppL10n {
  static final Map<String, String Function(List<dynamic>)> _translations = {};

  Map<String, String Function(List<dynamic>)> get translations {
    if (_translations.isEmpty) {
      _translations.addAll({
        'appTitle': (_) => appTitle,
        'exitTip': (_) => exitTip,
        'addNew': (_) => addNew,
        'local': (_) => local,
        'localCreate': (_) => localCreate,
        'localEdit': (_) => localEdit,
        'remote': (_) => remote,
        'remoteCreate': (_) => remoteCreate,
        'remoteEdit': (_) => remoteEdit,
        'termName': (_) => termName,
        'termShell': (_) => termShell,
        'termHost': (_) => termHost,
        'termPort': (_) => termPort,
        'termUser': (_) => termUser,
        'termPass': (_) => termPass,
        'inRequired': (args) {
          final v1 = args.elementAtOrNull(0);
          if (v1 == null) {
            logger.w('AppL10n: inRequired arguments are missing or invalid.');
            return inRequired('');
          }
          return inRequired(v1);
        },
        'inSelecting': (args) {
          final v1 = args.elementAtOrNull(0);
          if (v1 == null || v1 is! int) {
            logger.w('AppL10n: inSelecting arguments are missing or invalid.');
            return inSelecting(0);
          }
          return inSelecting(v1);
        },
        'home': (_) => home,
        'noTerm': (_) => noTerm,
        'term': (_) => term,
        'setting': (_) => setting,
        'general': (_) => general,
        'theme': (_) => theme,
        'system': (_) => system,
        'light': (_) => light,
        'dark': (_) => dark,
        'useSystemAccent': (_) => useSystemAccent,
        'color': (_) => color,
        'selectColor': (_) => selectColor,
        'terminal': (_) => terminal,
        'termMaxLines': (_) => termMaxLines,
        'unknown': (_) => unknown,
        'goBack': (_) => goBack,
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

  String replaceAllWithSkip(Pattern from, String replace, [int skipCount = 0]) {
    int skipped = 0;
    final r = StringBuffer();
    int lastIndex = 0;

    for (var match in from.allMatches(this)) {
      r.write(substring(lastIndex, match.start));
      if (skipped < skipCount) {
        r.write(match.group(0));
        skipped++;
      } else {
        r.write(replace);
      }
      lastIndex = match.end;
    }

    r.write(substring(lastIndex));
    return r.toString();
  }
}

extension ExBuildContext on BuildContext {
  bool get isWideScreen => MediaQuery.of(this).size.width >= 768;
  bool get isNarrowScreen => MediaQuery.of(this).size.width < 768;
}
