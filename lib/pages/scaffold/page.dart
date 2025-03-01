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
            valueListenable: logic.isWideScreen,
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
                      routeMap: logic.routeMap,
                      redirectMap: logic.redirectMap,
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
      listenable: Listenable.merge([logic.currentRoute, logic.selected]),
      builder: (context, _) {
        return AnimatedSwitcher(
          duration: kAnimationDuration,
          child: value
              ? AppSwitchableButton(
                  duration: kAnimationDuration,
                  enabled: logic.canBack || logic.selected.isNotEmpty,
                  onPressed: logic.onTapLeading,
                  firstIcon: Icons.close,
                  firstToolTip: 'clear'.tr(context),
                  secondIcon: Icons.arrow_back,
                  secondToolTip: 'back'.tr(context),
                  iconState: logic.selected.isNotEmpty
                      ? IconState.first
                      : IconState.second,
                )
              : AppAnimatedLeading(
                  duration: kAnimationDuration,
                  isForward: logic.canForward,
                  onPressed: logic.onTapLeading,
                  firstIconData: AnimatedIcons.menu_close,
                  firstIconStartTip: 'drawer'.tr(context),
                  firstIconEndTip: 'clear'.tr(context),
                  secondIconData: AnimatedIcons.menu_arrow,
                  secondIconStartTip: 'drawer'.tr(context),
                  secondIconEndTip: 'back'.tr(context),
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
          child: logic.isPages(['/view'])
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
          extended: logic.extended.value,
          borderRadius: BorderRadius.all(Radius.zero),
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
                  child: AppSwitchableButton(
                    duration: kAnimationDuration,
                    onPressed: logic.onDrawerExtended,
                    firstIcon: Icons.menu_open,
                    secondIcon: Icons.menu,
                    iconState: logic.extended.value
                        ? IconState.first
                        : IconState.second,
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
      listenable: Listenable.merge([logic.currentRoute, logic.selected]),
      builder: (context, _) {
        return AnimatedSwitcher(
          duration: kAnimationDuration,
          child: logic.isPages(['/home', '/terminal'])
              ? BottomAppBar(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
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
    String tip(String name) {
      return switch (name) {
        '/home' => 'addNew',
        '/home/form' => 'submit',
        _ => '',
      };
    }

    return ListenableBuilder(
      listenable: logic.currentRoute,
      builder: (context, _) {
        return AnimatedSwitcher(
          duration: kAnimationDuration,
          child: logic.isPages(['/home', '/home/form'])
              ? FloatingActionButton(
                  tooltip: tip(logic.currentRoute.value).tr(context),
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
