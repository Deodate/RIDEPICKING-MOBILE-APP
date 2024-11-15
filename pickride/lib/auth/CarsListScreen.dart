import 'package:flutter/material.dart';

class Car {
  final String name;
  final String sitPlace;
  final String plateNumber;

  Car({required this.name, required this.sitPlace, required this.plateNumber});
}

class CarsListScreen extends StatefulWidget {
  @override
  _CarsListScreenState createState() => _CarsListScreenState();
}

class _CarsListScreenState extends State<CarsListScreen> {
  List<Car> _cars = List.generate(
    50,
    (index) => Car(
      name: 'Car $index',
      sitPlace: 'Sit $index',
      plateNumber: 'Plate $index',
    ),
  );

  List<Car> _filteredCars = [];
  String _searchQuery = '';
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _filteredCars = _cars;
  }

  void _filterCars(String query) {
    setState(() {
      _searchQuery = query;
      _filteredCars = _cars
          .where((car) =>
              car.name.toLowerCase().contains(query.toLowerCase()) ||
              car.sitPlace.toLowerCase().contains(query.toLowerCase()) ||
              car.plateNumber.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A395D), // Dark blue background
        title: const Text(
          'CARS LIST',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // White text color
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Colors.white), // White icon color
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
                width: 170, // Set width to 150px
                height: 40, // Set height to 40px
                child: TextField(
                  onChanged: _filterCars,
                  decoration: InputDecoration(
                    labelText: 'Search',
                    prefixIcon: Icon(Icons.search),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                          color: Colors.blue), // Blue border color
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                          color: Colors.blue), // Blue border color
                    ),
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 2, horizontal: 5),
                  ),
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            PaginatedDataTable(
              columns: const [
                DataColumn(label: Text('#')),
                DataColumn(label: Text('NAME')),
                DataColumn(label: Text('SIT PLACE')),
                DataColumn(label: Text('PLATE #')),
                DataColumn(label: Text('Action')),
              ],
              source: CarDataTableSource(_filteredCars, _currentPage),
              rowsPerPage: 5, // Display 5 rows per page
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
}

class CarDataTableSource extends DataTableSource {
  final List<Car> cars;
  final int currentPage;

  CarDataTableSource(this.cars, this.currentPage);

  @override
  DataRow getRow(int index) {
    if (index >= cars.length) return null as DataRow;
    final car = cars[index];
    return DataRow(cells: [
      DataCell(Text('${index + 1}')), // Serial number
      DataCell(Text(car.name)),
      DataCell(Text(car.sitPlace)),
      DataCell(Text(car.plateNumber)),
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
  int get rowCount => cars.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
