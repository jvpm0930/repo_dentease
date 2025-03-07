import 'package:dentease/patients/patient_booking.dart';
import 'package:dentease/widgets/background_cont.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PatientClinicInfoPage extends StatefulWidget {
  final String clinicId;

  const PatientClinicInfoPage({super.key, required this.clinicId});

  @override
  _PatientClinicInfoPageState createState() => _PatientClinicInfoPageState();
}

class _PatientClinicInfoPageState extends State<PatientClinicInfoPage> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? clinic;
  List<Map<String, dynamic>> services = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchClinicDetails();
  }

  /// **🔹 Fetch clinic details and approved services**
  Future<void> _fetchClinicDetails() async {
    try {
      // Fetch clinic details
      final clinicResponse = await supabase
          .from('clinics')
          .select('clinic_name, info, address, latitude, longitude')
          .eq('clinic_id', widget.clinicId)
          .maybeSingle();

      // Fetch only approved services for this clinic
      final servicesResponse = await supabase
          .from('services')
          .select('service_id, service_name, service_price')
          .eq('clinic_id', widget.clinicId)
          .eq('status', 'approved'); // Only approved services

      setState(() {
        clinic = clinicResponse;
        services = List<Map<String, dynamic>>.from(servicesResponse);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching clinic details: $e';
        isLoading = false;
      });
    }
  }

  /// **🔹 Opens Google Maps app with navigation**
  void _openGoogleMaps(double lat, double lon) async {
    final url = "https://www.google.com/maps/search/?api=1&query=$lat,$lon";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open Google Maps.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundCont(
        child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          "Clinic Info and Services",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Transparent AppBar
        elevation: 0, // Remove shadow
        iconTheme: const IconThemeData(color: Colors.white), // White icons
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(errorMessage,
                      style: const TextStyle(color: Colors.red)))
              : clinic == null
                  ? const Center(child: Text("Clinic not found"))
                  : Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Clinic Name
                          Text(
                            clinic!['clinic_name'] ?? 'Unknown Clinic',
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),

                          // Clinic Info
                          Text(
                            clinic!['info'] ?? 'No clinic info available',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.white),
                          ),
                          const SizedBox(height: 20),

                          // Clinic Address
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.red),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  clinic!['address'] ?? 'No address available',
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Map Display
                          if (clinic!['latitude'] != null &&
                              clinic!['longitude'] != null)
                            GestureDetector(
                              onTap: () => _openGoogleMaps(
                                clinic!['latitude'],
                                clinic!['longitude'],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  "https://maps.googleapis.com/maps/api/staticmap?"
                                  "center=${clinic!['latitude']},${clinic!['longitude']}"
                                  "&zoom=15&size=400x300&maptype=roadmap"
                                  "&markers=color:red%7C${clinic!['latitude']},${clinic!['longitude']}"
                                  "&key=AIzaSyBg-fAm25WSVmO768I42gecvL80vuJiuh4", // Replace with your API key
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset('assets/placeholder_map.png',
                                          fit: BoxFit.cover),
                                ),
                              ),
                            ),
                          const SizedBox(height: 20),

                          // Services List
                          const Text(
                            "Services Offered:",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          services.isEmpty
                              ? const Text("No approved services available.",
                                  style: TextStyle(color: Colors.grey))
                              : Expanded(
                                  child: ListView.builder(
                                    itemCount: services.length,
                                    itemBuilder: (context, index) {
                                      final service = services[index];
                                      return Card(
                                        child: ListTile(
                                          title: Text(service['service_name']),
                                          subtitle: Text(
                                              "Price: ${service['service_price']} PHP"),
                                          leading: const Icon(
                                              Icons.medical_services),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PatientBookingPage(
                                                  serviceId: service[
                                                      'service_id'], // Ensure your database has 'id' for services
                                                  serviceName:
                                                      service['service_name'],
                                                  clinicId: widget.clinicId,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),

                                ),
                        ],
                      ),
                    ),
    ));
  }
}
