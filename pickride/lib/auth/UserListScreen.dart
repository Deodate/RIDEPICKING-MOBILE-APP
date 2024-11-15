import 'package:flutter/material.dart';

class User {
  final String name;
  final String username;
  final String email;

  User({required this.name, required this.username, required this.email});
}

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<User> _users = List.generate(
    50,
    (index) => User(
      name: 'User $index',
      username: 'Username $index',
      email: 'user$index@example.com',
    ),
  );

  List<User> _filteredUsers = [];
  String _searchQuery = '';
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _filteredUsers = _users;
  }

  void _filterUsers(String query) {
    setState(() {
      _searchQuery = query;
      _filteredUsers = _users
          .where((user) =>
              user.name.toLowerCase().contains(query.toLowerCase()) ||
              user.username.toLowerCase().contains(query.toLowerCase()) ||
              user.email.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A395D), // Dark blue background
        title: const Text(
          'LIST OF USERS',
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
            const SizedBox(height: 1),
            const Center(
              child: Text(
                '',
              ),
            ),
            const SizedBox(height: 10),
            // Search Input positioned on the right side with specific dimensions
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 170, // Set width to 150px
                height: 40, // Set height to 40px
                child: TextField(
                  onChanged: _filterUsers,
                  decoration: InputDecoration(
                    labelText: 'Search',
                    prefixIcon: Icon(Icons.search),
                    // Set border when not focused
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                          color: Colors
                              .blue), // Blue border color when not focused
                    ),
                    // Set border when focused
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                          color: Colors.blue), // Blue border color when focused
                    ),
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 2, horizontal: 5), // Adjust padding
                  ),
                  style: TextStyle(
                      fontSize: 12), // Set font size for search input text
                ),
              ),
            ),

            const SizedBox(height: 20),
            // Paginated Table
            PaginatedDataTable(
              columns: const [
                DataColumn(label: Text('#')),
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Username')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Action')),
              ],
              source: UserDataTableSource(_filteredUsers, _currentPage),
              rowsPerPage: 5, // Display 5 rows per page
              onPageChanged: (pageIndex) {
                setState(() {
                  _currentPage = pageIndex;
                });
              },
              showCheckboxColumn: false,
              columnSpacing: 20,
              headingRowColor: MaterialStateProperty.all(
                  Colors.blue), // Set header background to blue
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

class UserDataTableSource extends DataTableSource {
  final List<User> users;
  final int currentPage;

  UserDataTableSource(this.users, this.currentPage);

  @override
  DataRow getRow(int index) {
    if (index >= users.length) return null as DataRow;
    final user = users[index];
    return DataRow(cells: [
      DataCell(Text('${index + 1}')), // Serial number
      DataCell(Text(user.name)),
      DataCell(Text(user.username)),
      DataCell(Text(user.email)),
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
  int get rowCount => users.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
