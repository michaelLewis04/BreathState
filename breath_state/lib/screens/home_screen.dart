import 'package:flutter/material.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: const Text(
          'Welcome to Breath State!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
