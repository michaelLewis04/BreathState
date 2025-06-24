import 'package:breath_state/widgets/guided_breathing.dart';
import 'package:flutter/material.dart';

class BoxBreathing extends StatelessWidget {
  const BoxBreathing({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 150),
            GuidedBreathing(
              inhaleDuration: const Duration(seconds: 4),
              holdDuration: const Duration(seconds: 4),
              exhaleDuration: const Duration(seconds: 4),
            ),
            const SizedBox(height: 150),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text("Stop"),
            ),
          ],
        ),
      ),
    );
  }
}
