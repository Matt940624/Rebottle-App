import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Center(
      child: Container(
        color: Colors.grey[300],
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 50),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: const Icon(
                Icons.person,
                size: 50,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              user.email ?? 'No email',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            // App Info Button
            const SizedBox(height: 100),
            ElevatedButton(
              onPressed: () => _showInfoDialog(
                context,
                "App Info",
                "Rebottle App\nVersion: 1.0.0\nDeveloped by Matt Shih and Michael Shih",
              ),
              style: _buttonStyle(),
              child: const Text('App Info',style: TextStyle(color: Colors.black87)),
            ),
            const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _showInfoDialog(
                  context,
                  "History",
                  "dates",
                ),
                style: _buttonStyle(),
                child: const Text('History'
                ,style: TextStyle(color: Colors.black87),),
              ),
            const SizedBox(height: 250),
            ElevatedButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

   // Reusable method to show an information dialog with custom colors
  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[200], // Set popup background color
          title: Text(title, style: const TextStyle(color: Colors.black)),
          content: Text(
            content,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.grey[200],
      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}