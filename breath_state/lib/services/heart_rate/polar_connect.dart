import 'dart:async';
import 'dart:developer' as developer;
import 'package:breath_state/constants/db_constants.dart';
import 'package:breath_state/services/db_service/database_service.dart';
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
  StreamController<List<PolarEcgSample>>? ecgController;
  Timer? saveTimer;
  int? latestHr;

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

  Future<Stream<int>> getHeartRate() async {
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
          latestHr = sample.hr;
        }
      }, onError: (err) => developer.log('HR streaming error: $err'));
      saveTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
        if (latestHr != null) {
          await DatabaseService.instance.addData(latestHr!, HEART_TABLE_NAME);
          developer.log('Saved HR: $latestHr');
        }
      });
    }
    return hrController!.stream;
  }

  Future<Stream<List<PolarEcgSample>>> getECG() async {
    ecgController = StreamController<List<PolarEcgSample>>();
    await connectToPolar();
    final availableTypes = await polar.getAvailableOnlineStreamDataTypes(
      identifier,
    );
    developer.log('Available data types: $availableTypes');
    if (availableTypes.contains(PolarDataType.ecg)) {
      ecgSubscription = polar.startEcgStreaming(identifier).listen((data) {
        for (final sample in data.samples) {
          developer.log('ECG: ${sample.voltage} mV, Time: ${sample.timeStamp}');
          //   // ecgController!.add(data.samples);
        }
        ecgController!.add(data.samples);
      }, onError: (err) => developer.log('ECG streaming error: $err'));
    }
    return ecgController!.stream;
  }

  Future<void> stopRecording() async {
    try {
      await hrSubscription?.cancel();
      await ecgSubscription?.cancel();
      await accSubscription?.cancel();

      hrController?.close();
      ecgController?.close();

      saveTimer?.cancel();
      await polar.disconnectFromDevice(identifier);
      developer.log('All streams cancelled and device disconnected.');
    } catch (e) {
      developer.log('Error stopping recording: $e');
    }
  }

  //TODO Add streamer
  //TODO Add other metrics and recording
}
