import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  final String name;

  const MainPage({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        backgroundColor: const Color(0xFF2BAE9C),
      ),
      body: Center(
        child: Text(
          'Welcome $name!',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}