import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Booking {
  String id;
  String fullName;
  String phoneNumber;
  String date;
  String time;
  String destination;
  String status;

  Booking({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.date,
    required this.time,
    required this.destination,
    String? status,
  }) : status = status ?? 'Pending';

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      date: json['booking_date'] ?? '',
      time: json['booking_time'] ?? '',
      destination: json['destination'] ?? '',
      status: json['status'] ?? 'Pending',
    );
  }
}

class BookingDataTableSource extends DataTableSource {
  final List<Booking> bookings;

  BookingDataTableSource(this.bookings);

  @override
  DataRow? getRow(int index) {
    if (index >= bookings.length) return null;
    final booking = bookings[index];

    return DataRow(cells: [
      DataCell(Text('${index + 1}')),
      DataCell(Text(booking.fullName)),
      DataCell(Text(booking.phoneNumber)),
      DataCell(Text(booking.date)),
      DataCell(Text(booking.time)),
      DataCell(Text(booking.destination)),
      DataCell(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: booking.status == 'Confirmed'
                ? Colors.green
                : booking.status == 'Canceled'
                    ? Colors.red
                    : Colors.blue,
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Text(
            booking.status,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => bookings.length;

  @override
  int get selectedRowCount => 0;
}

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  _DriverDashboardState createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Booking> _filteredBookings = [];
  bool _isLoading = true;
  String? _error;
  int _bookingsCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
    _setupRealtimeSubscription();
  }

  Future<void> _fetchBookings() async {
    try {
      setState(() => _isLoading = true);

      final response =
          await _supabase.from('bookings').select().eq('status', 'Confirmed');

      final List<Map<String, dynamic>> data =
          List<Map<String, dynamic>>.from(response);

      setState(() {
        _bookingsCount = data.length;
        _filteredBookings =
            data.map((booking) => Booking.fromJson(booking)).toList();
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  void _setupRealtimeSubscription() {
    _supabase.from('bookings').stream(primaryKey: ['id']).listen((data) {
      if (mounted) {
        _fetchBookings();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A395D),
      appBar: AppBar(
        backgroundColor: Colors.green.shade300,
        title: const Text('Driver Dashboard'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {},
              ),
              if (_bookingsCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      '$_bookingsCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: PaginatedDataTable(
                            columns: const [
                              DataColumn(label: Text('#')),
                              DataColumn(label: Text('Names')),
                              DataColumn(label: Text('Phone')),
                              DataColumn(label: Text('Date')),
                              DataColumn(label: Text('Time')),
                              DataColumn(label: Text('Destination')),
                              DataColumn(label: Text('Status')),
                            ],
                            source: BookingDataTableSource(_filteredBookings),
                            rowsPerPage: 5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

