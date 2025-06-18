import 'dart:async';
import 'dart:typed_data';
import 'dart:developer' as developer;

class ProcessData {
  late StreamController<List<Int16List>> recorderDataController;
  late List<int> averageStreamList = List.empty(growable: true);
  int numberOfSamples = 0; //To be used later for streaming
  int windowSize = 10;
  int minGap = 80;

  Future<void> getStream(StreamController<List<Int16List>> recorder) async {
    recorderDataController = recorder;
    await for (var value in recorderDataController.stream) {
      for (var chunk in value) {
        int average = (chunk.reduce((a, b) => a + b) ~/ chunk.length).abs();
        // developer.log("data: ${average}");
        numberOfSamples += chunk.length;
        averageStreamList.add(average);
      }
    }
  }

  Future<int> calculateBreathRate() async {
    List<int> amplitudes = averageStreamList;

    // developer.log("Raw data: $amplitudes");

    List<int> smoothed = [];

    for (int i = 0; i < amplitudes.length; i++) {
      int start = (i - windowSize ~/ 2).clamp(0, amplitudes.length - 1);
      int end = (i + windowSize ~/ 2).clamp(0, amplitudes.length - 1);
      int sum = 0;
      int count = 0;

      for (int j = start; j <= end; j++) {
        sum += amplitudes[j];
        count++;
      }

      smoothed.add((sum / count).round());
    }

    // developer.log("Smoothed data: $smoothed");

    double average = smoothed.reduce((a, b) => a + b) / smoothed.length;
    // developer.log("Average of smoothed data: $average");

    int numberOfPeaks = 0;
    bool above = false;
    int lastPeakIndex = -1 * minGap;

    for (int i = 0; i < smoothed.length; i++) {
      int amp = smoothed[i];

      if (!above && amp > average) {
        if (i - lastPeakIndex >= minGap) {
          numberOfPeaks++;
          lastPeakIndex = i;
        }
        above = true;
      } else if (above && amp < average) {
        above = false;
      }
    }

    double bpm =
        numberOfPeaks *
        (60.0 /
            30.0); // Change if we are stopping/streaming...Rn recording only for 30 seconds
    // developer.log("Breathing rate = ${bpm.toStringAsFixed(2)} BPM");

    return bpm.round();
  }
}
