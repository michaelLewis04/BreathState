import 'package:breath_state/providers/nav_bar_provider.dart';
import 'package:breath_state/screens/doctor_screen.dart';
import 'package:breath_state/screens/record_screen.dart';
import 'package:breath_state/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/bottom_nav_bar.dart';
import 'screens/home_screen.dart';
import 'screens/guided_breathing_screen.dart';

import 'dart:developer' as developer;

//TODO: Make all the sizes defined be wrt to context size
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => NavBarProvider(0),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<Widget> screens = const [
    HomeScreen(),
    GuidedBreathingScreen(),
    RecordScreen(),
    DoctorScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Consumer<NavBarProvider>(
        builder: (context, model, child) {
          return Scaffold(
            body: screens[model.getIndex()],
            bottomNavigationBar: const BottomNavBar(),
          );
        },
      ),
    );
  }
}
