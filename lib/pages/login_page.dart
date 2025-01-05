import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collegeapp/pages/student_home_page.dart';
import 'package:collegeapp/pages/teacher_home_page.dart';
import 'package:collegeapp/pages/admin/admin_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  void signUserIn() async {
    // Show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // Get user input
      String username = usernameController.text.trim();
      String password = passwordController.text.trim();

      // Query Firestore for user in 'users' collection
      final userQuerySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .where('password', isEqualTo: password)
          .get();

      // If the user is found in the 'users' collection
      if (userQuerySnapshot.docs.isNotEmpty) {
        final userDoc = userQuerySnapshot.docs.first;
        String role = userDoc['role'];

        // Navigate to role-based page
        if (mounted) {
          Navigator.pop(context); // Remove loading circle

          if (role == 'Student') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => StudentHomePage()),
            );
          } else if (role == 'Teacher') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => TeacherHomePage()),
            );
          } else if (role == 'Admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminHomePage()),
            );
          } else {
            throw Exception('Invalid role.');
          }
        }
      } else {
        // If user is not found in the 'users' collection, check in the 'students' subcollection
        final classDocs =
            await FirebaseFirestore.instance.collection('classes').get();

        bool studentFound = false;

        for (var classDoc in classDocs.docs) {
          final studentQuerySnapshot = await FirebaseFirestore.instance
              .collection('classes')
              .doc(classDoc.id)
              .collection('students')
              .where('username', isEqualTo: username)
              .where('password', isEqualTo: password)
              .get();

          if (studentQuerySnapshot.docs.isNotEmpty) {
            if (mounted) {
              Navigator.pop(context); // Remove loading circle

              // Navigate to Student Home Page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => StudentHomePage()),
              );
            }

            studentFound = true;
            break;
          }
        }

        if (!studentFound) {
          throw Exception('Invalid username or password.');
        }
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context); // Remove loading circle
      showErrorMessage(e.toString());
    }
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.red,
          title: Center(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                const Icon(Icons.school, size: 100),
                const SizedBox(height: 50),
                Text(
                  'Welcome! Please log in',
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),
                const SizedBox(height: 25),
                // Username TextField
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                // Password TextField
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 25),
                // Sign In Button
                ElevatedButton(
                  onPressed: signUserIn,
                  child: const Text('Sign In'),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
