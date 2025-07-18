import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TripFormDialog extends StatefulWidget {
  final DateTime? initialDate;
  final String? initialJustification;
  final double? initialDistance;
  final double? initialCost;
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
    this.initialDate,
    this.initialJustification,
    this.initialDistance,
    this.initialCost,
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

  int? _originLocationId;
  int? _destinationLocationId;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _justificationController = TextEditingController(text: widget.initialJustification ?? '');
    _distanceController = TextEditingController(text: (widget.initialDistance ?? 0).toStringAsFixed(0));
    _costController = TextEditingController(text: (widget.initialCost ?? 0.0).toStringAsFixed(2));
    _originLocationId = widget.initialOriginLocationId;
    _destinationLocationId = widget.initialDestinationLocationId;
  }

  @override
  void dispose() {
    _justificationController.dispose();
    _distanceController.dispose();
    _costController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialJustification == null ? 'Add Trip' : 'Edit Trip'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Date'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                      const Icon(Icons.calendar_today, size: 18),
                    ],
                  ),
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
                decoration: const InputDecoration(labelText: 'Cost (€)'),
              ),
              DropdownButtonFormField<int>(
                value: _originLocationId,
                decoration: const InputDecoration(labelText: 'Origin Location'),
                items: [], // TODO: fill with real items
                onChanged: (value) => setState(() => _originLocationId = value),
                validator: (value) => value == null ? 'Select origin' : null,
              ),
              DropdownButtonFormField<int>(
                value: _destinationLocationId,
                decoration: const InputDecoration(labelText: 'Destination Location'),
                items: [], // TODO: fill with real items
                onChanged: (value) => setState(() => _destinationLocationId = value),
                validator: (value) => value == null ? 'Select destination' : null,
              ),
            ],
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
