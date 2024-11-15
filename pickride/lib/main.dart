import 'package:flutter/material.dart';
import 'package:pickride/ui/onboarding_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Hello',
      home: OnboardingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}


