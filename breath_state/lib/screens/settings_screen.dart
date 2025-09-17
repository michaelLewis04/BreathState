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

class _SettingsScreenState extends State<SettingsScreen> {
  String? _selectDeviceUUID;
  bool _isConnected = false;
  final fileSharer = FileWriterService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // dark background
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Connection Section
            Card(
              color: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.bluetooth,
                          size: 28,
                          color: Colors.lightBlueAccent,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _isConnected
                                ? "Connected to Polar Sensor"
                                : "Not Connected",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        CircleAvatar(
                          radius: 6,
                          backgroundColor:
                              _isConnected ? Colors.green : Colors.redAccent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        await BleScanning.requestPermissions();
                        await BleScanning.checkAndRequestBluetooth(context);
                        await BleScanning.checkAndRequestLocation(context);
                        _selectDeviceUUID = await Navigator.push<String>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BleDeviceSelect(),
                          ),
                        );
                        developer.log(
                          "Selected Device UUID: $_selectDeviceUUID",
                        );
                        if (_selectDeviceUUID != null) {
                          setState(() => _isConnected = true);
                          await context
                              .read<PolarConnectProvider>()
                              .connectToPolarSensor(_selectDeviceUUID!);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      child: Text(
                        _isConnected
                            ? "Reconnect to Sensor"
                            : "Connect to Polar Sensor",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    if (_selectDeviceUUID != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        "Selected Device ID:\n$_selectDeviceUUID",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Export Section
            Card(
              color: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.file_upload,
                          size: 28,
                          color: Colors.tealAccent,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Export Data",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                backgroundColor: const Color(0xFF1E1E1E),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                title: const Text(
                                  "Export Data",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      "Choose which data file to share",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    const SizedBox(height: 20),
                                    _buildExportButton(
                                      label: "Breathing Data",
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                        await fileSharer.shareFile(
                                          BREATH_FILE_NAME,
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    _buildExportButton(
                                      label: "ECG Data",
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                        await fileSharer.shareFile(
                                          ECG_FILE_NAME,
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    _buildCancelButton(context),
                                  ],
                                ),
                              ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[400],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      child: const Text(
                        "Export Data",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueGrey[700],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 1,
        ),
        child: Text(label, style: const TextStyle(fontSize: 15)),
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).pop(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[700],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 1,
        ),
        child: const Text("Cancel", style: TextStyle(fontSize: 15)),
      ),
    );
  }
}
