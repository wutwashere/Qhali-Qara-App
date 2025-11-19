import 'package:flutter/material.dart';
import 'package:qhaliqara_app/views/widgets/hero_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        children: [
          HeroWidget(),
          SizedBox(
            width: 200,
            child: FilledButton(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
              },

              child: Text('ALERTAS'),
            ),
          ),
          SizedBox(
            width: 200,
            child: FilledButton(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              onPressed: () {

              },
              child: Text('CONSULTAR ESPECIALISTA'),
            ),
          ),
          SizedBox(
            width: 200,
            child: FilledButton(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              onPressed: () {

              },
              child: Text('HISTORIAL MEDICO'),
            ),
          ),
        ],
      ),
    );
  }
}