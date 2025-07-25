import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/location.dart';
import '../services/database_service.dart';

class TripFormDialog extends StatefulWidget {
  final String userId;
  final DateTime? initialDate;
  final String? initialJustification;
  final double? initialDistance;
  final double? initialCost;
  final double? targetRatio;
  final int? initialOriginLocationId;
  final int? initialDestinationLocationId;

  final void Function({
    required DateTime date,
    required String justification,
    required double distance,
    required double cost,
    required int originLocationId,
    required int destinationLocationId,
  }) onSubmit;

  final VoidCallback? onDelete;

  const TripFormDialog({
    super.key,
    required this.userId,
    this.initialDate,
    this.initialJustification,
    this.initialDistance,
    this.initialCost,
    this.targetRatio,
    this.initialOriginLocationId,
    this.initialDestinationLocationId,
    required this.onSubmit,
    this.onDelete,
  });

  @override
  State<TripFormDialog> createState() => _TripFormDialogState();
}

class _TripFormDialogState extends State<TripFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _justificationController;
  late TextEditingController _distanceController;
  late TextEditingController _costController;
  late DateTime _selectedDate;

  List<Location> _allLocations = [];
  List<Location> _destinationOptions = [];

  int? _originLocationId;
  int? _destinationLocationId;
  bool _isLoadingLocations = true;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _justificationController = TextEditingController(text: widget.initialJustification ?? '');
    _distanceController = TextEditingController(text: (widget.initialDistance ?? 0).toStringAsFixed(1));
    _distanceController.addListener(_updateCostFromDistance);
    _costController = TextEditingController(text: (widget.initialCost ?? 0).toStringAsFixed(2));
    _originLocationId = widget.initialOriginLocationId;
    _destinationLocationId = widget.initialDestinationLocationId;
    _loadLocations();
    _updateCostFromDistance();
  }

  void _updateCostFromDistance() {
    final distance = double.tryParse(_distanceController.text) ?? 0.0;
    final cost = distance * (widget.targetRatio ?? 0.0);
    _costController.text = cost.toStringAsFixed(2);
  }

  Future<void> _loadLocations() async {
    try {
      final databaseService = DatabaseService();
      final locations = await databaseService.fetchLocations(widget.userId);

      if (!mounted) return;

      setState(() {
        _allLocations = locations;
        _isLoadingLocations = false;
        _updateDestinationOptions();
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingLocations = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load locations')),
      );
    }
  }

  void _updateDestinationOptions() {
    setState(() {
      _destinationOptions = _allLocations
          .where((loc) => loc.id != _originLocationId)
          .toList();
    });
  }

  @override
  void dispose() {
    _distanceController.removeListener(_updateCostFromDistance);
    _justificationController.dispose();
    _distanceController.dispose();
    _costController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_originLocationId == null || _destinationLocationId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select origin and destination')),
        );
        return;
      }

      widget.onSubmit(
        date: _selectedDate,
        justification: _justificationController.text.trim(),
        distance: double.tryParse(_distanceController.text.trim()) ?? 0.0,
        cost: double.tryParse(_costController.text.trim()) ?? 0.0,
        originLocationId: _originLocationId!,
        destinationLocationId: _destinationLocationId!,
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialJustification == null ? 'Add Trip' : 'Edit Trip'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InputDecorator(
                  decoration: const InputDecoration(labelText: 'Date'),
                  child: Text(
                    DateFormat('dd/MM/yyyy').format(_selectedDate),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                TextFormField(
                  controller: _justificationController,
                  decoration: const InputDecoration(labelText: 'Justification'),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Enter justification' : null,
                ),
                TextFormField(
                  controller: _distanceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Distance (km)'),
                ),
                TextFormField(
                  controller: _costController,
                  keyboardType: TextInputType.number,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Cost (€)',
                    filled: true,
                    fillColor: Color(0xFFE0E0E0),
                  ),
                ),
                if (_isLoadingLocations)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CircularProgressIndicator(),
                  )
                else ...[
                  DropdownButtonFormField<int>(
                    isExpanded: true,
                    value: _originLocationId,
                    decoration: const InputDecoration(labelText: 'Origin Location'),
                    items: _allLocations.map((location) {
                      return DropdownMenuItem<int>(
                        value: location.id,
                        child: Text(location.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _originLocationId = value;
                        _destinationLocationId = null;
                        _updateDestinationOptions();
                      });
                    },
                    validator: (value) => value == null ? 'Select origin' : null,
                  ),
                  DropdownButtonFormField<int>(
                    isExpanded: true,
                    value: _destinationLocationId,
                    decoration: const InputDecoration(labelText: 'Destination Location'),
                    items: _destinationOptions.map((location) {
                      return DropdownMenuItem<int>(
                        value: location.id,
                        child: Text(location.name),
                      );
                    }).toList(),
                    onChanged: _originLocationId != null
                      ? (value) => setState(() => _destinationLocationId = value)
                      : null, // disables dropdown when origin not selected
                    validator: (value) => value == null ? 'Select destination' : null,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Save'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        if (widget.onDelete != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onDelete!();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
      ],
    );
  }
}
