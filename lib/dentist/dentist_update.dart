import 'package:dentease/widgets/background_cont.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DentistEditPage extends StatefulWidget {
  final String dentistId;

  const DentistEditPage({super.key, required this.dentistId});

  @override
  State<DentistEditPage> createState() => _DentistEditPageState();
}

class _DentistEditPageState extends State<DentistEditPage> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String selectedRole = 'user';

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDentistDetails();
  }

  Future<void> _fetchDentistDetails() async {
    try {
      final response = await supabase
          .from('dentists')
          .select('firstname, lastname, email, phone')
          .eq('dentist_id', widget.dentistId)
          .single();

      setState(() {
        firstnameController.text = response['firstname'] ?? '';
        lastnameController.text = response['lastname'] ?? '';
        emailController.text = response['email'] ?? '';
        phoneController.text = response['phone'] ?? '';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching dentist details: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateDentistDetails() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await supabase.from('dentists').update({
        'firstname': firstnameController.text,
        'lastname': lastnameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
      }).eq('dentist_id', widget.dentistId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dentist details updated successfully!')),
      );

      Navigator.pop(context, true); // Return "true" to refresh details
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating dentist details: $e')),
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
              "Dentist update",
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent, // Transparent AppBar
            elevation: 0, // Remove shadow
            iconTheme: const IconThemeData(color: Colors.white), // White icons
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        TextFormField(
                          controller: firstnameController,
                          decoration: const InputDecoration(labelText: 'Firstname'),
                          validator: (value) => value!.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: lastnameController,
                          decoration: const InputDecoration(labelText: 'Lastname'),
                          validator: (value) => value!.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: (value) => value!.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: phoneController,
                          decoration: const InputDecoration(labelText: 'Phone'),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _updateDentistDetails,
                          child: const Text('Save Changes'),
                        ),
                      ],
                    ),
                  ),
                ),
        ));
  }
}
