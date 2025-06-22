import 'package:flutter/material.dart';

class BoxBreathing extends StatefulWidget {
  const BoxBreathing({super.key});

  @override
  State<BoxBreathing> createState() => _BoxBreathingState();
}

class _BoxBreathingState extends State<BoxBreathing> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text("Box Breathing Screen"), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Box Breathing animation"),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 250, 112, 102),
                foregroundColor: Colors.white,
              ),
              child: Text("Stop"),
            ),
          ],
        ),
      ),
    );
  }
}
