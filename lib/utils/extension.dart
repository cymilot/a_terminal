import 'package:a_terminal/l10n/output/l10n.dart';
import 'package:flutter/widgets.dart';

extension ExAppL10n on AppL10n {
  static final Map<String, String Function(Map<String, dynamic>)>
      _translations = {};

  Map<String, String Function(Map<String, dynamic>)> get translations {
    if (_translations.isEmpty) {
      _translations.addAll({
        'appTitle': (_) => appTitle,
        'exitTip': (_) => exitTip,
        'addNew': (_) => addNew,
        'isRequired': (args) {
          final v1 = args['name'] ?? '';
          return isRequired(v1);
        },
        'inSelecting': (args) {
          final v1 = args['count'] ?? 0;
          return inSelecting(v1);
        },
        'home': (_) => home,
        'terminal': (args) {
          final v1 = args['action'] ?? '';
          final v2 = args['type'] ?? '';
          final v3 = args['lower'] ?? 0;
          return terminal(v1, v2, v3);
        },
        'terminalName': (_) => terminalName,
        'terminalShell': (_) => terminalShell,
        'terminalHost': (_) => terminalHost,
        'terminalPort': (_) => terminalPort,
        'terminalUser': (_) => terminalUser,
        'terminalPass': (_) => terminalPass,
        'local': (_) => local,
        'remote': (_) => remote,
        'emptyTerminal': (_) => emptyTerminal,
        'sftp': (_) => sftp,
        'history': (_) => history,
        'settings': (_) => settings,
        'general': (_) => general,
        'theme': (_) => theme,
        'systemTheme': (_) => systemTheme,
        'lightTheme': (_) => lightTheme,
        'darkTheme': (_) => darkTheme,
        'color': (_) => color,
        'dynamicColor': (_) => dynamicColor,
        'switchColor': (_) => switchColor,
        'maxLines': (_) => maxLines,
        'unknown': (_) => unknown,
        'back': (_) => back,
        'clear': (_) => clear,
        'drawer': (_) => drawer,
        'edit': (_) => edit,
        'submit': (_) => submit,
        'showPass': (_) => showPass,
        'hidePass': (_) => hidePass,
      });
    }
    return Map.unmodifiable(_translations);
  }
}

extension ExString on String {
  String tr(BuildContext context, [Map<String, dynamic> args = const {}]) {
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

extension ExNavigatorState on NavigatorState {
  Future<T?> pushUri<T extends Object?>(
    String name, {
    Map<String, String>? queryParams,
    Object? arguments,
    bool replace = false,
  }) {
    final uri = Uri(path: name, queryParameters: queryParams);
    if (replace) {
      return pushReplacementNamed(uri.toString(), arguments: arguments);
    } else {
      return pushNamed(uri.toString(), arguments: arguments);
    }
  }
}
