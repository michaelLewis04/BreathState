import 'dart:async';
import 'dart:developer' as Developer;
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
  //TODO Stream the breathing rate

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

            Consumer<PolarConnectProvider>(
              builder: (context, polarConnectProvider, child) {
                return ElevatedButton(
                  onPressed: () async {
                    PolarConnect? polar =
                        polarConnectProvider.getPolarConnect();
                    if (polar == null) {
                      // TODO Add alert pop up
                      Developer.log("Connect first");
                    } else {
                      try {
                       
                        await polar.startRecording();
                        Developer.log("Recording done");
                      } catch (e) {
                        Developer.log("Error in recording: $e");
                      }
                    }
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 112, 180, 236),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text("Record Heart Rate"),
                );
              },
            ),

            // TextButton(
            //   onPressed: () async {
            //     _recorder = SoundRecorder();
            //     breathingRate = -1;
            //     setState(() {});
            //     breathingRate = await _recorder.startRecord();
            //     setState(() {});
            //   },
            //   child: const Text("Record Breathing Rate"),
            // ),

            //TODO : Add feature to stop recording and breathing rate

            // TextButton(
            //   onPressed: () async {
            //     await _recorder.stopRecord();
            //   },
            //   child: const Text("Stop Recording"),
            // ),
          ],
        ),
      ),
    );
  }
}
