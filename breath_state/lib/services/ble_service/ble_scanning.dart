import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'dart:developer' as developer;

class BleScanning {
  final flutterReactiveBle = FlutterReactiveBle();
  final List<DiscoveredDevice> _devices = [];

  Function(List<DiscoveredDevice>)? onDeviceDiscovered;

  void scanDevices() {
    //NIT: serviceId for Polar devices
    flutterReactiveBle
        .scanForDevices(withServices: [], scanMode: ScanMode.lowLatency)
        .listen(
          (device) {
            if (_devices.every((d) => d.id != device.id)) {
              _devices.add(device);
              if (onDeviceDiscovered != null) {
                onDeviceDiscovered!(_devices);
              }
            }
          },
          onError: (err) {
            developer.log("Scan error: $err");
          },
        );
  }

  void clearDevices() {
    _devices.clear();
  }
}
