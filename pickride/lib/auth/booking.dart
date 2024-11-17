import 'package:flutter/material.dart';

class Booking {
  String bookingId;
  String customerName;
  String service;
  String date;
  String status;

  Booking({
    required this.bookingId,
    required this.customerName,
    required this.service,
    required this.date,
    required this.status,
  });

  // Method to cycle through statuses
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
      bookingId: 'BK${index + 1001}',
      customerName: 'Customer $index',
      service: 'Service ${index % 5 + 1}',
      date: '2024-11-${(index % 30) + 1}',
      status: 'Pending', // Default status is set to 'Pending'
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
              booking.bookingId.toLowerCase().contains(query.toLowerCase()) ||
              booking.customerName.toLowerCase().contains(query.toLowerCase()) ||
              booking.service.toLowerCase().contains(query.toLowerCase()) ||
              booking.date.toLowerCase().contains(query.toLowerCase()) ||
              booking.status.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showSnackBar(BuildContext context, String message, String status) {
    Color getBackgroundColor(String status) {
      switch (status.toLowerCase()) {
        case 'confirmed':
          return Colors.green;
        case 'canceled':
          return Colors.red;
        case 'pending':
          return Colors.blue;
        default:
          return Colors.grey;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: getBackgroundColor(status),
        duration: const Duration(seconds: 2),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 170,
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
            PaginatedDataTable(
              columns: const [
                DataColumn(label: Text('#')),
                DataColumn(label: Text('Booking ID')),
                DataColumn(label: Text('Customer Name')),
                DataColumn(label: Text('Service')),
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Status')),
              ],
              source: BookingDataTableSource(
                  _filteredBookings, _updateStatus, _showSnackBar, context),
              rowsPerPage: 5,
              onPageChanged: (pageIndex) {
                setState(() {
                  _currentPage = pageIndex;
                });
              },
              showCheckboxColumn: false,
              columnSpacing: 20,
              headingRowColor: MaterialStateProperty.all(Colors.blue),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text('Page: ${_currentPage + 1}'),
            ),
          ],
        ),
      ),
    );
  }

  // Method to update status
  void _updateStatus(int index) {
    setState(() {
      _filteredBookings[index].toggleStatus();
    });
  }
}

class BookingDataTableSource extends DataTableSource {
  final List<Booking> bookings;
  final Function(int) updateStatus;
  final Function(BuildContext, String, String) showSnackBar;
  final BuildContext context;

  BookingDataTableSource(
      this.bookings, this.updateStatus, this.showSnackBar, this.context);

  @override
  DataRow? getRow(int index) {
    if (index >= bookings.length) return null;
    final booking = bookings[index];

    // Determine button color based on status
    Color getStatusColor(String status) {
      switch (status.toLowerCase()) {
        case 'confirmed':
          return Colors.green;
        case 'canceled':
          return Colors.red;
        case 'pending':
          return Colors.blue;
        default:
          return Colors.grey;
      }
    }

    return DataRow(cells: [
      DataCell(Text('${index + 1}')),
      DataCell(Text(booking.bookingId)),
      DataCell(Text(booking.customerName)),
      DataCell(Text(booking.service)),
      DataCell(Text(booking.date)),
      DataCell(
        GestureDetector(
          onTap: () {
            updateStatus(index);
            showSnackBar(context, 'Status changed to: ${bookings[index].status}', bookings[index].status);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: getStatusColor(booking.status),
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
