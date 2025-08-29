import 'package:breath_state/constants/file_constants.dart';
import 'package:breath_state/providers/polar_connect_provider.dart';
import 'package:breath_state/services/ble_service/ble_scanning.dart';
import 'package:breath_state/services/file_service/file_write.dart';
import 'package:breath_state/widgets/ble_device_select.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

//TODO Add a connection status indicator

class _SettingsScreenState extends State<SettingsScreen> {
  String? _selectDeviceUUID;
  final fileSharer = FileWriterService();
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
              //TODO Change text, if connected to polar device
              child: const Text("Connect to Polar Sensor"),
            ),
            const SizedBox(height: 30),
            if (_selectDeviceUUID != null)
              Text(
                "Selected Device ID: $_selectDeviceUUID",
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text(
                          "Export Data",
                          textAlign: TextAlign.center, // Center title
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Choose which data file to share",
                              textAlign:
                                  TextAlign.center, // Center content text
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity, // ✅ full width button
                              child: ElevatedButton(
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  await fileSharer.shareFile(BREATH_FILE_NAME);
                                },
                                child: const Text(
                                  "Breathing Data",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity, // ✅ full width button
                              child: ElevatedButton(
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  await fileSharer.shareFile(ECG_FILE_NAME);
                                },
                                child: const Text(
                                  "ECG Data",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity, // ✅ full width button
                              child: ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[300],
                                  foregroundColor: Colors.black,
                                ),
                                child: const Text(
                                  "Cancel",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 112, 180, 236),
                foregroundColor: const Color.fromARGB(255, 36, 10, 10),
              ),
              child: const Text("Export Data"),
            ),
          ],
        ),
      ),
    );
  }
}
