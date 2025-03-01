import 'package:dentease/dentist/dentist_update.dart';
import 'package:dentease/widgets/background_cont.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DentistDetailsPage extends StatefulWidget {
  final String dentistId;

  const DentistDetailsPage({super.key, required this.dentistId});

  @override
  State<DentistDetailsPage> createState() => _DentistDetailsPageState();
}

class _DentistDetailsPageState extends State<DentistDetailsPage> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? dentistDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDentistDetails();
  }

  Future<void> _fetchDentistDetails() async {
    try {
      final response = await supabase
          .from('dentists')
          .select('firstname, lastname, email, phone, role')
          .eq('dentist_id', widget.dentistId)
          .single();

      setState(() {
        dentistDetails = response;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching dentist details: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildTextField(String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        readOnly: true,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.grey[300],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundCont(
        child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
        title: const Text(
          "Dentist Details",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Transparent AppBar
        elevation: 0, // Remove shadow
        iconTheme: const IconThemeData(color: Colors.white), // White icons
      ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildTextField(dentistDetails?['firstname'] ?? 'Firstname'),
                    _buildTextField(dentistDetails?['lastname'] ?? 'Lastname'),
                    _buildTextField(dentistDetails?['email'] ?? 'Email'),
                    _buildTextField(dentistDetails?['phone'] ?? 'Phone'),
                    _buildTextField(dentistDetails?['role'] ?? 'Role'),

                    const SizedBox(height: 16),

                    // "Edit Details" Button
                    ElevatedButton(
                      onPressed: () async {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DentistEditPage(dentistId: widget.dentistId),
                          ),
                        );

                        if (updated == true) {
                          _fetchDentistDetails(); // Refresh after update
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.indigo,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Edit Details'),
                    ),
                  ],
                ),
              ),
      ));
  }
}
