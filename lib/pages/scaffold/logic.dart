import 'dart:math' as math;

import 'package:a_terminal/consts.dart';
import 'package:a_terminal/models/terminal.dart';
import 'package:a_terminal/pages/unknown/page.dart';
import 'package:a_terminal/router/router.dart';
import 'package:a_terminal/utils/extension.dart';
import 'package:a_terminal/utils/listenable.dart';
import 'package:a_terminal/utils/storage.dart';
import 'package:a_terminal/widgets/rail.dart';
import 'package:a_terminal/widgets/tab.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

class ScaffoldLogic with ChangeNotifier, DiagnosticableTreeMixin {
  ScaffoldLogic(this.context);

  final BuildContext context;

  final scaffoldKey = GlobalKey<ScaffoldState>(debugLabel: 'scaffold');
  ScaffoldState? get scaffold => scaffoldKey.currentState;
  final navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'nested_navigator');
  NavigatorState? get navigator => navigatorKey.currentState;
  NavigatorState? get rootNavigator =>
      Navigator.maybeOf(context, rootNavigator: true);

  AppRouteLogic get appRoute => context.read<AppRouteLogic>();

  final extended = ValueNotifier(false);
  final drawerIndex = ValueNotifier<dynamic>('/home');
  final canPop = ValueNotifier(false);
  final tabIndex = ValueNotifier(0);
  final selected = ListenableList<String>();
  final activated = ListenableList<ActivatedTerminal>();

  DateTime? lastPressed;

  bool canForward() {
    if (appRoute.canBack) return true;
    if (selected.isNotEmpty) return true;
    return false;
  }

  void onPopInvokedWithResult(bool didPop, Object? result) {
    if (appRoute.currentRoute.value != '/home') {
      drawerIndex.value = '/home';
      navigator?.pushReplacementNamed('/home');
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
    if (appRoute.canBack) {
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

  void onDrawerItemSelected(dynamic index) {
    if (drawerIndex.value != index) {
      drawerIndex.value = index;
      navigator?.pushUri(index as String, replace: true);
      scaffold?.closeDrawer();
    }
  }

  void onTapFloating(String name) async {
    if (!appRoute.isPages([name])) {
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
        navigator?.pushUri(name, queryParams: {'type': result});
      }
    } else {
      navigator?.maybePop(true);
    }
  }

  void onTabItemSelected(int index) => tabIndex.value = index;

  void onTabItemRemoved(int index) {
    final terminal = activated.removeAt(index);
    terminal.destroy();
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

  void onDrawerExtended() => extended.value = !extended.value;

  Widget genUnknownPage(BuildContext context, Map<String, String> queryParams) {
    return const UnknownPage();
  }

  List<Widget> genDrawerItems(AppRailItemType type) {
    return appRoute.iterableRouteMap((key, value) {
      if (value.railConfig != null && value.railConfig!.type == type) {
        return AppRailItem(
          icon: Icon(value.railConfig!.iconData),
          selectedIcon: Icon(value.railConfig!.selectedIconData),
          label: Text(value.name.tr(context)),
          action: value.railConfig!.action?.call(context),
          data: key,
        );
      }
      return null;
    });
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
    if (appRoute.isPages(['/home']) && selected.isNotEmpty) {
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
    extended.dispose();
    drawerIndex.dispose();
    canPop.dispose();
    tabIndex.dispose();
    selected.dispose();
    activated.dispose();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(DiagnosticsProperty('extended', extended.value));
    properties.add(DiagnosticsProperty('drawerIndex', drawerIndex.value));
    properties.add(DiagnosticsProperty('canPop', canPop.value));
    properties.add(DiagnosticsProperty('lastPressed', lastPressed));
    properties.add(IntProperty('tabIndex', tabIndex.value));
    properties.add(IntProperty('selected', selected.length));
    properties.add(DiagnosticsProperty('activated', activated.length));
    super.debugFillProperties(properties);
  }

  @override
  String toStringShort() {
    return 'AppLogic(extended: ${extended.value},'
        ' drawerIndex: ${drawerIndex.value},'
        ' canPop: ${canPop.value},'
        ' lastPressed: $lastPressed,'
        ' tabIndex: ${tabIndex.value},'
        ' selected: ${selected.length},'
        ' activated: ${activated.length})';
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
