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
    return ChangeNotifierProvider(
      create: (context) => ScaffoldLogic(context: context),
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
          child: Scaffold(
            key: logic.scaffoldKey,
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              automaticallyImplyLeading: false,
              leading: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _buildLeading(logic),
              ),
              leadingWidth: 72.0, // 56.0 + 8.0 * 2
              title: _buildTitle(logic),
              titleSpacing: 0.0,
            ),
            drawer: context.isWideScreen ? null : _buildDrawer(logic),
            body: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                AnimatedSwitcher(
                  duration: kAnimationDuration,
                  child: context.isWideScreen
                      ? _buildExtendableDrawer(logic)
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
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Navigator(
                          key: logic.navigatorKey,
                          initialRoute: logic.routeName.value,
                          onGenerateRoute: logic.genRoute,
                          observers: [
                            AppOberserver(
                              onUpdateRouteName: logic.onUpdateRouteName,
                              onUpdatePageName: logic.onUpdatePageName,
                            ),
                          ],
                        ),
                      ),
                      _buildBottom(logic),
                    ],
                  ),
                ),
              ],
            ),
            floatingActionButton: _buildFloating(logic),
            floatingActionButtonLocation: const CustomLocation(),
          ),
        );
      },
    );
  }

  Widget _buildLeading(ScaffoldLogic logic) {
    return ListenableBuilder(
      listenable: Listenable.merge([logic.routeName, logic.selectedTerms]),
      builder: (context, _) {
        if (context.isWideScreen) {
          return AppLeading(
            duration: kAnimationDuration,
            enabled: logic.canBack() || logic.selectedTerms.isNotEmpty,
            onPressed: logic.onTapLeading,
            firstIcon: Icons.close,
            secondIcon: Icons.arrow_back,
            iconState: logic.selectedTerms.isNotEmpty
                ? IconState.first
                : IconState.second,
          );
        } else {
          return AppAnimatedLeading(
            duration: kAnimationDuration,
            isForward: logic.canForward(),
            onPressed: logic.onTapLeading,
            firstIconData: AnimatedIcons.menu_close,
            secondIconData: AnimatedIcons.menu_arrow,
            iconState: logic.selectedTerms.isNotEmpty
                ? IconState.first
                : IconState.second,
          );
        }
      },
    );
  }

  Widget _buildTitle(ScaffoldLogic logic) {
    return ValueListenableBuilder(
      valueListenable: logic.routeName,
      builder: (context, _, __) {
        return AnimatedSwitcher(
          duration: kAnimationDuration,
          child: logic.isPages([rActive])
              ? ListenableBuilder(
                  listenable: Listenable.merge([
                    logic.tabIndex,
                    logic.activeTerms,
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
                    logic.pageName,
                    logic.selectedTerms,
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
                      child: logic.selectedTerms.isNotEmpty
                          ? Text(
                              'inSelecting'.tr(context, [
                                logic.selectedTerms.length,
                              ]),
                              key: const ValueKey('selected'),
                            )
                          : Text(
                              logic.pageName.value.tr(context),
                              key: const ValueKey('page'),
                            ),
                    );
                  },
                ),
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

  Widget _buildExtendableDrawer(ScaffoldLogic logic) {
    return ListenableBuilder(
      listenable: Listenable.merge([logic.drawerIndex, logic.extended]),
      builder: (context, _) {
        return AppRail(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: context.isWideScreen
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
      listenable: Listenable.merge([logic.routeName, logic.selectedTerms]),
      builder: (context, _) {
        return AnimatedSwitcher(
          duration: kAnimationDuration,
          child: logic.isPages([rHome, rTerm])
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
      valueListenable: logic.routeName,
      builder: (context, _, __) {
        return AnimatedSwitcher(
          duration: kAnimationDuration,
          child: logic.isPages([rHome, rForm])
              ? FloatingActionButton(
                  onPressed: () => logic.onTapFloating(rForm),
                  child: AnimatedSwitcher(
                    duration: kAnimationDuration,
                    child: logic.isPages([rHome])
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
