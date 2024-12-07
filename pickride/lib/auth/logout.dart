import 'package:flutter/material.dart';
import 'package:pickride/ui/onboarding_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LogoutHandler extends StatefulWidget {
  final Widget child;

  const LogoutHandler({super.key, required this.child});

  @override
  _LogoutHandlerState createState() => _LogoutHandlerState();
}

class _LogoutHandlerState extends State<LogoutHandler> {
  Future<void> _handleLogout(BuildContext context) async {
    try {
      // Show confirmation dialog
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

      // Perform logout
      print('===== LOGOUT PROCESS STARTED =====');

      // Clear Supabase session
      await Supabase.instance.client.auth.signOut();

      print('Logout Successful');

      // Navigate to onboarding screen and clear navigation stack
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const OnboardingScreen(),
        ),
        (route) => false,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Logged out successfully',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      print('Logout Error: $error');

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Error during logout. Please try again.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      print('===== LOGOUT PROCESS COMPLETED =====');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// Logout button to be used on any screen
class LogoutButton extends StatelessWidget {
  final Color? color;

  const LogoutButton({
    super.key,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.logout,
        color: color ?? Colors.white,
      ),
      onPressed: () {
        final logoutState = context.findAncestorStateOfType<_LogoutHandlerState>();
        logoutState?._handleLogout(context);
      },
      tooltip: 'Logout',
    );
  }
}

// Example AppBar with logout button
class LogoutAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;
  final Color foregroundColor;

  const LogoutAppBar({
    super.key,
    required this.title,
    this.backgroundColor = const Color(0xFF0A395D),
    this.foregroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(color: foregroundColor),
      ),
      backgroundColor: backgroundColor,
      actions: [
        LogoutButton(color: foregroundColor),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
