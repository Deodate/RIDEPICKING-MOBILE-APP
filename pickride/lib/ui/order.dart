import 'dart:convert';
import 'package:flutter/material.dart';

class OrderForm extends StatefulWidget {
  const OrderForm({Key? key}) : super(key: key);

  @override
  _OrderFormState createState() => _OrderFormState();
}

class _OrderFormState extends State<OrderForm> {
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  double _cost = 0.0;
  String? _selectedTime;

  // Sample destinations with distances
  final List<Map<String, dynamic>> _destinations = [
    {"name": "Kigali Genocide Memorial", "distance_km": 5.0},
    {"name": "Kimironko Market", "distance_km": 7.2},
    {"name": "Kigali Convention Center", "distance_km": 4.3},
  ];

  @override
  void initState() {
    super.initState();
    _destinationController.addListener(_onDestinationChanged);
  }

  @override
  void dispose() {
    _destinationController.removeListener(_onDestinationChanged);
    _destinationController.dispose();
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
      // Find the selected destination from the list
      final selectedDestination = _destinations.firstWhere(
        (dest) => dest['name'].toLowerCase().contains(destination.toLowerCase()),
        orElse: () => {'name': 'Unknown', 'distance_km': 0.0},
      );

      final distance = selectedDestination['distance_km'];

      // Cost calculation: 500 RWF per kilometer
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A395D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A395D),
        elevation: 0,
        title: const Text(
          'BOOK A RIDE',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            _buildTextField('Full Name'),
            const SizedBox(height: 10),
            _buildTextField('WhatsApp number'),
            const SizedBox(height: 10),
            _buildTextField('Email Address'),
            const SizedBox(height: 10),
            _buildDropdownTimePicker(),
            const SizedBox(height: 10),
            _buildTextField('Date'),
            const SizedBox(height: 10),
            _buildDestinationField(),
            const SizedBox(height: 10),
            _buildTextField('Passenger'),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.3,
                child: _buildTextField('Cost', controller: _costController, readOnly: true),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildButton('Order Now', Colors.green, () {}),
                const SizedBox(width: 6),
                _buildButton('Cancel', Colors.red, () {
                  Navigator.pop(context);
                }),
              ],
            ),
            const SizedBox(height: 33),
            const Padding(
              padding: EdgeInsets.only(bottom: 20.0),
              child: Column(
                children: [
                  Text('Powered by PickRide', style: TextStyle(color: Colors.white, fontSize: 16)),
                  Text('© 2024 PickRide Inc.', style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hintText, {TextEditingController? controller, bool readOnly = false}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
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

  Widget _buildDestinationField() {
    return TextField(
      controller: _destinationController,
      decoration: const InputDecoration(
        hintText: 'Enter Destination',
        hintStyle: TextStyle(color: Colors.white),
      ),
      style: const TextStyle(color: Colors.white),
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
      value: _selectedTime,
      hint: const Text('SELECT TIME', style: TextStyle(color: Colors.grey)),
      items: times.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
      onChanged: (newValue) => setState(() => _selectedTime = newValue),
    );
  }

  Widget _buildButton(String label, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.3,
      height: MediaQuery.of(context).size.height * 0.07,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(backgroundColor: color),
        child: Text(label, style: const TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }
}
