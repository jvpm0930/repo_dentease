import 'package:dentease/widgets/staffWidgets/staff_footer.dart';
import 'package:dentease/widgets/staffWidgets/staff_header.dart';
import 'package:flutter/material.dart';
import 'package:dentease/widgets/background_cont.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class StaffClinicPage extends StatefulWidget {
  final String clinicId;

  const StaffClinicPage({super.key, required this.clinicId});

  @override
  State<StaffClinicPage> createState() => _StaffClinicPageState();
}

class _StaffClinicPageState extends State<StaffClinicPage> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? clinicDetails;
  String? staffId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchClinicDetails();
  }

  Future<void> _fetchClinicDetails() async {
    try {
      final clinicResponse = await supabase
          .from('clinics')
          .select()
          .eq('clinic_id', widget.clinicId)
          .limit(1) // Ensure at most one result
          .maybeSingle();

      final dentistResponse = await supabase
          .from('staffs')
          .select('staff_id')
          .eq('clinic_id', widget.clinicId)
          .limit(1) // Ensure at most one result
          .maybeSingle();

      if (!mounted) return; // Prevent state updates if widget is disposed

      setState(() {
        clinicDetails = clinicResponse;
        staffId = dentistResponse?['staff_id'];
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching clinic details: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Expanded(
            child: Text(value ?? 'N/A',
                textAlign: TextAlign.right,
                style: const TextStyle(color: Colors.white, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundCont(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            const StaffHeader(),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: isLoading
                    ? const CircularProgressIndicator()
                    : clinicDetails == null
                        ? const Text('No clinic details found.',
                            style: TextStyle(fontSize: 14))
                        : SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 30),
                                _buildDetailRow(
                                    'Status:', clinicDetails?['status']),
                                _buildDetailRow('Clinic Name:',
                                    clinicDetails?['clinic_name']),
                                _buildDetailRow(
                                    'Address:', clinicDetails?['address']),
                                if (clinicDetails?['latitude'] != null &&
                                    clinicDetails?['longitude'] != null)
                                  Column(
                                    children: [
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        height: 150,
                                        child: GoogleMap(
                                          initialCameraPosition: CameraPosition(
                                            target: LatLng(
                                              clinicDetails?['latitude'] ??
                                                  0.0, // Default value
                                              clinicDetails?['longitude'] ??
                                                  0.0,
                                            ),
                                            zoom: 15,
                                          ),
                                          markers: {
                                            Marker(
                                              markerId: const MarkerId(
                                                  'clinicLocation'),
                                              position: LatLng(
                                                clinicDetails?['latitude'] ??
                                                    0.0,
                                                clinicDetails?['longitude'] ??
                                                    0.0,
                                              ),
                                            ),
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 8),
                                if (clinicDetails?['license_url'] != null)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'License:',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          clinicDetails?['license_url'],
                                          height: 150,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
              ),
            ),
            if (staffId != null)
              StaffFooter(clinicId: widget.clinicId, staffId: staffId!),
          ],
        ),
      ),
    );
  }
}
