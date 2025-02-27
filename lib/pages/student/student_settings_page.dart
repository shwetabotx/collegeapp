import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StudentSettingsPage extends StatefulWidget {
  final String classId;
  final String studentId;

  const StudentSettingsPage(
      {required this.classId, required this.studentId, super.key});

  @override
  StudentSettingsPageState createState() => StudentSettingsPageState();
}

class StudentSettingsPageState extends State<StudentSettingsPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();

  String? storedPassword; // To store the password fetched from Firestore

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('classes')
        .doc(widget.classId)
        .collection('students')
        .doc(widget.studentId)
        .get();

    if (userDoc.exists) {
      setState(() {
        storedPassword = userDoc['password']; // Store the actual password
      });
    }
  }

  Future<void> updateUserData() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> updatedData = {
        'username': usernameController.text.trim().isEmpty
            ? null
            : usernameController.text.trim(),
        'email': emailController.text.trim().isEmpty
            ? null
            : emailController.text.trim(),
        'phone': phoneController.text.trim().isEmpty
            ? null
            : phoneController.text.trim(),
      };

      // Remove null values (fields that were left empty)
      updatedData.removeWhere((key, value) => value == null);

      // If user wants to change the password
      if (oldPasswordController.text.isNotEmpty ||
          newPasswordController.text.isNotEmpty) {
        if (storedPassword == oldPasswordController.text.trim()) {
          updatedData['password'] = newPasswordController.text.trim();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Old password is incorrect!"),
            backgroundColor: Colors.red,
          ));
          return;
        }
      }

      // Update only if there are changes
      if (updatedData.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('classes')
            .doc(widget.classId)
            .collection('students')
            .doc(widget.studentId)
            .update(updatedData);

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Profile Updated Successfully"),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("No changes made"),
        ));
      }

      // Clear the password fields
      oldPasswordController.clear();
      newPasswordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: "New Username"),
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "New Email"),
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                controller: phoneController,
                decoration:
                    const InputDecoration(labelText: "New Phone Number"),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              const Text("Change Password",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextFormField(
                controller: oldPasswordController,
                decoration: const InputDecoration(labelText: "Old Password"),
                obscureText: true,
              ),
              TextFormField(
                controller: newPasswordController,
                decoration: const InputDecoration(labelText: "New Password"),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: updateUserData, child: const Text("Save Changes")),
            ],
          ),
        ),
      ),
    );
  }
}
