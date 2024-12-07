import 'package:flutter/material.dart';
import 'package:pickride/auth/admin.dart';
import 'package:pickride/ui/login.dart';
import 'package:pickride/ui/order.dart';
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
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PICKRIDE',
      home: const OnboardingScreen(),
      routes: {
        '/admin': (context) => AdminPage(),  // Defined route for Admin page
        '/login': (context) => const LoginForm(),
        '/signup': (context) => const SignUpForm(),
         '/order': (context) => OrderForm(),
         
      },
      onGenerateRoute: (settings) {
        // Handle specific named routes
        if (settings.name == '/admin') {
          return MaterialPageRoute(builder: (context) => AdminPage());
        }
        return null;  // Return null if no matching route found
      },
      onUnknownRoute: (settings) {
        // Fallback page when the route is not found
        return MaterialPageRoute(builder: (context) => const NotFoundPage());
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

// NotFoundPage widget definition
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: const Center(child: Text('Sorry, this page does not exist!')),
    );
  }
}
