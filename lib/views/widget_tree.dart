import 'package:flutter/material.dart';
import 'package:qhaliqara_app/data/notifiers.dart';
import 'package:qhaliqara_app/views/screens/advice_screen.dart';
import 'package:qhaliqara_app/views/screens/camera_screen.dart';
import 'package:qhaliqara_app/views/screens/home_screen.dart';
import 'package:qhaliqara_app/views/screens/map_screen.dart';
import 'package:qhaliqara_app/views/screens/profile_screen.dart';
import 'package:qhaliqara_app/views/screens/settings_screen.dart';

import 'widgets/navbar_widget.dart';

List<Widget> screens = [
  HomeScreen(),
  AdviceScreen(),
  CameraScreen(),
  MapScreen(),
  ProfileScreen(),
];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Qhali Qara'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) {
                    return SettingsScreen();
                    },
                  ),
              );
            },
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: selectedScreenNotifier,
        builder: (context, selectedScreen, child) {
        return screens.elementAt(selectedScreen);
        },
      ),
      bottomNavigationBar: NavbarWidget(),
    );
  }
}
