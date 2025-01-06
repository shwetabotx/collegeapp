// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_home_page.dart';
import 'teacher_home_page.dart';
import 'admin_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  void signUserIn() async {
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      String username = usernameController.text.trim();
      String password = passwordController.text.trim();

      // Query 'users' collection
      final userQuerySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .where('password', isEqualTo: password)
          .get();

      if (userQuerySnapshot.docs.isNotEmpty) {
        final userDoc = userQuerySnapshot.docs.first;
        String role = userDoc['role'];

        if (mounted) Navigator.pop(context); // Remove loading indicator

        if (role == 'Student') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => StudentHomePage(
                classId: userDoc['classId'],
                studentId: userDoc.id,
              ),
            ),
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
      } else {
        // Search in 'teachers' collection
        final teacherQuerySnapshot = await FirebaseFirestore.instance
            .collection('teachers')
            .where('username', isEqualTo: username)
            .where('password', isEqualTo: password)
            .get();

        if (teacherQuerySnapshot.docs.isNotEmpty) {
          if (mounted) Navigator.pop(context); // Remove loading indicator

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => TeacherHomePage()),
          );
          return;
        }

        // Search in 'students' subcollection
        final classDocs =
            await FirebaseFirestore.instance.collection('classes').get();

        for (var classDoc in classDocs.docs) {
          final studentQuerySnapshot = await FirebaseFirestore.instance
              .collection('classes')
              .doc(classDoc.id)
              .collection('students')
              .where('username', isEqualTo: username)
              .where('password', isEqualTo: password)
              .get();

          if (studentQuerySnapshot.docs.isNotEmpty) {
            if (mounted) Navigator.pop(context); // Remove loading indicator

            final studentDoc = studentQuerySnapshot.docs.first;

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => StudentHomePage(
                  classId: classDoc.id,
                  studentId: studentDoc.id,
                ),
              ),
            );
            return;
          }
        }

        throw Exception('Invalid username or password.');
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Remove loading indicator
      showErrorMessage("Invalid credentials. Please try again.");
    }
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red,
        title: Center(
          child: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
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
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 25),
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
