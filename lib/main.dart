import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const TraduttoreVocaleApp());
}

class TraduttoreVocaleApp extends StatelessWidget {
  const TraduttoreVocaleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Traduttore Vocale',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
