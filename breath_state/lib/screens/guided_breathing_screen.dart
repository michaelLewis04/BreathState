import 'package:breath_state/screens/box_breathing.dart';
import 'package:flutter/material.dart';
import 'package:breath_state/widgets/guided_breathing.dart';

class GuidedBreathingScreen extends StatefulWidget {
  const GuidedBreathingScreen({super.key});

  @override
  State<GuidedBreathingScreen> createState() => _GuidedBreathingScreenState();
}

class _GuidedBreathingScreenState extends State<GuidedBreathingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => GuidedBreathing(
                            inhaleDuration: const Duration(seconds: 4),
                            holdDuration: const Duration(seconds: 4),
                            exhaleDuration: const Duration(seconds: 4),
                          ),
                    ),
                  );
                },
                style: ButtonStyle(
                  fixedSize: WidgetStateProperty.all(const Size(150, 200)),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                child: const Text("Box Breathing"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => GuidedBreathing(
                            inhaleDuration: const Duration(seconds: 4),
                            holdDuration: const Duration(seconds: 0),
                            exhaleDuration: const Duration(seconds: 4),
                          ),
                    ),
                  );
                },
                style: ButtonStyle(
                  fixedSize: WidgetStateProperty.all(const Size(150, 200)),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                child: const Text(
                  "Equal Breathing",
                ), //TODO: Remove the transition to hold in the split second
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => GuidedBreathing(
                            inhaleDuration: const Duration(seconds: 4),
                            holdDuration: const Duration(seconds: 7),
                            exhaleDuration: const Duration(seconds: 8),
                          ),
                    ),
                  );
                },
                style: ButtonStyle(
                  fixedSize: WidgetStateProperty.all(const Size(150, 200)),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                child: const Text("4-7-8 Breathing"),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ButtonStyle(
                  fixedSize: WidgetStateProperty.all(const Size(150, 200)),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                child: const Text("Button 4"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
