import 'package:collegeapp/components/my_button.dart';
import 'package:collegeapp/components/my_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collegeapp/pages/student_home_page.dart';
import 'package:collegeapp/pages/teacher_home_page.dart';
import 'package:collegeapp/pages/admin_home_page.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final List<String> roles = ["Student", "Teacher", "Admin"];
  String? selectedRole;
  bool _isWorking = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void signUserUp() async {
    if (_isWorking) return;

    setState(() {
      _isWorking = true;
    });

    // Show loading dialog
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const Center(child: CircularProgressIndicator());
        },
      );
    }

    try {
      // Validate passwords
      if (passwordController.text != confirmPasswordController.text) {
        if (mounted) {
          Navigator.pop(context); // Close loading dialog
          _showErrorMessage('Passwords do not match.');
        }
        return;
      }

      // Validate role selection
      if (selectedRole == null) {
        if (mounted) {
          Navigator.pop(context); // Close loading dialog
          _showErrorMessage('Please select a role.');
        }
        return;
      }

      // Create user in Firebase Auth
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Save user details to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': emailController.text.trim(),
        'role': selectedRole,
        'uid': userCredential.user!.uid,
      });

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Navigate based on the selected role
      if (mounted) {
        if (selectedRole == 'Student') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => StudentHomePage()));
        } else if (selectedRole == 'Teacher') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const TeacherHomePage()));
        } else if (selectedRole == 'Admin') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const AdminHomePage()));
        }
      }
    } on FirebaseAuthException catch (e) {
      // Handle errors
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        _showErrorMessage(e.message ?? 'An error occurred. Please try again.');
      }
    } finally {
      // Reset working state
      if (mounted) {
        setState(() {
          _isWorking = false;
        });
      }
    }
  }

  void _showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple,
          title: Center(
            child: Text(message, style: const TextStyle(color: Colors.white)),
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
                  'Let\'s create an account for you!',
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),
                const SizedBox(height: 25),
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                DropdownButton<String>(
                  value: selectedRole,
                  hint: const Text('Select Role'),
                  items: roles.map((String role) {
                    return DropdownMenuItem<String>(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value;
                    });
                  },
                ),
                const SizedBox(height: 25),
                MyButton(text: "Sign Up", onTap: signUserUp),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already a member?',
                        style: TextStyle(color: Colors.grey[700])),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Login now',
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
