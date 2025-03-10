import 'package:flutter/material.dart';

enum IconState {
  first,
  second,
}

class AppSwitchableButton extends StatelessWidget {
  const AppSwitchableButton({
    super.key,
    required this.duration,
    this.enabled = true,
    required this.onPressed,
    required this.iconState,
    required this.firstIcon,
    this.firstToolTip,
    this.secondIcon,
    this.secondToolTip,
    this.mouseCursor,
  });

  final Duration duration;
  final bool enabled;
  final void Function() onPressed;
  final IconState iconState;
  final IconData firstIcon;
  final String? firstToolTip;
  final IconData? secondIcon;
  final String? secondToolTip;
  final MouseCursor? mouseCursor;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: _getToolTip,
      onPressed: enabled ? onPressed : null,
      mouseCursor: mouseCursor,
      icon: AnimatedSwitcher(
        duration: duration,
        child: _getIcon,
      ),
    );
  }

  Widget get _getIcon {
    return switch (iconState) {
      IconState.first => Icon(key: const ValueKey('first'), firstIcon),
      IconState.second =>
        Icon(key: const ValueKey('second'), secondIcon ?? firstIcon),
    };
  }

  String? get _getToolTip {
    return switch (iconState) {
      IconState.first => enabled ? firstToolTip : null,
      IconState.second => enabled ? secondToolTip : null,
    };
  }
}

class AppAnimatedLeading extends StatefulWidget {
  const AppAnimatedLeading({
    super.key,
    required this.duration,
    required this.isForward,
    this.enabled = true,
    required this.onPressed,
    required this.firstIconData,
    this.firstIconStartTip,
    this.firstIconEndTip,
    this.secondIconData,
    this.secondIconStartTip,
    this.secondIconEndTip,
    this.iconState = IconState.first,
    this.curve = Curves.linear,
  });

  final Duration duration;
  final bool isForward;
  final bool enabled;
  final void Function() onPressed;
  final AnimatedIconData firstIconData;
  final String? firstIconStartTip;
  final String? firstIconEndTip;
  final AnimatedIconData? secondIconData;
  final String? secondIconStartTip;
  final String? secondIconEndTip;
  final IconState iconState;
  final Curve curve;

  @override
  State<AppAnimatedLeading> createState() => _AppAnimatedLeadingState();
}

class _AppAnimatedLeadingState extends State<AppAnimatedLeading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  late AnimatedIconData _iconData;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    _iconData = _getIconData;
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed && !widget.isForward) {
        _updateIconData();
      }
    });

    if (widget.isForward) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void didUpdateWidget(covariant AppAnimatedLeading oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isForward != oldWidget.isForward) {
      if (widget.isForward) {
        _updateIconData();
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: _getToolTip,
      onPressed: widget.enabled ? widget.onPressed : null,
      icon: AnimatedIcon(
        icon: _iconData,
        progress: _animation,
      ),
    );
  }

  AnimatedIconData get _getIconData {
    return switch (widget.iconState) {
      IconState.first => widget.firstIconData,
      IconState.second => widget.secondIconData ?? widget.firstIconData,
    };
  }

  String? get _getToolTip {
    return switch (widget.iconState) {
      IconState.first => widget.isForward
          ? widget.enabled
              ? widget.firstIconEndTip
              : null
          : widget.enabled
              ? widget.firstIconStartTip
              : null,
      IconState.second => widget.isForward
          ? widget.enabled
              ? widget.secondIconEndTip
              : null
          : widget.enabled
              ? widget.secondIconStartTip
              : null,
    };
  }

  void _updateIconData() {
    setState(() => _iconData = _getIconData);
  }
}
