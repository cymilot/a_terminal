import 'package:a_terminal/pages/view/page.dart';
import 'package:a_terminal/pages/form/page.dart';
import 'package:a_terminal/pages/home/page.dart';
import 'package:a_terminal/pages/setting/page.dart';
import 'package:a_terminal/pages/terminal/page.dart';
import 'package:a_terminal/pages/unknown/page.dart';
import 'package:a_terminal/utils/debug.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum AppRailItemType {
  body,
  footer,
}

// class RouteArguments {
//   RouteArguments({
//     required this.subName,
//     this.matchKey,
//   });

//   final String subName;
//   final String? matchKey;
// }

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
  final Widget Function(BuildContext)? action;
  final Widget Function(BuildContext, Map<String, String>, Object?) builder;
  final Map<String, RouteInfo>? children;

  PageRoute toRoute(
    RouteSettings settings, {
    bool maintainState = false,
    Map<String, String> queryParams = const {},
  }) {
    // todo: transition animation
    return MaterialPageRoute(
      settings: settings,
      maintainState: maintainState,
      builder: (context) => builder(
        context,
        queryParams,
        settings.arguments,
      ),
    );
  }
}

class RouteIn {
  const RouteIn({
    required this.path,
    required this.name,
    this.type,
    this.iconData,
    this.selectedIconData,
    this.action,
    required this.builder,
    this.children,
  });

  final String path;
  final String name;
  final AppRailItemType? type;
  final IconData? iconData;
  final IconData? selectedIconData;
  final Widget Function(BuildContext)? action;
  final Widget Function(BuildContext, Map<String, String>, Object?) builder;
  final List<RouteIn>? children;

  PageRoute toRoute(
    RouteSettings settings, {
    bool maintainState = false,
    Map<String, String> queryParams = const {},
  }) {
    // todo: transition animation
    return MaterialPageRoute(
      settings: settings,
      maintainState: maintainState,
      builder: (context) => builder(
        context,
        queryParams,
        settings.arguments,
      ),
    );
  }
}

class RouteBox {
  RouteBox(
    this.path,
    this.info, [
    this.queryParameters = const {},
  ]);

  final String path;
  final Map<String, String> queryParameters;
  final RouteInfo info;
}

final navigatorKey = GlobalKey<NavigatorState>();

const initialRoute = '/home';
const initialName = 'home';

class AppRouterLogic extends ChangeNotifier {
  AppRouterLogic(this.context) {
    _infoMap = _toInfoMap(infoList);
  }

  final BuildContext context;

  late final Map<String, RouteIn> _infoMap;
  Map<String, RouteIn> get infoMap => _infoMap;

  final currentRoute = ValueNotifier(initialRoute);
  final currentName = ValueNotifier(initialName);
  final canBack = ValueNotifier(false);

  final infoList = [
    RouteIn(
      path: '/home',
      name: 'home',
      iconData: Icons.home_outlined,
      selectedIconData: Icons.home,
      type: AppRailItemType.body,
      builder: (_, queryParams, __) => const HomePage(),
      children: [
        RouteIn(
          path: '/form',
          name: 'form',
          builder: (_, queryParams, __) => FormPage(queryParams: queryParams),
        ),
      ],
    ),
    RouteIn(
      path: '/terminal',
      name: 'terminal',
      iconData: Icons.terminal_outlined,
      selectedIconData: Icons.terminal,
      type: AppRailItemType.body,
      builder: (_, queryParams, __) => const TerminalPage(),
    ),
    RouteIn(
      path: '/setting',
      name: 'setting',
      iconData: Icons.settings_outlined,
      selectedIconData: Icons.settings,
      type: AppRailItemType.footer,
      builder: (_, queryParams, __) => const SettingPage(),
    ),
    RouteIn(
      path: '/view',
      name: 'view',
      builder: (_, queryParams, __) => const ViewPage(),
    ),
    RouteIn(
      path: '/unknown',
      name: 'unknown',
      builder: (_, queryParams, __) => const UnknownPage(),
    ),
  ];

  Map<String, RouteIn> _toInfoMap(List<RouteIn> infoList, [String path = ""]) {
    final infoMap = <String, RouteIn>{};
    for (final i in infoList) {
      infoMap['$path${i.path}'] = i;
      if (i.children != null) {
        infoMap.addAll(_toInfoMap(i.children!, '$path${i.path}'));
      }
    }
    return infoMap;
  }

  bool isPages(List<String> routeNames) {
    return routeNames.contains(currentRoute.value);
  }

  // RouteBox getRouteBox(String? routeName) {
  //   try {
  //     if (routeName == null || routeName.isEmpty) {
  //       return RouteBox('/unknown', info['/unknown']!);
  //     }
  //     final uri = Uri.parse(routeName);
  //     final pathSegments = uri.pathSegments;
  //     final queryParams = uri.queryParameters;
  //     if (pathSegments.isEmpty || info['/${pathSegments.first}'] == null) {
  //       return RouteBox('/unknown', info['/unknown']!, queryParams);
  //     }
  //     final pathBuffer = StringBuffer();
  //     return RouteBox(pathBuffer.toString(), routeInfo, queryParams);
  //   } catch (e) {
  //     // 处理 Uri.parse 可能抛出的异常
  //     return RouteBox('/unknown', info['/unknown']!);
  //   }
  // }

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    if (settings.name == null || settings.name!.isEmpty) {
      return _infoMap['/unknown']!.toRoute(RouteSettings(
        name: '/unknown',
        arguments: settings.arguments,
      ));
    }
    try {
      final uri = Uri.parse(settings.name!);
      final path = uri.path;
      final queryParams = uri.queryParameters;
      if (path == '/') {
        return _infoMap['/home']!.toRoute(
          RouteSettings(
            name: '/home',
            arguments: settings.arguments,
          ),
          queryParams: queryParams,
        );
      }
      if (_infoMap[path] == null) {
        return _infoMap['/unknown']!.toRoute(
          RouteSettings(
            name: '/unknown',
            arguments: settings.arguments,
          ),
          queryParams: queryParams,
        );
      }
      return _infoMap[path]!.toRoute(
        RouteSettings(
          name: path,
          arguments: settings.arguments,
        ),
        queryParams: queryParams,
      );
    } catch (e) {
      return _infoMap['/unknown']!.toRoute(RouteSettings(
        name: '/unknown',
        arguments: settings.arguments,
      ));
    }
  }
}

class AppOberserver extends NavigatorObserver {
  AppOberserver(this.context);

  final BuildContext context;

  AppRouterLogic get router => context.read<AppRouterLogic>();

  @override
  void didPush(Route route, Route? previousRoute) {
    logger.d(
        'didPush: ${route.settings.name}, previousRoute: ${previousRoute?.settings.name}');
    router.currentRoute.value = route.settings.name!;
    router.currentName.value = router.infoMap[route.settings.name!]!.name;
    if (previousRoute != null || previousRoute?.settings.name != '/unknown') {
      router.canBack.value = true;
    }
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    logger.d(
        'didPop: ${route.settings.name}, previousRoute: ${previousRoute?.settings.name}');
    router.currentRoute.value = previousRoute!.settings.name!;
    router.currentName.value =
        router.infoMap[previousRoute.settings.name!]!.name;
    router.canBack.value = false;
    super.didPop(route, previousRoute);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    logger.d(
        'didRemove: ${route.settings.name}, previousRoute: ${previousRoute?.settings.name}');
    router.currentRoute.value = previousRoute!.settings.name!;
    router.currentName.value =
        router.infoMap[previousRoute.settings.name!]!.name;
    super.didRemove(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    logger.d(
        'didReplace: ${newRoute?.settings.name}, oldRoute: ${oldRoute?.settings.name}');
    router.currentRoute.value = newRoute!.settings.name!;
    router.currentName.value = router.infoMap[newRoute.settings.name!]!.name;
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}
