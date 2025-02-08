import 'package:a_terminal/pages/view/page.dart';
import 'package:a_terminal/pages/form/page.dart';
import 'package:a_terminal/pages/home/page.dart';
import 'package:a_terminal/pages/setting/page.dart';
import 'package:a_terminal/pages/terminal/page.dart';
import 'package:a_terminal/pages/unknown/page.dart';
import 'package:flutter/material.dart';

enum AppRailItemType {
  body,
  footer,
}

class FormArgs {
  FormArgs({
    required this.subName,
    this.matchKey,
  });

  final String subName;
  final String? matchKey;
}

class RouteInfo {
  const RouteInfo({
    required this.name,
    this.type,
    this.iconData,
    this.selectedIconData,
    this.action,
    required this.builder,
    this.children,
  });

  final String name;
  final AppRailItemType? type;
  final IconData? iconData;
  final IconData? selectedIconData;
  final Widget Function(BuildContext context)? action;
  final Widget Function(BuildContext context, Object? args) builder;
  final Map<String, RouteInfo>? children;

  PageRoute route(RouteSettings settings, [bool maintainState = false]) =>
      // todo: transition animation
      MaterialPageRoute(
        settings: settings,
        maintainState: maintainState,
        builder: (context) => builder(context, settings.arguments),
      );
}

/// /home
const rHome = '/home';

/// /home/form
const rForm = '/home/form';

/// /term
const rTerm = '/term';

const rSetting = '/setting';
const rActive = '/active';

/// /unknown
const rUnknown = '/unknown';

class AppRouter {
  static const initialRoute = '/home';
  static const initialName = 'home';
  static const initialIndex = 0;

  static final info = {
    // body
    '/home': RouteInfo(
      name: 'home',
      type: AppRailItemType.body,
      iconData: Icons.home_outlined,
      selectedIconData: Icons.home,
      builder: (context, args) => const HomePage(key: ValueKey(rHome)),
      children: {
        '/form': RouteInfo(
          name: 'form',
          builder: (context, args) => FormPage(
            key: const ValueKey(rForm),
            args: args,
          ),
        ),
      },
    ),
    '/term': RouteInfo(
      name: 'term',
      type: AppRailItemType.body,
      iconData: Icons.terminal_outlined,
      selectedIconData: Icons.terminal,
      builder: (context, args) => const TerminalPage(key: ValueKey(rTerm)),
    ),
    // footer
    '/setting': RouteInfo(
      name: 'setting',
      type: AppRailItemType.footer,
      iconData: Icons.settings_outlined,
      selectedIconData: Icons.settings,
      builder: (context, args) => const SettingPage(key: ValueKey(rSetting)),
    ),
    // other
    '/active': RouteInfo(
      name: 'active',
      builder: (context, args) => const ViewPage(key: ValueKey(rActive)),
    ),
    '/unknown': RouteInfo(
      name: 'unknown',
      builder: (context, args) => const UnknownPage(key: ValueKey(rUnknown)),
    ),
  };

  static bool isSubRoute(String routeName) => routeName.indexOf('/', 1) != -1;

  static RouteInfo getInfo([String? routeName]) {
    late RouteInfo result;
    if (routeName == null) {
      return info[rUnknown]!;
    }
    final r = routeName.split(RegExp(r'(?=\/)'));
    if (info[r[0]] == null) {
      return info[rUnknown]!;
    }
    result = info[r[0]]!;
    for (var i = 1; i < r.length; i++) {
      if (result.children == null && result.children![r[i]] == null) {
        return result;
      }
      result = result.children![r[i]]!;
    }
    return result;
  }
}
