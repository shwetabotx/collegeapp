import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';

class AddDeleteTeachersPage extends StatefulWidget {
  const AddDeleteTeachersPage({super.key});

  @override
  State<AddDeleteTeachersPage> createState() => _AddDeleteTeachersPageState();
}

class _AddDeleteTeachersPageState extends State<AddDeleteTeachersPage> {
  // Controllers for adding teachers
  final teacherNameController = TextEditingController();
  final teacherUsernameController = TextEditingController();
  final teacherPasswordController = TextEditingController();
  final teacherClassIdController = TextEditingController();
  final teacherDepartmentController = TextEditingController();
  final teacherIdController = TextEditingController();
  final teacherEmailController = TextEditingController();
  final teacherPhoneController = TextEditingController();

  // Controllers for deleting teachers
  final deleteTeacherUsernameController = TextEditingController();
  final deleteTeacherClassIdController = TextEditingController();

  // Add Teacher to Firestore
  void addTeacherToDatabase() async {
    String name = teacherNameController.text.trim();
    String username = teacherUsernameController.text.trim();
    String password = teacherPasswordController.text.trim();
    String classId = teacherClassIdController.text.trim().toUpperCase();
    String department = teacherDepartmentController.text.trim();
    String teacherId = teacherIdController.text.trim();
    String email = teacherEmailController.text.trim();
    String phone = teacherPhoneController.text.trim();

    // Validations
    if (name.isEmpty ||
        username.isEmpty ||
        password.isEmpty ||
        classId.isEmpty ||
        department.isEmpty ||
        teacherId.isEmpty ||
        email.isEmpty ||
        phone.isEmpty) {
      showErrorMessage('All fields are required');
      return;
    }

    if (!EmailValidator.validate(email)) {
      showErrorMessage('Invalid email format');
      return;
    }

    if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
      showErrorMessage('Phone number must be exactly 10 digits');
      return;
    }

    try {
      DocumentReference teacherRef = FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('teachers')
          .doc(username); // Use username as document ID

      DocumentSnapshot teacherSnapshot = await teacherRef.get();

      if (teacherSnapshot.exists) {
        showErrorMessage('A teacher with this username already exists.');
        return;
      }

      // Add teacher with username as document ID
      await teacherRef.set({
        'name': name,
        'username': username,
        'password': password,
        'classId': classId,
        'department': department,
        'teacherId': teacherId,
        'email': email,
        'phone': phone,
        'role': 'Teacher',
      });

      showSuccessMessage('Teacher added successfully');
      _clearFields();
    } catch (e) {
      showErrorMessage('Failed to add teacher: $e');
    }
  }

  // Delete Teacher from Firestore
  void deleteTeacherFromDatabase() async {
    String username = deleteTeacherUsernameController.text.trim();
    String classId = deleteTeacherClassIdController.text.trim().toUpperCase();

    if (username.isEmpty || classId.isEmpty) {
      showErrorMessage(
          'Username and Class ID are required to delete a teacher');
      return;
    }

    try {
      DocumentReference teacherRef = FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('teachers')
          .doc(username);

      DocumentSnapshot teacherSnapshot = await teacherRef.get();

      if (!teacherSnapshot.exists) {
        showErrorMessage('No teacher found with this username in this class');
        return;
      }

      await teacherRef.delete();

      showSuccessMessage('Teacher deleted successfully');
      deleteTeacherUsernameController.clear();
      deleteTeacherClassIdController.clear();
    } catch (e) {
      showErrorMessage('Failed to delete teacher: $e');
    }
  }

  // Clear input fields
  void _clearFields() {
    teacherNameController.clear();
    teacherUsernameController.clear();
    teacherPasswordController.clear();
    teacherClassIdController.clear();
    teacherDepartmentController.clear();
    teacherIdController.clear();
    teacherEmailController.clear();
    teacherPhoneController.clear();
  }

  // Show success message
  void showSuccessMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.green,
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

  // Show error message
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
      appBar: AppBar(
        title: const Text('Manage Teachers'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add Teacher Section
            Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add Teacher',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(teacherNameController, 'Teacher Name'),
                    _buildTextField(teacherUsernameController, 'Username'),
                    _buildTextField(teacherPasswordController, 'Password',
                        obscureText: true),
                    _buildTextField(teacherClassIdController, 'Class ID '),
                    _buildTextField(teacherDepartmentController, 'Department'),
                    _buildTextField(teacherIdController, 'Teacher ID'),
                    _buildTextField(teacherEmailController, 'Email'),
                    _buildTextField(
                        teacherPhoneController, 'Phone (10 digits)'),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: addTeacherToDatabase,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Teacher'),
                    ),
                  ],
                ),
              ),
            ),
            // Delete Teacher Section
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Delete Teacher',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                        deleteTeacherUsernameController, 'Username to Delete'),
                    _buildTextField(deleteTeacherClassIdController, 'Class ID'),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: deleteTeacherFromDatabase,
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete Teacher'),
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget for text fields
  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
