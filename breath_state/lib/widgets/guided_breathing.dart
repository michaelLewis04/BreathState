import 'dart:async';
import 'package:flutter/material.dart';

class GuidedBreathing extends StatefulWidget {
  final Duration inhaleDuration;
  final Duration holdDuration;
  final Duration exhaleDuration;

  final bool showStopButton;

  const GuidedBreathing({
    super.key,
    required this.inhaleDuration,
    required this.holdDuration,
    required this.exhaleDuration,
    this.showStopButton = true,
  });

  @override
  State<GuidedBreathing> createState() => _GuidedBreathingState();
}

class _GuidedBreathingState extends State<GuidedBreathing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  Timer? _phaseTimer;
  Timer? _introTimer;
  Timer? _countdownTimer;

  String _phaseText = "Relax...";
  double minSize = 100;
  double maxSize = 200;

  int _introSecondsLeft = 5;
  int _phaseSecondsLeft = 0;

  //TODO: Add vibration when state change in breathing

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.inhaleDuration,
    );

    _animation = Tween<double>(
      begin: minSize,
      end: maxSize,
    ).animate(_controller);

    _introTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_introSecondsLeft == 1) {
        timer.cancel();
        setState(() => _introSecondsLeft = 0);
        _startCycle();
      } else {
        setState(() => _introSecondsLeft--);
      }
    });
  }

  void _startCycle() {
    _doInhale();
  }

  void _doInhale() {
    setState(() => _phaseText = "Inhale");
    _controller.duration =
        widget.inhaleDuration; //TODO Make sure they are synchronised
    _startCountdown(widget.inhaleDuration);
    _controller.forward().whenComplete(() {
      if (widget.holdDuration == Duration.zero) {
        _doExhale();
        return;
      }
      _doHold(afterInhale: true);
    });
  }

  void _doExhale() {
    setState(() => _phaseText = "Exhale");
    _controller.duration = widget.exhaleDuration;
    _startCountdown(widget.exhaleDuration);
    _controller.reverse().whenComplete(() {
      if (widget.holdDuration == Duration.zero) {
        _doInhale();
        return;
      }
      _doHold(afterInhale: false);
    });
  }

  void _doHold({required bool afterInhale}) {
    setState(() => _phaseText = "Hold");
    _startCountdown(widget.holdDuration);
    _phaseTimer = Timer(widget.holdDuration, () {
      if (afterInhale) {
        _doExhale();
      } else {
        _doInhale();
      }
    });
  }

  void _startCountdown(Duration duration) {
    _countdownTimer?.cancel();

    // total ms left
    int msLeft = duration.inMilliseconds;
    setState(() => _phaseSecondsLeft = (msLeft / 1000).ceil());

    _countdownTimer = Timer.periodic(const Duration(milliseconds: 200), (
      timer,
    ) {
      msLeft -= 200;

      if (msLeft <= 0) {
        timer.cancel();
        setState(() => _phaseSecondsLeft = 0);
      } else {
        // Update text every 200ms instead of whole second
        setState(() => _phaseSecondsLeft = (msLeft / 1000).ceil());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _phaseTimer?.cancel();
    _introTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 150),
            Column(
              children: [
                const SizedBox(height: 50),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer fixed circle
                    Container(
                      width: maxSize + 20,
                      height: maxSize + 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.withOpacity(0.2),
                      ),
                    ),
                    // Inner fixed circle
                    Container(
                      width: minSize - 20,
                      height: minSize - 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.withOpacity(0.2),
                      ),
                    ),
                    // Animated breathing circle
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Container(
                          width: _animation.value,
                          height: _animation.value,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.fromARGB(255, 109, 183, 243),
                          ),
                          child: Center(
                            child:
                                _introSecondsLeft > 0
                                    ? const SizedBox.shrink()
                                    : AnimatedOpacity(
                                      opacity:
                                          _phaseSecondsLeft == 1 ? 0.0 : 1.0,
                                      duration: const Duration(
                                        milliseconds: 600,
                                      ),
                                      child: Text(
                                        '$_phaseSecondsLeft',
                                        style: const TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Text(
                  _introSecondsLeft > 0
                      ? "Relax... $_introSecondsLeft"
                      : _phaseText,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (widget.showStopButton) const SizedBox(height: 150),
            if (widget.showStopButton)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Stop"),
              ),
          ],
        ),
      ),
    );
  }
}
