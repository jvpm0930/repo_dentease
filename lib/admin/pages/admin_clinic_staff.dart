import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClinicStaffPage extends StatefulWidget {
  final String clinicId;

  const ClinicStaffPage({super.key, required this.clinicId});

  @override
  State<ClinicStaffPage> createState() => _ClinicStaffPageState();
}

class _ClinicStaffPageState extends State<ClinicStaffPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> dentists = [];
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
          .from('staffs')
          .select('firstname, email')
          .eq('clinic_id', widget.clinicId);

      setState(() {
        dentists = List<Map<String, dynamic>>.from(response);
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
        title: const Text('Staffs'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: dentists.length,
              itemBuilder: (context, index) {
                final dentist = dentists[index];
                return ListTile(
                  title: Text(dentist['name']),
                  subtitle: Text(dentist['email']),
                );
              },
            ),
    );
  }
}
