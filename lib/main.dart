import 'package:flutter/material.dart';
import 'package:qhaliqara_app/views/screens/welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

//Material App (Statefull)
//Scafold
//App Title
//Bottom navegation bar setState

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Color.fromRGBO(215, 206, 181, 1.0),
            brightness: Brightness.light,
        ),
      ),
      home: WelcomeScreen(),
    );
  }
}



