import 'package:dentease/patients/patient_clinicv2.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClinicCarousel extends StatefulWidget {
  const ClinicCarousel({super.key});

  @override
  _ClinicCarouselState createState() => _ClinicCarouselState();
}

class _ClinicCarouselState extends State<ClinicCarousel> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> clinics = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchClinics();
  }

  /// **🔹 Fetch only clinics where `status = 'approved'`**
  Future<void> _fetchClinics() async {
    try {
      final List<dynamic> response = await supabase
          .from('clinics')
          .select('clinic_id, clinic_name')
          .eq('status', 'approved'); // Only approved clinics

      setState(() {
        clinics = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching clinics: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(
          child: Text(errorMessage, style: const TextStyle(color: Colors.red)));
    }

    if (clinics.isEmpty) {
      return const Center(
          child: Text('No approved clinics available',
              style: TextStyle(color: Colors.grey)));
    }

    return SizedBox(
      height: 250, // Adjust height as needed
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: clinics.length,
        itemBuilder: (context, index) {
          final clinic = clinics[index];
          final clinicName = clinic['clinic_name'] ?? 'Unknown Clinic';

          return GestureDetector(
            onTap: () {
              // Navigate to the details page with only clinic_id
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PatientClinicInfoPage(clinicId: clinic['clinic_id']),
                ),
              );
            },
            child: _buildClinicCard(context, clinicName),
          );
        },
      ),
    );
  }

  /// Creates a Clickable Clinic Card
  Widget _buildClinicCard(BuildContext context, String title) {
    return Container(
      width: 180, // Card width
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 5, spreadRadius: 1)
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child:
                Image.asset('assets/logo2.png', width: 100),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Center(
              child: Text(
                title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
