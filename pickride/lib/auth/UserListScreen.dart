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
        backgroundColor: Colors.teal,
        title: const Text(
          'Ride Admin',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            const Center(
              child: Text(
                'List Of Users',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            // Search Input
            TextField(
              onChanged: _filterUsers,
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Paginated Table
            PaginatedDataTable(
              header: const Text(
                'User List',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              columns: [
                DataColumn(label: Text('No')),
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Username')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Action')),
              ],
              source: UserDataTableSource(_filteredUsers, _currentPage),
              rowsPerPage: 10,
              onPageChanged: (pageIndex) {
                setState(() {
                  _currentPage = pageIndex;
                });
              },
              showCheckboxColumn: false,
              columnSpacing: 20,
            ),
            const SizedBox(height: 20),
            Center(
              child: Text('Page: ${_currentPage + 1}'),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Joyce Mutoni @2024',
                style: TextStyle(fontWeight: FontWeight.bold),
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
