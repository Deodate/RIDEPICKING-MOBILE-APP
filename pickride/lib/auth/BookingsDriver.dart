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
  String car_type;
  String status;

  Booking({
    required this.id,
    required this.fullName,
    required this.date,
    required this.time,
     required this.car_type,
    required this.destination,
    String? status,
  }) : status = status ?? 'Pending';

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      date: json['booking_date'] ?? '',
      time: json['booking_time'] ?? '',
      car_type: json['car_type'] ?? '',
      destination: json['destination'] ?? '',
      status: json['status'] ?? 'Pending',
    );
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
  int _currentPage = 1;
  final int _itemsPerPage = 5;

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

      final response = await _supabase.from('bookings').select().eq('status', 'Confirmed');

      final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(response);

      final List<Booking> fetchedBookings = data.map((booking) {
        return Booking.fromJson(booking);
      }).toList();

      final currentDate = DateTime.now();

      fetchedBookings.sort((a, b) {
        final dateA = DateTime.parse(a.date);
        final dateB = DateTime.parse(b.date);

        if (dateA.isAtSameMomentAs(currentDate)) return -1;
        if (dateB.isAtSameMomentAs(currentDate)) return 1;

        return dateA.compareTo(dateB);
      });

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
              (booking.id.toLowerCase().contains(query.toLowerCase()) ||
              booking.fullName.toLowerCase().contains(query.toLowerCase()) ||
              booking.destination.toLowerCase().contains(query.toLowerCase()) ||
              booking.date.toLowerCase().contains(query.toLowerCase())) &&
              booking.status == 'Confirmed')
          .toList();
      _currentPage = 1; // Reset to first page when filtering
    });
  }

  List<Booking> _getPaginatedBookings() {
    int startIndex = (_currentPage - 1) * _itemsPerPage;
    int endIndex = startIndex + _itemsPerPage;
    return _filteredBookings.sublist(
      startIndex, 
      endIndex > _filteredBookings.length ? _filteredBookings.length : endIndex
    );
  }

  int get _totalPages => (_filteredBookings.length / _itemsPerPage).ceil();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A395D),
        title: const Text(
          'CONFIRMED BOOKINGS DRIVER',
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
                    child: _filteredBookings.isEmpty
                        ? Center(
                            child: Text(
                              'No confirmed bookings found',
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('#')),
                                DataColumn(label: Text('Names')),
                                DataColumn(label: Text('Date')),
                                DataColumn(label: Text('Time')),
                                DataColumn(label: Text('Destination')),
                                DataColumn(label: Text('Car Type')),
                                DataColumn(label: Text('Booking')),
                              ],
                              rows: _getPaginatedBookings().asMap().entries.map((entry) {
                                int index = entry.key + 1 + ((_currentPage - 1) * _itemsPerPage);
                                Booking booking = entry.value;
                                return DataRow(cells: [
                                  DataCell(Text(index.toString())),
                                  DataCell(Text(booking.fullName)),
                                  DataCell(Text(booking.date)),
                                  DataCell(Text(booking.time)),
                                  DataCell(Text(booking.destination)),
                                  DataCell(Text(booking.car_type)),
                                  DataCell(Text(booking.status)),
                                ]);
                              }).toList(),
                            ),
                          ),
                  ),
                  if (_filteredBookings.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: _currentPage > 1 
                            ? () => setState(() { _currentPage--; }) 
                            : null,
                        ),
                        Text('Page $_currentPage of $_totalPages'),
                        IconButton(
                          icon: Icon(Icons.arrow_forward),
                          onPressed: _currentPage < _totalPages 
                            ? () => setState(() { _currentPage++; }) 
                            : null,
                        ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }
}