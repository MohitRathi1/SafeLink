// lib/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:clinte/core/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () async {
            User? user = await AuthService().signInWithGoogle();
            if (user != null) {
              // Navigate to the main app screen after successful login
              // Replace with your home screen
              Navigator.of(context).pushReplacementNamed('/home');
            } else {
              // Handle login failure, show a message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to sign in with Google.')),
              );
            }
          },
          icon: Image.asset(
            'assets/google-logo.png', // You'll need to add a Google logo image to your assets folder
            height: 24.0,
          ),
          label: const Text('Sign in with Google'),
        ),
      ),
    );
  }
}