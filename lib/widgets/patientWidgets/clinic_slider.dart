import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClinicCarousel extends StatefulWidget {
  const ClinicCarousel({super.key});

  @override
  _ClinicCarouselState createState() => _ClinicCarouselState();
}

class _ClinicCarouselState extends State<ClinicCarousel> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> clinics = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchClinics();
  }

  /// **🔹 Fetch only clinics where `status = 'approved'`**
  Future<void> _fetchClinics() async {
    try {
      final List<dynamic> response = await supabase
          .from('clinics')
          .select('clinic_id, clinic_name, latitude, longitude, status')
          .eq('status', 'approved'); // Only approved clinics

      print("Fetched Approved Clinics: ${response.length}");

      setState(() {
        clinics = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching clinics: $e");
      setState(() {
        errorMessage = 'Error fetching clinics: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(
          child: Text(errorMessage, style: TextStyle(color: Colors.red)));
    }

    if (clinics.isEmpty) {
      return const Center(
          child: Text('No approved clinics available',
              style: TextStyle(color: Colors.grey)));
    }

    return SizedBox(
      height: 250, // Adjust height as needed
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: clinics.length,
        itemBuilder: (context, index) {
          final clinic = clinics[index];
          final clinicName = clinic['clinic_name'] ?? 'Unknown Clinic';
          final latitude = clinic['latitude'] ?? 0.0;
          final longitude = clinic['longitude'] ?? 0.0;

          final mapUrl = _getGoogleMapsUrl(latitude, longitude);

          return _buildClinicCard(
            context,
            mapUrl, // Google Maps Image
            clinicName,
          );
        },
      ),
    );
  }

  /// Generates Google Maps Static API URL for clinic location
  String _getGoogleMapsUrl(double lat, double lon) {
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lon&zoom=15&size=400x300&maptype=roadmap&markers=color:red%7C$lat,$lon&key=AIzaSyBg-fAm25WSVmO768I42gecvL80vuJiuh4';
  }

  /// Creates a Clickable Clinic Card
  Widget _buildClinicCard(BuildContext context, String mapUrl, String title) {
    return Container(
      width: 180, // Card width
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 5, spreadRadius: 1)
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Image.network(
              mapUrl,
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Image.asset('assets/placeholder_map.png', fit: BoxFit.cover),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Center(
              child: Text(
                title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
