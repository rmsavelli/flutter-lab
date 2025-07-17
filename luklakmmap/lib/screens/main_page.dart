import 'login_page.dart';
import 'locations_page.dart';
import 'user_preferences_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/trip.dart';
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

  List<Trip> trips = [];
  Map<int, String> locationNames = {};
  double totalCost = 0.0;
  double totalDistance = 0.0;

  final DateTime now = DateTime.now();
  late DateTime selectedMonth = DateTime(now.year, now.month);
  late List<DateTime> monthOptions = List.generate(5, (index) {
    final month = DateTime(now.year, now.month - 3 + index);
    return DateTime(month.year, month.month);
  });

  @override
  void initState() {
    super.initState();
    _loadAppData(selectedMonth);
  }

  Future<void> _loadUser() async {
    user = await _databaseService.fetchUser(widget.userId);
  }

  Future<void> _loadTripTotals(DateTime month) async {
    totalDistance = await _databaseService.fetchTripTotalDistance(widget.userId, month);
    totalCost = await _databaseService.fetchTripTotalCost(widget.userId, month);
  }

  Future<void> _loadTrips(DateTime month) async {
    trips = await _databaseService.fetchTripsForMonth(widget.userId, month);
  }

  Future<void> _loadTripsLocationNames() async {
    await _loadLocationNames(trips);
  }

  Future<void> _loadAppData(DateTime month) async {
    await _loadUser();
    await _loadTrips(month);
    await _loadTripTotals(month);
    await _loadTripsLocationNames();

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadLocationNames(List<Trip> trips) async {
    final uniqueLocationIds = <int> {
      for (var trip in trips) ...[
        trip.originLocationId,
        trip.destinationLocationId
      ]
    };

    for (var locationId in uniqueLocationIds) {
      if (!locationNames.containsKey(locationId)) {
        final name = await _databaseService.fetchLocationName(locationId);
        locationNames[locationId] = name;
      }
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
    final isWideScreen = MediaQuery.of(context).size.width >= 600;

    final remainingCost = user != null ? (user!.targetCost - totalCost) : 0.0;
    final remainingDistance = user != null ? (user!.targetDistance - totalDistance) : 0.0;

    final drawerContent = Container(
      width: 250,
      color: Colors.white,
      child: Column(
        children: [
          Container(
            color: const Color(0xFF2BAE9C),
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
            child: SafeArea(
              bottom: false,
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
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.location_on),
                        title: const Text('Your Locations'),
                        onTap: () {
                          if (!isWideScreen) Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LocationsPage(userId: widget.userId),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.settings),
                        title: const Text('Preferences'),
                        onTap: () {
                          if (!isWideScreen) Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserPreferencesPage(userId: widget.userId),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Logout'),
                      onTap: _logout,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final mainContent = isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_month),
                        const SizedBox(width: 8),
                        DropdownButtonHideUnderline(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child: DropdownButton<DateTime>(
                              value: selectedMonth,
                              isDense: true,
                              icon: const Icon(Icons.arrow_drop_down),
                              dropdownColor: Colors.white,
                              style: const TextStyle(color: Colors.black),
                              items: monthOptions.map((date) {
                                return DropdownMenuItem<DateTime>(
                                  value: date,
                                  child: Text(DateFormat('MMMM/yyyy').format(date)),
                                );
                              }).toList(),
                              onChanged: (newDate) {
                                if (newDate != null) {
                                  setState(() {
                                    selectedMonth = newDate;
                                  });
                                  _loadAppData(newDate);
                                }
                              },
                            ),
                          ),
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
                    columnSpacing: 16,
                    dataRowMinHeight: 48,
                    columns: const [
                      DataColumn(label: Text('Day', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Distance', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Justification', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Origin', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Destination', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: trips.map((trip) {
                      final day = DateFormat('dd').format(trip.beginDate);
                      final distanceStr = '${trip.distance.toStringAsFixed(0)}km (${trip.cost.toStringAsFixed(2)}€)';
                      final originName = locationNames[trip.originLocationId] ?? '...';
                      final destinationName = locationNames[trip.destinationLocationId] ?? '...';
                      return DataRow(cells: [
                        DataCell(Text(day)),
                        DataCell(Text(distanceStr)),
                        DataCell(Text(trip.justification)),
                        DataCell(Text(originName)),
                        DataCell(Text(destinationName)),
                      ]);
                    }).toList(),
                  ),
                ),
              ],
            ),
          );

    return isWideScreen
        ? Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(isLoading ? 'Loading...' : 'Welcome, ${user?.name ?? ''}'),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            body: Row(
              children: [
                drawerContent,
                const VerticalDivider(width: 1),
                Expanded(child: mainContent),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              backgroundColor: Colors.teal,
              child: const Icon(Icons.add),
            ),
          )
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(isLoading ? 'Loading...' : 'Welcome, ${user?.name ?? ''}'),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            drawer: Drawer(child: drawerContent),
            body: mainContent,
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              backgroundColor: Colors.teal,
              child: const Icon(Icons.add),
            ),
          );
  }
}
