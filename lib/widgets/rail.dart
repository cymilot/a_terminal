import 'package:flutter/material.dart';

const double _itemLabelSize = 16.0;

class AppRailSize {
  const AppRailSize({
    this.compactSize = const Size(56.0, double.infinity),
    this.extendSize = const Size(256.0, double.infinity),
    this.horizontalSpace = 8.0,
  });

  final Size compactSize;
  final Size extendSize;
  final double horizontalSpace;

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
    this.footerHeight = 56.0,
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
  final double footerHeight;
  final Duration selectedDuration;
  final dynamic selectedIndex;
  final ValueChanged<dynamic>? onItemSelected;

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
        borderRadius: borderRadius,
        child: AnimatedContainer(
          duration: extendedDuration,
          width: extended ? size.extendSize.width : size.compactSize.width,
          height: extended ? size.extendSize.height : size.compactSize.height,
          margin: EdgeInsets.symmetric(horizontal: size.horizontalSpace),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8.0),
                AnimatedContainer(
                  duration: extendedDuration,
                  width:
                      extended ? size.extendSize.width : size.compactSize.width,
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
      height: footerHeight,
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return items[index];
        },
      ),
    );
  }

  Widget _wrapper(Widget original, int itemIndex, [dynamic data]) {
    return _ItemInfo(
      selected: selectedIndex == data || selectedIndex == itemIndex,
      itemIndex: itemIndex,
      selectedDuration: selectedDuration,
      onTap: () {
        if (onItemSelected != null &&
            (selectedIndex != data || selectedIndex != itemIndex)) {
          onItemSelected?.call(data ?? itemIndex);
        }
      },
      child: original,
    );
  }

  List<Widget> _wrapItems(List<Widget> items, int startIndex) {
    int itemIndex = startIndex;
    return items.map((item) {
      if (item is AppRailItem) {
        return _wrapper(item, itemIndex++, item.data);
      }
      return item;
    }).toList();
  }
}

class AppRailItem extends StatelessWidget {
  const AppRailItem({
    super.key,
    this.enabled = true,
    this.iconSize,
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.action,
    this.tooltip,
    this.data,
    this.mouseCursor = SystemMouseCursors.basic,
    this.itemHeight = 56.0,
    this.indicatorColor,
    this.itemShape = const StadiumBorder(),
  });

  final bool enabled;
  final double? iconSize;
  final IconData icon;
  final IconData? selectedIcon;
  final Widget label;
  final Widget? action;
  final String? tooltip;
  final dynamic data;
  final MouseCursor mouseCursor;
  final double itemHeight;
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
          itemHeight: itemHeight,
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
          itemHeight: itemHeight,
          selectedIconWidget: Icon(
            selectedIcon ?? icon,
            key: const ValueKey('selectedIcon'),
            size: iconSize,
            color: enabled
                ? theme.colorScheme.onSecondaryContainer
                : theme.colorScheme.onSecondaryContainer
                    .withValues(alpha: 0.38),
          ),
          unselectedIconWidget: Icon(
            icon,
            key: const ValueKey('unselectedIcon'),
            size: iconSize,
            color: enabled
                ? theme.colorScheme.onSurfaceVariant
                : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.38),
          ),
          selectedLabelTextStyle:
              _buildSelectedLabelStyle(theme, defaultTextStyle),
          unselectedLabelTextStyle:
              _buildUnselectedLabelStyle(theme, defaultTextStyle),
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
            child: content,
          );
        } else {
          return content;
        }
      }(),
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
    final iconWidth =
        size.compactSize.width == 0 ? itemHeight : size.compactSize.width;
    final contentWidth = size.extendSize.width - iconWidth;

    return AnimatedContainer(
      duration: extendedDuration,
      width: extended ? size.extendSize.width : iconWidth,
      child: Row(
        children: [
          // icon
          _buildIcon(
            iconWidth,
            extendedDuration,
            selected,
            selectedIconWidget,
            unselectedIconWidget,
          ),
          // content
          _buildContent(
            extended,
            contentWidth,
            iconWidth,
            itemHeight,
            selected,
            selectedLabelTextStyle,
            unselectedLabelTextStyle,
            label,
            action,
            extendedDuration,
            selectedDuration,
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(
    double compactWidth,
    Duration extendedDuration,
    bool selected,
    Widget selectedIconWidget,
    Widget unselectedIconWidget,
  ) {
    return AnimatedContainer(
      duration: extendedDuration,
      width: extended ? compactWidth : size.compactSize.width,
      height: itemHeight,
      child: AnimatedSwitcher(
        duration: selectedDuration,
        child: selected ? selectedIconWidget : unselectedIconWidget,
      ),
    );
  }

  Widget _buildContent(
    bool extended,
    double contentWidth,
    double iconWidth,
    double itemHeight,
    bool selected,
    TextStyle selectedLabelTextStyle,
    TextStyle unselectedLabelTextStyle,
    Widget label,
    Widget? action,
    Duration extendedDuration,
    Duration selectedDuration,
  ) {
    return AnimatedContainer(
      duration: extendedDuration,
      width: extended ? contentWidth : 0,
      height: itemHeight,
      child: AnimatedCrossFade(
        firstChild: _buildRowContent(
          contentWidth,
          iconWidth,
          itemHeight,
          selected,
          selectedLabelTextStyle,
          unselectedLabelTextStyle,
          label,
          action,
        ),
        secondChild: const SizedBox.shrink(),
        crossFadeState:
            extended ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        duration: extendedDuration,
        layoutBuilder: (Widget topChild, Key topChildKey, Widget bottomChild,
            Key bottomChildKey) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(key: bottomChildKey, left: 0.0, child: bottomChild),
              Positioned(key: topChildKey, left: 0.0, child: topChild),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRowContent(
    double contentWidth,
    double iconWidth,
    double itemHeight,
    bool selected,
    TextStyle selectedLabelTextStyle,
    TextStyle unselectedLabelTextStyle,
    Widget label,
    Widget? action,
  ) {
    return SizedBox(
      width: contentWidth,
      height: itemHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 1.0),
            child: AnimatedDefaultTextStyle(
              style:
                  selected ? selectedLabelTextStyle : unselectedLabelTextStyle,
              duration: selectedDuration,
              child: label,
            ),
          ),
          SizedBox(
            width: iconWidth,
            height: itemHeight,
            child: Align(
              alignment: Alignment.center,
              child: action,
            ),
          ),
        ],
      ),
    );
  }
}
