import 'package:dentease/clinic/ownerSignup/dental_signup.dart';
import 'package:dentease/widgets/background_container.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../login/login_screen.dart';

class DentalApplyFirst extends StatefulWidget {
  const DentalApplyFirst({super.key});

  @override
  _DentalApplyFirstState createState() => _DentalApplyFirstState();
}

class _DentalApplyFirstState extends State<DentalApplyFirst> {
  final clinicnameController = TextEditingController();
  final emailController = TextEditingController();

  final supabase = Supabase.instance.client;

  /// **🔹 Check if Clinics Name Already Exist**
  Future<bool> _checkIfNameExists(String clinicname) async {
    final response = await supabase
        .from('clinics')
        .select('clinic_id')
        .eq('clinic_name', clinicname)
        .maybeSingle();

    return response != null; // If response is not null, name exists
  }

  /// **🔹 Sign-Up Function with Duplicate Checks**
  Future<void> signUp() async {
    try {
      final clinicname = clinicnameController.text.trim();
      final email = emailController.text.trim();

      // 🔹 **Check for Empty Fields**
      if (clinicname.isEmpty || email.isEmpty) {
        _showSnackbar('Please fill in all fields.');
        return;
      }

      // 🔹 **Check if Name Exists**
      if (await _checkIfNameExists(clinicname)) {
        _showSnackbar('Name already taken. Please use a different name.');
        return;
      }

      // **Store Info in Clinic Table and Retrieve `clinic_id`**
      final response = await supabase
          .from('clinics')
          .insert({
            'clinic_name': clinicname,
            'email': email,
          })
          .select('clinic_id')
          .maybeSingle();

      if (response == null || response['clinic_id'] == null) {
        _showSnackbar('Error creating clinic. Please try again.');
        return;
      }

      final clinicId = response['clinic_id']; // Retrieve clinic_id

      // ✅ **Success Message & Navigate to Dental Signup page**
      _showSnackbar('Success! Now Dentist Signup.');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DentalSignup(
            clinicId: clinicId, // Pass clinicId
            email: email, // Pass email
          ),
        ),
      );
    } catch (e) {
      _showSnackbar('Error: $e');
    }
  }

  /// **🔹 Snackbar Message Helper**
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
        child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    Image.asset('assets/logo2.png', width: 500), // App Logo
                    const Text(
                      'Clinic Details',
                      style: TextStyle( 
                        color: Colors.white, // Change color
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(clinicnameController, 'Clinic Name',
                        Icons.local_hospital),
                    const SizedBox(height: 10),
                    _buildTextField(emailController, 'Email', Icons.mail,
                        keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 20),
                    _buildSignUpButton(Icons.arrow_left),
                    _buildLoginTextButton(),
                  ],
                ),
              ),
            )));
  }

  /// **🔹 Reusable TextField Widget**
  Widget _buildTextField(
      TextEditingController controller, String hint, IconData icon,
      {bool isPassword = false,
      TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(icon, color: Colors.indigo[900]),
        ),
      ),
    );
  }

  /// **🔹 Sign-Up Button Widget**
  Widget _buildSignUpButton(
    IconData icon
  ) {
    return ElevatedButton(
        onPressed: signUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[300], // Light grey background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50), // Fully rounded edges
          ),
          padding: const EdgeInsets.symmetric(vertical: 13),
          minimumSize: const Size(400, 20), // Wider button
          elevation: 0, // No shadow
        ),
        child: Text(
          'Next',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.indigo[900], // Dark blue text
          ),
        ));
  }

  /// **🔹 Login Redirect Button**
  Widget _buildLoginTextButton() {
    return TextButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      ),
      child: const Text(
        'Change your mind? Login',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }
}
