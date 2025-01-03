import 'package:flutter/material.dart';
import 'package:pickride/ui/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Booking {
  String id;
  String fullName;
  String phoneNumber;
  String date;
  String time;
  String destination;
  String status;
  bool isRead;

  Booking({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.date,
    required this.time,
    required this.destination,
    String? status,
    this.isRead = false,
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
      isRead: json['is_read'] ?? false,
    );
  }
}

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalEntries;
  final int entriesPerPage;
  final Function(int) onPageChanged;

  const PaginationControls({
    Key? key,
    required this.currentPage,
    required this.totalEntries,
    required this.entriesPerPage,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalPages = (totalEntries / entriesPerPage).ceil();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text('Showing'),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Text('$entriesPerPage'),
                    const Icon(Icons.arrow_drop_down, size: 20),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text('of $totalEntries entries'),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: currentPage > 1
                    ? () => onPageChanged(currentPage - 1)
                    : null,
                style: IconButton.styleFrom(
                  backgroundColor:
                      currentPage > 1 ? Colors.blue : Colors.grey.shade200,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: currentPage < totalPages
                    ? () => onPageChanged(currentPage + 1)
                    : null,
                style: IconButton.styleFrom(
                  backgroundColor: currentPage < totalPages
                      ? Colors.blue
                      : Colors.grey.shade200,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
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
  bool _isLoggingOut = false;
  int _currentPage = 1;
  final int _entriesPerPage = 10;

  int get _bookingsCount =>
      _filteredBookings.where((booking) => !booking.isRead).length;

  List<Booking> get _unreadBookings {
    return _filteredBookings.where((booking) => !booking.isRead).toList();
  }

  List<Booking> get _readBookings {
    return _filteredBookings.where((booking) => booking.isRead).toList();
  }

  List<Booking> get _paginatedBookings {
    // Sort bookings to put unread ones first
    final sortedBookings = List<Booking>.from(_filteredBookings)
      ..sort((a, b) {
        if (a.isRead == b.isRead) return 0;
        return a.isRead ? 1 : -1; // Push read bookings to bottom
      });

    final startIndex = (_currentPage - 1) * _entriesPerPage;
    final endIndex = startIndex + _entriesPerPage;
    return sortedBookings.sublist(
      startIndex,
      endIndex > sortedBookings.length ? sortedBookings.length : endIndex,
    );
  }

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

  Future<void> _markAsRead(String bookingId) async {
    try {
      await _supabase
          .from('bookings')
          .update({'is_read': true}).eq('id', bookingId);

      // Refresh the bookings list immediately after marking as read
      await _fetchBookings();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error marking booking as read: $error')),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    setState(() => _isLoggingOut = true);
    try {
      await _supabase.auth.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginForm()),
          (route) => false,
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: $error')),
        );
      }
    }
    setState(() => _isLoggingOut = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          _isLoggingOut
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: _handleLogout,
                ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _paginatedBookings.length,
                        itemBuilder: (context, index) {
                          final booking = _paginatedBookings[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            color: booking.isRead
                                ? Colors.yellow.shade100
                                : const Color(
                                    0xFFE7FCE0), // Updated color for unread bookings
                            child: ExpansionTile(
                              onExpansionChanged: (isExpanded) async {
                                if (isExpanded && !booking.isRead) {
                                  await _markAsRead(booking.id);
                                } else if (!isExpanded) {
                                  await _fetchBookings();
                                }
                              },
                              title: Text(
                                '${booking.destination} Trip',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle:
                                  Text('${booking.date} - ${booking.time}'),
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFFE3F2FD),
                                child: Stack(
                                  children: [
                                    const Icon(Icons.card_travel,
                                        color: Colors.blue),
                                    if (!booking.isRead)
                                      Positioned(
                                        right: -2,
                                        top: -2,
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              children: [
                                ListTile(
                                  title: const Text('Name'),
                                  subtitle: Text(booking.fullName),
                                ),
                                ListTile(
                                  title: const Text('Phone'),
                                  subtitle: Text(booking.phoneNumber),
                                ),
                                ListTile(
                                  title: const Text('Location'),
                                  subtitle: Text(booking.destination),
                                ),
                                ListTile(
                                  title: const Text('Status'),
                                  subtitle: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: booking.status == 'Confirmed'
                                          ? Colors.green
                                          : booking.status == 'Canceled'
                                              ? Colors.red
                                              : Colors.blue,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      booking.status,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    PaginationControls(
                      currentPage: _currentPage,
                      totalEntries: _filteredBookings.length,
                      entriesPerPage: _entriesPerPage,
                      onPageChanged: (page) =>
                          setState(() => _currentPage = page),
                    ),
                  ],
                ),
    );
  }
}
