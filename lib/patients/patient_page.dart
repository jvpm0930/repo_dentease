import 'package:dentease/widgets/background_cont.dart';
import 'package:flutter/material.dart';
import '../widgets/patientWidgets/clinic_slider.dart';
import '../widgets/patientWidgets/patient_header.dart';
import '../widgets/patientWidgets/patient_footer.dart';

class PatientPage extends StatelessWidget {
  const PatientPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundCont(
      child: Scaffold(
        backgroundColor: Colors.transparent, // Fix to make background work
        body: Stack(
          children: [
            PatientHeader(),
            SizedBox(height: 40),
            Expanded(
              child: Center(
                child: ClinicCarousel(), // Centered carousel
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: PatientFooter(), // Fixes position at the bottom
            ), // Add floating navigation bar
          ],
        ),
      ),
    );
  }
}
