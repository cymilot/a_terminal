import 'package:flutter/material.dart';

const _itemFontSize = 16.0;

class AppRailSize {
  const AppRailSize({
    this.compactWidth = 56.0,
    this.extendWidth = 256.0,
    this.verticalSpace = 8.0,
    this.horizontalSpace = 8.0,
  });

  final double compactWidth;
  final double extendWidth;
  final double verticalSpace;
  final double horizontalSpace;

  @override
  bool operator ==(Object other) {
    return other is AppRailSize &&
        other.compactWidth == compactWidth &&
        other.extendWidth == extendWidth &&
        other.verticalSpace == verticalSpace &&
        other.horizontalSpace == horizontalSpace;
  }

  @override
  int get hashCode => Object.hashAll([
        compactWidth,
        extendWidth,
        verticalSpace,
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
    final wrappedFooterItems = _wrapItems(
      footerItems,
      items.whereType<AppRailItem>().length,
    );

    return _RailInfo(
      size: size,
      extendedDuration: extendedDuration,
      extended: extended,
      child: Material(
        color: backgroundColor ?? theme.colorScheme.surface,
        borderRadius: borderRadius,
        child: AnimatedContainer(
          duration: extendedDuration,
          width: extended ? size.extendWidth : size.compactWidth,
          margin: EdgeInsets.symmetric(
            vertical: size.verticalSpace,
            horizontal: size.horizontalSpace,
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: extendedDuration,
                  width: extended ? size.extendWidth : size.compactWidth,
                  child: header,
                ),
                Expanded(child: _buildListView(wrappedItems)),
                SizedBox(
                  height: footerHeight,
                  child: _buildListView(wrappedFooterItems),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListView(List<Widget> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) => items[index],
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

  Widget _wrapper(Widget item, int itemIndex, dynamic data) {
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
      child: item,
    );
  }
}

class AppRailItem extends StatelessWidget {
  const AppRailItem({
    super.key,
    this.enabled = true,
    this.iconSize = 24.0,
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
  final double iconSize;
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
          iconSize: iconSize,
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
      fontSize: _itemFontSize,
    ));
  }

  TextStyle _buildUnselectedLabelStyle(ThemeData theme, TextStyle style) {
    return style.merge(TextStyle(
      color: enabled
          ? theme.colorScheme.onSurfaceVariant
          : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.38),
      fontSize: _itemFontSize,
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
        width: extended ? size.extendWidth : size.compactWidth,
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
    required this.iconSize,
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
  final double iconSize;
  final Widget selectedIconWidget;
  final Widget unselectedIconWidget;
  final TextStyle selectedLabelTextStyle;
  final TextStyle unselectedLabelTextStyle;
  final Widget label;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: extendedDuration,
      width: extended ? size.extendWidth : size.compactWidth,
      child: Row(
        children: [
          // icon
          _buildIcon(),
          // content
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return SizedBox(
      width: size.compactWidth,
      height: itemHeight,
      child: AnimatedSwitcher(
        duration: selectedDuration,
        child: selected ? selectedIconWidget : unselectedIconWidget,
      ),
    );
  }

  Widget _buildContent() {
    return AnimatedContainer(
      duration: extendedDuration,
      width: extended ? size.extendWidth - size.compactWidth : 0,
      height: itemHeight,
      child: AnimatedCrossFade(
        firstChild: _buildRowContent(),
        secondChild: const SizedBox.shrink(),
        crossFadeState:
            extended ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        duration: extendedDuration,
        layoutBuilder: (topChild, topChildKey, bottomChild, bottomChildKey) {
          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              Positioned(key: bottomChildKey, child: bottomChild),
              Positioned(key: topChildKey, child: topChild),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRowContent() {
    return SizedBox(
      width: size.extendWidth - size.compactWidth,
      height: itemHeight,
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: iconSize,
              child: AnimatedDefaultTextStyle(
                style: selected
                    ? selectedLabelTextStyle
                    : unselectedLabelTextStyle,
                duration: selectedDuration,
                child: label,
              ),
            ),
          ),
          if (action != null) action!
        ],
      ),
    );
  }
}
