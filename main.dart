import 'package:flutter/material.dart';
import 'debt.dart';
import 'settings.dart';
import 'sign.dart';
import 'home.dart';
import 'about.dart';

import 'splashscreen.dart';
import 'login.dart';
import 'navbar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _mode = ThemeMode.system;

  void setThemeMode(ThemeMode newMode) {
    setState(() => _mode = newMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrackFunds',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: _mode,
      debugShowCheckedModeBanner: false,
      
      
      routes: {
        '/settings': (context) => Settings(
              currentMode: _mode,
              onModeChanged: setThemeMode,
            ),
        '/sign': (context) =>  Sign(),
        '/home': (context) => Home(),
        '/about': (context) => const About(),
        '/login': (context) => login(), 
      },
      
      
      
      home: const Splashscreen(),
    );
  }
}