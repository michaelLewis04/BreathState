import 'package:breath_state/services/heart_rate/polar_connect.dart';
import 'package:flutter/widgets.dart';

//TODO Rename variables to eg: mnanager

class PolarConnectProvider extends ChangeNotifier {
  PolarConnect? _polarConnect;
  //NIT : Could use only 1 instance of Polar Connect
  Future<void> connectToPolarSensor(String identifier) async {
    _polarConnect = PolarConnect(identifier: identifier);
  }

  PolarConnect? getPolarConnect() {
    return _polarConnect;
  }
}
