import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingReportScreen extends StatefulWidget {
  const BookingReportScreen({super.key});

  @override
  _BookingReportScreenState createState() => _BookingReportScreenState();
}

class _BookingReportScreenState extends State<BookingReportScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  Map<String, int> statusCounts = {
    'Pending': 0,
    'Confirmed': 0,
    'Canceled': 0,
  };
  double totalConfirmedAmount = 0.0; // Variable to store total confirmed amount
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchStatusCounts();
  }

  Future<void> _fetchStatusCounts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Fetch bookings from Supabase
      final response = await _supabase.from('bookings').select();

      final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(response);

      // Count statuses and calculate total amount for confirmed bookings
      final counts = {
        'Pending': 0,
        'Confirmed': 0,
        'Canceled': 0,
      };

      double confirmedAmount = 0.0;

      for (var booking in data) {
        String status = booking['status'] ?? 'Pending';
        double amount = booking['cost'] ?? 0.0; // Assuming 'cost' is the amount field

        if (counts.containsKey(status)) {
          counts[status] = counts[status]! + 1;
        }

        if (status == 'Confirmed') {
          confirmedAmount += amount; // Add amount to total for confirmed
        }
      }

      setState(() {
        statusCounts = counts;
        totalConfirmedAmount = confirmedAmount;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Failed to fetch booking status: ${error.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A395D),
        title: const Text(
          'Booking Status Report',
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
                  if (_error != null)
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: DataTable(
                        headingRowColor: WidgetStateColor.resolveWith(
                            (states) => Color(0xFFe2e3e5)),
                        columns: const [
                          DataColumn(
                            label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          DataColumn(
                            label: Text('Report', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          DataColumn(
                            label: Text('AMOUNT', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                        rows: statusCounts.entries
                            .map(
                              (entry) => DataRow(
                                cells: [
                                  DataCell(Text(entry.key)),
                                  DataCell(
                                    ElevatedButton(
                                      onPressed: () {
                                        // You can handle button press if needed
                                        print('${entry.key} count: ${entry.value}');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _getStatusColor(entry.key), // Dynamic background color
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.zero, // Remove rounded corners
                                        ),
                                      ),
                                      child: Text(
                                        entry.value.toString(),
                                        style: TextStyle(
                                          color: Colors.white, // Button text color
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Display amount for each status (if needed)
                                  DataCell(Text(
                                    entry.key == 'Confirmed'
                                        ? totalConfirmedAmount.toStringAsFixed(2)
                                        : '0.00',
                                  )),
                                ],
                              ),
                            )
                            .toList()
                          ..add(DataRow(
                            cells: [
                              DataCell(Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(Text('')), // Empty cell for report
                              DataCell(Text(totalConfirmedAmount.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                          )),
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

  // Helper function to get the status color based on the status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.blue; // Blue for Pending
      case 'Confirmed':
        return Colors.green; // Green for Confirmed
      case 'Canceled':
        return Colors.red; // Red for Canceled
      default:
        return Colors.grey; // Default color
    }
  }
}
