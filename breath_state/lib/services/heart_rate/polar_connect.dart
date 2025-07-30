import 'dart:async';
import 'dart:developer' as developer;
import 'package:polar/polar.dart';

//TODO Add permisions pop up for bluetooth
//TODO Add a dispose

class PolarConnect {
  final String identifier;
  final Polar polar = Polar();

  StreamSubscription? hrSubscription;
  StreamSubscription? ecgSubscription;
  StreamSubscription? accSubscription;

  StreamController<int>? hrController;

  PolarConnect({required this.identifier});

  //TODO Add reconnect, see if connection gets broken

  Future<void> connectToPolar() async {
    developer.log("Searching device");

    try {
      await polar.connectToDevice(identifier);
      await polar.sdkFeatureReady.firstWhere(
        (e) =>
            e.identifier == identifier &&
            e.feature == PolarSdkFeature.onlineStreaming,
      );

      developer.log("Device connected and ready for streaming.");
    } catch (e) {
      developer.log("Error connecting: $e");
    }

    return;
  }

  void getPolarBatteryLevel() {
    //TODO Add battery level
  }

  Future<Stream<int>> startRecording() async {
    hrController = StreamController<int>();
    await connectToPolar();
    final availableTypes = await polar.getAvailableOnlineStreamDataTypes(
      identifier,
    );
    developer.log('Available data types: $availableTypes');

    if (availableTypes.contains(PolarDataType.hr)) {
      hrSubscription = polar.startHrStreaming(identifier).listen((data) {
        for (final sample in data.samples) {
          developer.log('HR: ${sample.hr} bpm');
          hrController!.add(sample.hr);
        }
      }, onError: (err) => developer.log('HR streaming error: $err'));
    }

    if (availableTypes.contains(PolarDataType.ecg)) {
      ecgSubscription = polar.startEcgStreaming(identifier).listen((data) {
        developer.log('ECG received with ${data.samples.length} samples');
      }, onError: (err) => developer.log('ECG streaming error: $err'));
    }

    if (availableTypes.contains(PolarDataType.acc)) {
      accSubscription = polar.startAccStreaming(identifier).listen((data) {
        developer.log('ACC received with ${data.samples.length} samples');
      }, onError: (err) => developer.log('ACC streaming error: $err'));
    }
    return hrController!.stream;
  }

  Future<void> stopRecording() async {
    try {
      await hrSubscription?.cancel();
      await ecgSubscription?.cancel();
      await accSubscription?.cancel();
      hrController?.close();
      await polar.disconnectFromDevice(identifier);
      developer.log('All streams cancelled and device disconnected.');
    } catch (e) {
      developer.log('Error stopping recording: $e');
    }
  }

  //TODO Add streamer
  //TODO Add other metrics and recording
}
