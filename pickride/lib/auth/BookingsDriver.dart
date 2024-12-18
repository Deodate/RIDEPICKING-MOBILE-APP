import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: BookingsDriver(),
  ));
}

class Booking {
  String id;
  String fullName;
  String date;
  String time;
  String destination;
  String status;

  Booking({
    required this.id,
    required this.fullName,
    required this.date,
    required this.time,
    required this.destination,
    String? status,
  }) : status = status ?? 'Pending';

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      date: json['booking_date'] ?? '',
      time: json['booking_time'] ?? '',
      destination: json['destination'] ?? '',
      status: json['status'] ?? 'Pending',
    );
  }

  void toggleStatus() {
    if (status == 'Pending') {
      status = 'Confirmed';
    } else if (status == 'Confirmed') {
      status = 'Canceled';
    } else {
      status = 'Pending';
    }
  }
}

class BookingsDriver extends StatefulWidget {
  const BookingsDriver({super.key});

  @override
  _BookingsDriverState createState() => _BookingsDriverState();
}

class _BookingsDriverState extends State<BookingsDriver> {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<Booking> _bookings = [];
  List<Booking> _filteredBookings = [];
  String _searchQuery = '';
  String? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await _supabase.from('bookings').select();

      final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(response);

      final List<Booking> fetchedBookings = data.map((booking) {
        return Booking.fromJson(booking);
      }).toList();

      setState(() {
        _bookings = fetchedBookings;
        _filteredBookings = fetchedBookings;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Failed to fetch bookings: ${error.toString()}';
        _isLoading = false;
      });
    }
  }

  void _filterBookings(String query) {
    setState(() {
      _searchQuery = query;
      _filteredBookings = _bookings
          .where((booking) =>
              booking.fullName.toLowerCase().contains(query.toLowerCase()) ||
              booking.destination.toLowerCase().contains(query.toLowerCase()) ||
              booking.date.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A395D),
        title: const Text(
          'BOOKINGS DRIVER',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 200,
                      height: 40,
                      child: TextField(
                        onChanged: _filterBookings,
                        decoration: InputDecoration(
                          labelText: 'Search',
                          prefixIcon: const Icon(Icons.search),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(color: Colors.blue),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(color: Colors.blue),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 5),
                        ),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Names')),
                          DataColumn(label: Text('Date')),
                          DataColumn(label: Text('Time')),
                          DataColumn(label: Text('Destination')),
                          DataColumn(label: Text('Status')),
                        ],
                        rows: _filteredBookings.map((booking) {
                          return DataRow(cells: [
                            DataCell(Text(booking.fullName)),
                            DataCell(Text(booking.date)),
                            DataCell(Text(booking.time)),
                            DataCell(Text(booking.destination)),
                            DataCell(Text(booking.status)),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
