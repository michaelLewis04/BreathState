import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:breath_state/widgets/guided_breathing.dart';
import 'package:breath_state/services/resonance_service/res_freq.dart';
import 'package:breath_state/services/heart_rate/polar_connect.dart';

class ResonanceFrequencyTrainer extends StatefulWidget {
  final ResonanceFrequency rf;
  final PolarConnect polar;

  const ResonanceFrequencyTrainer({
    super.key,
    required this.rf,
    required this.polar,
  });

  @override
  State<ResonanceFrequencyTrainer> createState() =>
      _ResonanceFrequencyTrainerState();
}

class _ResonanceFrequencyTrainerState extends State<ResonanceFrequencyTrainer> {
  double _currentRate = 5.0;
  final double _maxRate = 7.0;
  final double _step = 0.2;
  final Duration _testDuration = const Duration(seconds: 90);

  bool _isRunning = false;
  Timer? _stepTimer;

  @override
  void initState() {
    super.initState();
    _startTest();
  }

  void _startTest() {
    setState(() => _isRunning = true);

    _runStep(); // start first breathing step
  }

  Future<void> _runStep() async {
    if (!mounted || _currentRate > _maxRate) {
      _finishTest();
      return;
    }

    developer.log("Starting test at $_currentRate BPM");

    // Start RMSSD measurement in parallel
    widget.rf.calculateRMSSDForBreathingRate(
      breathingRate: _currentRate,
      polar: widget.polar,
    );

    // Start a 90s timer for this breathing rate
    _stepTimer = Timer(_testDuration, () {
      if (!mounted) return;

      // increment BPM after 90s
      setState(() {
        _currentRate = double.parse((_currentRate + _step).toStringAsFixed(1));
      });

      _runStep(); // recursively move to next step
    });
  }

  void _finishTest() {
    developer.log("All rates tested");
    developer.log("RMSSD results: ${widget.rf.rmssdResults}");
    developer.log("Best rate: ${widget.rf.getResonanceBreathingRate()}");

    if (mounted) {
      setState(() => _isRunning = false);
    }
  }

  @override
  void dispose() {
    _stepTimer?.cancel(); // cancel running timer to prevent leaks
    try {
      widget.polar.stopRecording();
      developer.log("Polar recording stopped in dispose()");
    } catch (e) {
      developer.log("Error stopping Polar recording in dispose(): $e");
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double cycleSeconds = 60.0 / _currentRate;
    final inhaleMs = (cycleSeconds * 500).toInt();
    final exhaleMs = inhaleMs;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 53, 53, 53),
      appBar: AppBar(
        title: const Text(
          "Resonance Frequency Test",
          style: TextStyle(color: Colors.white), // White appbar text
        ),
        backgroundColor: const Color.fromARGB(255, 53, 53, 53),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child:
            _isRunning
                ? Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Testing rate: $_currentRate BPM",
                      style: TextStyle(
                        fontSize: 28, 
                        fontWeight: FontWeight.bold,
                        foreground:
                            Paint()
                              ..shader = const LinearGradient(
                                colors: <Color>[
                                  Colors.lightBlueAccent,
                                  Colors.cyanAccent,
                                ],
                              ).createShader(
                                const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                              ),
                        shadows: [
                          Shadow(
                            blurRadius: 8.0,
                            color: Colors.black.withOpacity(0.6),
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),
                    Expanded(
                      child: GuidedBreathing(
                        inhaleDuration: Duration(milliseconds: inhaleMs),
                        holdDuration: Duration.zero,
                        exhaleDuration: Duration(milliseconds: exhaleMs),
                        showStopButton: false,
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                )
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Test completed!"),
                    Text(
                      "Best rate: ${widget.rf.getResonanceBreathingRate()} BPM",
                    ),
                  ],
                ),
      ),
    );
  }
}
