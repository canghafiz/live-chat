import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// Object
final TimerService timerService = TimerService();

class TimerService extends ChangeNotifier {
  // Singleton
  static final _instance = TimerService._constructor();
  TimerService._constructor();

  factory TimerService() {
    return _instance;
  }

  // Process
  Duration _duration = const Duration();
  Timer? _timer;

  // Getter
  Duration get duration => _duration;

  // Setter
  void startTime() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => addTime());
  }

  void reset() {
    _duration = const Duration();
    _timer?.cancel();
    notifyListeners();
  }

  void addTime() {
    const addSeconds = 1;

    final seconds = _duration.inSeconds + addSeconds;

    _duration = Duration(seconds: seconds);
    notifyListeners();
  }
}
