import 'package:flutter/material.dart';

class MyAnimatedIcon extends StatefulWidget {
  final IconData icon;
  late final ValueNotifier<bool>? notifySuccess;
  late final ValueNotifier<String?>? notifyError;

  MyAnimatedIcon(
      { required this.icon,
        this.notifySuccess,
        this.notifyError,
        Key? key}
      ) : super(key: key);

  @override
  State<MyAnimatedIcon> createState() => _MyAnimatedIconState();
}

class _MyAnimatedIconState extends State<MyAnimatedIcon> {
  ValueNotifier<bool>? internalNotifySuccess;
  ValueNotifier<String?>? internalNotifyError;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: (widget.notifySuccess ?? internalNotifySuccess)!,
        builder: (context, showSuccess, _) {
          return ValueListenableBuilder(
              valueListenable: (widget.notifyError ?? internalNotifyError)!,
              builder: (context, showError, __) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: () {
                    const double kIconSize = 27.0;
                    if (showSuccess) {
                      return const Icon(
                        key: ValueKey<int>(0),
                        Icons.check,
                        color: Colors.indigo,
                        size: kIconSize,
                      );
                    }
                    if (showError?.isNotEmpty == true) {
                      return Icon(
                        key: ValueKey<int>(1),
                        Icons.error_outline_rounded,
                        color: Colors.red[300]!,
                        size: kIconSize,
                      );
                    }
                    return Icon(
                      key: const ValueKey<int>(2),
                      widget.icon,
                      color: Colors.indigo,
                      size: kIconSize,
                    );
                  }(),
                );
              }
          );
        }
    );
  }

  @override
  void initState() {
    super.initState();

    if (widget.notifySuccess == null) {
      internalNotifySuccess = ValueNotifier(false);
    }
    if (widget.notifyError == null) {
      internalNotifyError = ValueNotifier(null);
    }
  }

  @override
  void dispose() {
    internalNotifySuccess?.dispose();
    internalNotifyError?.dispose();
    super.dispose();
  }
}