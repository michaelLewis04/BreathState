import 'package:breath_state/services/ble_service/ble_scanning.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleDeviceSelect extends StatefulWidget {
  const BleDeviceSelect({super.key});

  @override
  State<BleDeviceSelect> createState() => _BleDeviceSelectState();
}

class _BleDeviceSelectState extends State<BleDeviceSelect> {
  final BleScanning _ble = BleScanning();
  List<DiscoveredDevice> scannedDevices = [];

  @override
  void initState() {
    super.initState();
    _ble.onDeviceDiscovered = (devices) {
      setState(() {
        scannedDevices = devices;
      });
    };
    _ble.scanDevices();
  }

  @override
  void dispose() {
    _ble.clearDevices();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Select Device"),
        elevation: 0,
        centerTitle: true,
      ),
      body:
          scannedDevices.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: scannedDevices.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final device = scannedDevices[index];
                  return GestureDetector(
                    onTap: () {
                      String name = device.name;
                      if (name.startsWith("Polar") && name.length >= 8) {
                        Navigator.pop(context, name.substring(name.length - 8));
                      } else {
                        Navigator.pop(context, device.id);
                      }
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.blue.shade100,
                              child: Icon(
                                Icons.bluetooth,
                                color: Colors.blue.shade700,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    device.name.isNotEmpty
                                        ? device.name
                                        : "Unknown Device",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "ID: ${device.id}",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "RSSI: ${device.rssi}",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
