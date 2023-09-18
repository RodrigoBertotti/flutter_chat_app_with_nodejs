import 'package:flutter/material.dart';


class ButtonWidget extends StatelessWidget {
  final String text;
  final void Function()? onPressed;
  final bool isLoading;
  final bool isSmall;

  const ButtonWidget({Key? key, this.isSmall = false, required this.text, this.onPressed, this.isLoading = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: !isSmall ? double.infinity : null,
      height: isSmall ? 30 : 35,
      child: ElevatedButton(
        style: ButtonStyle(
            elevation: MaterialStateProperty.all<double>(0),
            backgroundColor: MaterialStateProperty.all(Colors.blue[500]),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                )
            )
        ),
        onPressed: isLoading ? null : onPressed,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: isLoading ? Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.blue[700]),),) : Text(text, style: TextStyle(fontSize: isSmall ? 12 : 14, letterSpacing: 2)),
        ),
      ),
    );
  }
}
