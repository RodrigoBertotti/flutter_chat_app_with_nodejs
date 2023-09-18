

import 'package:flutter/material.dart';
import 'package:flutter_chat_app_with_mysql/main.dart';

class MyMultilineTextField extends StatelessWidget {
  final ValueChanged<String>? onSubmitted;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController controller;
  final String hintText;
  final Color? fillColor;
  final int maxLines;
  final int? maxLength;

  const MyMultilineTextField({Key? key, this.maxLength, this.fillColor, this.maxLines = 20, this.onSubmitted, required this.hintText, this.prefixIcon, this.suffixIcon, required this.controller,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const inputStyle = TextStyle(color: Colors.white, fontSize: 16);
    final border = OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(15)),
      borderSide: BorderSide(color: Colors.indigo[800]!, width: 0.0),
    );

    return TextField(
      textInputAction: TextInputAction.go,
      controller: controller,
      onSubmitted: onSubmitted,
      keyboardType: TextInputType.multiline,
      minLines: 1,
      maxLines: maxLines,
      maxLength: maxLength,
      textAlignVertical: TextAlignVertical.center,
      clipBehavior: Clip.none,
      decoration: InputDecoration(
        prefixText: '    ',
        suffixIconConstraints: const BoxConstraints(
          maxHeight: kIconSize
        ),
        isCollapsed: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 10,),
        isDense: true,
        hintStyle: TextStyle(color: Colors.blue[50]),
        hintText: hintText,
        fillColor: fillColor ?? Colors.indigo,
        focusedBorder: border,
        enabledBorder: border,
        errorBorder: border,
        disabledBorder: border,
        border: border,
        focusedErrorBorder: border,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
      ),
      style: inputStyle,
    );
  }
}
