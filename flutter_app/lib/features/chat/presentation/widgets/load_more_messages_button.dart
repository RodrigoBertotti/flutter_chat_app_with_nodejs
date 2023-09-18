import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class LoadMoreMessagesButton extends StatelessWidget {
  final void Function() onTap;

  const LoadMoreMessagesButton({required this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.center,
        child: InkWell(
          onTap: onTap,
          child: Ink(
            child: Container(
              margin: const EdgeInsets.only(top: 17, bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.lightBlue[50],
                borderRadius: const BorderRadius.all(Radius.circular(50)),
              ),
              child: const Text("Load more messages", style: TextStyle(color: Colors.indigo, fontSize: 14)),
            ),
          ),
        )
    );
  }
}
