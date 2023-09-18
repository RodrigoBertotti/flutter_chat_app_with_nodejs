import 'package:flutter/material.dart';

import 'stopwatch_controller.dart';


class StopwatchWidget extends StatefulWidget {
  final StopwatchController controller;
  final Color color;
  final double fontSize;

  const StopwatchWidget({this.color = Colors.white, required this.controller, this.fontSize = 22, super.key});

  @override
  State<StopwatchWidget> createState() => _StopwatchWidgetState();
}

class _StopwatchWidgetState extends State<StopwatchWidget> {
  @override
  void initState() {
    super.initState();
    widget.controller.addOnChangedListener(listener: refresh);
  }

  @override
  Widget build(BuildContext context) {
    return Text(widget.controller.text, style: TextStyle(color: widget.color, fontWeight: FontWeight.w700, fontSize: widget.fontSize), );
  }

  @override
  void dispose() {
    widget.controller.removeOnChangedListener(listener: refresh);
    super.dispose();
  }

  void refresh(_) {
    setState(() {});
  }
}
