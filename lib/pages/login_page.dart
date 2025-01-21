// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_home_page.dart';
import 'teacher_home_page.dart';
import 'admin_home_page.dart';
import 'driver_home_page.dart'; // Import DriverHomePage

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

      // Query 'users' collection for Admins or other general users
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
          throw Exception(
              'Teachers must log in via the class-specific subcollection.');
        } else if (role == 'Admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminHomePage()),
          );
        } else {
          throw Exception('Invalid role.');
        }
        return;
      }

      // Search for teachers in 'classes' subcollections
      final classDocs =
          await FirebaseFirestore.instance.collection('classes').get();

      for (var classDoc in classDocs.docs) {
        final teacherQuerySnapshot = await FirebaseFirestore.instance
            .collection('classes')
            .doc(classDoc.id)
            .collection('teachers')
            .where('username', isEqualTo: username)
            .where('password', isEqualTo: password)
            .get();

        if (teacherQuerySnapshot.docs.isNotEmpty) {
          if (mounted) Navigator.pop(context); // Remove loading indicator

          final teacherDoc = teacherQuerySnapshot.docs.first;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TeacherHomePage(
                teacherId: teacherDoc.id,
                classId: classDoc.id,
              ),
            ),
          );
          return;
        }
      }

      // Search for students in 'classes' subcollections
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

      // Search for drivers in 'drivers' root collection
      final driverQuerySnapshot = await FirebaseFirestore.instance
          .collection('drivers')
          .where('username', isEqualTo: username)
          .where('password', isEqualTo: password)
          .get();

      if (driverQuerySnapshot.docs.isNotEmpty) {
        if (mounted) Navigator.pop(context); // Remove loading indicator

        final driverDoc = driverQuerySnapshot.docs.first;

        // Navigate to Driver Home Page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DriverHomePage(driverId: driverDoc.id),
          ),
        );
        return;
      }

      throw Exception('Invalid username or password.');
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  const Icon(Icons.school, size: 100, color: Colors.white),
                  const SizedBox(height: 20),
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Log in to your account',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: usernameController,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              prefixIcon: const Icon(Icons.person),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              prefixIcon: const Icon(Icons.lock),
                            ),
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: signUserIn,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6A11CB),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Forgot your password?',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
