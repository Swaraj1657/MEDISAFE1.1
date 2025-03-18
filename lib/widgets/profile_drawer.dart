import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Pages/edit_profile_page.dart';
import '../Authentication/login_screen.dart';

class ProfileDrawer extends StatefulWidget {
  const ProfileDrawer({super.key});

  @override
  State<ProfileDrawer> createState() => _ProfileDrawerState();
}

class _ProfileDrawerState extends State<ProfileDrawer> {
  String _username = 'User';
  String _email = '';
  File? _profileImage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Load user data
      String username = prefs.getString('username') ?? '';
      String email = prefs.getString('user_email') ?? '';

      // Load profile picture path
      String? imagePath = prefs.getString('profile_image_path');
      File? profileImage;

      if (imagePath != null && imagePath.isNotEmpty) {
        File imageFile = File(imagePath);
        if (await imageFile.exists()) {
          profileImage = imageFile;
        }
      }

      if (mounted) {
        setState(() {
          _username = username.isNotEmpty ? username : 'User';
          _email = email;
          _profileImage = profileImage;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Simple logout function
  void _logout(BuildContext context) {
    // Sign out from Firebase
    FirebaseAuth.instance
        .signOut()
        .then((_) {
          // Navigate to login screen
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => false,
          );
        })
        .catchError((error) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to logout: ${error.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              _username,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(
              _email.isNotEmpty ? _email : 'Add your email',
              style: const TextStyle(color: Colors.white),
            ),
            currentAccountPicture:
                _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage:
                          _profileImage != null
                              ? FileImage(_profileImage!)
                              : null,
                      child:
                          _profileImage == null
                              ? const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.blue,
                              )
                              : null,
                    ),
            decoration: const BoxDecoration(color: Colors.blue),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Edit Profile'),
            onTap: () {
              // First close the drawer
              Navigator.pop(context);
              // Then navigate to edit profile page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfilePage(),
                ),
              ).then((_) {
                // Reload user data when returning from edit profile
                _loadUserData();
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notifications'),
            onTap: () {
              // TODO: Implement notifications
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Medicine History'),
            onTap: () {
              // TODO: Implement medicine history
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {
              // TODO: Implement settings
              Navigator.pop(context);
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              // Close the drawer first
              Navigator.pop(context);
              // Then logout
              _logout(context);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
