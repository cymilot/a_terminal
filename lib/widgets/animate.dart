import 'package:flutter/material.dart';

enum IconState {
  first,
  second,
}

class AppLeading extends StatelessWidget {
  const AppLeading({
    super.key,
    required this.duration,
    this.enabled = true,
    required this.onPressed,
    required this.iconState,
    required this.firstIcon,
    this.secondIcon,
  });

  final Duration duration;
  final bool enabled;
  final void Function() onPressed;
  final IconState iconState;
  final IconData firstIcon;
  final IconData? secondIcon;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: enabled ? onPressed : null,
      icon: AnimatedSwitcher(
        duration: duration,
        child: _getIcon(iconState),
      ),
    );
  }

  Widget _getIcon(IconState iconState) {
    switch (iconState) {
      case IconState.first:
        return Icon(key: const ValueKey('first'), firstIcon);
      case IconState.second:
        return Icon(key: const ValueKey('second'), secondIcon ?? firstIcon);
    }
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
    this.secondIconData,
    this.iconState = IconState.first,
    this.curve = Curves.linear,
  });

  final Duration duration;
  final bool isForward;
  final bool enabled;
  final void Function() onPressed;
  final AnimatedIconData firstIconData;
  final AnimatedIconData? secondIconData;
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

    _iconData = _getIconData(widget.iconState);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed && !widget.isForward) {
        _updateIconData();
      }
    });
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
      onPressed: widget.enabled ? widget.onPressed : null,
      icon: AnimatedIcon(
        icon: _iconData,
        progress: _animation,
      ),
    );
  }

  AnimatedIconData _getIconData(IconState state) {
    switch (state) {
      case IconState.first:
        return widget.firstIconData;
      case IconState.second:
        return widget.secondIconData ?? widget.firstIconData;
    }
  }

  void _updateIconData() {
    setState(() => _iconData = _getIconData(widget.iconState));
  }
}
