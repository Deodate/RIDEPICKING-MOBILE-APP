import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingReportScreen extends StatefulWidget {
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

      if (response == null) {
        throw Exception('No data received from Supabase');
      }

      final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(response);

      // Count statuses
      final counts = {
        'Pending': 0,
        'Confirmed': 0,
        'Canceled': 0,
      };

      for (var booking in data) {
        String status = booking['status'] ?? 'Pending';
        if (counts.containsKey(status)) {
          counts[status] = counts[status]! + 1;
        }
      }

      setState(() {
        statusCounts = counts;
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
                        headingRowColor: MaterialStateColor.resolveWith(
                            (states) => Color(0xFFe2e3e5)),
                        columns: const [
                          DataColumn(
                            label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          DataColumn(
                            label: Text('Count', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                        rows: statusCounts.entries
                            .map(
                              (entry) => DataRow(
                                cells: [
                                  DataCell(Text(entry.key)),
                                  DataCell(Text(entry.value.toString())),
                                ],
                              ),
                            )
                            .toList(),
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
