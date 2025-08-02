import 'dart:developer' as developer;
import 'package:breath_state/providers/nav_bar_provider.dart';
import 'package:breath_state/providers/polar_connect_provider.dart';
import 'package:breath_state/services/breath_rate/record.dart';
import 'package:breath_state/services/heart_rate/polar_connect.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  late SoundRecorder _recorder;
  Stream<int>? hrStream;
  //TODO Stream the breathing rate and heart rate
  //TODO dispose polar connect

  bool isRecordingHR = false;
  int breathingRate = -2;
  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  //TODO : Add Audio_waveforms
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
            //TODO Multiple instances created if button clicked twice
            ElevatedButton(
              onPressed: () async {
                _recorder = SoundRecorder();
                breathingRate = -1;
                setState(() {});
                breathingRate = await _recorder.startRecord();
                setState(() {});
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 112, 180, 236),
                foregroundColor: Colors.black,
              ),
              child: const Text("Record Breathing Rate"),
            ),
            hrStream == null
                ? const SizedBox.shrink() // Show nothing before recording
                : StreamBuilder<int>(
                  stream: hrStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    } else if (!snapshot.hasData) {
                      return const SizedBox.shrink(); // No data yet, show nothing
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
                                    Navigator.of(
                                      context,
                                    ).pop(); // Close the dialog
                                    context.read<NavBarProvider>().changeIndex(
                                      4,
                                    ); // Go to settings tab
                                  },
                                  child: const Text("Go to Settings"),
                                ),
                              ],
                            ),
                      );
                    } else {
                      try {
                        if (!isRecordingHR) {
                          // TODO Use riverpod to stream the data
                          final stream = await polar.startRecording();
                          setState(() {
                            hrStream = stream;
                            isRecordingHR = true;
                          });
                          developer.log("Recording started");
                        } else {
                          // Stop recording
                          await polar.stopRecording();
                          setState(() {
                            hrStream = null;
                            isRecordingHR = false;
                          });
                          developer.log("Recording stopped");
                        }
                      } catch (e) {
                        developer.log("HR recording error: $e");
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 112, 180, 236),
                    foregroundColor: Colors.black,
                  ),
                  child: Text(
                    isRecordingHR ? "Stop Recording HR" : "Record Heart Rate",
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
