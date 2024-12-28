import 'package:flutter/material.dart';
import 'package:pickride/ui/onboarding_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Booking {
  String id;
  String passengerId;
  String passengerName;
  String pickupLocation;
  String destination;
  String pickupTime;
  String status;
  String carModel;
  
  Booking({
    required this.id,
    required this.passengerId,
    required this.passengerName,
    required this.pickupLocation,
    required this.destination,
    required this.pickupTime,
    required this.status,
    required this.carModel,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    final users = json['users'] as Map<String, dynamic>?;
    final cars = json['cars'] as Map<String, dynamic>?;
    
    return Booking(
      id: json['id'] ?? '',
      passengerId: json['passenger_id'] ?? '',
      passengerName: users?['full_name'] ?? 'Unknown',
      pickupLocation: json['pickup_location'] ?? '',
      destination: json['destination'] ?? '',
      pickupTime: json['pickup_time']?.toString() ?? '',
      status: json['status'] ?? 'Pending',
      carModel: cars?['model'] ?? 'Unknown',
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
  bool _hasUnreadNotifications = false;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _setupRealtimeSubscription();
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

  Future<void> _fetchConfirmedBookings() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('No user logged in');
        return;
      }

      print('Fetching bookings for driver: ${user.id}');

      final response = await _supabase
          .from('bookings')
          .select('''
            id,
            passenger_id,
            pickup_location,
            destination,
            pickup_time,
            status,
            cars (
              id,
              model
            ),
            users!bookings_passenger_id_fkey (
              id,
              full_name
            )
          ''')
          .eq('assigned_driver_id', user.id)
          .eq('status', 'Confirmed');

      print('Fetched response: $response');

      if (response == null) {
        print('No response from database');
        setState(() => _confirmedBookings = []);
        return;
      }

      final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(response);
      final bookings = data.map((booking) => Booking.fromJson(booking)).toList();
      
      print('Parsed bookings: ${bookings.length}');

      if (mounted) {
        setState(() => _confirmedBookings = bookings);
      }
    } catch (error) {
      print('Error in _fetchConfirmedBookings: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading bookings: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
      throw error;
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

      await _supabase.auth.signOut();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during logout: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
                      child: Card(
                        margin: const EdgeInsets.all(16),
                        child: _confirmedBookings.isEmpty
                            ? const Center(
                                child: Text('No confirmed bookings found'),
                              )
                            : SingleChildScrollView(
                                child: PaginatedDataTable(
                                  columns: const [
                                    DataColumn(label: Text('Passenger')),
                                    DataColumn(label: Text('Pickup')),
                                    DataColumn(label: Text('Destination')),
                                    DataColumn(label: Text('Time')),
                                    DataColumn(label: Text('Car')),
                                    DataColumn(label: Text('Status')),
                                  ],
                                  source: DriverBookingDataSource(_confirmedBookings),
                                  rowsPerPage: 8,
                                  showFirstLastButtons: true,
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

    return DataRow(
      cells: [
        DataCell(Text(booking.passengerName)),
        DataCell(Text(booking.pickupLocation)),
        DataCell(Text(booking.destination)),
        DataCell(Text(booking.pickupTime)),
        DataCell(Text(booking.carModel)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              booking.status,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => bookings.length;

  @override
  int get selectedRowCount => 0;
}