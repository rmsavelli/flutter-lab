import 'package:flutter/material.dart';
import 'package:mindful_app/screens/settings_screen.dart';


class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome Screen'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/Sea.jpg',
            fit: BoxFit.cover,
          )),
          const Align(
            alignment: Alignment(0, -0.5),
          child: Text(
            'Welcome', 
            style: TextStyle(
            color: Colors.white,
            shadows: [Shadow(
              blurRadius: 10,
              color: Colors.black,
              offset: Offset(5, 5)
            )],
            fontSize: 24),
        )),
        Align(
          alignment: const Alignment(0,0.5),
          child: ElevatedButton(
            onPressed: (){
              Navigator.of(context).push(
                MaterialPageRoute(builder: (BuildContext context) => const SettingsScreen())
              );
            },          
            child: const Text('Start')),
        ),
        ],
      ),
    );
  }
}
