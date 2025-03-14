import 'package:dentease/models/clinicchatpage.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClinicPatientChatList extends StatefulWidget {
  final String clinicId;

  const ClinicPatientChatList({super.key, required this.clinicId});

  @override
  _ClinicPatientChatListState createState() => _ClinicPatientChatListState();
}

class _ClinicPatientChatListState extends State<ClinicPatientChatList> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> patients = [];

  @override
  void initState() {
    super.initState();
    fetchPatients();
  }

  /// Fetches patients based on clinic_id from `bookings`, retrieving patient details from `patients` table
  Future<void> fetchPatients() async {
    final bookingResponse = await supabase
        .from('bookings')
        .select('patient_id')
        .eq('clinic_id', widget.clinicId);

    final patientIds =
        bookingResponse.map((booking) => booking['patient_id']).toList();

    if (patientIds.isEmpty) {
      setState(() {
        patients = [];
      });
      return;
    }

    final patientResponse = await supabase
        .from('patients')
        .select('patient_id, firstname, email')
        .inFilter('patient_id', patientIds); // Fixed the filter

    setState(() {
      patients = List<Map<String, dynamic>>.from(patientResponse);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Patients List")),
      body: patients.isEmpty
          ? const Center(
              child: CircularProgressIndicator()) // Show loading indicator
          : ListView.builder(
              itemCount: patients.length,
              itemBuilder: (context, index) {
                final patient = patients[index];
                final patientId = patient['patient_id'] as String?;
                final patientName = patient['firstname'] as String? ?? 'Unknown';
                final patientEmail = patient['email'] as String? ?? '';

                return ListTile(
                  title: Text(patientName),
                  subtitle: Text(patientEmail),
                  trailing: const Icon(Icons.chat, color: Colors.blue),
                  onTap: () {
                    if (patientId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ClinicChatPage(
                            patientId: patientId,
                            patientName: patientName,
                            clinicId: widget.clinicId,
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
