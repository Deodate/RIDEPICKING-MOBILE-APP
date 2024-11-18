import 'package:flutter/material.dart';
import 'package:pickride/ui/onboarding_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PickRide Booking',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const OrderForm(),
    );
  }
}

class OrderForm extends StatefulWidget {
  const OrderForm({Key? key}) : super(key: key);

  @override
  _OrderFormState createState() => _OrderFormState();
}

class _OrderFormState extends State<OrderForm> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;

  double _cost = 0.0;
  String? _selectedTime;
  String? _selectedCarType;

  // Sample destinations with distances
  final List<Map<String, dynamic>> _destinations = [
    {"name": "Kigali Genocide Memorial", "distance_km": 5.0},
    {"name": "Kimironko Market", "distance_km": 7.2},
    {"name": "Kigali Convention Center", "distance_km": 4.3},
    {"name": "Remera", "distance_km": 2.0},
  ];

  // Car types for dropdown
  final List<String> _carTypes = ['PICNIC', 'VOITURE'];

  Future<void> _saveBookings() async {
    final fullName = _fullNameController.text.trim();
    final phoneNumber = _phoneNumberController.text.trim();
    final emailAddress = _emailController.text.trim();
    final bookingDate = _dateController.text.isNotEmpty
        ? DateTime.parse(_dateController.text)
        : null;
    final destination = _destinationController.text.trim();
    final bookingTime = _selectedTime;
    final cost = double.tryParse(_costController.text.replaceAll(' RWF', ''));

    if (fullName.isEmpty || phoneNumber.isEmpty || bookingTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      await _supabase.from('bookings').insert({
        'full_name': fullName,
        'phone_number': phoneNumber,
        'email_address': emailAddress,
        'booking_time': bookingTime,
        'booking_date': bookingDate?.toIso8601String(),
        'destination': destination,
        'cost': cost,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Car ordering submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Reset form
        _fullNameController.clear();
        _phoneNumberController.clear();
        _emailController.clear();
        _destinationController.clear();
        _dateController.clear();
        _costController.clear();
        setState(() {
          _selectedTime = null;
          _selectedCarType = null;
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving booking: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _destinationController.addListener(_onDestinationChanged);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _destinationController.dispose();
    _dateController.dispose();
    _costController.dispose();
    super.dispose();
  }

  void _onDestinationChanged() {
    if (_destinationController.text.isNotEmpty) {
      _calculateCost(_destinationController.text);
    }
  }

  void _calculateCost(String destination) {
    try {
      final selectedDestination = _destinations.firstWhere(
        (dest) =>
            dest['name'].toLowerCase().contains(destination.toLowerCase()),
        orElse: () => {'name': 'Unknown', 'distance_km': 0.0},
      );

      final distance = selectedDestination['distance_km'];
      final cost = distance * 500;

      setState(() {
        _cost = cost;
        _costController.text = '${_cost.toStringAsFixed(2)} RWF';
      });
    } catch (e) {
      _showErrorDialog('Error calculating cost: ${e.toString()}');
      setState(() {
        _cost = 0.0;
        _costController.text = '';
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A395D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A395D),
        title: const Text(
          'Book a Ride',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildTextField('Full Name', controller: _fullNameController),
            const SizedBox(height: 10),
            _buildTextField('Phone number', controller: _phoneNumberController),
            const SizedBox(height: 10),
            _buildTextField('Email Address', controller: _emailController),
            const SizedBox(height: 10),
            _buildDropdownTimePicker(),
            const SizedBox(height: 10),
            _buildDateField(),
            const SizedBox(height: 10),
            _buildDestinationField(),
            const SizedBox(height: 10),
            _buildCarTypeDropdown(),
            const SizedBox(height: 10),
            _buildTextField('0.00',
                controller: _costController, readOnly: true),
            const SizedBox(height: 20),
            Row(
              children: [
                Spacer(), // This takes up all available space and pushes the button to the right
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.green, // Background color for the Save button
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.zero, // Set border radius to zero
                    ),
                  ),
                  onPressed:
                      _saveBookings, // Ensure the appropriate function is called
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Save',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
                const SizedBox(width: 16.0), // Spacer between the buttons
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.red, // Background color for the Cancel button
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.zero, // Set border radius to zero
                    ),
                  ),
                  onPressed: () {
                    // Navigate to the OnboardingScreen when the Cancel button is pressed
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => OnboardingScreen()),
                    );
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label,
      {TextEditingController? controller, bool readOnly = false}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      style:
          const TextStyle(color: Colors.white), // Set input text color to white
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
            color: Colors.white), // Set placeholder text color to white
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
              color: Colors.white), // Set the border color to white (optional)
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
              color: Colors.white), // Set the border color to white (optional)
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return TextField(
      controller: _dateController,
      readOnly: true,
      decoration: const InputDecoration(
        hintText: 'Select Date',
        hintStyle:
            TextStyle(color: Colors.white), // Set the hint text color to white
      ),
      onTap: () => _selectDate(context),
    );
  }

  Widget _buildDestinationField() {
    return TextField(
      controller: _destinationController,
      style: const TextStyle(
          color: Colors.white), // Set the input text color to white
      decoration: const InputDecoration(
        hintText: 'Enter Destination',
        hintStyle:
            TextStyle(color: Colors.white), // Set the hint text color to white
      ),
    );
  }

  Widget _buildCarTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCarType,
      hint: const Text(
        'Select Car Type', // Placeholder text
        style: TextStyle(
            color: Colors.white), // Set the placeholder text color to white
      ),
      items: _carTypes
          .map((carType) =>
              DropdownMenuItem(value: carType, child: Text(carType)))
          .toList(),
      onChanged: (newValue) => setState(() => _selectedCarType = newValue),
    );
  }

  Widget _buildDropdownTimePicker() {
    List<String> times = List.generate(48, (index) {
      final hour = index ~/ 2;
      final minute = (index % 2) * 30;
      final period = hour < 12 ? 'AM' : 'PM';
      final displayHour = hour % 12 == 0 ? 12 : hour % 12;
      return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
    });

    return DropdownButtonFormField<String>(
      value: _selectedTime, // Make sure to define _selectedTime
      hint: const Text(
        'Select Time', // Placeholder text
        style: TextStyle(
            color: Colors.white), // Set the placeholder text color to white
      ),
      items: times
          .map((time) => DropdownMenuItem(value: time, child: Text(time)))
          .toList(),
      onChanged: (newValue) => setState(() => _selectedTime = newValue),
    );
  }
}
