import 'package:flutter/material.dart';
import 'package:pickride/auth/admin.dart';
import 'package:pickride/ui/login.dart';
import 'package:pickride/ui/signupForm.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pickride/ui/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load the .env file 
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PICKRIDE',
    home: const OnboardingScreen(),
      routes: {
        '/admin': (context) => AdminPage(), // Add your AdminPage here
        '/login': (context) => const LoginForm(),
        '/signup': (context) => const SignUpForm(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}