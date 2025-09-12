import 'package:flutter/material.dart';
import 'package:breath_state/widgets/guided_breathing.dart';

class GuidedBreathingScreen extends StatelessWidget {
  const GuidedBreathingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_BreathingOption> breathingOptions = [
      _BreathingOption(
        title: "Box Breathing",
        description: "Inhale • Hold • Exhale • Hold",
        color: Colors.blueAccent,
        inhale: 4,
        hold: 4,
        exhale: 4,
      ),
      _BreathingOption(
        title: "Equal Breathing",
        description: "Balanced inhale and exhale",
        color: Colors.greenAccent,
        inhale: 4,
        hold: 0,
        exhale: 4,
      ),
      _BreathingOption(
        title: "4-7-8 Breathing",
        description: "Relaxation and calmness",
        color: Colors.purpleAccent,
        inhale: 4,
        hold: 7,
        exhale: 8,
      ),
      _BreathingOption(
        title: "Extended Breathing",
        description: "Long, deep exhale",
        color: Colors.orangeAccent,
        inhale: 3,
        hold: 0,
        exhale: 9,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Guided Breathing",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 24,
            letterSpacing: 1.2,
            color: Color.fromARGB(255, 185, 184, 184),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color.fromARGB(255, 0, 0, 0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const Spacer(flex: 1),
            Expanded(
              flex: 8,
              child: GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 0.85,
                ),
                itemCount: breathingOptions.length,
                itemBuilder: (context, index) {
                  final option = breathingOptions[index];
                  return _BreathingCard(option: option);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BreathingOption {
  final String title;
  final String description;
  final Color color;
  final int inhale;
  final int hold;
  final int exhale;

  _BreathingOption({
    required this.title,
    required this.description,
    required this.color,
    required this.inhale,
    required this.hold,
    required this.exhale,
  });
}

class _BreathingCard extends StatelessWidget {
  final _BreathingOption option;

  const _BreathingCard({required this.option});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => GuidedBreathing(
                  inhaleDuration: Duration(seconds: option.inhale),
                  holdDuration: Duration(seconds: option.hold),
                  exhaleDuration: Duration(seconds: option.exhale),
                ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: option.color.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: option.color.withOpacity(0.7), width: 1),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.self_improvement, size: 48, color: option.color),
            const SizedBox(height: 12),
            Text(
              option.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              option.description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
