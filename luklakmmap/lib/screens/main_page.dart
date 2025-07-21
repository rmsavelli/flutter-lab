import 'login_page.dart';
import 'locations_page.dart';
import 'user_preferences_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/trip.dart';
import '../models/user.dart' as app_model;
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/trip_form_dialog.dart';


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
    final uniqueLocationIds = <int>{
      for (var trip in trips) ...[
        trip.originLocationId,
        trip.destinationLocationId,
      ]
    };
    for (var locationId in uniqueLocationIds) {
      if (!locationNames.containsKey(locationId)) {
        locationNames[locationId] = await _databaseService.fetchLocationName(locationId);
      }
    }
  }

  Future<void> _showAddTripDialog(DateTime date) async {
    if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Trips cannot be added on weekends."),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (_) => TripFormDialog(
        userId: user!.id,
        initialDate: date,
        onSubmit: ({
          required DateTime date,
          required String justification,
          required double distance,
          required double cost,
          required int originLocationId,
          required int destinationLocationId,
        }) async {
          final trip = Trip(
            beginDate: date,
            justification: justification,
            distance: distance,
            cost: cost,
            originLocationId: originLocationId,
            destinationLocationId: destinationLocationId,
          );

          await _databaseService.insertTrip(trip, widget.userId);
          _loadAppData(selectedMonth); // Refresh view
        },
      ),
    );
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

  Future<void> _logout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  List<DateTime> _generateDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final nextMonth = DateTime(month.year, month.month + 1, 1);
    final daysCount = nextMonth.difference(firstDay).inDays;
    return List.generate(daysCount, (i) => DateTime(month.year, month.month, i + 1));
  }

  Map<int, List<Trip>> _groupTripsByDay(List<Trip> trips) {
    final map = <int, List<Trip>>{};
    for (var trip in trips) {
      map.putIfAbsent(trip.beginDate.day, () => []).add(trip);
    }
    return map;
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
                  Image.asset('assets/logo-lukla.png', height: 40),
                  const SizedBox(height: 12),
                  const Text('KmMap', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
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

    final daysInMonth = _generateDaysInMonth(selectedMonth);
    final groupedTrips = _groupTripsByDay(trips);

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
                                    isLoading = true;
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
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: (remainingCost < 0 || remainingDistance < 0)
                              ? Colors.red
                              : Colors.black,
                            ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Trips', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                // Agenda style list
                ...daysInMonth.map((date) {
                  final tripsForDay = groupedTrips[date.day] ?? [];
                  final dayStr = DateFormat('dd').format(date);
                  final weekdayStr = DateFormat('E').format(date);
                  final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;

                  final labelColor = isWeekend ? Colors.red : Colors.black;
                  final emptyBoxColor = isWeekend ? const Color(0xFFFFE5E5) : const Color(0xFFE5E5E5);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => _showAddTripDialog(date),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '$dayStr ($weekdayStr)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: labelColor,
                            ),
                          ),
                        ),
                      ),
                      if (tripsForDay.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                          child: GestureDetector(
                            onTap: () => _showAddTripDialog(date),
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: emptyBoxColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        )
                      else
                        ...tripsForDay.map((trip) {
                          final originName = locationNames[trip.originLocationId] ?? '...';
                          final destinationName = locationNames[trip.destinationLocationId] ?? '...';

                          return Dismissible(
                            key: ValueKey(trip.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              color: Colors.red[200],
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (direction) async {
                              await _databaseService.deleteTrip(trip.id!);
                              _loadAppData(selectedMonth);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Trip deleted')),
                              );
                            },
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                              title: Text(
                                trip.justification,
                                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('From: $originName'),
                                  Text('To: $destinationName'),
                                ],
                              ),
                              trailing: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('${trip.distance.toStringAsFixed(0)} km',
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text('${trip.cost.toStringAsFixed(2)} €',
                                      style: const TextStyle(color: Colors.black54)),
                                ],
                              ),
                              onTap: () async {
                                await showDialog(
                                  context: context,
                                  builder: (_) => TripFormDialog(
                                    userId: widget.userId,
                                    initialDate: trip.beginDate,
                                    initialJustification: trip.justification,
                                    initialDistance: trip.distance,
                                    initialCost: trip.cost,
                                    initialOriginLocationId: trip.originLocationId,
                                    initialDestinationLocationId: trip.destinationLocationId,
                                    onSubmit: ({
                                      required DateTime date,
                                      required String justification,
                                      required double distance,
                                      required double cost,
                                      required int originLocationId,
                                      required int destinationLocationId,
                                    }) async {
                                      final updatedTrip = Trip(
                                        id: trip.id,
                                        beginDate: date,
                                        justification: justification,
                                        distance: distance,
                                        cost: cost,
                                        originLocationId: originLocationId,
                                        destinationLocationId: destinationLocationId,
                                      );

                                      await _databaseService.updateTrip(updatedTrip);
                                      _loadAppData(selectedMonth);
                                    },
                                    onDelete: () async {
                                      await _databaseService.deleteTrip(trip.id!);
                                      _loadAppData(selectedMonth);
                                    },
                                  ),
                                );
                              },
                            ),
                          );
                        }),
                      const SizedBox(height: 8),
                    ],
                  );
                }),
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
              children: [drawerContent, const VerticalDivider(width: 1), Expanded(child: mainContent)],
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
          );
        }
  }