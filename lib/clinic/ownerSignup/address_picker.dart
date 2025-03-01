import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddressPickerScreen extends StatefulWidget {
  final Function(String, double, double) onAddressSelected;

  const AddressPickerScreen({super.key, required this.onAddressSelected});

  @override
  State<AddressPickerScreen> createState() => _AddressPickerScreenState();
}

class _AddressPickerScreenState extends State<AddressPickerScreen> {
  LatLng? selectedPosition;
  GoogleMapController? mapController;
  String? actualAddress;
  final String apiKey =
      'AIzaSyBg-fAm25WSVmO768I42gecvL80vuJiuh4'; // Replace with your API key

  Future<void> _getAddressFromCoordinates(LatLng position) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      print('Response: ${response.body}'); // Debugging API response
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          setState(() {
            actualAddress = data['results'][0]['formatted_address'];
          });
        } else {
          setState(() {
            actualAddress = 'No address found';
          });
        }
      } else {
        setState(() {
          actualAddress = 'Failed to fetch address';
        });
      }
    } catch (e) {
      setState(() {
        actualAddress = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Address'),
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(7.448212, 125.809425), // Default Tagum City
              zoom: 14,
            ),
            myLocationEnabled: true,
            onMapCreated: (controller) => mapController = controller,
            onTap: (LatLng position) async {
              setState(() {
                selectedPosition = position;
                actualAddress = 'Fetching address...';
              });
              await _getAddressFromCoordinates(position);
            },
            markers: selectedPosition != null
                ? {
                    Marker(
                      markerId: const MarkerId('selected_location'),
                      position: selectedPosition!,
                    ),
                  }
                : {},
          ),
          // Address Display
          if (actualAddress != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  actualAddress!,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (selectedPosition != null && actualAddress != null) {
            widget.onAddressSelected(
              actualAddress!,
              selectedPosition!.latitude,
              selectedPosition!.longitude,
            );
            Navigator.pop(context);
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
