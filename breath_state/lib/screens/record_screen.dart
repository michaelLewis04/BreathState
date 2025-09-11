import 'dart:developer' as developer;
import 'package:breath_state/providers/nav_bar_provider.dart';
import 'package:breath_state/providers/polar_connect_provider.dart';
import 'package:breath_state/services/breath_rate/record.dart';
import 'package:breath_state/services/heart_rate/polar_connect.dart';
import 'package:breath_state/services/resonance_service/res_freq.dart';
import 'package:breath_state/services/resonance_service/rf_trainer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  SoundRecorder? _recorder;
  Stream<int>? _hrStream;

  bool isRecordingHR = false;
  bool isRecordingBR = false;
  int breathingRate = -2;

  @override
  void dispose() {
    _recorder?.dispose();
    _stopHRRecording();
    super.dispose();
  }

  Future<void> _startRecording({
    required bool recordBR,
    required bool recordHR,
  }) async {
    if (recordBR) {
      _recorder = SoundRecorder();
      setState(() {
        breathingRate = -1;
        isRecordingBR = true;
      });

      // run BR asynchronously without blocking HR
      _recorder!.startRecord().then((rate) {
        if (mounted) {
          setState(() {
            breathingRate = rate;
            isRecordingBR = false;
          });
        }
      });
    }

    if (recordHR) {
      final polarConnectProvider = context.read<PolarConnectProvider>();
      PolarConnect? polar = polarConnectProvider.getPolarConnect();
      if (polar == null) {
        if (mounted) {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text("Device Not Connected"),
                  content: const Text(
                    "Please connect to the Polar device in Settings.",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.read<NavBarProvider>().changeIndex(4);
                      },
                      child: const Text("Go to Settings"),
                    ),
                  ],
                ),
          );
        }
      } else {
        try {
          final hrStream = await polar.getHeartRate();
          setState(() {
            _hrStream = hrStream;
            isRecordingHR = true;
          });
          developer.log("HR recording started");
        } catch (e) {
          developer.log("HR recording error: $e");
        }
      }
    }
  }

  Future<void> _stopHRRecording() async {
    final polarConnectProvider = context.read<PolarConnectProvider>();
    PolarConnect? polar = polarConnectProvider.getPolarConnect();
    if (polar != null) {
      try {
        await polar.stopRecording();
        setState(() {
          _hrStream = null;
          isRecordingHR = false;
        });
        developer.log("HR recording stopped");
      } catch (e) {
        developer.log("Error stopping HR recording: $e");
      }
    }
  }

  void _showRecordDialog() {
    bool recordBR = false;
    bool recordHR = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Select what to record"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    title: const Text("Record Breathing Rate"),
                    value: recordBR,
                    onChanged:
                        (val) => setStateDialog(() => recordBR = val ?? false),
                  ),
                  CheckboxListTile(
                    title: const Text("Record Heart Rate"),
                    value: recordHR,
                    onChanged:
                        (val) => setStateDialog(() => recordHR = val ?? false),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _startRecording(recordBR: recordBR, recordHR: recordHR);
                  },
                  child: const Text("Start Recording"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (breathingRate == -2)
              const Text("Let's calculate breathing rate (30s)")
            else if (breathingRate == -1)
              const Text("Calculating...")
            else ...[
              const Text(
                "Breathing Rate(per min):",
                style: TextStyle(fontSize: 24),
              ),
              Text(
                "$breathingRate",
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
            _hrStream == null
                ? const SizedBox.shrink()
                : StreamBuilder<int>(
                  stream: _hrStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    } else if (!snapshot.hasData) {
                      return const SizedBox.shrink();
                    } else {
                      return Text(
                        "Heart Rate: ${snapshot.data} bpm",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      );
                    }
                  },
                ),
            ElevatedButton(
              onPressed: isRecordingHR ? _stopHRRecording : _showRecordDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 112, 180, 236),
                foregroundColor: Colors.black,
              ),
              child: Text(
                isRecordingHR ? "Stop Recording" : "Select Recording Options",
              ),
            ),
            const SizedBox(height: 10),
            Consumer<PolarConnectProvider>(
              builder: (context, polarConnectProvider, child) {
                return ElevatedButton(
                  onPressed: () async {
                    PolarConnect? polar =
                        polarConnectProvider.getPolarConnect();
                    if (polar == null) {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text("Device Not Connected"),
                              content: const Text(
                                "Please connect to the Polar device in Settings.",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    context.read<NavBarProvider>().changeIndex(
                                      4,
                                    );
                                  },
                                  child: const Text("Go to Settings"),
                                ),
                              ],
                            ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ResonanceFrequencyTrainer(
                                rf: ResonanceFrequency(),
                                polar: polar,
                              ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 112, 180, 236),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text("Measure Resonance Frequency"),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
