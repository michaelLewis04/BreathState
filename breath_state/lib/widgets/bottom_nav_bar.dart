import 'package:breath_state/providers/nav_bar_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

 
  @override
  Widget build(BuildContext context) {
    return Consumer<NavBarProvider>(
      builder: (context, navBarProvider, child) {
        return BottomNavigationBar(
          currentIndex: navBarProvider.getIndex(),
          onTap: (index) {
            context.read<NavBarProvider>().changeIndex(index);
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.self_improvement),
              label: 'Breathing',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.my_location_outlined),
              label: 'Record',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.medical_services),
              label: 'Doctor',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        );
      },
    );
  }
}
