import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StaffClinicSchedPage extends StatefulWidget {
  final String dentistId;
  final String clinicId;

  const StaffClinicSchedPage(
      {super.key, required this.dentistId, required this.clinicId});

  @override
  _StaffClinicSchedPageState createState() => _StaffClinicSchedPageState();
}

class _StaffClinicSchedPageState extends State<StaffClinicSchedPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> schedules = [];
  DateTime selectedDate = DateTime.now();
  int startTime = 9;
  int endTime = 17;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchSchedule();
  }

  /// 🔹 Fetch the existing schedule for the dentist
  Future<void> _fetchSchedule() async {
    final response = await supabase
        .from('staff_schedule')
        .select()
        .eq('staff_id', widget.dentistId)
        .eq('clinic_id', widget.clinicId)
        .order('date', ascending: true);

    setState(() {
      schedules = List<Map<String, dynamic>>.from(response);
    });
  }

  /// 🔹 Add a new schedule
  Future<void> _addSchedule() async {
    setState(() => isLoading = true);

    await supabase.from('staff_schedule').insert({
      'staff_id': widget.dentistId,
      'clinic_id': widget.clinicId,
      'date': selectedDate.toIso8601String(),
      'start_time': startTime,
      'end_time': endTime,
    });

    _fetchSchedule();
    setState(() => isLoading = false);
  }

  /// 🔹 Delete a schedule
  Future<void> _deleteSchedule(String id) async {
    await supabase.from('staff_schedule').delete().eq('id', id);
    _fetchSchedule();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Schedule")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Date Picker
            ListTile(
              title: Text(
                  "Selected Date: ${selectedDate.toLocal()}".split(' ')[0]),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (picked != null) setState(() => selectedDate = picked);
                },
              ),
            ),

            // Start & End Hour Pickers
            DropdownButton<int>(
              value: startTime,
              items: List.generate(24, (index) => index)
                  .map((hour) =>
                      DropdownMenuItem(value: hour, child: Text("$hour:00")))
                  .toList(),
              onChanged: (value) => setState(() => startTime = value!),
            ),
            const Text("to"),
            DropdownButton<int>(
              value: endTime,
              items: List.generate(24, (index) => index)
                  .map((hour) =>
                      DropdownMenuItem(value: hour, child: Text("$hour:00")))
                  .toList(),
              onChanged: (value) => setState(() => endTime = value!),
            ),

            const SizedBox(height: 20),

            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _addSchedule,
                    child: const Text("Save Schedule"),
                  ),

            const SizedBox(height: 20),

            // Display existing schedules
            Expanded(
              child: ListView.builder(
                itemCount: schedules.length,
                itemBuilder: (context, index) {
                  final schedule = schedules[index];
                  return Card(
                    child: ListTile(
                      title: Text("Date: ${schedule['date'].split('T')[0]}"),
                      subtitle: Text(
                          "Time: ${schedule['start_time']}:00 - ${schedule['end_time']}:00"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteSchedule(schedule['id']),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
