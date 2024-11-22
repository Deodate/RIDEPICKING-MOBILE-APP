import 'package:flutter/material.dart';
import 'package:pickride/auth/CarsListScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditCarScreen extends StatefulWidget {
  final Car car;
  final Function onUpdate;

  EditCarScreen({required this.car, required this.onUpdate});

  @override
  _EditCarScreenState createState() => _EditCarScreenState();
}

class _EditCarScreenState extends State<EditCarScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;

  String? _carName;
  String? _carType;
  String? _plateNumber;

  @override
  void initState() {
    super.initState();
    // Set initial values from the passed car object
    _carName = widget.car.name;
    _carType = widget.car.carType;
    _plateNumber = widget.car.plateNumber;
  }

  Future<void> _updateCar() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Update car data in the Supabase database
        final response = await _supabase.from('cars').update({
          'car_name': _carName,
          'car_type': _carType,
          'plate': _plateNumber,
        }).eq('id', widget.car.id);

        // Check for successful update
        if (response.error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Car updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          widget.onUpdate(); // Notify parent to refresh the list

          Navigator.pop(context); // Go back after successful update
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating car: ${response.error?.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating car: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A395D),
        title: const Text(
          'Edit Car',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: const Color.fromARGB(255, 4, 5, 75),
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Edit Car Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Car Name Input
              TextFormField(
                initialValue: _carName,
                decoration: const InputDecoration(
                  labelText: 'Car Name',
                  labelStyle: TextStyle(
                    fontFamily: 'Times New Roman',
                    color: Colors.white,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
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
                value: _carType,
                decoration: const InputDecoration(
                  labelText: 'Car Type',
                  labelStyle: TextStyle(
                    fontFamily: 'Times New Roman',
                    color: Colors.white,
                  ),
                ),
                style: const TextStyle(color: Colors.black),
                onChanged: (value) {
                  setState(() {
                    _carType = value;
                  });
                },
                items: ['Picnic', 'Voiture']
                    .map((type) => DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a car type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Plate Number Input
              TextFormField(
                initialValue: _plateNumber,
                decoration: const InputDecoration(
                  labelText: 'Plate Number',
                  labelStyle: TextStyle(
                    fontFamily: 'Times New Roman',
                    color: Colors.white,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a plate number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _plateNumber = value!;
                },
              ),
              const SizedBox(height: 40),

              // Save Button
              ElevatedButton(
                onPressed: _isLoading ? null : _updateCar,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Update Car'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
