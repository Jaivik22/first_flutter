import 'dart:async';
import 'package:flutter/material.dart';

class WindowsStyleProgressBar extends StatefulWidget {
  final double width;
  final Color backgroundColor;
  final Color progressColor;
  final Duration duration;

  const WindowsStyleProgressBar({
    Key? key,
    this.width = 200,
    this.backgroundColor = Colors.grey,
    this.progressColor = Colors.blue,
    this.duration = const Duration(seconds: 5),
  }) : super(key: key);

  @override
  _WindowsStyleProgressBarState createState() =>
      _WindowsStyleProgressBarState();
}

class _WindowsStyleProgressBarState extends State<WindowsStyleProgressBar> {
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _startProgress();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: 5,
      color: widget.backgroundColor,
      child: Stack(
        children: [
          AnimatedContainer(
            duration: widget.duration,
            width: widget.width * _progress,
            color: widget.progressColor,
          ),
        ],
      ),
    );
  }

  void _startProgress() {
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        _progress += 0.01;
        if (_progress >= 1.0) {
          timer.cancel();
        }
      });
    });
  }
}
