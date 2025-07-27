import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'dart:developer' as developer;
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';

class BleScanning {
  final flutterReactiveBle = FlutterReactiveBle();
  final List<DiscoveredDevice> _devices = [];

  Function(List<DiscoveredDevice>)? onDeviceDiscovered;

  static Future<void> requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
    ].request();
  }

  static Future<void> checkAndRequestBluetooth(BuildContext context) async {
    final isOn = await FlutterBluePlus.isOn;

    if (!isOn) {
      if (Platform.isAndroid) {
        await FlutterBluePlus.turnOn();
      } else if (Platform.isIOS) {
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text("Bluetooth Required"),
                content: const Text("Please enable Bluetooth in Settings."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"),
                  ),
                ],
              ),
        );
      }
    } else {
      debugPrint("Bluetooth is ON");
    }
  }

  static Future<void> checkAndRequestLocation(BuildContext context) async {
    final location = loc.Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text("Location Required"),
                content: const Text(
                  "Please enable Location services to scan BLE devices.",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"),
                  ),
                ],
              ),
        );
      }
    }
  }

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
