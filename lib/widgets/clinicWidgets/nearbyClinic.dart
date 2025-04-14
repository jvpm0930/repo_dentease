import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClinicMapPage extends StatefulWidget {
  const ClinicMapPage({super.key});

  @override
  State<ClinicMapPage> createState() => _ClinicMapPageState();
}

class _ClinicMapPageState extends State<ClinicMapPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  LatLng? _currentPosition;
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initLocationAndClinics();
  }

  Future<void> _initLocationAndClinics() async {
    try {
      await _getCurrentLocation();
      await _fetchClinicLocations();
    } catch (e) {
      print('Error: $e');
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _currentPosition = LatLng(position.latitude, position.longitude);

    _markers.add(Marker(
      markerId: const MarkerId('you'),
      position: _currentPosition!,
      infoWindow: const InfoWindow(title: "You are here"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    ));
  }

  Future<void> _fetchClinicLocations() async {
    final response = await supabase
        .from('clinics')
        .select('clinic_id, clinic_name, latitude, longitude')
        .eq('status', 'approved');

    for (var clinic in response) {
      final lat = clinic['latitude'];
      final lng = clinic['longitude'];

      if (lat != null && lng != null) {
        final double? latitude = double.tryParse(lat.toString());
        final double? longitude = double.tryParse(lng.toString());

        if (latitude != null && longitude != null && _currentPosition != null) {
          // Calculate distance in meters
          final double distanceInMeters = Geolocator.distanceBetween(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            latitude,
            longitude,
          );

          // Convert to km with 1 decimal
          final distanceInKm = (distanceInMeters / 1000).toStringAsFixed(1);

          // Add clinic marker with distance in infoWindow
          _markers.add(
            Marker(
              markerId: MarkerId(clinic['clinic_id'].toString()),
              position: LatLng(latitude, longitude),
              infoWindow: InfoWindow(
                title: clinic['clinic_name'],
                snippet: '$distanceInKm km away',
              ),
            ),
          );
        }
      }
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nearby Clinics"),
        centerTitle: true,
      ),
      body: isLoading || _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition!,
                zoom: 15,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onMapCreated: (controller) {
                _mapController = controller;
              },
              markers: _markers,
            ),
    );
  }
}
