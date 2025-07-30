import 'package:breath_state/providers/polar_connect_provider.dart';
import 'package:breath_state/services/ble_service/ble_scanning.dart';
import 'package:breath_state/widgets/ble_device_select.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _selectDeviceUUID;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await BleScanning.requestPermissions();
                await BleScanning.checkAndRequestBluetooth(context);
                await BleScanning.checkAndRequestLocation(context);
                _selectDeviceUUID = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(builder: (_) => BleDeviceSelect()),
                );
                developer.log("Selected Device UUID: $_selectDeviceUUID");
                if (_selectDeviceUUID != null) {
                  setState(() {});
                  await context
                      .read<PolarConnectProvider>()
                      .connectToPolarSensor(_selectDeviceUUID!);
                }
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 112, 180, 236),
                foregroundColor: const Color.fromARGB(255, 36, 10, 10),
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
