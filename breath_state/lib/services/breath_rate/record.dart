import 'dart:async';
import 'dart:typed_data';
import 'package:breath_state/services/breath_rate/process_data.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:developer' as developer;

class SoundRecorder {
  final FlutterSoundRecorder _myRecorder = FlutterSoundRecorder();
  bool recordIsOpen = false;
  final int kSAMPLERATE = 8000;
  final int kNUMBEROFCHANNELS = 1;

  var recorderDataController = StreamController<List<Int16List>>();

  //TODO :Make open Recorder in initState

  Future<void> openRecorder() async {
    await _myRecorder.openRecorder();
    recordIsOpen = true;
  }

  Future<void> getPermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
      if (!status.isGranted) {
        developer.log("Microphone permission denied");
        throw Exception("Microphone permission denied");
      }
    }
  }

  Future<int> startRecord() async {
    await getPermission();
    await openRecorder();
    if (!recordIsOpen) {
      developer.log("Unable to open recorder");
      throw Exception("Unable to open recorder");
    }

    await _myRecorder.startRecorder(
      codec: Codec.pcm16,
      sampleRate: kSAMPLERATE,
      numChannels: kNUMBEROFCHANNELS,
      toStreamInt16: recorderDataController.sink,
    );

    ProcessData P = ProcessData();

    P.getStream(recorderDataController);

    await Future.delayed(const Duration(seconds: 30));

    await stopRecord();
  
    return await P.calculateBreathRate();
  }

  Future<void> stopRecord() async {
    await _myRecorder.stopRecorder();
    await closeRecorder();
  }

  Future<void> closeRecorder() async {
    await _myRecorder.closeRecorder();
    recordIsOpen = false;
  }

  void dispose() {
    recorderDataController.close();
  }
}
