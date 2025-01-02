import 'package:flutter/material.dart';
import 'package:pickride/ui/onboarding_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Driver {
  String id;
  String fullName;
  String phoneNumber;
  String date;
  String time;
  String destination;
  String status;
  String? assignedDriverId;
  String? assignedDriverName;

  Driver({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.date,
    required this.time,
    required this.destination,
    String? status,
    this.assignedDriverId,
    this.assignedDriverName,
  }) : status = status ?? 'Pending';

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      date: json['booking_date'] ?? '',
      time: json['booking_time'] ?? '',
      destination: json['destination'] ?? '',
      status: json['status'] ?? 'Pending',
      assignedDriverId: json['assigned_driver_id'],
      assignedDriverName: json['assigned_driver_name'],
    );
  }
}

class DriverUser {
  String id;
  String fullName;
  String telephone;
  bool isAvailable;
  int currentBookings;

  DriverUser({
    required this.id,
    required this.fullName,
    required this.telephone,
    this.isAvailable = true,
    this.currentBookings = 0,
  });

  factory DriverUser.fromJson(Map<String, dynamic> json) {
    return DriverUser(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      telephone: json['telephone'] ?? '',
      isAvailable: json['is_available'] ?? true,
      currentBookings: json['current_bookings'] ?? 0,
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
  bool _isLoading = true;
  String? _error;
  List<Driver> _bookings = [];
  List<Driver> _filteredBookings = [];
  List<DriverUser> _availableDrivers = [];
  String _searchQuery = '';
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await Future.wait([
        _fetchAvailableDrivers(),
        _fetchBookings(),
      ]);
      await _assignDriversToBookings();
    } catch (error) {
      setState(() {
        _error = 'Failed to initialize data: ${error.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchAvailableDrivers() async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('role', 'Driver')
          .eq('is_available', true);

      final List<Map<String, dynamic>> data =
          List<Map<String, dynamic>>.from(response);

      setState(() {
        _availableDrivers = data.map((user) => DriverUser.fromJson(user)).toList();
      });
    } catch (error) {
      throw Exception('Failed to fetch drivers: ${error.toString()}');
    }
  }

   Future<void> _fetchBookings() async {
    try {
      final response = await _supabase
          .from('bookings')
          .select()
          .eq('status', 'Confirmed')
          .filter('assigned_driver_id', 'is', null); 

      final List<Map<String, dynamic>> data =
          List<Map<String, dynamic>>.from(response);

      final List<Driver> fetchedBookings = data.map((booking) {
        return Driver.fromJson(booking);
      }).toList();

      setState(() {
        _bookings = fetchedBookings;
        _filteredBookings = fetchedBookings;
      });
    } catch (error) {
      throw Exception('Failed to fetch bookings: ${error.toString()}');
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

  Future<void> _assignDriversToBookings() async {
    try {
      for (var booking in _bookings) {
        // Find the most suitable driver (least number of current bookings)
        if (_availableDrivers.isEmpty) continue;
        
        final availableDriver = _availableDrivers.reduce((curr, next) =>
            curr.currentBookings <= next.currentBookings ? curr : next);

        // Update booking with assigned driver
        await _supabase.from('bookings').update({
          'assigned_driver_id': availableDriver.id,
          'assigned_driver_name': availableDriver.fullName,
          'status': 'Assigned'
        }).eq('id', booking.id);

        // Update driver's booking count
        await _supabase.from('users').update({
          'current_bookings': availableDriver.currentBookings + 1,
          'is_available': availableDriver.currentBookings + 1 < 3 // Limit to 3 bookings per driver
        }).eq('id', availableDriver.id);

        // Update local state
        setState(() {
          booking.assignedDriverId = availableDriver.id;
          booking.assignedDriverName = availableDriver.fullName;
          booking.status = 'Assigned';
          
          // Update driver's availability
          availableDriver.currentBookings++;
          availableDriver.isAvailable = availableDriver.currentBookings < 3;
          
          // Remove driver from available list if they've reached the limit
          if (!availableDriver.isAvailable) {
            _availableDrivers.remove(availableDriver);
          }
        });
      }
    } catch (error) {
      throw Exception('Failed to assign drivers: ${error.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF0A395D),
        leading: IconButton(
          icon: const Icon(Icons.lock_outline, color: Colors.white),
          onPressed: () => _handleLogout(context),
        ),
        title: const Text(
          'BOOKING LIST',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () {
                  // Handle notification click
                },
              ),
              if (_filteredBookings.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      '${_filteredBookings.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 10),
          _buildSearchBar(),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _horizontalScrollController,
              child: SizedBox(
                width: 800,
                child: PaginatedDataTable(
                  headingRowColor: WidgetStateProperty.resolveWith(
                      (states) => const Color(0xFFe2e3e5)),
                  columns: const [
                    DataColumn(
                        label:
                            Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Customer',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Phone',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label:
                            Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label:
                            Text('Time', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Destination',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Assigned Driver',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Status',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  source: BookingDataTableSource(_filteredBookings),
                  rowsPerPage: 5,
                  showCheckboxColumn: false,
                  columnSpacing: 20,
                  horizontalMargin: 10,
                  header: Container(
                    padding: const EdgeInsets.all(8.0),
                    color: Colors.blue,
                    child: const Text(
                      'BOOKINGS WITH ASSIGNED DRIVERS',
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
          ),
          const SizedBox(height: 20),
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
    );
  }

  Widget _buildSearchBar() {
    return Align(
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
    );
  }
}

class BookingDataTableSource extends DataTableSource {
  final List<Driver> bookings;

  BookingDataTableSource(this.bookings);

  @override
  DataRow? getRow(int index) {
    if (index >= bookings.length) return null;
    final booking = bookings[index];

    return DataRow(
      cells: [
        DataCell(Text('${index + 1}')),
        DataCell(Text(booking.fullName)),
        DataCell(Text(booking.phoneNumber)),
        DataCell(Text(booking.date)),
        DataCell(Text(booking.time)),
        DataCell(Text(booking.destination)),
        DataCell(Text(booking.assignedDriverName ?? 'Not assigned')),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: _getStatusColor(booking.status),
              borderRadius: BorderRadius.circular(4.0),
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'assigned':
        return Colors.green;
      case 'confirmed':
        return Colors.blue;
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => bookings.length;

  @override
  int get selectedRowCount => 0;
}