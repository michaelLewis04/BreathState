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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Device")),
      body:
          scannedDevices.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: scannedDevices.length,
                itemBuilder: (context, index) {
                  final device = scannedDevices[index];
                  return ListTile(
                    title: Text(
                      device.name.isNotEmpty ? device.name : "Unknown",
                    ),
                    subtitle: Text("ID: ${device.id}\nRSSI: ${device.rssi}"),
                    onTap: () {
                    Navigator.pop(context, device.id); 
                  },
                  );
                },
              ),
    );
  }
}
