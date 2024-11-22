import 'package:flutter/material.dart';
import 'package:pickride/auth/CarsListScreen.dart';
import 'package:pickride/auth/CreateUserAccount.dart';
import 'package:pickride/auth/UserListScreen.dart';
import 'package:pickride/auth/addCar.dart';
import 'package:pickride/auth/booking.dart';
import 'package:pickride/ui/onboarding_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() => runApp(AdminPage());

class AdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        drawer: AppDrawer(),
        body: AdminDashboard(),
      ),
    );
  }
}

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade300, Colors.blueAccent.shade200],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Top Row with Menu Icon and Dashboard Text
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Admin Dashboard',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Icon(
              Icons.check_circle,
              size: 70,
              color: Colors.white,
            ),
            const SizedBox(height: 90),
            const Text(
              'Welcome!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BookingListScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 40.0),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                  ),
                ),
                child: const Text(
                  'Booked Car',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const Spacer(),
            const Text(
              'Joyce Mutoni\n©2024',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  Future<void> _handleLogout(BuildContext context) async {
    try {
      bool? shouldLogout = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        },
      );

      if (shouldLogout != true) return;

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Perform logout
      await Supabase.instance.client.auth.signOut();

      Navigator.pop(context); // Remove loading indicator

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logged out successfully'),
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate to onboarding screen and clear navigation stack
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        (route) => false,
      );

    } catch (error) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error during logout. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: 100,
            color: Colors.blue,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: const Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.book_online, color: Colors.blue),
            title: const Text('Booking'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BookingListScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.car_rental, color: Colors.blue),
            title: const Text('List of Car'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CarsListScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.add_box, color: Colors.blue),
            title: const Text('Add Car'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddCarScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.person_add, color: Colors.blue),
            title: const Text('Register User'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateUserAccountScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.people, color: Colors.blue),
            title: const Text('List of User'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserListScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () => _handleLogout(context),
          ),
        ],
      ),
    );
  }
}
