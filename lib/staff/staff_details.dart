import 'package:dentease/staff/staff_update.dart';
import 'package:dentease/widgets/background_cont.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StaffDetailsPage extends StatefulWidget {
  final String staffId;

  const StaffDetailsPage({super.key, required this.staffId});

  @override
  State<StaffDetailsPage> createState() => _StaffDetailsPageState();
}

class _StaffDetailsPageState extends State<StaffDetailsPage> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? staffDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStaffDetails();
  }

  Future<void> _fetchStaffDetails() async {
    try {
      final response = await supabase
          .from('staffs')
          .select('firstname, lastname, email, phone, role')
          .eq('staff_id', widget.staffId)
          .single();

      setState(() {
        staffDetails = response;
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
          "My Profile",
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
                  _buildTextField(staffDetails?['firstname'] ?? 'Firstname'),
                  _buildTextField(staffDetails?['lastname'] ?? 'Lastname'),
                  _buildTextField(staffDetails?['email'] ?? 'Email'),
                  _buildTextField(staffDetails?['phone'] ?? 'Phone'),
                  _buildTextField(staffDetails?['role'] ?? 'Role'),

                  const SizedBox(height: 16),

                  // "Edit Details" Button
                  ElevatedButton(
                    onPressed: () async {
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              StaffEditPage(staffId: widget.staffId),
                        ),
                      );

                      if (updated == true) {
                        _fetchStaffDetails(); // Refresh after update
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
