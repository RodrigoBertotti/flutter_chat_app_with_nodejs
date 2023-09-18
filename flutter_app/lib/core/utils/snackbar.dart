


import 'package:flutter/material.dart';

void showSnackBarWarning ({required BuildContext context, required String message}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    backgroundColor: Colors.indigo[900],
    duration: const Duration(seconds: 5),
    content: Row(
      children: [
        const Icon(Icons.warning, size: 18, color: Colors.yellow,),
        const SizedBox(width: 5,),
        Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),)
      ],
    ),
  ));
}