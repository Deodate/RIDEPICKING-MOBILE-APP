import 'package:flutter/material.dart';
import 'package:pickride/auth/addCar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Car {
  final String name;
  final String carType;
  final String plateNumber;
  final String id;

  Car({
    required this.name,
    required this.carType,
    required this.plateNumber,
    required this.id,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id']?.toString() ?? '',
      name: json['car_name'] ?? '',
      carType: json['car_type'] ?? '',
      plateNumber: json['plate'] ?? '',
    );
  }
}

class CarsListScreen extends StatefulWidget {
  @override
  _CarsListScreenState createState() => _CarsListScreenState();
}

class _CarsListScreenState extends State<CarsListScreen> {
  final _supabase = Supabase.instance.client;
  List<Car> _cars = [];
  List<Car> _filteredCars = [];
  String _searchQuery = '';
  int _currentPage = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCars();
  }

  Future<void> _fetchCars() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await _supabase.from('cars').select().order('car_name');

      final List<Car> fetchedCars =
          (response as List).map((car) => Car.fromJson(car)).toList();

      setState(() {
        _cars = fetchedCars;
        _filteredCars = fetchedCars;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Failed to fetch cars: ${error.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteCar(String carId) async {
    try {
      await _supabase.from('cars').delete().eq('id', carId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Car deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );

      _fetchCars(); // Refresh the list
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete car: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _filterCars(String query) {
    setState(() {
      _searchQuery = query;
      _filteredCars = _cars
          .where((car) =>
              car.name.toLowerCase().contains(query.toLowerCase()) ||
              car.carType.toLowerCase().contains(query.toLowerCase()) ||
              car.plateNumber.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A395D),
        title: const Text(
          'CARS LIST',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchCars,
          ),
        ],
      ),
      body: _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_error!, style: TextStyle(color: Colors.red)),
                  ElevatedButton(
                    onPressed: _fetchCars,
                    child: Text('Retry'),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Link-style "ADD" button
                      TextButton(
                        onPressed: () {
                          // Navigate to the AddCarScreen page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AddCarScreen()), // Ensure AddCarScreen is imported
                          );
                        },
                        child: Text(
                          'ADD',
                          style: TextStyle(
                            color: Colors
                                .white, // Blue color for the link-style text
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.green, // Green background color
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          textStyle: TextStyle(fontSize: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),

                      const SizedBox(
                          width: 10), // Space between button and search bar
                      Expanded(
                        child: Container(
                          height: 40,
                          child: TextField(
                            onChanged: _filterCars,
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
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 5),
                            ),
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : PaginatedDataTable(
                          columns: const [
                            DataColumn(label: Text('#')),
                            DataColumn(label: Text('NAME')),
                            DataColumn(label: Text('TYPE')),
                            DataColumn(label: Text('PLATE #')),
                            DataColumn(label: Text('Action')),
                          ],
                          source: CarDataTableSource(
                            _filteredCars,
                            _currentPage,
                            onDelete: _deleteCar,
                          ),
                          rowsPerPage: 5,
                          onPageChanged: (pageIndex) {
                            setState(() {
                              _currentPage = pageIndex;
                            });
                          },
                          showCheckboxColumn: false,
                          columnSpacing: 20,
                          headingRowColor:
                              MaterialStateProperty.all(Colors.blue),
                        ),
                  const SizedBox(height: 20),
                  if (!_isLoading)
                    Center(
                      child: Text('Page: ${_currentPage + 1}'),
                    ),
                ],
              ),
            ),
    );
  }
}

class CarDataTableSource extends DataTableSource {
  final List<Car> cars;
  final int currentPage;
  final Function(String) onDelete;

  CarDataTableSource(this.cars, this.currentPage, {required this.onDelete});

  @override
  DataRow getRow(int index) {
    final car = cars[index];
    return DataRow(cells: [
      DataCell(Text('${index + 1}')),
      DataCell(Text(car.name)),
      DataCell(Text(car.carType)),
      DataCell(Text(car.plateNumber)),
      DataCell(Row(
        children: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => onDelete(car.id),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () {
              // Handle edit action - You can navigate to AddCarScreen with car data
            },
          ),
        ],
      )),
    ]);
  }

  @override
  int get rowCount => cars.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
