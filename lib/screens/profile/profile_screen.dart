import 'package:flutter/material.dart';

// Placeholder Profile tab. Layout penuh menyusul (UC-19/UC-20).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1A),
        elevation: 0,
        title: const Text('PROFILE',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
      ),
      body: const Center(
        child: Text('Profile coming soon',
            style: TextStyle(color: Colors.grey)),
      ),
    );
  }
}
