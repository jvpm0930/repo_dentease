import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

String formatDateTime(String dateTime) {
  DateTime parsedDate = DateTime.parse(dateTime);
  return DateFormat('MMM d, y • h:mma').format(parsedDate).toLowerCase();
}

class DentistBookingApprvPage extends StatefulWidget {
  final String dentistId;
  const DentistBookingApprvPage({super.key, required this.dentistId});

  @override
  _DentistBookingApprvPageState createState() =>
      _DentistBookingApprvPageState();
}

class _DentistBookingApprvPageState extends State<DentistBookingApprvPage> {
  final supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _bookingsFuture = _fetchBookings();
  }

  Future<List<Map<String, dynamic>>> _fetchBookings() async {
    final response = await supabase
        .from('bookings')
        .select(
            'booking_id, patient_id, service_id, clinic_id, date, status, patients(firstname), services(service_name)')
        .eq('status', 'pending');
    return response;
  }

  Future<void> _updateBookingStatus(String bookingId, String newStatus) async {
    await supabase
        .from('bookings')
        .update({'status': newStatus}).eq('booking_id', bookingId);

    // Refresh bookings list after update
    setState(() {
      _bookingsFuture = _fetchBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking Requests"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No pending bookings"));
          }

          final bookings = snapshot.data!;

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              String currentStatus = booking['status'];

              return Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking['services']['service_name'],
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text("Patient: ${booking['patients']['firstname']}"),
                      Text("Date: ${formatDateTime(booking['date'])}"),
                      const SizedBox(height: 5),

                      // Status dropdown
                      Row(
                        children: [
                          const Text("Status: "),
                          DropdownButton<String>(
                            value: currentStatus,
                            onChanged: (newStatus) {
                              if (newStatus != null) {
                                setState(() {
                                  booking['status'] = newStatus;
                                });
                              }
                            },
                            items: ["pending", "approved"]
                                .map<DropdownMenuItem<String>>((String status) {
                              return DropdownMenuItem<String>(
                                value: status,
                                child: Text(status),
                              );
                            }).toList(),
                          ),
                          const SizedBox(width: 10),

                          // Update button
                          ElevatedButton(
                            onPressed: () {
                              _updateBookingStatus(
                                  booking['booking_id'].toString(),
                                  booking['status']);
                            },
                            child: const Text("Update"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
