import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddressPickerScreen extends StatefulWidget {
  final Function(String, double, double) onAddressSelected;

  const AddressPickerScreen({super.key, required this.onAddressSelected});

  @override
  State<AddressPickerScreen> createState() => _AddressPickerScreenState();
}

class _AddressPickerScreenState extends State<AddressPickerScreen> {
  LatLng? selectedPosition;
  GoogleMapController? mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Address'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(7.448212, 125.809425), // Default Tagum City
              zoom: 14,
            ),
            myLocationEnabled: true,
            onMapCreated: (controller) => mapController = controller,
            onTap: (LatLng position) {
              setState(() {
                selectedPosition = position;
              });
            },
          ),
          if (selectedPosition != null)
            Center(
              child:
                  const Icon(Icons.location_pin, size: 50, color: Colors.red),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.check),
        onPressed: () {
          if (selectedPosition != null) {
            widget.onAddressSelected(
              "Selected Address", // You can use a reverse geocoding API to fetch the actual address
              selectedPosition!.latitude,
              selectedPosition!.longitude,
            );
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
