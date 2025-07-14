import 'package:flutter/material.dart';

class LocationsPage extends StatelessWidget {
  const LocationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final locations = [
      {'#': '1', 'name': 'Headquarters', 'address': '123 Main Street'},
      {'#': '2', 'name': 'Warehouse A', 'address': '45 Industrial Ave'},
      {'#': '3', 'name': 'Branch Office', 'address': '78 Business Rd'},
      {'#': '4', 'name': 'Client Site', 'address': '101 Elm Street'},
      {'#': '5', 'name': 'Depot', 'address': '22 Logistics Blvd'},
      {'#': '6', 'name': 'Remote Hub', 'address': '5 Remote Path'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Locations'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
          columns: const [
            DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Address', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: locations.map((location) {
            return DataRow(
              cells: [
                DataCell(Text(location['#']!)),
                DataCell(Text(location['name']!)),
                DataCell(Text(location['address']!)),
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
