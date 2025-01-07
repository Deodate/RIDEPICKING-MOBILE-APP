import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:email_validator/email_validator.dart';
import 'package:pickride/ui/login.dart';
import 'package:pickride/ui/onboarding_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _fullNameController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _roleController = TextEditingController();
  // final _driverController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';

  final List<String> _roles = ['Administration', 'Driver'];
  List<String> _filteredRoles = [];
  final List<String> _drivers = ['John Doe', 'Jane Smith', 'Bob Johnson'];
  List<String> _filteredDrivers = [];

  @override
  void initState() {
    super.initState();
    _filteredRoles = _roles;
    _filteredDrivers = _drivers;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _roleController.dispose();
    // _driverController.dispose();
    super.dispose();
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // New method to validate full name
  bool _isValidFullName(String fullName) {
    // Check if the full name contains exactly two words
    final parts = fullName.split(' ');

    // Ensure there are exactly two names
    if (parts.length != 2) {
      return false;
    }

    // Check that both names contain only alphabetic characters
    return parts.every((name) => RegExp(r'^[a-zA-Z]+$').hasMatch(name));
  }

  bool _validateForm() {
    if (_fullNameController.text.trim().isEmpty ||
        _telephoneController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _confirmPasswordController.text.trim().isEmpty ||
        _roleController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'All fields are required');
      return false;
    }

    // New full name validation
    if (!_isValidFullName(_fullNameController.text.trim())) {
      setState(() => _errorMessage =
          'Full name must contain two names with only alphabetic characters');
      return false;
    }

    if (!EmailValidator.validate(_emailController.text.trim())) {
      setState(() => _errorMessage = 'Invalid email address');
      return false;
    }

    if (!RegExp(r'^[0-9]{10,}$').hasMatch(_telephoneController.text.trim())) {
      setState(() => _errorMessage = 'Invalid telephone number');
      return false;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Passwords do not match');
      return false;
    }

    if (_passwordController.text.length < 8) {
      setState(
          () => _errorMessage = 'Password must be at least 8 characters long');
      return false;
    }

    return true;
  }

  void _filterRoles(String value) {
    setState(() {
      _filteredRoles = _roles
          .where((role) => role.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  void _filterDrivers(String value) {
    setState(() {
      _filteredDrivers = _drivers
          .where((driver) => driver.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  String _mapSupabaseError(PostgrestException error) {
    switch (error.code) {
      case '23505': // Unique constraint violation (duplicate entry)
        return 'This email or phone number is already registered. Please use a different one.';
      case '42601': // Syntax error
        return 'There was an issue with the input. Please try again.';
      default:
        return 'An error occurred. Please try again later.';
    }
  }

  Future<void> _registerUser() async {
    // Log the start of the registration process
    print('===== REGISTRATION PROCESS STARTED =====');

    // Form validation
    if (!_validateForm()) {
      print('Form Validation Failed');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Hash password
      final hashedPassword = _hashPassword(_passwordController.text);

      // Prepare user data for insertion
      final userData = {
        'full_name': _fullNameController.text.trim(),
        'telephone': _telephoneController.text.trim(),
        'email': _emailController.text.trim(),
        'password_hash': hashedPassword,
        'role': _roleController.text.trim(),
        // Optional: Add driver information if role is 'Driver'
        // 'assigned_driver': _roleController.text.trim() == 'Driver'
        //     ? _driverController.text.trim()
        //     : null,
        // Optional: Add timestamp of registration
        'created_at': DateTime.now().toIso8601String(),
      };

      // Attempt Supabase insertion
      final response = await Supabase.instance.client
          .from('users')
          .insert(userData)
          .select();

      // Log successful registration details
      print('Registration Successful');
      print('Inserted User Data: $userData');

      // Show success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration Successful!'),
          backgroundColor: Colors.green, // Set the background color to green
        ),
      );

      // Navigate to login page
      Navigator.pushReplacementNamed(context, '/login');
    } on PostgrestException catch (error) {
      // Detailed Supabase error logging
      print('Supabase Registration Error:');
      print('Error Code: ${error.code}');
      print('Error Message: ${error.message}');

      // Set user-friendly error message
      setState(() {
        _errorMessage = _mapSupabaseError(error);
      });
    } catch (error) {
      // Comprehensive unexpected error logging
      print('Unexpected Registration Error:');
      print('Error Details: ${error.toString()}');

      // Set generic error message
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again.';
      });
    } finally {
      // Ensure loading state is always turned off
      setState(() {
        _isLoading = false;
      });

      // Log end of registration process
      print('===== REGISTRATION PROCESS COMPLETED =====');
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
              'SIGN UP',
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
            _buildTextField('Full Name', _fullNameController),
            const SizedBox(height: 10),
            _buildTextField('Telephone', _telephoneController,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 10),
            _buildTextField('Email Address', _emailController,
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 10),
            _buildAutocompleteField(
                'Role', _roleController, _filteredRoles, _filterRoles),
            const SizedBox(height: 10),
            _buildTextField('Password', _passwordController, obscureText: true),
            const SizedBox(height: 10),
            _buildTextField('Confirm Password', _confirmPasswordController,
                obscureText: true),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionButton(
                  text: 'Submit',
                  color: Colors.blue,
                  onPressed: _isLoading ? null : _registerUser,
                ),
                const SizedBox(width: 6),
                 _buildActionButton(
                  text: 'Cancel',
                  color: Colors.red,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const OnboardingScreen()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 33),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'If you have an account, ',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginForm())),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 73),
            const Text('Joyce Mutoni',
                style: TextStyle(color: Colors.white, fontSize: 16)),
            const Text('@2024',
                style: TextStyle(color: Colors.white54, fontSize: 12)),
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

  Widget _buildAutocompleteField(
    String hintText,
    TextEditingController controller,
    List<String> options,
    void Function(String) onChanged,
  ) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return options.where((option) =>
            option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
      },
      onSelected: (String selection) {
        controller.text = selection;
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
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
      },
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
        child: _isLoading && text == 'Submit'
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(text,
                style: const TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }
}
