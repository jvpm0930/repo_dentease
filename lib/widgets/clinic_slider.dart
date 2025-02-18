import 'package:dentease/patients/patient_page.dart';
import 'package:flutter/material.dart';

class ClinicCarousel extends StatelessWidget {
  const ClinicCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250, // Adjust height as needed
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildClinicCard(
            context,
            'assets/clinic1.png', // Replace with your images
            'Clinic A',
            PatientPage(),
          ),
          _buildClinicCard(
            context,
            'assets/clinic2.png',
            'Clinic B',
            PatientPage(),
          ),
          _buildClinicCard(
            context,
            'assets/clinic3.png',
            'Clinic C',
            PatientPage(),
          ),
        ],
      ),
    );
  }

  /// Creates a Clickable Clinic Card
  Widget _buildClinicCard(
      BuildContext context, String imagePath, String title, Widget nextPage) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => nextPage));
      },
      child: Container(
        width: 180, // Card width
        margin: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 5, spreadRadius: 1)
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                imagePath,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Icon(Icons.favorite_border,
                  color: Colors.white, size: 28), // Heart icon
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Center(
                  child: Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

