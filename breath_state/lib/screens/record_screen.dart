import 'dart:async';

import 'package:breath_state/services/breath_rate/record.dart';
import 'package:flutter/material.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  final SoundRecorder _recorder = SoundRecorder();
  //TODO Stream the breathing rate
  // StreamController breathingRate = StreamController<int>();

  int breathingRate = -1;
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
            Text("Breathing Rate: ${breathingRate}"),
            TextButton(
              onPressed: () async {
                breathingRate = await _recorder.startRecord();
                setState(() {});
              },
              child: const Text("Start Recording"),
            ),
            TextButton(
              onPressed: () async {
                await _recorder.stopRecord();
              },
              child: const Text("Stop Recording"),
            ),
          ],
        ),
      ),
    );
  }
}
