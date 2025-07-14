import 'login_page.dart';
import 'locations_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user.dart' as app_model;
import '../services/auth_service.dart';
import '../services/database_service.dart';

class MainPage extends StatefulWidget {
  final String userId;

  const MainPage({super.key, required this.userId});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();

  app_model.User? user;
  bool isLoading = true;

  double totalCost = 0.0;
  double totalDistance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadHeaderData();
  }

  Future<void> _loadHeaderData() async {
    final fetchedUser = await _databaseService.fetchUser(widget.userId);
    final fetchedTotalDistance = await _databaseService.fetchTripTotalDistance(widget.userId);
    final fetchedTotalCost = await _databaseService.fetchTripTotalCost(widget.userId);

    if (fetchedUser != null && mounted) {
      setState(() {
        user = fetchedUser;
        totalCost = fetchedTotalCost;
        totalDistance = fetchedTotalDistance;
        isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final remainingCost = user != null ? (user!.targetCost - totalCost) : 0.0;
    final remainingDistance = user != null ? (user!.targetDistance - totalDistance) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(isLoading ? 'Loading...' : 'Welcome, ${user?.name ?? ''}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Container(
                color: const Color(0xFF2BAE9C),
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 40, 16, 16), // Top = 40 for safe area
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/logo-lukla.png',
                      height: 40,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'KmMap',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.location_on),
                      title: const Text('Your Locations'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LocationsPage(userId: widget.userId)),
                          );
                      },
                    ),
                  ],
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: _logout,
              ),
            ],
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date and total stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_month),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat.MMMM().format(DateTime.now()),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${remainingCost.toStringAsFixed(2)}€ (${remainingDistance.toStringAsFixed(1)}Km)',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Trips',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  // DataTable
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
                      columnSpacing: 16,
                      dataRowMinHeight: 48,
                      columns: const [
                        DataColumn(
                          label: Text(
                            'Day',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Distance',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Justification',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Origin',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Destination',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      rows: const [
                        DataRow(cells: [
                          DataCell(Text('07')),
                          DataCell(Text('127km (68.98€)')),
                          DataCell(Text('Team building Porto')),
                          DataCell(Text('Street 1 door 3')),
                          DataCell(Text('Street 2 door 7')),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('08')),
                          DataCell(Text('93km (50.22€)')),
                          DataCell(Text('Client meeting')),
                          DataCell(Text('Street 4 door 1')),
                          DataCell(Text('Street 5 door 9')),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('09')),
                          DataCell(Text('110km (57.40€)')),
                          DataCell(Text('Conference')),
                          DataCell(Text('Main Ave 10')),
                          DataCell(Text('Expo Center Gate B')),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('10')),
                          DataCell(Text('75km (39.05€)')),
                          DataCell(Text('Training session')),
                          DataCell(Text('Office HQ')),
                          DataCell(Text('Branch Office')),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('11')),
                          DataCell(Text('60km (31.20€)')),
                          DataCell(Text('Equipment pickup')),
                          DataCell(Text('Depot A')),
                          DataCell(Text('Warehouse Z')),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('12')),
                          DataCell(Text('82km (42.64€)')),
                          DataCell(Text('Site inspection')),
                          DataCell(Text('Street 6 door 4')),
                          DataCell(Text('Street 9 door 2')),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Trip list can go here
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add travel logic later
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
