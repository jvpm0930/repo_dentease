import 'package:flutter/material.dart';

class StaffPage extends StatelessWidget {
  const StaffPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Staff Dashboard')),
      body: Center(
        child: Text('Welcome, Staff!', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
