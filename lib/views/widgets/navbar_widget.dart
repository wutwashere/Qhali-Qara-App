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
          height: 83,
          indicatorColor: Colors.amberAccent,
          backgroundColor: Color.fromRGBO(46, 58, 89, 1.0),
          destinations: [
            NavigationDestination(
                icon: Icon(
                  Icons.home,
                  color: Colors.amber[50],

                ),
                label: ''),
            NavigationDestination(icon: Icon(Icons.menu_book, color: Colors.amber[50]), label: ''),
            NavigationDestination(icon: Icon(Icons.remove_red_eye, color: Colors.amber[50]), label: ''),
            NavigationDestination(icon: Icon(Icons.map, color: Colors.amber[50]), label: ''),
            NavigationDestination(icon: Icon(Icons.person, color: Colors.amber[50]), label: ''),
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
