import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/text.dart';
import '../../models/game.dart';

class Clock extends StatefulWidget {
  const Clock({Key? key, required this.size}) : super(key: key);

  final double size;

  @override
  State<Clock> createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  late PlayTimer timer;

  @override
  void initState() {
    super.initState();
    timer = context.read<SudokuGame>().timer;
    timer.addListener(_listener);
  }

  void _listener() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final seconds = timer.currentDuration.inSeconds;
    final hours = (seconds / 3600).floor();
    final hasHours = hours > 0;
    final mins = (seconds / 60).floor();
    final hasMins = mins > 0;
    final secs = seconds % 60;
    return AppText('${hasHours ? '${mins}h ' : ''}${hasMins ? '${mins}m ' : ''}${secs}s', size: widget.size);
  }

  @override
  void dispose() {
    timer.removeListener(_listener);
    super.dispose();
  }
}

class PlayTimer extends ChangeNotifier {
  final Stopwatch _watch = Stopwatch();
  final int initialSeconds;
  Timer? _timer;

  Duration get currentDuration => _currentDuration + Duration(seconds: initialSeconds);
  Duration _currentDuration = Duration.zero;

  bool get isRunning => _timer != null;

  PlayTimer(this.initialSeconds);

  void _onTick(Timer timer) {
    _currentDuration = _watch.elapsed;
    notifyListeners();
  }

  void start() {
    if (_timer != null) return;

    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
    _watch.start();

    notifyListeners();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _watch.stop();
    _currentDuration = _watch.elapsed;

    notifyListeners();
  }

  void reset() {
    stop();
    _watch.reset();
    _currentDuration = Duration.zero;

    notifyListeners();
  }
}
