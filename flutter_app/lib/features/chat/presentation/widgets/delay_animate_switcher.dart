import 'package:flutter/material.dart';
import 'dart:math' as math;

class DelayAnimateSwitcher extends StatefulWidget {
  final bool animate;
  final Duration delay;
  final Duration animationDuration;
  final Widget secondChild;
  final Widget? firstChild;
  final Widget Function(Widget child, Animation<double> animation)? transitionBuilder;

  const DelayAnimateSwitcher({Key? key,
    required this.secondChild,
    this.firstChild,
    this.animate = true,
    this.delay = const Duration(milliseconds: 1),
    this.transitionBuilder,
    this.animationDuration = const Duration(milliseconds: 150)}) : super(key: key);

  @override
  State<DelayAnimateSwitcher> createState() => _DelayAnimateSwitcherState();
}

class _DelayAnimateSwitcherState extends State<DelayAnimateSwitcher> {
  bool showChild2 = false;

  @override
  void initState() {
    super.initState();

    if (widget.animate && widget.animationDuration.inMilliseconds > 0) {
      Future.delayed(
          Duration(milliseconds: math.max(widget.delay.inMilliseconds, 10)))
          .then((_) {
        setState(() {
          showChild2 = true;
        });
      });
    } else {
      showChild2 = true;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (!widget.animate || widget.animationDuration.inMilliseconds == 0) {
      return widget.secondChild;
    }

    return AnimatedSwitcher(
      duration: widget.animationDuration,
      transitionBuilder: widget.transitionBuilder ?? (Widget child, Animation<double> animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: showChild2
          ? widget.secondChild
          : (widget.firstChild ?? Container()),
    );
  }
}
