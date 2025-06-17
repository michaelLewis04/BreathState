import 'dart:async';
import 'dart:typed_data';
import 'dart:developer' as developer;

class ProcessData {
  late StreamController<List<Int16List>> recorderDataController;
  late List<int> averageStreamList = List.empty(growable: true);
  int numberOfSamples = 0;
  int windowSize = 50;
  
  Future<void> getStream(StreamController<List<Int16List>> recorder) async {
    
    recorderDataController = recorder;
    await for (var value in recorderDataController.stream) {
      for (var chunk in value) {
        // print("Data is : ${chunk}");
        int average = (chunk.reduce((a, b) => a + b) ~/ chunk.length).abs();
        developer.log("data: ${average}");
        numberOfSamples += chunk.length;
        averageStreamList.add(average);
        // yield calculateBreathRate(chunk);
      }
    }
  }


  Future<int> calculateBreathRate() async {
  List<int> amplitudes = averageStreamList;

  if (amplitudes.length < 40) {
    developer.log("Not enough data to calculate breathing rate.");
    return 0;
  }

  double average = amplitudes.reduce((a, b) => a + b) / amplitudes.length;

  int crossings = 0;
  bool above = false;
  int lastPeakIndex = -100; // Initialized far back
  const int minGap = 100;    // Minimum distance between breaths (samples)

  for (int i = 0; i < amplitudes.length; i++) {
    int amp = amplitudes[i];

    if (!above && amp > average) {
      if (i - lastPeakIndex >= minGap) {
        crossings++;
        lastPeakIndex = i;
      }
      above = true;
    } else if (above && amp < average) {
      above = false;
    }
  }

  double bpm = crossings * (60.0 / 30.0); // Assuming 30 sec recording
  developer.log("Breathing rate (with min gap $minGap) = ${bpm.toStringAsFixed(2)} BPM");

  return bpm.round();
}
}
