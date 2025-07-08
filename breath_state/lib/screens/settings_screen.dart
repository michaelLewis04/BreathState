import 'package:breath_state/providers/polar_connect_provider.dart';
import 'package:breath_state/widgets/ble_device_select.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:io';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _selectDeviceUUID;
  @override
  Widget build(BuildContext context) {
    Future<void> requestPermissions() async {
      await [
        Permission.bluetooth,
        Permission.bluetoothConnect,
        Permission.bluetoothScan,
        Permission.location,
      ].request();
    }

    Future<void> checkAndRequestBluetooth(BuildContext context) async {
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

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await requestPermissions();
                await checkAndRequestBluetooth(context);
                _selectDeviceUUID = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(builder: (_) => BleDeviceSelect()),
                );
                if (_selectDeviceUUID != null) {
                  setState(() {});
                }
                await context.read<PolarConnectProvider>().connectToPolarSensor(
                  _selectDeviceUUID!,
                );
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 112, 180, 236),
                foregroundColor: Colors.black,
              ),
              child: const Text("Connect to polar sensor"),
            ),
            SizedBox(height: 30),
            if (_selectDeviceUUID != null)
              Text(
                "Selected Device ID: $_selectDeviceUUID",
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
