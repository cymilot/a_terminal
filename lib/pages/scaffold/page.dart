import 'package:a_terminal/consts.dart';
import 'package:a_terminal/pages/scaffold/logic.dart';
import 'package:a_terminal/router/router.dart';
import 'package:a_terminal/utils/extension.dart';
import 'package:a_terminal/widgets/animate.dart';
import 'package:a_terminal/widgets/rail.dart';
import 'package:a_terminal/widgets/tab.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScaffoldPage extends StatelessWidget {
  const ScaffoldPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => ScaffoldLogic(context),
      dispose: (context, logic) => logic.dispose(),
      lazy: true,
      builder: (context, _) {
        final logic = context.read<ScaffoldLogic>();
        return ValueListenableBuilder(
          valueListenable: logic.canPop,
          builder: (context, canPop, child) {
            return PopScope(
              canPop: canPop,
              onPopInvokedWithResult: logic.onPopInvokedWithResult,
              child: child!,
            );
          },
          child: ValueListenableBuilder(
            valueListenable: logic.appLogic.isWideScreen,
            builder: (context, value, child) {
              return Scaffold(
                key: logic.scaffoldKey,
                appBar: AppBar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  automaticallyImplyLeading: false,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: _buildLeading(logic, value),
                  ),
                  leadingWidth: 72.0, // 56.0 + 8.0 * 2
                  title: _buildTitle(logic),
                  titleSpacing: 0.0,
                ),
                drawer: value ? null : _buildDrawer(logic),
                body: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    AnimatedSwitcher(
                      duration: kAnimationDuration,
                      child: value
                          ? _buildExtendableDrawer(logic, value)
                          : const SizedBox.shrink(),
                      layoutBuilder: (currentChild, previousChildren) {
                        return Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            ...previousChildren,
                            if (currentChild != null) currentChild,
                          ],
                        );
                      },
                      transitionBuilder: (child, animation) {
                        return SizeTransition(
                          sizeFactor: animation,
                          axis: Axis.horizontal,
                          child: child,
                        );
                      },
                    ),
                    child!,
                  ],
                ),
                floatingActionButton: _buildFloating(logic),
                floatingActionButtonLocation: const CustomLocation(),
              );
            },
            child: Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: AppNavigator(
                      navigatorKey: logic.navigatorKey,
                      initialRoute: '/home',
                      routeMap: logic.appRoute.routeMap,
                      redirectMap: logic.appRoute.redirectMap,
                      unknownPageBuilder: logic.genUnknownPage,
                    ),
                  ),
                  _buildBottom(logic),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLeading(ScaffoldLogic logic, bool value) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        logic.appRoute.currentRoute,
        logic.selected,
      ]),
      builder: (context, _) {
        return AnimatedSwitcher(
          duration: kAnimationDuration,
          child: value
              ? AppLeading(
                  duration: kAnimationDuration,
                  enabled: logic.appRoute.canBack || logic.selected.isNotEmpty,
                  onPressed: logic.onTapLeading,
                  firstIcon: Icons.close,
                  secondIcon: Icons.arrow_back,
                  iconState: logic.selected.isNotEmpty
                      ? IconState.first
                      : IconState.second,
                )
              : AppAnimatedLeading(
                  duration: kAnimationDuration,
                  isForward: logic.canForward,
                  onPressed: logic.onTapLeading,
                  firstIconData: AnimatedIcons.menu_close,
                  secondIconData: AnimatedIcons.menu_arrow,
                  iconState: logic.selected.isNotEmpty
                      ? IconState.first
                      : IconState.second,
                ),
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              alignment: Alignment.center,
              children: [
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTitle(ScaffoldLogic logic) {
    return ValueListenableBuilder(
      valueListenable: logic.appRoute.currentRoute,
      builder: (context, _, __) {
        return AnimatedSwitcher(
          duration: kAnimationDuration,
          child: logic.appRoute.isPages(['/view'])
              ? ListenableBuilder(
                  listenable: Listenable.merge([
                    logic.tabIndex,
                    logic.activated,
                  ]),
                  builder: (context, _) => AppDraggableTabBar(
                    items: logic.genTabItems(),
                    selectedIndex: logic.tabIndex.value,
                    onItemSelected: logic.onTabItemSelected,
                    onItemRemoved: logic.onTabItemRemoved,
                    onReorder: logic.onTabReorder,
                  ),
                )
              : ListenableBuilder(
                  listenable: Listenable.merge([
                    logic.appRoute.currentName,
                    logic.selected,
                  ]),
                  builder: (context, _) {
                    return AnimatedSwitcher(
                      duration: kAnimationDuration,
                      layoutBuilder: (currentChild, previousChildren) {
                        return Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            ...previousChildren,
                            if (currentChild != null) currentChild,
                          ],
                        );
                      },
                      child: logic.selected.isNotEmpty
                          ? Text(
                              'inSelecting'.tr(
                                  context, {'count': logic.selected.length}),
                              key: const ValueKey('selected'),
                            )
                          : Text(
                              logic.appRoute.currentName.value,
                              key: const ValueKey('page'),
                            ),
                    );
                  },
                ),
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              alignment: Alignment.topCenter,
              children: [
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDrawer(ScaffoldLogic logic) {
    return ValueListenableBuilder(
      valueListenable: logic.drawerIndex,
      builder: (context, index, _) {
        return AppRail(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
          extended: true,
          selectedIndex: index,
          onItemSelected: logic.onDrawerItemSelected,
          items: logic.genDrawerItems(AppRailItemType.body),
          footerItems: logic.genDrawerItems(AppRailItemType.footer),
        );
      },
    );
  }

  Widget _buildExtendableDrawer(ScaffoldLogic logic, bool value) {
    return ListenableBuilder(
      listenable: Listenable.merge([logic.drawerIndex, logic.extended]),
      builder: (context, _) {
        return AppRail(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: value
              ? const BorderRadius.all(Radius.zero)
              : const BorderRadius.only(
                  topRight: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0),
                ),
          extended: logic.extended.value,
          selectedIndex: logic.drawerIndex.value,
          onItemSelected: logic.onDrawerItemSelected,
          items: logic.genDrawerItems(AppRailItemType.body),
          footerItems: [
            ...logic.genDrawerItems(AppRailItemType.footer),
            Row(
              children: [
                SizedBox(
                  width: 56.0,
                  height: 56.0,
                  child: IconButton(
                    onPressed: logic.onDrawerExtended,
                    icon: const Icon(Icons.menu_open),
                    mouseCursor: SystemMouseCursors.basic,
                  ),
                ),
              ],
            ),
          ],
          footerHeight: 112.0, // 56.0 * 2
        );
      },
    );
  }

  Widget _buildBottom(ScaffoldLogic logic) {
    return ListenableBuilder(
      listenable:
          Listenable.merge([logic.appRoute.currentRoute, logic.selected]),
      builder: (context, _) {
        return AnimatedSwitcher(
          duration: kAnimationDuration,
          child: logic.appRoute.isPages(['/home', '/terminal'])
              ? BottomAppBar(
                  height: 80.0,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 72.0),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: logic.genBottomItems(),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              alignment: Alignment.bottomCenter,
              children: [
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            );
          },
          transitionBuilder: (child, animation) {
            return SizeTransition(sizeFactor: animation, child: child);
          },
        );
      },
    );
  }

  Widget _buildFloating(ScaffoldLogic logic) {
    return ValueListenableBuilder(
      valueListenable: logic.appRoute.currentRoute,
      builder: (context, _, __) {
        return AnimatedSwitcher(
          duration: kAnimationDuration,
          child: logic.appRoute.isPages(['/home', '/home/form'])
              ? FloatingActionButton(
                  onPressed: () => logic.onTapFloating('/home/form'),
                  child: AnimatedSwitcher(
                    duration: kAnimationDuration,
                    child: logic.appRoute.isPages(['/home'])
                        ? const Icon(Icons.add)
                        : const Icon(Icons.check),
                  ),
                )
              : const SizedBox.shrink(),
        );
      },
    );
  }
}
