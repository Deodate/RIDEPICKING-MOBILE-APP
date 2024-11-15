import 'package:flutter/material.dart';

class Booking {
  final String bookingId;
  final String customerName;
  final String service;
  final String date;
  final String status;

  Booking({
    required this.bookingId,
    required this.customerName,
    required this.service,
    required this.date,
    required this.status,
  });
}

class BookingListScreen extends StatefulWidget {
  @override
  _BookingListScreenState createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  List<Booking> _bookings = List.generate(
    50,
    (index) => Booking(
      bookingId: 'BK${index + 1001}',
      customerName: 'Customer $index',
      service: 'Service ${index % 5 + 1}',
      date: '2024-11-${(index % 30) + 1}',
      status: index % 2 == 0 ? 'Confirmed' : 'Pending',
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
                    prefixIcon: Icon(Icons.search),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                  ),
                  style: TextStyle(fontSize: 12),
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
                DataColumn(label: Text('Action')),
              ],
              source: BookingDataTableSource(_filteredBookings, _currentPage),
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
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.only(bottom: 20.0),
              child: Column(
                children: [
                  Text(
                    'Joyce Mutoni',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  Text('© 2024 PickRide Inc.',
                      style: TextStyle(color: Colors.black, fontSize: 12)),
                ],
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
  final int currentPage;

  BookingDataTableSource(this.bookings, this.currentPage);

  @override
  DataRow getRow(int index) {
    if (index >= bookings.length) return null as DataRow;
    final booking = bookings[index];
    return DataRow(cells: [
      DataCell(Text('${index + 1}')),
      DataCell(Text(booking.bookingId)),
      DataCell(Text(booking.customerName)),
      DataCell(Text(booking.service)),
      DataCell(Text(booking.date)),
      DataCell(Text(booking.status)),
      DataCell(Row(
        children: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              // Handle delete action
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () {
              // Handle edit action
            },
          ),
        ],
      )),
    ]);
  }

  @override
  int get rowCount => bookings.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
