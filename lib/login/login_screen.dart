import 'package:dentease/admin/pages/clinics/admin_dentease_first.dart';
import 'package:dentease/clinic/ownerSignup/dental_apply_frst.dart';
import 'package:dentease/staff/staff_page.dart';
import 'package:dentease/widgets/background_container.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../dentist/dentist_page.dart';
import '../patients/patient_pagev2.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final supabase = Supabase.instance.client;

  Future<void> login() async {
    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      // Authenticate user
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final userId = response.user?.id;
      if (userId == null) throw 'Login failed';

      String? userEmail;

      // Check role in `profiles` table
      final profileResponse = await supabase
          .from('profiles')
          .select('role, email')
          .eq('id', userId)
          .maybeSingle();

      if (profileResponse != null) {
        final role = profileResponse['role'];
        userEmail = profileResponse['email'];

        if (role == 'admin') {
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logged in as $userEmail')),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AdminPage(),
            ),
          );
          return;
        }
      }

      // Check role in `patients` table
      final patientResponse = await supabase
          .from('patients')
          .select('role, email')
          .eq('patient_id', userId)
          .maybeSingle();

      if (patientResponse != null) {
        userEmail = patientResponse['email'];

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logged in as $userEmail')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PatientPage(),
          ),
        );
        return;
      }

      // Check role in `dentists` table
      final dentistResponse = await supabase
          .from('dentists')
          .select('role, email')
          .eq('dentist_id', userId)
          .maybeSingle();

      if (dentistResponse != null) {
        userEmail = dentistResponse['email'];

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logged in as $userEmail')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DentistPage(),
          ),
        );
        return;
      }

      // Check role in `staffs` table
      final staffResponse = await supabase
          .from('staffs')
          .select('role, email, clinic_id, staff_id') // Fetch staff_id
          .eq('staff_id', userId)
          .maybeSingle();

      if (staffResponse != null) {
        userEmail = staffResponse['email'];
        String clinicId = staffResponse['clinic_id']; // Get clinic_id
        String staffId = staffResponse['staff_id']; // Get staff_id

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logged in as $userEmail')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                StaffPage(clinicId: clinicId, staffId: staffId), // Pass staffId
          ),
        );
        return;
      }


      // If no role found
      throw 'User role not found in any table';
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
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
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 30),
                Image.asset('assets/logo2.png', width: 500), // App Logo
                const SizedBox(height: 40),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.mail, color: Colors.indigo[900]),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.lock, color: Colors.indigo[900]),
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    minimumSize: const Size(400, 20),
                    elevation: 0,
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[900],
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SignUpScreen()),
                  ),
                  child: const Text(
                    'Don\'t have an Account? Sign up',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DentalApplyFirst()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    minimumSize: const Size(400, 20),
                    elevation: 0,
                  ),
                  child: Text(
                    'Be our Partner',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[900],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
