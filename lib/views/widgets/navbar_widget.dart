import 'package:flutter/material.dart';
import 'package:qhaliqara_app/data/notifiers.dart';

class NavbarWidget extends StatelessWidget {
  const NavbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedScreenNotifier,
      builder: (context, selectedScreen, child) {
        return NavigationBar(
          destinations: [
            NavigationDestination(icon: Icon(Icons.home), label: ''),
            NavigationDestination(icon: Icon(Icons.menu_book), label: ''),
            NavigationDestination(icon: Icon(Icons.remove_red_eye), label: ''),
            NavigationDestination(icon: Icon(Icons.map), label: ''),
            NavigationDestination(icon: Icon(Icons.person), label: ''),
          ],
          onDestinationSelected: (int value) {
            selectedScreenNotifier.value = value;
          },
          selectedIndex: selectedScreen,
        );
      },
    );
  }
}
