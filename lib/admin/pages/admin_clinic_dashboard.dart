import 'package:flutter/material.dart';
import 'admin_clinic_dentist.dart';
import 'admin_clinic_details.dart';
import 'admin_clinic_patient.dart';
import 'admin_clinic_staff.dart';

class ClinicDashboardPage extends StatelessWidget {
  final String clinicId;
  final String clinicName;

  const ClinicDashboardPage({
    super.key,
    required this.clinicId,
    required this.clinicName,
  });

  Widget _buildCardButton({
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(clinicName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCardButton(
              title: 'Dentists',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ClinicDentistsPage(clinicId: clinicId),
                  ),
                );
              },
            ),
            _buildCardButton(
              title: 'Staff',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClinicStaffPage(clinicId: clinicId),
                  ),
                );
              },
            ),
            _buildCardButton(
              title: 'Patients',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ClinicPatientsPage(clinicId: clinicId),
                  ),
                );
              },
            ),
            _buildCardButton(
              title: 'Details',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClinicDetailsPage(clinicId: clinicId),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
