import 'package:breath_state/screens/box_breathing.dart';
import 'package:flutter/material.dart';

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
                    MaterialPageRoute(builder: (context) => BoxBreathing()),
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
                onPressed: () {},
                style: ButtonStyle(
                  fixedSize: WidgetStateProperty.all(const Size(150, 200)),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                child: const Text("Button 2"),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
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
                child: const Text("Button 3"),
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
