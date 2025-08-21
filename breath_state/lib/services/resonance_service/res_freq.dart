import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';
import 'package:polar/polar.dart';
import 'package:breath_state/services/heart_rate/polar_connect.dart';

class ResonanceFrequency {
  final List<PolarEcgSample> _ecgBuffer = [];
  final List<int> _rPeaksTimestamps = [];

  final Map<double, double> rmssdResults = {};

  final int _timeInterval = 70;

  final int _smoothWindowSize = 10;
  final int _minGapMs = 200;

  PolarConnect? _polar;
  StreamSubscription? _ecgSub;

  ResonanceFrequency();

  Future<void> _getEcgData() async {
    if (_polar == null) {
      developer.log("Polar device not set!");
      return;
    }
    final ecgStream = await _polar!.getECG();
    _ecgSub = ecgStream.listen(
      (sampleBatch) {
        _ecgBuffer.addAll(sampleBatch);
      },
      onError: (err) {
        developer.log("ECG Stream Error: $err");
      },
    );
  }

  Future<void> calculateRMSSDForBreathingRate({
    required double breathingRate,
    required PolarConnect polar,
  }) async {
    _polar = polar;
    _ecgBuffer.clear();

    developer.log(
      "Starting ECG collection for breathing rate $breathingRate...",
    );
    await _getEcgData();

    await Future.delayed(Duration(seconds: _timeInterval));

    await polar.stopRecording();

    developer.log("ECG data so far: ${_ecgBuffer.length} samples");

    _detectRPeaks(_ecgBuffer);

    List<int> rrIntervals = [];
    for (int i = 1; i < _rPeaksTimestamps.length; i++) {
      rrIntervals.add(_rPeaksTimestamps[i] - _rPeaksTimestamps[i - 1]);
      developer.log("RR Interval ${i - 1}: ${rrIntervals.last} ms");
    }

    double rmssd = _calculateRMSSD(rrIntervals);
    rmssdResults[breathingRate] = rmssd;

    developer.log("RMSSD at $breathingRate BPM breathing: $rmssd");

    await _ecgSub?.cancel();
  }

  void _detectRPeaks(List<PolarEcgSample> samples) {
    _rPeaksTimestamps.clear();

    List<double> smoothed = [];
    for (int i = 0; i < samples.length; i++) {
      int start = max(0, i - _smoothWindowSize ~/ 2);
      int end = min(samples.length - 1, i + _smoothWindowSize ~/ 2);
      double sum = 0;
      for (int j = start; j <= end; j++) {
        sum += samples[j].voltage.toDouble();
      }
      smoothed.add(sum / (end - start + 1));
    }

    double avgVoltage = smoothed.reduce((a, b) => a + b) / smoothed.length;

    bool above = false;
    int lastPeakTime = -_minGapMs;

    for (int i = 0; i < smoothed.length; i++) {
      double val = smoothed[i];
      int timeMs = samples[i].timeStamp.millisecondsSinceEpoch;

      if (!above && val > avgVoltage) {
        if (timeMs - lastPeakTime >= _minGapMs) {
          _rPeaksTimestamps.add(timeMs);
          lastPeakTime = timeMs;
        }
        above = true;
      } else if (above && val < avgVoltage) {
        above = false;
      }
    }
  }

  double _calculateRMSSD(List<int> rr) {
    if (rr.length < 2) return 0.0;
    double sumSqDiff = 0.0;
    for (int i = 1; i < rr.length; i++) {
      double diff = (rr[i] - rr[i - 1]).toDouble();
      sumSqDiff += diff * diff;
    }
    return sqrt(sumSqDiff / (rr.length - 1));
  }

  double getResonanceBreathingRate() {
    if (rmssdResults.isEmpty) {
      developer.log("No RMSSD results available.");
      return 0.0;
    }
    double maxRmssd = rmssdResults.values.reduce(max);
    return rmssdResults.entries
        .firstWhere((entry) => entry.value == maxRmssd)
        .key;
  }
}
