import 'package:flutter/material.dart';

class UserForm extends StatefulWidget {
  final String? initialName;
  final String? initialEmail;
  final String? initialNif;
  final String? initialHomeAddress;
  final String? initialLicensePlate;
  final double? initialTargetCost;
  final double? initialTargetDistance;
  final String? initialTargetRatio;
  final void Function({
    required String name,
    required String email,
    required String nif,
    required String homeAddress,
    required String licensePlate,
    required double targetCost,
    required double targetDistance,
    required String targetRatio,
  }) onSubmit;
  final VoidCallback? onDelete;

  const UserForm({
    super.key,
    this.initialName,
    this.initialEmail,
    this.initialNif,
    this.initialHomeAddress,
    this.initialLicensePlate,
    this.initialTargetCost,
    this.initialTargetDistance,
    this.initialTargetRatio,
    required this.onSubmit,
    this.onDelete,
  });

  @override
  State<UserForm> createState() => _UserForm();
}

class _UserForm extends State<UserForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _nifController;
  late final TextEditingController _homeAddressController;
  late final TextEditingController _licensePlateController;
  late final TextEditingController _targetCostController;
  late final TextEditingController _targetDistanceController;
  late final TextEditingController _targetRatioController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
    _nifController = TextEditingController(text: widget.initialNif ?? '');
    _homeAddressController = TextEditingController(text: widget.initialHomeAddress ?? '');
    _licensePlateController = TextEditingController(text: widget.initialLicensePlate ?? '');
    _targetCostController = TextEditingController(
        text: widget.initialTargetCost?.toString() ?? '0.0');
    _targetDistanceController = TextEditingController(
        text: widget.initialTargetDistance?.toString() ?? '0.0');
    _targetRatioController = TextEditingController(
        text: widget.initialTargetRatio ?? '0.0');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _nifController.dispose();
    _homeAddressController.dispose();
    _licensePlateController.dispose();
    _targetCostController.dispose();
    _targetDistanceController.dispose();
    _targetRatioController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        nif: _nifController.text.trim(),
        homeAddress: _homeAddressController.text.trim(),
        licensePlate: _licensePlateController.text.trim(),
        targetCost: double.tryParse(_targetCostController.text.trim()) ?? 0.0,
        targetDistance: double.tryParse(_targetDistanceController.text.trim()) ?? 0.0,
        targetRatio: _targetRatioController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialName == null ? 'Add User' : 'Edit User'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Enter name' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                controller: _nifController,
                decoration: const InputDecoration(labelText: 'NIF'),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Enter NIF' : null,
              ),
              TextFormField(
                controller: _homeAddressController,
                decoration: const InputDecoration(labelText: 'Home Address'),
              ),
              TextFormField(
                controller: _licensePlateController,
                decoration: const InputDecoration(labelText: 'License Plate'),
              ),
              TextFormField(
                controller: _targetCostController,
                decoration: const InputDecoration(labelText: 'Target Cost'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              TextFormField(
                controller: _targetDistanceController,
                decoration: const InputDecoration(labelText: 'Target Distance'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              TextFormField(
                controller: _targetRatioController,
                decoration: const InputDecoration(labelText: 'Target Ratio'),
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
