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
                        context.read<NavBarProvider>().changeIndex(3);
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
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (breathingRate == -2)
                const Text(
                  "Breathing rate will take ~30 seconds",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                )
              else if (breathingRate == -1)
                const Text(
                  "Calculating...",
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                )
              else ...[
                const Text(
                  "Breathing Rate (per min):",
                  style: TextStyle(fontSize: 22, color: Colors.white70),
                ),
                Text(
                  "$breathingRate",
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlueAccent,
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
                        return Text(
                          "Error: ${snapshot.error}",
                          style: const TextStyle(color: Colors.redAccent),
                        );
                      } else if (!snapshot.hasData) {
                        return const SizedBox.shrink();
                      } else {
                        return Text(
                          "Heart Rate: ${snapshot.data} bpm",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        );
                      }
                    },
                  ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isRecordingHR ? _stopHRRecording : _showRecordDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isRecordingHR ? "Stop Recording" : "Select Recording Options",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 12),
              Consumer<PolarConnectProvider>(
                builder: (context, polarConnectProvider, child) {
                  return Column(
                    children: [
                      const SizedBox(height: 28),
                      ElevatedButton.icon(
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
                                        onPressed:
                                            () => Navigator.of(context).pop(),
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          context
                                              .read<NavBarProvider>()
                                              .changeIndex(3);
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
                        icon: const Icon(
                          Icons.auto_awesome,
                          color: Colors.tealAccent,
                        ),
                        label: const Text("Measure Resonance Frequency"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            43,
                            43,
                            43,
                          ),
                          foregroundColor: Colors.tealAccent.shade200,
                          side: BorderSide(
                            color: Colors.tealAccent.shade200,
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
