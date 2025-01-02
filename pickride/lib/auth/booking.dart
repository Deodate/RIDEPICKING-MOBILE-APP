import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: BookingListScreen(),
  ));
}

class Booking {
  String id;
  String fullName;
  String phoneNumber;
  String email;
  String date;
  String time;
  String destination;
  String cost;
  String status;

  Booking({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.date,
    required this.time,
    required this.destination,
    required this.cost,
    String? status,
  }) : status = status ?? 'Pending';

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      email: json['email_address'] ?? '',
      date: json['booking_date'] ?? '',
      time: json['booking_time'] ?? '',
      destination: json['destination'] ?? '',
      cost: (json['cost'] ?? 0.0).toString(),
      status: json['status'] ?? 'Pending',  // Fetch status from database
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

class BookingListScreen extends StatefulWidget {
  const BookingListScreen({super.key});

  @override
  _BookingListScreenState createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
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

    // Fetch bookings from Supabase
    final response = await _supabase.from('bookings').select();

    final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(response);

    final List<Booking> fetchedBookings = data.map((booking) {
      return Booking.fromJson(booking);
    }).toList();

    // Get the current date in the format used by the bookings (assuming it's 'yyyy-MM-dd')
    final currentDate = DateTime.now();

    // Sort the bookings by date, placing the current date first
    fetchedBookings.sort((a, b) {
      final dateA = DateTime.parse(a.date);
      final dateB = DateTime.parse(b.date);

      // Place current date at the start
      if (dateA.isAtSameMomentAs(currentDate)) {
        return -1; // current date should come first
      } else if (dateB.isAtSameMomentAs(currentDate)) {
        return 1;
      }

      // Otherwise, order by date
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
              booking.id.toLowerCase().contains(query.toLowerCase()) ||
              booking.fullName.toLowerCase().contains(query.toLowerCase()) ||
              booking.destination.toLowerCase().contains(query.toLowerCase()) ||
              booking.date.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _updateStatus(int index) async {
    try {
      final booking = _filteredBookings[index];
      String newStatus;
      
      // Determine new status
      if (booking.status == 'Pending') {
        newStatus = 'Confirmed';
      } else if (booking.status == 'Confirmed') {
        newStatus = 'Canceled';
      } else {
        newStatus = 'Pending';
      }

      // Update in Supabase
      await _supabase
          .from('bookings')
          .update({'status': newStatus})
          .eq('id', booking.id);

      // Update local state
      setState(() {
        booking.status = newStatus;
      });

      // Show snackbar with appropriate color
      Color bgColor;
      if (newStatus == 'Confirmed') {
        bgColor = Colors.green;
      } else if (newStatus == 'Canceled') {
        bgColor = Colors.red;
      } else {
        bgColor = Colors.blue;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking for ${booking.fullName} is now $newStatus!'),
          backgroundColor: bgColor,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(10),
        ),
      );

    } catch (error) {
      // Show error message if update fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: ${error.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(10),
        ),
      );
    }
  

    final booking = _filteredBookings[index];
    Color bgColor;

    if (booking.status == 'Confirmed') {
      bgColor = Colors.green;
    } else if (booking.status == 'Canceled') {
      bgColor = Colors.red;
    } else {
      bgColor = Colors.blue;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Booking for ',
                style: TextStyle(color: Colors.white), // Default color
              ),
              TextSpan(
                text: booking.fullName,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black), // Bold and black color
              ),
              TextSpan(
                text: ' is now ${booking.status}!',
                style: TextStyle(color: Colors.white), // Default color
              ),
            ],
          ),
        ),
        backgroundColor: bgColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A395D),
        title: const Text(
          'BOOKING LIST',
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
                      child: PaginatedDataTable(
                        headingRowColor: WidgetStateColor.resolveWith(
                            (states) => Color(0xFFe2e3e5)),
                        columns: const [
                          DataColumn(
                              label: Text('#',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Names',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Phone',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Email',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Date',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Time',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Destination',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Cost',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Status',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        source: BookingDataTableSource(
                          _filteredBookings,
                          _updateStatus,
                        ),
                        rowsPerPage: 5,
                        showCheckboxColumn: false,
                        columnSpacing: 10,
                        horizontalMargin: 3,
                        checkboxHorizontalMargin: 3,
                        header: Container(
                          color: Colors.blue,
                          padding: const EdgeInsets.all(8.0),
                          child: const Text(
                            'BOOKINGS',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    'Joyce Mutoni\n©2024',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(179, 247, 5, 5),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class BookingDataTableSource extends DataTableSource {
  final List<Booking> bookings;
  final Function(int) updateStatus;

  BookingDataTableSource(this.bookings, this.updateStatus);

  @override
  DataRow? getRow(int index) {
    if (index >= bookings.length) return null;
    final booking = bookings[index];

    return DataRow(cells: [
      DataCell(Text('${index + 1}')),
      DataCell(Text(booking.fullName)),
      DataCell(Text(booking.phoneNumber)),
      DataCell(Text(booking.email)),
      DataCell(Text(booking.date)),
      DataCell(Text(booking.time)),
      DataCell(Text(booking.destination)),
      DataCell(Text(booking.cost)),
      DataCell(
        GestureDetector(
          onTap: () => updateStatus(index),
          child: Container(
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
