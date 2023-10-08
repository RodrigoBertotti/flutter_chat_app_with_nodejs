import 'package:flutter/material.dart';
import 'package:flutter_chat_app_with_mysql/main.dart';
import 'dart:math' as math;

typedef NewConstraints = BoxConstraints? Function(BoxConstraints currentConstraints);

class BalloonWidget extends StatelessWidget {
  final Widget? centerChild;
  final bool isLeftSide;
  final NewConstraints? centerChildConstraints;

  const BalloonWidget({ Key? key, this.centerChildConstraints, this.centerChild, required this.isLeftSide, }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double kWidth = 13.0;
    const double kHeight = 10.0;

    final curve = Padding(
      padding: isLeftSide ? EdgeInsets.zero : const EdgeInsets.only(left: kWidth),
      child: Transform(
        transform: isLeftSide ? Matrix4.rotationY(0) : Matrix4.rotationY(math.pi),
        child: ClipPath(
          clipper: _SideWidgetClipper(),
          child: Container(
            width: kWidth,
            height: kHeight,
            color: isLeftSide ? Colors.white : Colors.indigo[700],
          ),
        ),
      ),
    );

    final leftSideChild = isLeftSide ? curve : null;
    final rightSideChild = isLeftSide ? null : curve;

    return Align(
      alignment: rightSideChild != null ? Alignment.bottomRight : Alignment.bottomLeft,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
              margin: const EdgeInsets.only( top: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if(leftSideChild != null)
                    leftSideChild,
                  Container(
                      padding: const EdgeInsets.only(left: 11, right: 11, top: 6, bottom: 2),
                      decoration: BoxDecoration(
                        color: rightSideChild != null ? Colors.indigo[700] : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.indigo.withOpacity(0.55),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: Offset(5 * (rightSideChild != null ? -1 : 1), 5), // changes position of shadow
                          ),
                        ],
                        borderRadius: BorderRadius.only(
                          topLeft: rightSideChild != null ? const Radius.circular(10) : Radius.zero,
                          bottomRight: const Radius.circular(10),
                          bottomLeft: const Radius.circular(10),
                          topRight: rightSideChild != null ? Radius.zero : const Radius.circular(10),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if(centerChild != null)
                            Container(
                              constraints: centerChildConstraints == null ? constraints : centerChildConstraints!(constraints),
                              child: centerChild!,
                            ),
                        ],
                      )
                  ),
                  if(rightSideChild != null)
                    rightSideChild,
                ],
              )
          );
        },
      ),
    );
  }
}

class _SideWidgetClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.quadraticBezierTo(
        size.width * 0.75,
        size.height / 6,
        size.width,
        size.height
    );
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}