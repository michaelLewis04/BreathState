import 'package:breath_state/services/heart_rate/polar_connect.dart';
import 'package:flutter/widgets.dart';

//TODO Rename variables to eg: mnanager

class PolarConnectProvider extends ChangeNotifier {
  PolarConnect? _polarConnect;

  Future<void> connectToPolarSensor(String identifier) async {
    _polarConnect = PolarConnect(identifier: identifier);
    await _polarConnect?.connectToPolar();
  }

  PolarConnect? getPolarConnect() {
    return _polarConnect;
  }
}
