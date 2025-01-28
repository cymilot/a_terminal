import 'package:flutter/material.dart';

const double _itemIconSize = 24.0;
const double _itemLabelSize = 16.0;
const double _itemHeight = 56.0;

class AppRailSize {
  const AppRailSize({
    this.compactSize = const Size(56.0, double.infinity),
    this.extendSize = const Size(256.0, double.infinity),
    this.horizontalSpace = 8.0,
  });

  final Size compactSize;
  final Size extendSize;
  final double horizontalSpace;

  double get widthDifferent => extendSize.width - compactSize.width;

  @override
  bool operator ==(Object other) {
    return other is AppRailSize &&
        other.compactSize == compactSize &&
        other.extendSize == extendSize &&
        other.horizontalSpace == horizontalSpace;
  }

  @override
  int get hashCode => Object.hashAll([
        compactSize,
        extendSize,
        horizontalSpace,
      ]);
}

class AppRail extends StatelessWidget {
  const AppRail({
    super.key,
    this.size = const AppRailSize(),
    this.extendedDuration = const Duration(milliseconds: 200),
    this.backgroundColor,
    this.borderRadius = const BorderRadius.only(
      topRight: Radius.circular(10.0),
      bottomRight: Radius.circular(10.0),
    ),
    this.extended = false,
    this.header = const SizedBox.shrink(),
    this.items = const [],
    this.footerItems = const [],
    this.footerHeight,
    this.selectedDuration = const Duration(milliseconds: 200),
    this.selectedIndex,
    this.onItemSelected,
  });

  final AppRailSize size;
  final Duration extendedDuration;
  final Color? backgroundColor;
  final BorderRadiusGeometry borderRadius;
  final bool extended;
  final Widget header;
  final List<Widget> items;
  final List<Widget> footerItems;
  final double? footerHeight;
  final Duration selectedDuration;
  final int? selectedIndex;
  final ValueChanged<int>? onItemSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final wrappedItems = _wrapItems(items, 0);
    final wrappedFooterItems =
        _wrapItems(footerItems, items.whereType<AppRailItem>().length);

    return _RailInfo(
      size: size,
      extendedDuration: extendedDuration,
      extended: extended,
      child: Material(
        color: backgroundColor ?? theme.colorScheme.surface,
        child: AnimatedContainer(
          duration: extendedDuration,
          decoration: BoxDecoration(borderRadius: borderRadius),
          width: extended
              ? size.extendSize.width + 2 * size.horizontalSpace
              : size.compactSize.width + 2 * size.horizontalSpace,
          height: extended ? size.extendSize.height : size.compactSize.height,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.horizontalSpace),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8.0),
                  AnimatedContainer(
                    duration: extendedDuration,
                    width: extended
                        ? size.extendSize.width
                        : size.compactSize.width,
                    child: header,
                  ),
                  const SizedBox(height: 8.0),
                  Expanded(child: _buildTopListView(wrappedItems)),
                  _buildBottomListView(wrappedFooterItems),
                  const SizedBox(height: 8.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopListView(List<Widget> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return items[index];
      },
    );
  }

  Widget _buildBottomListView(List<Widget> items) {
    return SizedBox(
      height: footerHeight ?? _itemHeight,
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return items[index];
        },
      ),
    );
  }

  Widget _wrapper(Widget original, int itemIndex) {
    return _ItemInfo(
      selected: selectedIndex == itemIndex,
      itemIndex: itemIndex,
      selectedDuration: selectedDuration,
      onTap: () {
        if (onItemSelected != null && selectedIndex != itemIndex) {
          onItemSelected?.call(itemIndex);
        }
      },
      child: original,
    );
  }

  List<Widget> _wrapItems(List<Widget> items, int startIndex) {
    int itemIndex = startIndex;
    return items.map((item) {
      if (item is AppRailItem) {
        return _wrapper(item, itemIndex++);
      }
      return item;
    }).toList();
  }
}

class AppRailItem extends StatelessWidget {
  const AppRailItem({
    super.key,
    this.enabled = true,
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.action,
    this.tooltip,
    this.mouseCursor = SystemMouseCursors.basic,
    this.itemHeight,
    this.indicatorColor,
    this.itemShape = const StadiumBorder(),
  });

  final bool enabled;
  final Widget icon;
  final Widget? selectedIcon;
  final Widget label;
  final Widget? action;
  final String? tooltip;
  final MouseCursor mouseCursor;
  final double? itemHeight;
  final Color? indicatorColor;
  final ShapeBorder itemShape;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultTextStyle = theme.textTheme.labelLarge!;
    final railInfo = _RailInfo.of(context);
    final itemInfo = _ItemInfo.of(context);

    final content = Stack(
      alignment: Alignment.center,
      children: [
        _ItemIndicatorBuilder(
          extended: railInfo.extended,
          extendedDuration: railInfo.extendedDuration,
          selected: itemInfo.selected,
          selectedDuration: itemInfo.selectedDuration,
          size: railInfo.size,
          itemHeight: itemHeight ?? _itemHeight,
          enabled: enabled,
          indicatorColor:
              indicatorColor ?? theme.colorScheme.secondaryContainer,
          indicatorShape: itemShape,
        ),
        _ItemContentBuilder(
          extended: railInfo.extended,
          extendedDuration: railInfo.extendedDuration,
          selected: itemInfo.selected,
          selectedDuration: itemInfo.selectedDuration,
          size: railInfo.size,
          itemHeight: itemHeight ?? _itemHeight,
          selectedIconWidget: _buildSelectedIconWidget(theme),
          unselectedIconWidget: _buildUnselectedIconWidget(theme),
          selectedLabelTextStyle: _buildSelectedLabelStyle(
            theme,
            defaultTextStyle,
          ),
          unselectedLabelTextStyle: _buildUnselectedLabelStyle(
            theme,
            defaultTextStyle,
          ),
          label: label,
          action: action,
        ),
      ],
    );

    return InkWell(
      onTap: enabled ? itemInfo.onTap : null,
      customBorder: itemShape,
      mouseCursor: mouseCursor,
      highlightColor: Colors.transparent,
      child: () {
        if (tooltip != null) {
          return Tooltip(
            message: tooltip,
            waitDuration: const Duration(seconds: 2),
            child: content,
          );
        } else {
          return content;
        }
      }(),
    );
  }

  Widget _buildSelectedIconWidget(ThemeData theme) {
    return IconTheme.merge(
      data: IconThemeData(
        size: _itemIconSize,
        color: enabled
            ? theme.colorScheme.onSecondaryContainer
            : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.38),
      ),
      child: selectedIcon ?? icon,
    );
  }

  Widget _buildUnselectedIconWidget(ThemeData theme) {
    return IconTheme.merge(
      data: IconThemeData(
        size: _itemIconSize,
        color: enabled
            ? theme.colorScheme.onSurfaceVariant
            : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.38),
      ),
      child: icon,
    );
  }

  TextStyle _buildSelectedLabelStyle(ThemeData theme, TextStyle style) {
    return style.merge(TextStyle(
      color: enabled
          ? theme.colorScheme.onSecondaryContainer
          : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.38),
      fontSize: _itemLabelSize,
    ));
  }

  TextStyle _buildUnselectedLabelStyle(ThemeData theme, TextStyle style) {
    return style.merge(TextStyle(
      color: enabled
          ? theme.colorScheme.onSurfaceVariant
          : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.38),
      fontSize: _itemLabelSize,
    ));
  }
}

class _RailInfo extends InheritedWidget {
  const _RailInfo({
    required super.child,
    required this.size,
    required this.extended,
    required this.extendedDuration,
  });

  final AppRailSize size;
  final bool extended;
  final Duration extendedDuration;

  @override
  bool updateShouldNotify(_RailInfo oldWidget) {
    return oldWidget.size != size ||
        oldWidget.extendedDuration != extendedDuration ||
        oldWidget.extended != extended;
  }

  static _RailInfo of(BuildContext context) {
    final _RailInfo? result =
        context.dependOnInheritedWidgetOfExactType<_RailInfo>();
    assert(result != null, '_RailInfo do not exist!');
    return result!;
  }
}

class _ItemInfo extends InheritedWidget {
  const _ItemInfo({
    required super.child,
    required this.selected,
    required this.itemIndex,
    required this.selectedDuration,
    required this.onTap,
  });

  final bool selected;
  final int itemIndex;
  final Duration selectedDuration;
  final VoidCallback onTap;

  @override
  bool updateShouldNotify(_ItemInfo oldWidget) {
    return oldWidget.selected != selected ||
        oldWidget.itemIndex != itemIndex ||
        oldWidget.selectedDuration != selectedDuration ||
        oldWidget.onTap != onTap;
  }

  static _ItemInfo of(BuildContext context) {
    final _ItemInfo? result =
        context.dependOnInheritedWidgetOfExactType<_ItemInfo>();
    assert(result != null, '_ItemInfo do not exist!');
    return result!;
  }
}

class _ItemIndicatorBuilder extends StatelessWidget {
  const _ItemIndicatorBuilder({
    required this.extended,
    required this.extendedDuration,
    required this.selected,
    required this.selectedDuration,
    required this.size,
    required this.itemHeight,
    required this.enabled,
    required this.indicatorColor,
    required this.indicatorShape,
  });

  final bool extended;
  final Duration extendedDuration;
  final bool selected;
  final Duration selectedDuration;
  final AppRailSize size;
  final double itemHeight;
  final bool enabled;
  final Color indicatorColor;
  final ShapeBorder indicatorShape;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: selected ? 1 : 0,
      duration: selectedDuration,
      child: AnimatedContainer(
        duration: extendedDuration,
        width: extended ? size.extendSize.width : size.compactSize.width,
        height: itemHeight,
        child: Material(
          color:
              enabled ? indicatorColor : indicatorColor.withValues(alpha: 0.38),
          shape: indicatorShape,
        ),
      ),
    );
  }
}

class _ItemContentBuilder extends StatelessWidget {
  const _ItemContentBuilder({
    required this.extended,
    required this.extendedDuration,
    required this.selected,
    required this.selectedDuration,
    required this.size,
    required this.itemHeight,
    required this.selectedIconWidget,
    required this.unselectedIconWidget,
    required this.selectedLabelTextStyle,
    required this.unselectedLabelTextStyle,
    required this.label,
    this.action,
  });

  final bool extended;
  final Duration extendedDuration;
  final bool selected;
  final Duration selectedDuration;
  final AppRailSize size;
  final double itemHeight;
  final Widget selectedIconWidget;
  final Widget unselectedIconWidget;
  final TextStyle selectedLabelTextStyle;
  final TextStyle unselectedLabelTextStyle;
  final Widget label;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // icon
        SizedBox(
          width: size.compactSize.width,
          height: itemHeight,
          child: AnimatedCrossFade(
            firstChild: selectedIconWidget,
            secondChild: unselectedIconWidget,
            crossFadeState:
                selected ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            duration: selectedDuration,
            layoutBuilder: (Widget topChild, Key topChildKey,
                Widget bottomChild, Key bottomChildKey) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    key: bottomChildKey,
                    child: bottomChild,
                  ),
                  Positioned(
                    key: topChildKey,
                    child: topChild,
                  )
                ],
              );
            },
          ),
        ),
        // content
        AnimatedContainer(
          duration: extendedDuration,
          width: extended ? size.widthDifferent : 0,
          height: itemHeight,
          child: AnimatedCrossFade(
            firstChild: SizedBox(
              width: size.widthDifferent,
              height: itemHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 1.0),
                    child: AnimatedDefaultTextStyle(
                      style: selected
                          ? selectedLabelTextStyle
                          : unselectedLabelTextStyle,
                      duration: selectedDuration,
                      child: label,
                    ),
                  ),
                  SizedBox(
                    width: size.compactSize.width,
                    height: itemHeight,
                    child: Align(
                      alignment: Alignment.center,
                      child: action,
                    ),
                  ),
                ],
              ),
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState:
                extended ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            duration: extendedDuration,
            layoutBuilder: (Widget topChild, Key topChildKey,
                Widget bottomChild, Key bottomChildKey) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    key: bottomChildKey,
                    left: 0.0,
                    child: bottomChild,
                  ),
                  Positioned(
                    key: topChildKey,
                    left: 0.0,
                    child: topChild,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
