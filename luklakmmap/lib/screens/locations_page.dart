import 'package:flutter/material.dart';
import '../models/location.dart';
import '../services/database_service.dart';
import '../widgets/location_form_dialog.dart';

class LocationsPage extends StatefulWidget {
  final String userId;

  const LocationsPage({super.key, required this.userId});

  @override
  State<LocationsPage> createState() => _LocationsPageState();
}

class _LocationsPageState extends State<LocationsPage> {
  final DatabaseService _databaseService = DatabaseService();
  List<Location> _locations = [];
  late LocationDataSource _dataSource;
  int _rowsPerPage = 5; // default value
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    debugPrint('Start loading locations...');
    try {
      final locations = await _databaseService.fetchLocations(widget.userId);
      debugPrint('Locations loaded: ${locations.length}');
      setState(() {
        _locations = locations;
        _dataSource = LocationDataSource(locations);
        _isLoading = false;
      });
    } catch (e, stack) {
      debugPrint('Error loading locations: $e');
      debugPrintStack(stackTrace: stack);
      setState(() {
        _locations = [];
        _dataSource = LocationDataSource([]);
        _isLoading = false;
      });
    }
  }

  Future<void> _addLocation(String name, String address) async {
    await _databaseService.insertLocation(
      name: name,
      address: address,
      userId: widget.userId,
    );
    await _loadLocations();
  }

  void _openAddLocationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return LocationFormDialog(
          onSubmit: (name, address) {
            Navigator.of(context).pop();
            _addLocation(name, address);
          },
        );
      },
    );
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
          : _locations.isEmpty
              ? const Center(child: Text('No locations found.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: PaginatedDataTable(
                    header: const Text('Your Saved Locations'),
                    rowsPerPage: _rowsPerPage,
                    availableRowsPerPage: const [3, 5, 8, 10],
                    onRowsPerPageChanged: (rows) {
                      if (rows != null) {
                        setState(() {
                          _rowsPerPage = rows;
                        });
                      }
                    },
                    columns: const [
                      DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Address', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    source: _dataSource,
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddLocationDialog,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Reusable DataTable source
class LocationDataSource extends DataTableSource {
  final List<Location> locations;

  LocationDataSource(this.locations);

  @override
  DataRow? getRow(int index) {
    if (index >= locations.length) return null;
    final location = locations[index];
    return DataRow(
      cells: [
        DataCell(Text('${index + 1}')),
        DataCell(Text(location.name)),
        DataCell(Text(location.address)),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => locations.length;

  @override
  int get selectedRowCount => 0;
}
