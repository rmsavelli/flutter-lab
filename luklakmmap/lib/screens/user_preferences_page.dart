import 'package:flutter/material.dart';
import '../models/location.dart';
import '../services/database_service.dart';

class UserPreferencesPage extends StatefulWidget {
  final String userId;

  const UserPreferencesPage({super.key, required this.userId});

  @override
  State<UserPreferencesPage> createState() => _UserPreferencesPageState();
}

class _UserPreferencesPageState extends State<UserPreferencesPage> {
  final _formKey = GlobalKey<FormState>();
  final _databaseService = DatabaseService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nifController = TextEditingController();
  final TextEditingController _homeAddressController = TextEditingController();
  final TextEditingController _licensePlateController = TextEditingController();
  final TextEditingController _targetCostController = TextEditingController(text: '0.0');
  final TextEditingController _targetDistanceController = TextEditingController(text: '0.0');
  final TextEditingController _targetRatioController = TextEditingController(text: '0.0');

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await _databaseService.fetchUser(widget.userId);

    if (user != null) {
      setState(() {
        _nameController.text = user.name ?? '';
        _emailController.text = user.email ?? '';
        _nifController.text = user.nif;
        _homeAddressController.text = user.homeAddress ?? '';
        _licensePlateController.text = user.licensePlate ?? '';
        _targetCostController.text = user.targetCost.toStringAsFixed(2);
        _targetDistanceController.text = user.targetDistance.toString();
        _targetRatioController.text = double.tryParse(user.targetRatio)?.toStringAsFixed(2) ?? '0.00';
      });
    }
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

  void _handleUpdate() async {
    if (_formKey.currentState!.validate()) {
      final updates = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'nif': _nifController.text.trim(),
        'home_address': _homeAddressController.text.trim(),
        'license_plate': _licensePlateController.text.trim(),
        'target_cost': double.tryParse(_targetCostController.text.trim()) ?? 0.0,
        'target_distance': double.tryParse(_targetDistanceController.text.trim()) ?? 0.0,
        'target_ratio': _targetRatioController.text.trim(),
      };

      final newHomeAddress = _homeAddressController.text.trim();

      try {
        await _databaseService.updateUser(widget.userId, updates);
        final existingLocation = await _databaseService.fetchHomeAddressLocation(widget.userId);

        if (existingLocation != null) {
          final newLocation = Location(
            id: existingLocation.id,
            name: existingLocation.name,
            address: newHomeAddress,
            immutable: true);
          await _databaseService.updateLocation(newLocation);
        }
        else
        {
          final newLocation = Location(id: 0, name: "Home Address", address: newHomeAddress, immutable: true);
          await _databaseService.insertLocation(newLocation, widget.userId);
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preferences updated successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e')),
        );
      }
    }
  }

  void _handleCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Preferences'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600), // Adjust width to your liking
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const Text(
                    'Your Current Preferences',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      filled: true,
                      fillColor: Color(0xFFE0E0E0),
                    ),
                    readOnly: true,
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      filled: true,
                      fillColor: Color(0xFFE0E0E0),
                    ),
                    readOnly: true,
                  ),
                  TextFormField(
                    controller: _nifController,
                    decoration: const InputDecoration(
                      labelText: 'NIF',
                      filled: true,
                      fillColor: Color(0xFFE0E0E0),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                    readOnly: true,
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
                    decoration: const InputDecoration(
                      labelText: 'Target Cost (€)',
                      filled: true,
                      fillColor: Color(0xFFE0E0E0),
                    ),
                    keyboardType: TextInputType.number,
                    readOnly: true,
                  ),
                  TextFormField(
                    controller: _targetDistanceController,
                    decoration: const InputDecoration(
                      labelText: 'Target Distance (km)',
                      filled: true,
                      fillColor: Color(0xFFE0E0E0),
                    ),
                    keyboardType: TextInputType.number,
                    readOnly: true,
                  ),
                  TextFormField(
                    controller: _targetRatioController,
                    decoration: const InputDecoration(
                      labelText: 'Target Ratio',
                      filled: true,
                      fillColor: Color(0xFFE0E0E0),
                    ),
                    readOnly: true,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _handleUpdate,
                          icon: const Icon(Icons.save),
                          label: const Text('Update'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextButton.icon(
                          onPressed: _handleCancel,
                          icon: const Icon(Icons.cancel),
                          label: const Text('Cancel'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
