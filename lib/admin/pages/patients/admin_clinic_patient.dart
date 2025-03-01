import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdmClinicPatientsPage extends StatefulWidget {
  final String clinicId;

  const AdmClinicPatientsPage({super.key, required this.clinicId});

  @override
  State<AdmClinicPatientsPage> createState() => _AdmClinicPatientsPageState();
}

class _AdmClinicPatientsPageState extends State<AdmClinicPatientsPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> patients = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDentists();
  }

  Future<void> _fetchDentists() async {
    try {
      // Fetching data using Supabase query
      final response = await supabase
          .from('patients')
          .select('firstname, email')
          .eq('clinic_id', widget.clinicId);

      setState(() {
        patients = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching dentists: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: patients.length,
              itemBuilder: (context, index) {
                final patient = patients[index];
                return ListTile(
                  title: Text(patient['firstname']),
                  subtitle: Text(patient['email']),
                );
              },
            ),
    );
  }
}
