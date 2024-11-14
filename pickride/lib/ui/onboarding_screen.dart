import 'package:flutter/material.dart';
import 'package:pickride/ui/login.dart';
import 'package:pickride/ui/signupForm.dart';
import 'package:pickride/ui/order.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A395D), // Dark blue background
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      drawer: Drawer(
        child: SizedBox(
          width: MediaQuery.of(context).size.width *
              0.6, // Reduce width to 90% of the screen
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFF0A395D),
                ),
                child: Text(
                  'Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_add),
                title: const Text('Sign up'),
                onTap: () {
                  // Navigate to the SignUp page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpForm()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.login),
                title: const Text('Login'),
                onTap: () {
                  // Navigate to the SignUp page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginForm()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Ride',
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Picking',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 50),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3072EA),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              // Navigate to the Order page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OrderForm()),
              );
            },
            child: const Text(
              'Order Now',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.only(bottom: 20.0),
            child: Column(
              children: [
                Text(
                  'Joyce Mutoni',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  '@2024',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
