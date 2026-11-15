import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/formatters.dart';

class SineCurve extends Curve {
  final double count;
  const SineCurve({this.count = 3});

  @override
  double transformInternal(double t) {
    return math.sin(count * 2 * math.pi * t);
  }
}

class SmoothTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleDown;
  final bool enableHaptic;

  const SmoothTap({
    super.key,
    required this.child,
    this.onTap,
    this.scaleDown = 0.965,
    this.enableHaptic = true,
  });

  @override
  State<SmoothTap> createState() => _SmoothTapState();
}

class _SmoothTapState extends State<SmoothTap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scale = Tween<double>(begin: 1.0, end: widget.scaleDown).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onTap != null) _ctrl.forward();
  }

  void _onTapUp(TapUpDetails _) {
    if (widget.onTap != null) _ctrl.reverse();
  }

  void _onTapCancel() {
    if (widget.onTap != null) _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap == null
          ? null
          : () {
              if (widget.enableHaptic) {
                HapticFeedback.selectionClick();
              }
              widget.onTap!();
            },
      child: ScaleTransition(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}

class AnimatedAppear extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration duration;

  const AnimatedAppear({
    super.key,
    required this.child,
    this.index = 0,
    this.duration = const Duration(milliseconds: 340),
  });

  @override
  Widget build(BuildContext context) {
    final cappedIndex = index.clamp(0, 8);
    final totalMs = duration.inMilliseconds + (cappedIndex * 35);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: totalMs),
      curve: Curves.easeOutCubic,
      builder: (context, val, c) {
        return Opacity(
          opacity: val.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - val)),
            child: c,
          ),
        );
      },
      child: child,
    );
  }
}

class SmoothProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  final Color backgroundColor;
  final double minHeight;
  final double borderRadius;

  const SmoothProgressBar({
    super.key,
    required this.value,
    required this.color,
    required this.backgroundColor,
    this.minHeight = 7,
    this.borderRadius = 6,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
      builder: (context, animVal, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: LinearProgressIndicator(
            value: animVal,
            minHeight: minHeight,
            backgroundColor: backgroundColor,
            color: color,
          ),
        );
      },
    );
  }
}

class AnimatedCurrencyText extends StatelessWidget {
  final int value;
  final bool sensor;
  final TextStyle? style;
  final String prefix;

  const AnimatedCurrencyText({
    super.key,
    required this.value,
    this.sensor = false,
    this.style,
    this.prefix = '',
  });

  @override
  Widget build(BuildContext context) {
    if (sensor) {
      return Text(
        '$prefix${formatRupiah(value, sensor: true)}',
        style: style,
      );
    }

    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: value, end: value),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      builder: (context, animVal, _) {
        return Text(
          '$prefix${formatRupiah(animVal, sensor: false)}',
          style: style,
        );
      },
    );
  }
}
