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
  int _rowsPerPage = 5;
  bool _isLoading = true;
  int? _sortColumnIndex;
  bool _sortAscending = true;

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
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: _sortAscending,
                    columns: [
                      DataColumn(
                        label: const Text('#', style: TextStyle(fontWeight: FontWeight.bold)),
                        onSort: (columnIndex, ascending) {
                          setState(() {
                            _sortColumnIndex = columnIndex;
                            _sortAscending = ascending;
                            _dataSource.sortByIndex(ascending);
                          });
                        },
                      ),
                      DataColumn(
                        label: const Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
                        onSort: (columnIndex, ascending) {
                          setState(() {
                            _sortColumnIndex = columnIndex;
                            _sortAscending = ascending;
                            _dataSource.sort((l) => l.name.toLowerCase(), ascending);
                          });
                        },
                      ),
                      DataColumn(
                        label: const Text('Address', style: TextStyle(fontWeight: FontWeight.bold)),
                        onSort: (columnIndex, ascending) {
                          setState(() {
                            _sortColumnIndex = columnIndex;
                            _sortAscending = ascending;
                            _dataSource.sort((l) => l.address.toLowerCase(), ascending);
                          });
                        },
                      ),
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

class LocationDataSource extends DataTableSource {
  List<Location> _locations;
  final List<Location> _original;

  LocationDataSource(List<Location> locations)
      : _locations = [...locations],
        _original = [...locations];

  void sort<T>(Comparable<T> Function(Location l) getField, bool ascending) {
    _locations.sort((a, b) {
      final aVal = getField(a);
      final bVal = getField(b);
      return ascending ? Comparable.compare(aVal, bVal) : Comparable.compare(bVal, aVal);
    });
    notifyListeners();
  }

  void sortByIndex(bool ascending) {
    _locations = ascending ? [..._original] : [..._original.reversed];
    notifyListeners();
  }

  @override
  DataRow? getRow(int index) {
    if (index >= _locations.length) return null;
    final location = _locations[index];
    return DataRow(
      cells: [
        DataCell(Text('${_original.indexOf(_locations[index]) + 1}')),
        DataCell(Text(location.name)),
        DataCell(Text(location.address)),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _locations.length;

  @override
  int get selectedRowCount => 0;
}
