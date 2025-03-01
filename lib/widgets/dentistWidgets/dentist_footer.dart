import 'package:dentease/dentist/dentist_details.dart';
import 'package:dentease/dentist/dentist_page.dart';
import 'package:flutter/material.dart';

class DentistFooter extends StatelessWidget {
  final String dentistId; // Ensure a valid dentistId is passed

  const DentistFooter({super.key, required this.dentistId});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 30,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavImage(
                'assets/icons/home.png', context, const DentistPage()),
            _buildNavImage('assets/icons/calendar.png', context,
                const DentistPage()), // Replace with the correct page
            _buildNavImage('assets/icons/chat.png', context,
                const DentistPage()), // Replace with the correct page
            _buildNavImage(
              'assets/icons/profile.png',
              context,
              DentistDetailsPage(dentistId: dentistId),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a navigation button with an image
  Widget _buildNavImage(String imagePath, BuildContext context, Widget page) {
    return IconButton(
      icon: Image.asset(
        imagePath,
        width: 30,
        height: 30,
        color: Colors.white,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
    );
  }
}
