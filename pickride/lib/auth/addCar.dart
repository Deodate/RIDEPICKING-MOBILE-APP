import 'package:flutter/material.dart';
import 'package:pickride/auth/admin.dart';

class AddCarScreen extends StatefulWidget {
  @override
  _AddCarScreenState createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _carName;
  String? _carType = 'SELECT';
  String? _plack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A395D),
        title: const Text(
          'Ride Admin',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminPage()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Add Cars',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Car Name Input
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Car Name',
                  labelStyle: TextStyle(fontFamily: 'Times New Roman'),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a car name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _carName = value!;
                },
              ),
              const SizedBox(height: 16.0),

              // Car Type Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Car Type',
                  labelStyle: TextStyle(fontFamily: 'Times New Roman'),
                ),
                value: _carType,
                items: ['SELECT', 'Sedan', 'SUV', 'Hatchback']
                    .map((type) => DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                validator: (value) {
                  if (value == 'SELECT') {
                    return 'Please select a car type';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _carType = value!;
                  });
                },
              ),
              const SizedBox(height: 16.0),

              // Plack Input
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Plack',
                  labelStyle: TextStyle(fontFamily: 'Times New Roman'),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a plack';
                  }
                  return null;
                },
                onSaved: (value) {
                  _plack = value!;
                },
              ),
              const SizedBox(height: 32.0),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Blue background
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero, // No border radius
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        // Handle form submission
                        print('Car Name: $_carName');
                        print('Car Type: $_carType');
                        print('Plack: $_plack');
                        // Perform any submission logic here
                      }
                    },
                    child: const Text(
                      'Save',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Red background
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero, // No border radius
                      ),
                    ),
                    onPressed: () {
                      _formKey.currentState!.reset();
                      setState(() {
                        _carType = 'SELECT';
                      });
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
