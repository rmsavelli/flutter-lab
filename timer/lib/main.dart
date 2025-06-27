import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const TimerApp());
}

class TimerApp extends StatelessWidget {
  const TimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timer Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TimerPage(),
    );
  }
}

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  int _seconds = 0;
  Timer? _timer;

  void _startTimer() {
    _timer?.cancel(); // Cancela qualquer timer anterior
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _resetTimer() {
    _stopTimer();
    setState(() {
      _seconds = 0;
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancela ao sair
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timer com Flutter')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Contador: $_seconds s',
                style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startTimer,
              child: const Text('Iniciar'),
            ),
            ElevatedButton(
              onPressed: _stopTimer,
              child: const Text('Parar'),
            ),
            ElevatedButton(
              onPressed: _resetTimer,
              child: const Text('Resetar'),
            ),
          ],
        ),
      ),
    );
  }
}