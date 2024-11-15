import 'package:flutter/material.dart';

class OrderForm extends StatefulWidget {
  const OrderForm({Key? key}) : super(key: key);

  @override
  _OrderFormState createState() => _OrderFormState();
}

class _OrderFormState extends State<OrderForm> {
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _costController = TextEditingController();

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
  final List<String> _carTypes = [
    'PICNIC',
    'VOITURE',
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
        elevation: 0,
        title: const Text(
          'Book a Ride',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
           
            _buildTextField('Full Name'),
            const SizedBox(height: 10),
            _buildTextField('Phone number'),
            const SizedBox(height: 10),
            _buildTextField('Email Address'),
            const SizedBox(height: 10),
            _buildDropdownTimePicker(),
            const SizedBox(height: 10),
            _buildDateField(),
            const SizedBox(height: 10),
            _buildDestinationField(),
            const SizedBox(height: 10),
            _buildCarTypeDropdown(),
            const SizedBox(height: 10),
            _buildTextField('Cost',
                controller: _costController, readOnly: true),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildButton('Submit', Colors.green, () {}),
                const SizedBox(width: 6),
                _buildButton('Cancel', Colors.red, () {
                  Navigator.pop(context);
                }),
              ],
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.only(bottom: 2.0),
              child: Column(
                children: [
                  Text('Joyce Mutoni',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
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

  Widget _buildTextField(String hintText,
      {TextEditingController? controller, bool readOnly = false}) {
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

  Widget _buildDateField() {
    return TextField(
      controller: _dateController,
      readOnly: true,
      decoration: const InputDecoration(
        hintText: 'Select Date',
        hintStyle: TextStyle(color: Colors.white),
      ),
      style: const TextStyle(color: Colors.white),
      onTap: () => _selectDate(context),
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

 Widget _buildCarTypeDropdown() {
  return Align(
    alignment: Alignment.centerLeft,
    child: Flexible(
      child: SizedBox(
       
        child: DropdownButtonFormField<String>(
          value: _selectedCarType,
          hint: const Text(
            'SELECT CAR TYPE',
            style: TextStyle(color: Colors.grey),
          ),
          items: _carTypes
              .map((carType) => DropdownMenuItem(
                    value: carType,
                    child: Text(carType),
                  ))
              .toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedCarType = newValue;
            });
          },
          decoration: const InputDecoration(
            isDense: true, // Add this line to reduce vertical padding
            contentPadding: EdgeInsets.all(8), // Adjust padding if needed
          ),
          dropdownColor: Colors.blueGrey[900],
          style: const TextStyle(color: Colors.white),
        ),
      ),
    ),
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
      items: times
          .map((value) => DropdownMenuItem(value: value, child: Text(value)))
          .toList(),
      onChanged: (newValue) => setState(() => _selectedTime = newValue),
    );
  }

  Widget _buildButton(String label, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.3,
      height: 30,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: const RoundedRectangleBorder(), // Removed border radius
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.white),
        ),
      ),
    );
  }
}
