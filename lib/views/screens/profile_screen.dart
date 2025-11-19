import 'package:flutter/material.dart';
import 'package:qhaliqara_app/data/notifiers.dart';
import 'package:qhaliqara_app/views/screens/welcome_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        children: [
          ListTile(title: Text('Cerrar sesión'),
            onTap: () {
              selectedScreenNotifier.value = 0;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return WelcomeScreen();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
