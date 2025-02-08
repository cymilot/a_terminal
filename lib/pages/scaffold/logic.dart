import 'dart:math' as math;

import 'package:a_terminal/consts.dart';
import 'package:a_terminal/models/terminal.dart';
import 'package:a_terminal/router/router.dart';
import 'package:a_terminal/utils/debug.dart';
import 'package:a_terminal/utils/extension.dart';
import 'package:a_terminal/utils/listenable.dart';
import 'package:a_terminal/utils/storage.dart';
import 'package:a_terminal/widgets/rail.dart';
import 'package:a_terminal/widgets/tab.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:toastification/toastification.dart';

class ScaffoldLogic with ChangeNotifier, DiagnosticableTreeMixin {
  ScaffoldLogic({required this.context});

  final BuildContext context;

  final scaffoldKey = GlobalKey<ScaffoldState>(debugLabel: 'scaffold');
  ScaffoldState? get scaffold => scaffoldKey.currentState;
  final navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'nested_navigator');
  NavigatorState? get navigator => navigatorKey.currentState;
  NavigatorState? get rootNavigator =>
      Navigator.maybeOf(context, rootNavigator: true);

  // final native = const MethodChannel('native_call');

  final routeName = ValueNotifier(AppRouter.initialRoute);
  final pageName = ValueNotifier(AppRouter.initialName);
  final extended = ValueNotifier(false);
  final drawerIndex = ValueNotifier(AppRouter.initialIndex);
  final canPop = ValueNotifier(false);
  final tabIndex = ValueNotifier(0);
  final selected = ListenableList<String>();
  final activated = ListenableList<ActivatedTerminal>();

  DateTime? lastPressed;

  bool isPages([List<String>? routeNames]) =>
      routeNames?.contains(routeName.value) ?? false;

  bool canBack() {
    // These pages use push instead of replace
    return isPages([rForm, rActive]);
  }

  bool canForward() {
    if (canBack()) return true;
    if (selected.isNotEmpty) return true;
    return false;
  }

  void onPopInvokedWithResult(bool didPop, Object? result) {
    if (routeName.value != rHome) {
      drawerIndex.value = 0;
      navigator?.pushReplacementNamed(rHome);
    } else if (!didPop &&
        (lastPressed == null ||
            DateTime.now().difference(lastPressed!) > kBackDuration)) {
      lastPressed = DateTime.now();
      toastification.show(
        type: ToastificationType.info,
        autoCloseDuration: kBackDuration,
        animationDuration: kAnimationDuration,
        animationBuilder: (context, animation, alignment, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        title: Text('exitTip'.tr(context)),
        alignment: Alignment.bottomCenter,
        style: ToastificationStyle.simple,
      );
      // if (Platform.isAndroid && !kIsWeb) {
      //   native.invokeMethod('showToast', {
      //     'message': 'exitTip'.tr(context),
      //     'duration': 0,
      //   });
      // }
      canPop.value = !canPop.value;
      // reset after 2 seconds
      Future.delayed(kBackDuration, () => canPop.value = !canPop.value);
    }
  }

  void onTapLeading() {
    if (canBack()) {
      // arrow back
      navigator?.maybePop();
    } else if (selected.isNotEmpty) {
      // close
      selected.clear();
    } else {
      // menu
      scaffold?.openDrawer();
    }
  }

  void onDrawerItemSelected(int index) {
    if (drawerIndex.value != index) {
      drawerIndex.value = index;
      navigator?.pushReplacementNamed(AppRouter.info.keys.elementAt(index));
      scaffold?.closeDrawer();
    }
  }

  void onTapFloating(String name) async {
    if (!isPages([name])) {
      final result = await showModalBottomSheet<String>(
        context: context,
        showDragHandle: true,
        useRootNavigator: true,
        builder: (context) {
          return Container(
            height: kModalContainerHeight,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: ListView(
              children: [
                ListTile(
                  title: Text('addNew'.tr(context)),
                  titleTextStyle: Theme.of(context).textTheme.titleMedium,
                ),
                ListTile(
                  leading: const Icon(Icons.terminal),
                  title: Text('local'.tr(context)),
                  onTap: () => rootNavigator?.pop('local'),
                ),
                ListTile(
                  leading: const Icon(Icons.dns),
                  title: Text('remote'.tr(context)),
                  onTap: () => rootNavigator?.pop('remote'),
                ),
              ],
            ),
          );
        },
      );
      if (result != null) {
        navigator?.pushNamed(name, arguments: FormArgs(subName: result));
      }
    } else {
      navigator?.maybePop(true);
    }
  }

  void onTabItemSelected(int index) {
    tabIndex.value = index;
  }

  void onTabItemRemoved(int index) {
    final r = activated.removeAt(index);
    r.destroy();

    if (tabIndex.value >= index && tabIndex.value != 0) {
      tabIndex.value -= 1;
    }
    if (activated.isEmpty) navigator?.pop();
  }

  void onTabReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = activated.removeAt(oldIndex);
    activated.insert(newIndex, item);
    tabIndex.value = newIndex;
  }

  void onDrawerExtended() {
    extended.value = !extended.value;
  }

  void onUpdateRouteName(String newRouteName) {
    routeName.value = newRouteName;
  }

  void onUpdatePageName(String newPageName) {
    pageName.value = newPageName;
  }

  Route<dynamic> genRoute(RouteSettings settings) =>
      AppRouter.getInfo(settings.name).route(settings);

  List<Widget> genDrawerItems(AppRailItemType type) {
    return AppRouter.info.values.where((info) => info.type == type).map((info) {
      return AppRailItem(
        icon: Icon(info.iconData),
        selectedIcon: Icon(info.selectedIconData),
        label: Text(info.name.tr(context)),
        action: info.action?.call(context),
      );
    }).toList();
  }

  List<Widget> genTabItems() {
    return activated.map((term) {
      return AppDraggableTab(
        key: term.key,
        label: Text(term.terminalData.terminalName),
      );
    }).toList();
  }

  List<Widget> genBottomItems() {
    if (isPages([rHome]) && selected.isNotEmpty) {
      return [
        SizedBox(
          width: 56.0,
          child: IconButton(
            onPressed: () async {
              activated.removeWhere(
                  (term) => selected.contains(term.terminalData.terminalKey));
              await Hive.box<TerminalModel>(boxKeyTerminal)
                  .deleteAll(selected.toList());
              selected.clear();
            },
            icon: const Icon(Icons.delete),
          ),
        ),
      ];
    }
    return [];
  }

  @override
  void dispose() {
    super.dispose();
    toastification.dismissAll(delayForAnimation: false);
    routeName.dispose();
    pageName.dispose();
    extended.dispose();
    drawerIndex.dispose();
    canPop.dispose();
    tabIndex.dispose();
    selected.dispose();
    activated.dispose();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(DiagnosticsProperty('routeName', routeName.value));
    properties.add(StringProperty('pageName', pageName.value));
    properties.add(DiagnosticsProperty('extended', extended.value));
    properties.add(IntProperty('drawerIndex', drawerIndex.value));
    properties.add(DiagnosticsProperty('canPop', canPop.value));
    properties.add(DiagnosticsProperty('lastPressed', lastPressed));
    properties.add(IntProperty('tabIndex', tabIndex.value));
    properties.add(IntProperty('selectedTerms', selected.length));
    properties.add(DiagnosticsProperty('activeTerms', activated.length));
    super.debugFillProperties(properties);
  }

  @override
  String toStringShort() {
    return 'AppLogic(routeName: ${routeName.value},'
        ' pageName: ${pageName.value},'
        ' extended: ${extended.value},'
        ' drawerIndex: ${drawerIndex.value},'
        ' canPop: ${canPop.value},'
        ' lastPressed: $lastPressed,'
        ' tabIndex: ${tabIndex.value},'
        ' selectedTerms: ${selected.length},'
        ' activeTerms: ${activated.length})';
  }
}

class AppOberserver extends NavigatorObserver {
  AppOberserver({
    required this.onUpdateRouteName,
    required this.onUpdatePageName,
  });

  final void Function(String) onUpdateRouteName;
  final void Function(String) onUpdatePageName;

  Route<dynamic> goOrRedirect(Route<dynamic>? route) {
    if (route != null) {
      final routeName = route.settings.name;
      final args = route.settings.arguments;
      if (routeName != null) {
        // not anonymous
        final pageName = args != null && args is FormArgs
            ? args.matchKey != null
                ? '${args.subName}Edit'
                : '${args.subName}Create'
            : AppRouter.getInfo(routeName).name;
        onUpdateRouteName(routeName);
        onUpdatePageName(pageName);
        return route;
      }
    }
    return AppRouter.getInfo().route(const RouteSettings(name: rUnknown));
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    logger.i('AppObserver: push ${route.settings.name} to stack.');
    final r = goOrRedirect(route);
    super.didPush(r, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    late final Route r;
    logger.i('AppObserver: pop ${route.settings.name} from stack.');
    if (previousRoute != null) {
      r = goOrRedirect(previousRoute);
    } else {
      r = goOrRedirect(route);
    }
    super.didPop(r, previousRoute);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    late final Route r;
    logger.i('AppObserver: remove ${route.settings.name} from stack.');
    if (previousRoute != null) {
      r = goOrRedirect(previousRoute);
    } else {
      r = goOrRedirect(route);
    }
    super.didRemove(r, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    logger.i('AppObserver: replace ${oldRoute?.settings.name} with '
        '${newRoute?.settings.name}.');
    final r = goOrRedirect(newRoute);
    super.didReplace(newRoute: r, oldRoute: oldRoute);
  }
}

class CustomLocation extends StandardFabLocation {
  const CustomLocation();

  // bar height (80) - button height / 2 (28)
  final double kDefaultMargin = 52.0;

  double _leftOffsetX(
      ScaffoldPrelayoutGeometry scaffoldGeometry, double adjustment) {
    return kFloatingActionButtonMargin +
        scaffoldGeometry.minInsets.left -
        adjustment;
  }

  double _rightOffsetX(
      ScaffoldPrelayoutGeometry scaffoldGeometry, double adjustment) {
    return scaffoldGeometry.scaffoldSize.width -
        kFloatingActionButtonMargin -
        scaffoldGeometry.minInsets.right -
        scaffoldGeometry.floatingActionButtonSize.width +
        adjustment;
  }

  @override
  double getOffsetX(
      ScaffoldPrelayoutGeometry scaffoldGeometry, double adjustment) {
    return switch (scaffoldGeometry.textDirection) {
      TextDirection.rtl => _leftOffsetX(scaffoldGeometry, adjustment),
      TextDirection.ltr => _rightOffsetX(scaffoldGeometry, adjustment),
    };
  }

  @override
  double getOffsetY(
      ScaffoldPrelayoutGeometry scaffoldGeometry, double adjustment) {
    final double contentBottom = scaffoldGeometry.contentBottom;
    final double contentMargin =
        scaffoldGeometry.scaffoldSize.height - contentBottom;
    final double bottomViewPadding = scaffoldGeometry.minViewPadding.bottom;
    final double bottomSheetHeight = scaffoldGeometry.bottomSheetSize.height;
    final double fabHeight = scaffoldGeometry.floatingActionButtonSize.height;
    final double snackBarHeight = scaffoldGeometry.snackBarSize.height;
    final double bottomMinInset = scaffoldGeometry.minInsets.bottom;

    double safeMargin;

    if (contentMargin > bottomMinInset + fabHeight / 2.0) {
      safeMargin = 0.0;
    } else if (contentMargin < kDefaultMargin) {
      safeMargin = kDefaultMargin;
    } else if (bottomMinInset == 0.0) {
      safeMargin = bottomViewPadding;
    } else {
      safeMargin = fabHeight / 2.0 + kFloatingActionButtonMargin;
    }
    double fabY = contentBottom - fabHeight / 2.0 - safeMargin;
    if (snackBarHeight > 0.0) {
      fabY = math.min(
          fabY,
          contentBottom -
              snackBarHeight -
              fabHeight -
              kFloatingActionButtonMargin);
    }

    if (bottomSheetHeight > 0.0) {
      fabY =
          math.min(fabY, contentBottom - bottomSheetHeight - fabHeight / 2.0);
    }
    final double maxFabY =
        scaffoldGeometry.scaffoldSize.height - fabHeight - safeMargin;
    return math.min(maxFabY, fabY);
  }

  @override
  String toString() => 'CustomLocation';
}
