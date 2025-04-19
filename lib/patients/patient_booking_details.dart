import 'package:dentease/widgets/background_cont.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

String formatDateTime(String dateTime) {
  DateTime parsedDate = DateTime.parse(dateTime);
  return DateFormat('MMM d, y • h:mma').format(parsedDate).toLowerCase();
}

class PatientBookingDetailsPage extends StatefulWidget {
  final Map<String, dynamic> booking;
  final String clinicId;

  const PatientBookingDetailsPage(
      {super.key, required this.booking, required this.clinicId});

  @override
  State<PatientBookingDetailsPage> createState() => _PatientBookingDetailsPageState();
}

class _PatientBookingDetailsPageState extends State<PatientBookingDetailsPage> {
  final supabase = Supabase.instance.client;
  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;

    return BackgroundCont(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            "Booking Details",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent, // Transparent AppBar
          elevation: 0, // Remove shadow
          iconTheme: const IconThemeData(color: Colors.white), // White icons
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Service name: ${booking['services']['service_name']}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text("Service price: ${booking['services']['service_price']}"),
                const SizedBox(height: 8),
                Text("Clinics name: ${booking['clinics']['clinic_name']}"),
                const SizedBox(height: 8),
                Text(
                    "Patient name: ${booking['patients']['firstname']} ${booking['patients']['lastname']}"),
                const SizedBox(height: 8),
                Text("Patient email: ${booking['patients']['email']}"),
                const SizedBox(height: 8),
                Text("Patient phone #: ${booking['patients']['phone']}"),
                const SizedBox(height: 8),
                Text("Service date booked: ${formatDateTime(booking['date'])}"),
                const SizedBox(height: 20),
                const Divider(thickness: 1.5, color: Colors.white),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
