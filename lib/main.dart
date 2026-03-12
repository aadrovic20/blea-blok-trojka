import 'package:flutter/material.dart';
import 'package:bela_blok_trojka/screens/home_screen.dart';

void main() {
  runApp(const BelaApp());
}

class BelaApp extends StatelessWidget {
  const BelaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bela Trojka',
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF0F2F5),
      ),
    );
  }
}
