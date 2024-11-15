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
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // Set title text color to white
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Colors.white), // Set icon color to white as well
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminPage()),
            );
          },
        ),
      ),
      body: Container(
        color: const Color.fromARGB(
            255, 4, 5, 75), // Set background color of the body
        padding: const EdgeInsets.all(16.0),
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
                  color: Colors.white, // Make title text white
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Car Name Input
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Car Name',
                labelStyle: TextStyle(
                    fontFamily: 'Times New Roman', color: Colors.white),
                hintStyle:
                    TextStyle(color: Colors.white), // Optional hint color
                enabledBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Colors.white), // White underline
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.white), // White underline when focused
                ),
              ),
              style: const TextStyle(
                  color: Colors.white), // White text in input field
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
                labelStyle: TextStyle(
                    fontFamily: 'Times New Roman', color: Colors.white),
              ),
              style: const TextStyle(
                  color: Colors.black), // White text for dropdown
              value: _carType,
              items: ['SELECT', 'Picnic', 'Voiture']
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
                labelText: 'Plate',
                labelStyle: TextStyle(
                    fontFamily: 'Times New Roman', color: Colors.white),
                hintStyle:
                    TextStyle(color: Colors.white), // Optional hint color
                enabledBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Colors.white), // White underline
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.white), // White underline when focused
                ),
              ),
              style: const TextStyle(
                  color: Colors.white), // White text in input field
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a plate';
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
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero, // No border radius
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      // Handle form submission
                      print('Car Name: $_carName');
                      print('Car Type: $_carType');
                      print('Plate: $_plack');
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
                    shape: const RoundedRectangleBorder(
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
            const Spacer(), // Pushes the footer to the bottom
            const Padding(
              padding: EdgeInsets.only(bottom: 20.0),
              child: Column(
                children: [
                  Text(
                    'Joyce Mutoni',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Text('© 2024 PickRide Inc.',
                      style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
