import 'package:flutter/material.dart';
import 'package:pickride/ui/onboarding_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LogoutHandler extends StatefulWidget {
  final Widget child;
  const LogoutHandler({Key? key, required this.child}) : super(key: key);

  @override
  _LogoutHandlerState createState() => _LogoutHandlerState();
}

class _LogoutHandlerState extends State<LogoutHandler> {
  bool _isLoggingOut = false;

  Future<void> handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final bool? shouldLogout = await showDialog<bool>(
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

    setState(() {
      _isLoggingOut = true;
    });

    try {
      // Log the logout attempt
      print('===== LOGOUT PROCESS STARTED =====');

      // Clear any stored session data in Supabase
      await Supabase.instance.client.auth.signOut();

      // Clear any local storage or cached data here if needed
      
      print('Logout Successful');

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out successfully'),
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate to onboarding screen and clear navigation stack
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const OnboardingScreen(),
          ),
          (route) => false, // This removes all previous routes
        );
      }

    } catch (error) {
      print('Logout Error: $error');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error during logout. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
      print('===== LOGOUT PROCESS COMPLETED =====');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// Example of a logout button that can be used in any screen
class LogoutButton extends StatelessWidget {
  final Color? color;
  
  const LogoutButton({
    Key? key,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.logout,
        color: color ?? Colors.white,
      ),
      onPressed: () {
        final logoutState = context.findAncestorStateOfType<_LogoutHandlerState>();
        logoutState?.handleLogout(context);
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
    Key? key,
    required this.title,
    this.backgroundColor = const Color(0xFF0A395D),
    this.foregroundColor = Colors.white,
  }) : super(key: key);

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