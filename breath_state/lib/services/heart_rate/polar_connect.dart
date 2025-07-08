import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:polar/polar.dart';

//TODO Add permisions pop up for bluetooth

class PolarConnect {
  final String identifier;
  final Polar polar = Polar();

  PolarConnect({required this.identifier});

  //TODO Add reconnect, see if connection gets broken

  Future<void> connectToPolar() async {
    developer.log("Searching device");

    try {
      await polar.connectToDevice(identifier);
      await Future.delayed(const Duration(seconds: 2));
      developer.log("Found device");
    } catch (e) {
      developer.log("Error connectiong $e");
    }

    return;
  }

  // StreamController sc = StreamController<int>();

  void getPolarBatteryLevel() {
    // sc.sink.add(polar.batteryLevel);
  }

  Future<void> startRecording() async {
    await polar.sdkFeatureReady.firstWhere(
      (e) =>
          e.identifier == identifier &&
          e.feature == PolarSdkFeature.onlineStreaming,
    );

    polar.startHrStreaming(identifier).listen((hrData) {
      final hr = hrData.samples[0];
      final rrRhs = hrData.samples[1];
      developer.log("HR value : $hr");
      developer.log("rrRhs value: $rrRhs");
      //TODO: Add streamer
    });

    polar.startEcgStreaming(identifier).listen((ecgData) {
      final ecgValue = ecgData.samples;
      developer.log("ECG value: $ecgValue");
    });
    //TODO Add other metrics and recording
  }
}
