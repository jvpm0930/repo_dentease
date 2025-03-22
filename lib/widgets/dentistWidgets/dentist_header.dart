import 'package:dentease/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DentistHeader extends StatefulWidget {
  const DentistHeader({super.key});

  @override
  _DentistHeaderState createState() => _DentistHeaderState();
}

class _DentistHeaderState extends State<DentistHeader> {
  String? userEmail; // Stores logged-in user's email
  String? profileUrl; // Stores the dentist's profile picture URL

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  // Fetches the currently logged-in user's email and profile picture
  Future<void> _fetchUserDetails() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      setState(() {
        userEmail = user.email; // Retrieve the email
      });

      // Fetch dentist profile details
      await _fetchProfileUrl(user.id);
    }
  }

  // Fetch the dentist's profile picture URL from the database
  Future<void> _fetchProfileUrl(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('dentists')
          .select('profile_url')
          .eq('dentist_id', userId)
          .single();

      if (response['profile_url'] != null) {
        setState(() {
          // Add cache-busting timestamp to avoid old cached images
          final url = response['profile_url'];
          profileUrl =
              '$url?timestamp=${DateTime.now().millisecondsSinceEpoch}';
        });
      }
    } catch (e) {
      debugPrint('Error fetching profile URL: $e');
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context, false),
            ),
            ElevatedButton(
              child: const Text('Logout'),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await Supabase.instance.client.auth.signOut();

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Profile Image and Email Column
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Picture with Fallback
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[300],
                    backgroundImage:
                        profileUrl != null && profileUrl!.isNotEmpty
                            ? NetworkImage(profileUrl!) // Load from Supabase
                            : const AssetImage('assets/profile.png')
                                as ImageProvider, // Fallback image
                    child: profileUrl == null || profileUrl!.isEmpty
                        ? const Icon(Icons.person, size: 30, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(height: 8),
                  // Display Email if Available
                  Text(
                    userEmail ?? "Loading...",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              // Logout Button
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white, size: 28),
                onPressed: () async => await _logout(context),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
