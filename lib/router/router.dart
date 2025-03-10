import 'package:a_terminal/consts.dart';
import 'package:a_terminal/pages/form/page.dart';
import 'package:a_terminal/pages/history/page.dart';
import 'package:a_terminal/pages/home/page.dart';
import 'package:a_terminal/pages/settings/page.dart';
import 'package:a_terminal/pages/sftp/page.dart';
import 'package:a_terminal/pages/terminal/page.dart';
import 'package:a_terminal/pages/unknown/page.dart';
import 'package:a_terminal/pages/view/page.dart';
import 'package:a_terminal/utils/extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum AppRailItemType {
  body,
  footer,
}

class RailConfig {
  RailConfig({
    required this.type,
    required this.iconData,
    required this.selectedIconData,
    this.action,
  });

  final AppRailItemType type;
  final IconData iconData;
  final IconData selectedIconData;
  final Widget Function(BuildContext)? action;

  @override
  String toString() => '''
RailConfig(
  type: $type,
  iconData: $iconData,
  selectedIconData: $selectedIconData,
)''';
}

class RouteConfig {
  const RouteConfig({
    required this.name,
    this.railConfig,
    required this.builder,
  });

  final String name;
  final RailConfig? railConfig;
  final Widget Function(BuildContext, Map<String, String>) builder;

  Route<dynamic> toRoute(
    RouteSettings settings,
    Map<String, String> queryParams,
  ) {
    return MaterialPageRoute(
      maintainState: false,
      builder: (context) => builder(context, queryParams),
      settings: settings,
    );
  }

  @override
  String toString() => '''
RouteConfig(
  name: $name,
  railConfig: $railConfig,
)''';
}

class AppRouteLogic with DiagnosticableTreeMixin {
  AppRouteLogic(this.context);

  final BuildContext context;

  final Map<String, RouteConfig> routeMap = {
    '/home': RouteConfig(
      name: 'home',
      railConfig: RailConfig(
        type: AppRailItemType.body,
        iconData: Icons.home_outlined,
        selectedIconData: Icons.home,
      ),
      builder: (context, queryParams) => const HomePage(),
    ),
    '/home/form': RouteConfig(
      name: 'terminal',
      builder: (context, queryParams) => FormPage(queryParams: queryParams),
    ),
    '/terminal': RouteConfig(
      name: 'terminal',
      railConfig: RailConfig(
        type: AppRailItemType.body,
        iconData: Icons.terminal_outlined,
        selectedIconData: Icons.terminal,
      ),
      builder: (context, queryParams) => const TerminalPage(),
    ),
    '/sftp': RouteConfig(
      name: 'sftp',
      railConfig: RailConfig(
        type: AppRailItemType.body,
        iconData: Icons.drive_file_move_outlined,
        selectedIconData: Icons.drive_file_move,
      ),
      builder: (context, queryParams) => const SftpPage(),
    ),
    '/history': RouteConfig(
      name: 'history',
      railConfig: RailConfig(
        type: AppRailItemType.body,
        iconData: Icons.history_outlined,
        selectedIconData: Icons.history,
      ),
      builder: (context, queryParams) => const HistoryPage(),
    ),
    '/settings': RouteConfig(
      name: 'settings',
      railConfig: RailConfig(
        type: AppRailItemType.footer,
        iconData: Icons.settings_outlined,
        selectedIconData: Icons.settings,
      ),
      builder: (context, queryParams) => const SettingsPage(),
    ),
    '/view': RouteConfig(
      name: 'view',
      builder: (context, queryParams) => ViewPage(queryParams: queryParams),
    ),
  };
  late final Map<String, RouteConfig> redirectMap = {
    '/': routeMap['/home']!,
  };

  final currentRoute = ValueNotifier('/home');
  final currentName = ValueNotifier('home');

  bool isPages(List<String> routeNames) =>
      routeNames.contains(currentRoute.value);

  bool get canBack => isPages(['/home/form', '/view']);

  List<T> iterableRouteMap<T>(T? Function(String, RouteConfig) callback) {
    final list = <T>[];
    for (var item in routeMap.entries) {
      final result = callback(item.key, item.value);
      if (result != null) {
        list.add(result);
      }
    }
    return list;
  }

  Widget buildUnknownPage(
    BuildContext context, [
    Map<String, String>? queryParams,
  ]) {
    return const UnknownPage();
  }

  void dispose() {
    currentRoute.dispose();
    currentName.dispose();
  }

  @override
  String toStringShort() => '''
AppRouteLogic(
  routeMap: ${routeMap.values},
  redirectMap: ${redirectMap.values},
  currentRoute: ${currentRoute.value},
  currentName: ${currentName.value}.
)''';
}

class AppRouteOberserver extends NavigatorObserver {
  AppRouteOberserver(this.context);

  final BuildContext context;

  AppRouteLogic get router => context.read<AppRouteLogic>();

  void update(Route? route) {
    late final String path;
    late final Map<String, String>? queryParams;

    if (route?.settings.name != null) {
      final uri = Uri.tryParse(route!.settings.name!);
      path = uri?.path ?? '/unknown';
      queryParams = uri?.queryParameters;
    } else {
      path = '/unknown';
      queryParams = null;
    }

    final name = router.routeMap[path]?.name ??
        router.redirectMap[path]?.name ??
        'unknown';

    router.currentRoute.value = path;
    router.currentName.value = switch (path) {
      '/home/form' => name.tr(context, {
          'action': queryParams?['action'],
          'type': queryParams?['type'],
          'lower': queryParams?['action'] != null ? 1 : 0,
        }),
      _ => name.tr(context),
    };
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    update(route);
    logger.d('didPush: ${route.settings.name}');
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    update(previousRoute);
    logger.d('didPop: ${route.settings.name}');
    super.didPop(route, previousRoute);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    update(previousRoute);
    logger.d('didRemove: ${route.settings.name}');
    super.didRemove(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    update(newRoute);
    logger.d(
      'didReplace: ${oldRoute?.settings.name} -> ${newRoute?.settings.name}',
    );
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}

class AppNavigator extends StatelessWidget {
  const AppNavigator({
    super.key,
    required this.navigatorKey,
    required this.initialRoute,
    required this.routeMap,
    required this.redirectMap,
    required this.unknownPageBuilder,
  });

  final Key navigatorKey;
  final String initialRoute;
  final Map<String, RouteConfig> routeMap;
  final Map<String, RouteConfig> redirectMap;
  final Widget Function(BuildContext, [Map<String, String>?])
      unknownPageBuilder;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      initialRoute: initialRoute,
      onGenerateRoute: _onGenerateRoute,
      onUnknownRoute: _onUnknownRoute,
      observers: [
        AppRouteOberserver(context),
      ],
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    if (settings.name == null || settings.name!.isEmpty) {
      return null;
    }
    try {
      final uri = Uri.parse(settings.name!);
      return routeMap[uri.path]?.toRoute(settings, uri.queryParameters) ??
          redirectMap[uri.path]?.toRoute(settings, uri.queryParameters);
    } catch (e) {
      return null;
    }
  }

  Route<dynamic> _onUnknownRoute(RouteSettings settings) {
    try {
      final uri = Uri.parse(settings.name!);
      return MaterialPageRoute(
        maintainState: false,
        builder: (context) => unknownPageBuilder(context, uri.queryParameters),
        settings: RouteSettings(
          name: '/unknown',
          arguments: settings.arguments,
        ),
      );
    } catch (e) {
      logger.e('Error: $e');
      return MaterialPageRoute(
        maintainState: false,
        builder: (context) => unknownPageBuilder(context),
        settings: RouteSettings(
          name: '/unknown',
          arguments: settings.arguments,
        ),
      );
    }
  }
}
