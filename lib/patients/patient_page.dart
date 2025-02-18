import 'package:dentease/widgets/background_cont.dart';
import 'package:flutter/material.dart';
import '../widgets/clinic_slider.dart';
import '../widgets/custom_header.dart';
import '../widgets/custom_navbar.dart';

class PatientPage extends StatelessWidget {
  const PatientPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundCont(
      child: Scaffold(
        backgroundColor: Colors.transparent, // Fix to make background work
        body: Stack(
          children: [
            CustomHeader(),
            SizedBox(height: 40),
            Expanded(
              child: Center(
                child: ClinicCarousel(), // Centered carousel
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: CustomBottomNavBar(), // Fixes position at the bottom
            ), // Add floating navigation bar
          ],
        ),
      ),
    );
  }
}
