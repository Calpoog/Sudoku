import 'dart:async';

import 'package:flutter/material.dart';

import '../../common/text.dart';

class Clock extends StatefulWidget {
  const Clock({Key? key, required this.size}) : super(key: key);

  final double size;

  @override
  _ClockState createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  late final Timer timer;
  int seconds = 0;

  @override
  void initState() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        seconds++;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final hours = (seconds / 3600).floor();
    final hasHours = hours > 0;
    final mins = (seconds / 60).floor();
    final hasMins = mins > 0;
    final secs = seconds % 60;
    return AppText('${hasHours ? '${mins}h ' : ''}${hasMins ? '${mins}m ' : ''}${secs}s', size: widget.size);
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}
