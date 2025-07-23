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
  late TextEditingController _originLocationController;
  late TextEditingController _costController;
  late DateTime _selectedDate;

  List<Location> _allLocations = [];

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
    _originLocationController = TextEditingController();
    _originLocationId = widget.initialOriginLocationId;
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
      final basedOnLocation = await databaseService.fetchBasedOnLocation(widget.userId);

      if (!mounted) return;

      setState(() {
        _allLocations = locations.where((loc) => loc.id != basedOnLocation.id).toList();
        _isLoadingLocations = false;

        _originLocationId = basedOnLocation.id;
        _originLocationController.text = basedOnLocation.name;
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

  @override
  void dispose() {
    _distanceController.removeListener(_updateCostFromDistance);
    _justificationController.dispose();
    _distanceController.dispose();
    _originLocationController.dispose();
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth > 600 ? 500.0 : constraints.maxWidth * 0.9;

        return AlertDialog(
          title: Text(widget.initialJustification == null ? 'Add Trip' : 'Edit Trip'),
          content: SizedBox(
            width: maxWidth,
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
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'Enter justification'
                          : null,
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
                      TextFormField(
                      controller: _originLocationController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Origin Location',
                        filled: true,
                        fillColor: Color(0xFFE0E0E0),
                      ),
                    ),
                      // DropdownButtonFormField<int>(
                      //   isExpanded: true,
                      //   value: _originLocationId,
                      //   decoration: const InputDecoration(labelText: 'Origin Location'),
                      //   items: _allLocations.map((location) {
                      //     return DropdownMenuItem<int>(
                      //       value: location.id,
                      //       child: Text(location.name),
                      //     );
                      //   }).toList(),
                      //   onChanged: (value) {
                      //     setState(() {
                      //       _originLocationId = value;
                      //     });
                      //   },
                      //   validator: (value) =>
                      //       value == null ? 'Select origin' : null,
                      // ),
                      DropdownButtonFormField<int>(
                        isExpanded: true,
                        value: _destinationLocationId,
                        decoration: const InputDecoration(labelText: 'Destination Location'),
                        items: _allLocations.map((location) {
                          return DropdownMenuItem<int>(
                            value: location.id,
                            child: Text(location.name),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _destinationLocationId = value),
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
      },
    );
  }
}
