import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UsersListScreen extends StatefulWidget {
  @override
  _UsersListScreenState createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  final _supabase = Supabase.instance.client;
  List<User> _users = [];
  List<User> _filteredUsers = [];
  String _searchQuery = '';
  int _currentPage = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await _supabase.from('users').select().order('name');

      // Map the response to a list of User objects and filter out any null values
      final List<User?> fetchedUsers =
          (response as List).map((user) => User.fromJson(user)).toList();

      setState(() {
        _users = fetchedUsers.whereType<User>().toList();
        _filteredUsers = _users;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Failed to fetch users: ${error.toString()}';
        _isLoading = false;
      });
    }
  }

  void _filterUsers(String query) {
    setState(() {
      _searchQuery = query;
      _filteredUsers = _users
          .where((user) =>
              user.name.toLowerCase().contains(query.toLowerCase()) ||
              user.email.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A395D),
        title: const Text(
          'USER LIST',
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
            onPressed: _fetchUsers,
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
                    onPressed: _fetchUsers,
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
                      Expanded(
                        child: Container(
                          height: 40,
                          child: TextField(
                            onChanged: _filterUsers,
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
                              contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
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
                            DataColumn(label: Text('EMAIL')),
                          ],
                          source: UserDataTableSource(
                            _filteredUsers,
                            _currentPage,
                          ),
                          rowsPerPage: 5,
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

class UserDataTableSource extends DataTableSource {
  final List<User> users;
  final int currentPage;

  UserDataTableSource(this.users, this.currentPage);

  @override
  DataRow? getRow(int index) {
    final user = users[index];

    return DataRow(cells: [
      DataCell(Text('${index + 1}')),
      DataCell(Text(user.name)),
      DataCell(Text(user.email)),
    ]);
  }

  @override
  int get rowCount => users.length;

  @override
  int get selectedRowCount => 0;

   @override
  bool get isRowCountApproximate => false; 
}

class User {
  final String name;
  final String email;

  User({required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      email: json['email'],
    );
  }
}
