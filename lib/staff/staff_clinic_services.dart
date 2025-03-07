import 'package:dentease/staff/staff_add_service.dart';
import 'package:dentease/widgets/staffWidgets/staff_footer.dart';
import 'package:dentease/widgets/staffWidgets/staff_header.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dentease/widgets/background_cont.dart';

class StaffServListPage extends StatefulWidget {
  final String clinicId;

  const StaffServListPage({super.key, required this.clinicId});

  @override
  _StaffServListPageState createState() => _StaffServListPageState();
}

class _StaffServListPageState extends State<StaffServListPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> services = [];
  String? staffId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStaffId();
    _fetchServices();
  }

  /// 🔹 Fetch `staff_id` for the logged-in user
  Future<void> _fetchStaffId() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null || user.email == null) {
        setState(() => isLoading = false);
        return;
      }

      final response = await supabase
          .from('staffs')
          .select('staff_id')
          .eq('email', user.email!)
          .maybeSingle();

      if (response != null && response['staff_id'] != null) {
        setState(() {
          staffId = response['staff_id'].toString();
        });
      }
    } catch (e) {
      print("Error fetching staff ID: $e");
    }
  }

  Future<void> _fetchServices() async {
    try {
      final response = await supabase
          .from('services')
          .select('service_name, service_price')
          .eq('clinic_id', widget.clinicId);

      setState(() {
        services = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching services: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundCont(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            const StaffHeader(),
            Padding(
              padding: const EdgeInsets.only(top: 150, bottom: 50),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StaffAddService(
                                clinicId: widget.clinicId,
                              ),
                            ),
                          );
                        },
                        child: const Text("Add New Services"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StaffAddService(
                                clinicId: widget.clinicId,
                              ),
                            ),
                          );
                        },
                        child: const Text("Clinic Schedules"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : services.isEmpty
                            ? const Center(child: Text("No services found."))
                            : ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: services.length,
                                itemBuilder: (context, index) {
                                  final service = services[index];
                                  return Card(
                                    margin: const EdgeInsets.all(10),
                                    child: ListTile(
                                      title: Text(
                                        "Name: ${service['service_name'] ?? 'N/A'}"
                                            .trim(),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              "Price: ${service['service_price'] ?? 'N/A'} php"),
                                        ],
                                      ),
                                      leading: const Icon(Icons.medical_services),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
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
