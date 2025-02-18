import 'package:flutter/material.dart';

class DentistPage extends StatelessWidget {
  const DentistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dentist Dashboard')),
      body: Center(
        child: Text('Welcome, Dentist!', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
