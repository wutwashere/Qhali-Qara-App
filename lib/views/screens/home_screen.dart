import 'package:flutter/material.dart';
import 'package:qhaliqara_app/views/screens/alerts_screen.dart';
import 'package:qhaliqara_app/views/screens/history_screen.dart';
import 'package:qhaliqara_app/views/screens/specialists_screen.dart';
import 'package:qhaliqara_app/views/widgets/hero_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(60.0),
      child: Column(
        children: [
          HeroWidget(),
          SizedBox(
            width: 167,
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                textStyle: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                )
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AlertsScreen()),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications, size: 25, color: Colors.white),
                  SizedBox(width: 8),
                  Text('ALERTAS'),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            width: 167,
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SpecialistsScreen()),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medical_services, size: 25, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'CONSULTAR ESPECIALISTA',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            width: 167,
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HistoryScreen()),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 25, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'HISTORIAL MÉDICO',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}