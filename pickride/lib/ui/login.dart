import 'package:flutter/material.dart';
import 'package:pickride/auth/DriverDashboard.dart';
import 'package:pickride/auth/admin.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

Future<void> _handleLogin() async {
  // Log the start of the login process
  print('===== LOGIN PROCESS STARTED =====');

  setState(() {
    _isLoading = true;
    _errorMessage = '';
  });

  try {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    
    // Input validation
    if (email.isEmpty || password.isEmpty) {
      throw 'Please fill in all fields';
    }

    // Hash the password to match stored hash
    final hashedPassword = _hashPassword(password);

    print('Attempting to verify credentials');
    
    // Query Supabase to check credentials
    final response = await Supabase.instance.client
        .from('users')
        .select()
        .eq('email', email)
        .eq('password_hash', hashedPassword)
        .single();

    print('Login Successful');
    
    // Determine routing based on user role
    if (response['role'] == 'Administration') {
      // Navigate to admin page
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => const AdminPage())
      );
    } else if (response['role'] == 'Driver') {
      // Navigate to driver dashboard
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => const DriverDashboard())
      );
    } else {
      // Unexpected role
      setState(() {
        _errorMessage = 'Invalid user role';
      });
      return;
    }
  
  } on PostgrestException catch (error) {
    print('Supabase Login Error:');
    print('Error Code: ${error.code}');
    print('Error Message: ${error.message}');
    
    setState(() {
      _errorMessage = 'Invalid credentials. Please try again.';
    });
  } catch (error) {
    print('Login Error: $error');
    
    setState(() {
      _errorMessage = error.toString();
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
    print('===== LOGIN PROCESS COMPLETED =====');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A395D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A395D),
        elevation: 0,
        title: const Text(
          'Welcome to Ride Picking',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              'LOGIN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            _buildTextField(
              'Email Address',
              _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            _buildTextField(
              'Password',
              _passwordController,
              obscureText: true,
            ),
            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionButton(
                  text: 'Login',
                  color: Colors.blue,
                  onPressed: _isLoading ? null : _handleLogin,
                ),
                const SizedBox(width: 6),
                _buildActionButton(
                  text: 'Cancel',
                  color: Colors.red,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 43),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Don\'t have an account? ',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/signup'),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 93),
            const Text(
              'Joyce Mutoni',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const Text(
              '@2024',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hintText,
    TextEditingController controller, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildActionButton({
    required String text,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.3,
      height: MediaQuery.of(context).size.height * 0.07,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
        child: _isLoading && text == 'Login'
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(text, style: const TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }
}