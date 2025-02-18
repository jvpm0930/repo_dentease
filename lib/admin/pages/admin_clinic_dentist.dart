import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClinicDentistsPage extends StatefulWidget {
  final String clinicId;

  const ClinicDentistsPage({super.key, required this.clinicId});

  @override
  State<ClinicDentistsPage> createState() => _ClinicDentistsPageState();
}

class _ClinicDentistsPageState extends State<ClinicDentistsPage> {
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
          .from('dentists')
          .select(
              'firstname, lastname') // Ensure these fields exist in the table
          .eq('clinic_id', widget.clinicId);

      setState(() {
        dentists = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching dentists: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dentists'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : dentists.isEmpty
              ? const Center(child: Text('No dentists found.'))
              : ListView.builder(
                  itemCount: dentists.length,
                  itemBuilder: (context, index) {
                    final dentist = dentists[index];
                    final String fullName =
                        'DR. ${dentist['firstname'] ?? ''} ${dentist['lastname'] ?? ''} M.D.';

                    return ListTile(
                      title: Text(
                        fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
