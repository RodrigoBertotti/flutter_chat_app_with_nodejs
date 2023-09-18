import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/presentation/widgets/balloon_widget.dart';

import 'message_widget.dart';

class _DotWidget extends StatefulWidget {
  Duration delayToStart;

  _DotWidget({Key? key, required this.delayToStart}) : super(key: key);

  @override
  State<_DotWidget> createState() => _DotWidgetState();
}

class _DotWidgetState extends State<_DotWidget> {
  final Duration duration = const Duration(milliseconds: 350);
  bool running = true;
  final double circleSize = 4.0;
  final double totalHeight = 10;
  bool isBottom = true;

  @override
  void initState() {
    super.initState();

    late void Function() func;
    func = () => Future.delayed(duration, () {
      if(running){
        setState(() {
          isBottom = !isBottom;
          Future.delayed(isBottom ? const Duration(milliseconds: 800) : Duration.zero, func);
        });
      }
    });
    Future.delayed(widget.delayToStart, func);
  }

  @override
  void dispose() {
    running = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: totalHeight,
      width: circleSize,
      child: Stack(
        children: [
          AnimatedPositioned(
            bottom: isBottom ? 0 : (totalHeight - circleSize),
            duration: duration,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.circular(50),
              ),
              width: circleSize,
              height: circleSize,
            ),
          ),
        ],
      ),
    );
  }
}

class TypingIndicatorWidget extends StatelessWidget {
  final EdgeInsets margin;
  const TypingIndicatorWidget({Key? key, this.margin = EdgeInsets.zero}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: BalloonWidget(
        isLeftSide: true,
        centerChild: Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 2, left: 8, right: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DotWidget(delayToStart: Duration.zero,),
              const SizedBox(width: 4,),
              _DotWidget(delayToStart: const Duration(milliseconds: 250),),
              const SizedBox(width: 4,),
              _DotWidget(delayToStart: const Duration(milliseconds: 500),),
            ],
          ),
        ),
      ),
    );
  }
}

