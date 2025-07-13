import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/user.dart' as app_model;

class MainPage extends StatefulWidget {
  final String userId;

  const MainPage({super.key, required this.userId});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final DatabaseService _databaseService = DatabaseService();

  app_model.User? user;
  bool isLoading = true;

  double totalCost = 0.0;
  int totalDistance = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final fetchedUser = await _databaseService.fetchUser(widget.userId);
    final stats = await _databaseService.fetchUserTripStats(widget.userId);

    if (fetchedUser != null) {
      setState(() {
        user = fetchedUser;
        totalCost = stats['totalCost'];
        totalDistance = stats['totalDistance'];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final remainingCost = user != null ? (user!.targetCost - totalCost) : 0.0;
    final remainingDistance = user != null ? (user!.targetDistance - totalDistance) : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(isLoading ? 'Loading...' : 'Welcome, ${user?.name ?? ''}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Icon(Icons.menu),
          ),
        ],
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
                        children: const [
                          Icon(Icons.calendar_month),
                          SizedBox(width: 8),
                          Text('July', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${remainingCost.toStringAsFixed(0)}€ ($remainingDistance Km)',
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
