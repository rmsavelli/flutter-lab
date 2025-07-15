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
  final TextEditingController _searchController = TextEditingController();

  List<Location> _allLocations = [];
  List<Location> _locations = [];
  late LocationDataSource _dataSource;

  int _rowsPerPage = 5;
  bool _isLoading = true;
  int? _sortColumnIndex;
  bool _sortAscending = true;
  String _searchQuery = '';

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
        _allLocations = locations;
        _locations = locations;
        _dataSource = LocationDataSource(_locations, onRowTap: _editLocation);
        _isLoading = false;
      });
    } catch (e, stack) {
      debugPrint('Error loading locations: $e');
      debugPrintStack(stackTrace: stack);
      setState(() {
        _allLocations = [];
        _locations = [];
        _dataSource = LocationDataSource([], onRowTap: _editLocation);
        _isLoading = false;
      });
    }
  }

  void _filterLocations(String query) {
    setState(() {
      _searchQuery = query;
      _locations = _allLocations.where((location) {
        final nameMatch = location.name.toLowerCase().contains(query.toLowerCase());
        final addressMatch = location.address.toLowerCase().contains(query.toLowerCase());
        return nameMatch || addressMatch;
      }).toList();
      _dataSource = LocationDataSource(_locations, onRowTap: _editLocation);
    });
  }

  Future<void> _addLocation(String name, String address) async {
    final newLocation = Location(id: 0, name: name, address: address);
    await _databaseService.insertLocation(newLocation, widget.userId);
    await _loadLocations();
    _filterLocations(_searchQuery);
  }

  Future<void> _editLocation(Location location) async {
    showDialog(
      context: context,
      builder: (context) {
        return LocationFormDialog(
          initialName: location.name,
          initialAddress: location.address,
          onSubmit: (newName, newAddress) async {
            Navigator.of(context).pop();
            await _databaseService.updateLocation(location);
            await _loadLocations();
            _filterLocations(_searchQuery);
          },
        );
      },
    );
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Filter by name or address',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _filterLocations,
                  ),
                  const SizedBox(height: 16),
                  PaginatedDataTable(
                    header: const Text('Your Saved Locations'),
                    showCheckboxColumn: false,
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
                ],
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
  final void Function(Location) onRowTap;

  LocationDataSource(List<Location> locations, {required this.onRowTap})
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
      onSelectChanged: (_) => onRowTap(location),
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
