import 'package:dentease/models/patientchatpage.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PatientClinicChatList extends StatefulWidget {
  final String patientId;

  const PatientClinicChatList({super.key, required this.patientId});

  @override
  _PatientClinicChatListState createState() => _PatientClinicChatListState();
}

class _PatientClinicChatListState extends State<PatientClinicChatList> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> clinics = [];

  @override
  void initState() {
    super.initState();
    fetchPatients();
  }

  /// Fetches clinics based on clinic_id from `bookings`, retrieving clinic details from `clinics` table
  Future<void> fetchPatients() async {
    final bookingResponse = await supabase
        .from('bookings')
        .select('clinic_id')
        .eq('patient_id', widget.patientId);

    final clinicIds =
        bookingResponse.map((booking) => booking['clinic_id']).toList();

    if (clinicIds.isEmpty) {
      setState(() {
        clinics = [];
      });
      return;
    }

    final clinicResponse = await supabase
        .from('clinics')
        .select('clinic_id, clinic_name, email')
        .inFilter('clinic_id', clinicIds); // Fixed the filter

    setState(() {
      clinics = List<Map<String, dynamic>>.from(clinicResponse);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Clinics List")),
      body: clinics.isEmpty
          ? const Center(
              child: CircularProgressIndicator()) // Show loading indicator
          : ListView.builder(
              itemCount: clinics.length,
              itemBuilder: (context, index) {
                final clinic = clinics[index];
                final clinicId = clinic['clinic_id'] as String?;
                final clinicName =
                    clinic['clinic_name'] as String? ?? 'Unknown';
                final clinicEmail = clinic['email'] as String? ?? '';

                return ListTile(
                  title: Text(clinicName),
                  subtitle: Text(clinicEmail),
                  trailing: const Icon(Icons.chat, color: Colors.blue),
                  onTap: () {
                    if (clinicId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PatientChatpage(
                            patientId: widget.patientId,
                            clinicName: clinicName,
                            clinicId: clinicId,
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
    );
  }
}
