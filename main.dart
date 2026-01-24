import 'package:flutter/material.dart';
import 'debt.dart';
import 'settings.dart';
import 'sign.dart';
import 'home.dart';
import 'about.dart';
import 'transaction.dart';
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
      theme:ThemeData.light(),
      darkTheme:ThemeData.dark(),
      themeMode:_mode ,
     
      debugShowCheckedModeBanner: false,
      routes:{
        '/settings':(context)=>Settings(
          currentMode: _mode,
          onModeChanged: setThemeMode
        ),
        '/sign':(context)=>Sign(),
        '/home':(context)=>Home(),
        '/debt':(context)=>Debt(),
        '/transaction':(context)=>AddTransaction(),
        '/about':(context)=>About(),
        '/login':(context)=>login(),
        '/navbar':(context)=>Navbar()
      },
       home:Splashscreen(),
    );
  }
}




