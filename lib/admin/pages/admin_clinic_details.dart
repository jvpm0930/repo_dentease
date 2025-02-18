import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClinicDetailsPage extends StatefulWidget {
  final String clinicId;

  const ClinicDetailsPage({super.key, required this.clinicId});

  @override
  State<ClinicDetailsPage> createState() => _ClinicDetailsPageState();
}

class _ClinicDetailsPageState extends State<ClinicDetailsPage> {
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
          .select(
              'clinic_name, email, license_url, latitude, longitude, address')
          .eq('clinic_id', widget.clinicId)
          .maybeSingle();

      if (response == null) {
        throw Exception('Clinic details not found');
      }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinic Details'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : clinicDetails == null
              ? const Center(child: Text('No details found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Clinic Name
                      Text(
                        clinicDetails!['clinic_name'] ?? '',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Clinic Email
                      Row(
                        children: [
                          const Icon(Icons.email, color: Colors.indigo),
                          const SizedBox(width: 8),
                          Text(
                            clinicDetails!['email'] ?? 'No email provided',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Clinic Address
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on, color: Colors.indigo),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              clinicDetails!['address'] ??
                                  'No address provided',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Clinic License Image
                      if (clinicDetails!['license_url'] != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),

                      // Map View
                      if (clinicDetails!['latitude'] != null &&
                          clinicDetails!['longitude'] != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Location:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 200,
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
                                    markerId: const MarkerId('clinicLocation'),
                                    position: LatLng(
                                      clinicDetails!['latitude'],
                                      clinicDetails!['longitude'],
                                    ),
                                  ),
                                },
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
    );
  }
}
