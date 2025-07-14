import 'package:flutter/material.dart';
import '../services/database_service.dart';

class LocationsPage extends StatefulWidget {
  final String userId;

  const LocationsPage({super.key, required this.userId});

  @override
  State<LocationsPage> createState() => _LocationsPageState();
}

class _LocationsPageState extends State<LocationsPage> {
  final DatabaseService _databaseService = DatabaseService();
  List<Map<String, dynamic>> _locations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    final locations = await _databaseService.fetchLocations(widget.userId);
    setState(() {
      _locations = locations;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Locations'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
                columns: const [
                  DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Address', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: _locations.asMap().entries.map((entry) {
                  final index = entry.key;
                  final location = entry.value;
                  return DataRow(
                    cells: [
                      DataCell(Text('${index + 1}')), // Renders 1, 2, 3, ...
                      DataCell(Text(location['name'] ?? '')),
                      DataCell(Text(location['address'] ?? '')),
                    ],
                  );
                }).toList(),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add location logic
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
