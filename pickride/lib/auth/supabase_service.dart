import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
      home: BookingListScreen(),
    ));

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
    required this.status,
  });

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
  @override
  _BookingListScreenState createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  List<Booking> _bookings = List.generate(
    10,
    (index) => Booking(
      id: 'BK${index + 1001}',
      fullName: 'Customer $index',
      phoneNumber: '123456789$index',
      email: 'customer$index@example.com',
      date: '2024-11-${(index % 30) + 1}',
      time: '10:${(index % 60).toString().padLeft(2, '0')} AM',
      destination: 'Destination ${index % 5 + 1}',
      cost: '\FRW ${(index + 10) * 10}',
      status: 'Pending',
    ),
  );

  List<Booking> _filteredBookings = [];
  String _searchQuery = '';
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _filteredBookings = _bookings;
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

  void _updateStatus(int index) {
    setState(() {
      _filteredBookings[index].toggleStatus();
    });

    // Show a SnackBar with different colors based on the status
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
        content: Text('Booking ${booking.id} is now ${booking.status}!'),
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
      body: Padding(
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
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: PaginatedDataTable(
                  headingRowColor: MaterialStateColor.resolveWith(
                      (states) => Color(0xFFe2e3e5)),
                  columns: const [
                    DataColumn(
                        label: Text('#',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Names',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Phone',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Email',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Date',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Time',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Destination',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Cost',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Status',
                            style: TextStyle(fontWeight: FontWeight.bold))),
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
            // Page Indicator

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
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Text(
              booking.status,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    ]);
  }

  @override
  int get rowCount => bookings.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
