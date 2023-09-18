import 'dart:math' as math;


class StopwatchController {
  final List<void Function(int seconds)> _listeners = [];
  bool _paused = true;
  late int _seconds;
  late int _stoppedSeconds;
  Duration? _reverseDuration;

  int get seconds {
    if (_reverseDuration != null) {
      return math.min(_stoppedSeconds, math.min(_seconds, _reverseDuration!.inSeconds));
    }
    return math.max(_stoppedSeconds, math.max(_seconds, 0));
  }

  StopwatchController({Duration? reverseDuration}) {
    _init(reverseDuration);
  }

  String get text {
    final minutesStr = seconds ~/ 60;
    final secondsStr = seconds % 60;
    return "${minutesStr < 10 ? '0' : ''}$minutesStr:${secondsStr < 10 ? '0' : ''}$secondsStr";
  }

  Duration? get reverseDuration => _reverseDuration;

  void start({Duration? customReverseDuration}) {
    if (!_paused) {
      return;
    }
    _init(customReverseDuration);
    _paused = false;


    (() async {
      while(!_paused){
        if (_reverseDuration != null) {
          _seconds--;
        } else {
          _seconds++;
        }
        for (final listener in _listeners) {
          listener(_seconds);
        }
        if (_seconds == 0 && _reverseDuration != null) {
          stop();
        } else {
          await Future.delayed(const Duration(seconds: 1));
        }
      }
    })();
  }
  
  void addOnChangedListener ({required void Function(int seconds) listener}) { _listeners.add(listener); }
  void removeOnChangedListener ({required void Function(int seconds) listener}) { _listeners.remove(listener); }
  
  void dispose() {
    stop();
  }
  void pause () {
    _paused = true;
  }
  void stop () {
    pause();
    _stoppedSeconds = _seconds;
    if (_reverseDuration != null) {
      _seconds = _reverseDuration!.inSeconds  + 1;
    } else {
      _seconds = -1;
    }
  }

  void _init(Duration? reverseDuration) {
    if (reverseDuration != null) {
      _reverseDuration = reverseDuration;
    }
    
    if (_reverseDuration != null) {
      _stoppedSeconds = _seconds = _reverseDuration!.inSeconds + 1;
    } else {
      _stoppedSeconds = _seconds = -1;
    }
  }
}