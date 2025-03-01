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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchClinicDetails();
  }

  Future<void> _fetchClinicDetails() async {
    try {
      final response = await supabase
          .from('clinics')
          .select()
          .eq('clinic_id', widget.clinicId)
          .single();

      setState(() {
        clinicDetails = response;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching clinic details: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Expanded(
            child: Text(value,
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
                                _buildDetailRow('Status:',
                                    clinicDetails?['status'] ?? 'N/A'),
                                _buildDetailRow('Clinic Name:',
                                    clinicDetails?['clinic_name'] ?? 'N/A'),
                                _buildDetailRow('Address:',
                                    clinicDetails?['address'] ?? 'N/A'),
                                if (clinicDetails!['latitude'] != null &&
                                    clinicDetails!['longitude'] != null)
                                  const SizedBox(height: 8),
                                SizedBox(
                                  height: 150,
                                  child: GoogleMap(
                                    initialCameraPosition: CameraPosition(
                                      target: LatLng(
                                        clinicDetails!['latitude'],
                                        clinicDetails!['longitude'],
                                      ),
                                      zoom: 15,
                                    ),
                                    markers: {
                                      Marker(
                                        markerId:
                                            const MarkerId('clinicLocation'),
                                        position: LatLng(
                                          clinicDetails!['latitude'],
                                          clinicDetails!['longitude'],
                                        ),
                                      ),
                                    },
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (clinicDetails!['license_url'] != null)
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
                                          clinicDetails!['license_url'],
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
            const StaffFooter(),
          ],
        ),
      ),
    );
  }
}
