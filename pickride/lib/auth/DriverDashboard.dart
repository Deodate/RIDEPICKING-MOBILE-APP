import 'package:flutter/material.dart';
import 'package:pickride/ui/onboarding_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: const DriverDashboard(),
  ));
}

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

class NotificationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getDriverNotifications() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final response = await _supabase
          .from('driver_notifications')
          .select('*, bookings(*)')
          .eq('driver_id', user.id)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      print('Error fetching notifications: $error');
      return [];
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _supabase
          .from('driver_notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (error) {
      print('Error marking notification as read: $error');
      throw Exception('Failed to mark notification as read');
    }
  }
}

class BookingDataTableSource extends DataTableSource {
  final List<Booking> bookings;
  final Function(int) onStatusUpdate;

  BookingDataTableSource(this.bookings, this.onStatusUpdate);

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
        GestureDetector(
          onTap: () => onStatusUpdate(index),
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

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  _DriverDashboardState createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  final NotificationService _notificationService = NotificationService();
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _notifications = [];
  List<Booking> _confirmedBookings = [];
  List<Booking> _bookings = [];
  List<Booking> _filteredBookings = [];
  bool _hasUnreadNotifications = false;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _setupRealtimeSubscription();
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

      final currentDate = DateTime.now();

      fetchedBookings.sort((a, b) {
        final dateA = DateTime.parse(a.date);
        final dateB = DateTime.parse(b.date);

        if (dateA.isAtSameMomentAs(currentDate)) {
          return -1;
        } else if (dateB.isAtSameMomentAs(currentDate)) {
          return 1;
        }
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

  Future<void> _fetchConfirmedBookings() async {
    try {
      final response = await _supabase
          .from('bookings')
          .select()
          .eq('status', 'Confirmed');
      
      final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(response);
      
      setState(() {
        _confirmedBookings = data.map((booking) => Booking.fromJson(booking)).toList();
      });
    } catch (error) {
      setState(() => _error = error.toString());
    }
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      await Future.wait([
        _loadNotifications(),
        _fetchConfirmedBookings(),
      ]);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _updateStatus(int index) async {
    try {
      final booking = _filteredBookings[index];
      String newStatus;
      
      if (booking.status == 'Pending') {
        newStatus = 'Confirmed';
      } else if (booking.status == 'Confirmed') {
        newStatus = 'Canceled';
      } else {
        newStatus = 'Pending';
      }

      await _supabase
          .from('bookings')
          .update({'status': newStatus})
          .eq('id', booking.id);

      setState(() {
        booking.status = newStatus;
      });

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
          content: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Booking for ',
                  style: TextStyle(color: Colors.white),
                ),
                TextSpan(
                  text: booking.fullName,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                TextSpan(
                  text: ' is now ${booking.status}!',
                  style: TextStyle(color: Colors.white),
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
    } catch (error) {
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
  }

  Future<void> _loadNotifications() async {
    final notifications = await _notificationService.getDriverNotifications();
    if (mounted) {
      setState(() {
        _notifications = notifications;
        _hasUnreadNotifications =
            notifications.any((n) => !(n['is_read'] as bool));
      });
    }
  }

  void _setupRealtimeSubscription() {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    _supabase
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq('assigned_driver_id', user.id)
        .listen((List<Map<String, dynamic>> data) {
          if (mounted) {
            _fetchConfirmedBookings();
          }
        });

    _supabase
        .from('driver_notifications')
        .stream(primaryKey: ['id'])
        .eq('driver_id', user.id)
        .listen((List<Map<String, dynamic>> data) {
          if (mounted) {
            _loadNotifications();
          }
        });
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      bool? shouldLogout = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        },
      );

      if (shouldLogout != true) return;

      await Supabase.instance.client.auth.signOut();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error during logout: ${error.toString()}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _showNotifications(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _notifications.length,
            itemBuilder: (context, index) {
              final notification = _notifications[index];
              final booking = notification['bookings'];

              return ListTile(
                title: Text(notification['message']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (booking != null) ...[
                      Text('Pickup: ${booking['pickup_location']}'),
                      Text('Destination: ${booking['destination']}'),
                      Text('Time: ${booking['pickup_time']}'),
                    ],
                    Text(
                      DateTime.parse(notification['created_at'])
                          .toLocal()
                          .toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                leading: Icon(
                  Icons.circle,
                  color: notification['is_read'] ? Colors.grey : Colors.green,
                  size: 12,
                ),
                onTap: () async {
                  if (!notification['is_read']) {
                    await _notificationService
                        .markNotificationAsRead(notification['id']);
                    _loadNotifications();
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A395D),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 100,
              color: Colors.green,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const Text(
                'Driver Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.drive_eta, color: Colors.green),
              title: const Text('My Rides'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Rides view coming soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.green),
              title: const Text('Profile'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile view coming soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () => _handleLogout(context),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.green.shade300,
        title: const Text('Driver Dashboard'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () => _showNotifications(context),
              ),
              if (_hasUnreadNotifications)
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
                      minWidth: 12,
                      minHeight: 12,
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
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: $_error',
                    style: const TextStyle(color: Colors.red),
                  ),
                  ElevatedButton(
                    onPressed: _loadInitialData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade300, Colors.blueAccent.shade200],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Confirmed Bookings',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _supabase.dispose();
    super.dispose();
  }
}

class DriverBookingDataSource extends DataTableSource {
  final List<Booking> bookings;

  DriverBookingDataSource(this.bookings);

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
        GestureDetector(
          // onTap: () => updateStatus(index),
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