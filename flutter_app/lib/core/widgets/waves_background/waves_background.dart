import 'package:flutter/material.dart';

import 'clipper/waves_background_clipper.dart';


class WavesBackground extends StatelessWidget {
  const WavesBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Colors.indigo[900]!,
                    Colors.indigo[800]!,
                    Colors.indigo[900]!,
                  ]
              )
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * .43,
          child: ClipPath(
            clipper: WavesBackgroundClipper(),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [
                        Colors.blue[900]!,
                        Colors.blue[800]!,
                        Colors.blue[900]!,
                      ]
                  )
              ),
            ),
          ),
        ),
      ],
    );
  }
}
