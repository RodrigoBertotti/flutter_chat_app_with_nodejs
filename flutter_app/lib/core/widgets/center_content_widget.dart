import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter_chat_app_with_mysql/main.dart';

/// Centers the `child` without a delimited container,
/// so we are able to create animations outside this widget,
/// like adding items to a list coming from the left or right
class CenterContentWidget extends StatelessWidget {
  final Widget child;
  final bool withBackground;
  final EdgeInsets? padding;
  final double? verticalMargin;

  const CenterContentWidget({required this.child, this.verticalMargin, this.withBackground = false, Key? key, this.padding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        clipBehavior: Clip.none,
        decoration: !withBackground ? null : BoxDecoration(
            gradient: LinearGradient(
                colors: [
                  Colors.blue[900]!,
                  Colors.blue[800]!,
                  Colors.blue[900]!,
                ]
            )
        ),
        child: Align(
            alignment: Alignment.topCenter,
            child: Builder(
                builder: (context) {
                  return Padding(
                    padding: padding ?? EdgeInsets.symmetric(
                        vertical: verticalMargin ?? kMargin,
                        horizontal: math.max(kMargin, (MediaQuery
                            .of(context)
                            .size
                            .width - kPageContentWidth) / 2)
                    ),
                    child: SafeArea(child: child,),
                  );
                })
        )
    );
  }
}
