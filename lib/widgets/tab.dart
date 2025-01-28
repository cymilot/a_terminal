import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class AppDraggableTabBar extends StatefulWidget {
  const AppDraggableTabBar({
    super.key,
    this.toolbarHeight = kToolbarHeight,
    this.scrollController,
    this.selectedIndex,
    required this.items,
    this.onItemSelected,
    this.onItemRemoved,
    required this.onReorder,
  });

  final double toolbarHeight;
  final ScrollController? scrollController;
  final int? selectedIndex;
  final List<Widget> items;

  /// Example:
  /// ```
  /// onItemSelected: (value) {
  ///   setState(() => selectedIndex = value);
  /// },
  /// ```
  final ValueChanged<int>? onItemSelected;

  /// Example:
  /// ```
  /// onItemRemoved: (value) {
  ///   setState(() {
  ///     tabItems.removeAt(value);
  ///     if (selectedIndex >= value && selectedIndex != 0) {
  ///       selectedIndex -= 1;
  ///     }
  ///   });
  /// },
  /// ```
  final void Function(int)? onItemRemoved;

  /// Example:
  /// ```
  /// onReorder: (oldIndex, newIndex) {
  ///   setState(() {
  ///     if (newIndex > oldIndex) {
  ///       newIndex -= 1;
  ///     }
  ///     final item = tabItems.removeAt(oldIndex);
  ///     tabItems.insert(newIndex, item);
  ///     selectedIndex = newIndex;
  ///   });
  /// },
  /// ```
  final ReorderCallback onReorder;

  @override
  State<AppDraggableTabBar> createState() => _AppDraggableTabBarState();
}

class _AppDraggableTabBarState extends State<AppDraggableTabBar> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.toolbarHeight,
      child: Scrollbar(
        controller: _scrollController,
        thickness: 4,
        child: ReorderableListView.builder(
          scrollDirection: Axis.horizontal,
          scrollController: _scrollController,
          itemCount: widget.items.length,
          itemBuilder: (context, index) {
            return ReorderableDragStartListener(
              key: widget.items[index].key,
              index: index,
              child: _wrapper(widget.items[index], index),
            );
          },
          onReorder: widget.onReorder,
          buildDefaultDragHandles: false,
        ),
      ),
    );
  }

  Widget _wrapper(Widget original, int index) {
    return _DraggableTabInfo(
      selected: widget.selectedIndex == index,
      currentIndex: index,
      onTap: () {
        if (widget.onItemSelected != null && widget.selectedIndex != index) {
          widget.onItemSelected?.call(index);
        }
      },
      onRemove: () {
        if (widget.onItemRemoved != null) {
          widget.onItemRemoved?.call(index);
        }
      },
      child: original,
    );
  }
}

class AppDraggableTab extends StatefulWidget {
  const AppDraggableTab({
    required Key key,
    required this.label,
  }) : super(key: key);

  final Widget label;

  @override
  State<AppDraggableTab> createState() => _AppDraggableTabState();
}

class _AppDraggableTabState extends State<AppDraggableTab> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tabItemInfo = _DraggableTabInfo.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: InkWell(
        onTap: tabItemInfo.onTap,
        child: Container(
          width: 96.0,
          decoration: BoxDecoration(
            color: tabItemInfo.selected
                ? theme.highlightColor
                : hovered
                    ? theme.hoverColor
                    : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: tabItemInfo.selected
                    ? theme.colorScheme.primary
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 18.0,
                child: DefaultTextStyle(
                  style: theme.textTheme.titleMedium!,
                  child: widget.label,
                ),
              ),
              Positioned(
                right: 8.0,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: tabItemInfo.onRemove,
                    child: const Tooltip(
                      message: 'Close',
                      verticalOffset: 8.0,
                      waitDuration: Durations.short4,
                      child: Icon(
                        Icons.close,
                        size: 16.0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DraggableTabInfo extends InheritedWidget {
  const _DraggableTabInfo({
    required super.child,
    required this.selected,
    required this.currentIndex,
    required this.onTap,
    required this.onRemove,
  });

  final bool selected;
  final int currentIndex;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  bool updateShouldNotify(_DraggableTabInfo oldWidget) {
    return oldWidget.selected != selected ||
        oldWidget.currentIndex != currentIndex ||
        oldWidget.onTap != onTap ||
        oldWidget.onRemove != onRemove;
  }

  static _DraggableTabInfo of(BuildContext context) {
    final _DraggableTabInfo? result =
        context.dependOnInheritedWidgetOfExactType<_DraggableTabInfo>();
    assert(result != null);
    return result!;
  }
}

// https://blog.gskinner.com/archives/2021/01/flutter-how-to-measure-widgets.html
class AppAdaptiveTabBarView extends StatefulWidget {
  const AppAdaptiveTabBarView({
    super.key,
    this.keepAlive = false,
    required this.tabs,
    required this.tabController,
    required this.children,
  });

  final bool keepAlive;
  final List<String> tabs;
  final TabController tabController;
  final List<Widget> children;

  @override
  State<AppAdaptiveTabBarView> createState() => _AppAdaptiveTabBarViewState();
}

class _AppAdaptiveTabBarViewState extends State<AppAdaptiveTabBarView> {
  late final ValueNotifier<Size> _sizeController;

  @override
  void initState() {
    super.initState();
    _sizeController = ValueNotifier<Size>(Size.zero);
  }

  @override
  void dispose() {
    super.dispose();
    _sizeController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8.0),
        TabBar(
          tabs: widget.tabs.map((e) => Tab(text: e)).toList(),
          controller: widget.tabController,
        ),
        ValueListenableBuilder(
          valueListenable: _sizeController,
          builder: (context, size, child) {
            return SizedBox(
              height: size.height,
              child: child,
            );
          },
          child: TabBarView(
            controller: widget.tabController,
            children: _buildWarpChildren(),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildWarpChildren() {
    return widget.children
        .map((e) => OverflowBox(
              alignment: Alignment.topCenter,
              minHeight: 0,
              maxHeight: double.infinity,
              child: _TabViewWrapper(
                onSizeChange: (size) {
                  _sizeController.value = size;
                },
                child: () {
                  if (widget.keepAlive) {
                    return _TabViewKeepAliveWrapper(e);
                  } else {
                    return e;
                  }
                }(),
              ),
            ))
        .toList();
  }
}

class _TabViewWrapper extends SingleChildRenderObjectWidget {
  const _TabViewWrapper({
    required this.onSizeChange,
    super.child,
  });

  final void Function(Size) onSizeChange;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _TabViewWrapperProxyBox(onSizeChange);
  }
}

class _TabViewWrapperProxyBox extends RenderProxyBox {
  _TabViewWrapperProxyBox(this.onSizeChange);

  final void Function(Size) onSizeChange;

  Size? _oldSize;

  @override
  void performLayout() {
    super.performLayout();
    assert(child != null);
    final newSize = child!.size;
    if (_oldSize == newSize) return;
    _oldSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) => onSizeChange(newSize));
  }
}

class _TabViewKeepAliveWrapper extends StatefulWidget {
  const _TabViewKeepAliveWrapper(this.child);

  final Widget child;

  @override
  State<_TabViewKeepAliveWrapper> createState() =>
      _TabViewKeepAliveWrapperState();
}

class _TabViewKeepAliveWrapperState extends State<_TabViewKeepAliveWrapper>
    with AutomaticKeepAliveClientMixin<_TabViewKeepAliveWrapper> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
