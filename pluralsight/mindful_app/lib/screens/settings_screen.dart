import 'package:flutter/material.dart';
import 'package:mindful_app/data/sp_helper.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController txtName = TextEditingController();
  final List<String> _images = ['Lake', 'Montain', 'Sea', 'Country'];
  String _selectedImage = 'Lake';

  @override
  void initState() {
    super.initState();
    getSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: txtName,
              decoration: const InputDecoration(hintText: 'Enter your name'),
            ),
            DropdownButton<String>(
              value: _selectedImage.isNotEmpty ? _selectedImage : null,
              items: _images.map((String value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text(value));
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _selectedImage = newValue ?? 'Lake';              
              });
            }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          saveSettings();
        },
        child: const Icon(Icons.save),
      ),
    ); 
  }

  Future saveSettings() async {
    final SpHelper helper = SpHelper();
    await helper.setSettings(txtName.text, _selectedImage);
  }

  Future getSettings() async {
    final SpHelper helper = SpHelper();
    Map<String, String> settings = await helper.getSettings();
    _selectedImage = settings['image'] ?? 'Lake';
    txtName.text = settings['name'] ?? '';
    setState(() {
      
    });
  }
}
