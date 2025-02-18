import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';

class AddDeleteStudentsPage extends StatefulWidget {
  const AddDeleteStudentsPage({super.key});

  @override
  State<AddDeleteStudentsPage> createState() => _AddDeleteStudentsPageState();
}

class _AddDeleteStudentsPageState extends State<AddDeleteStudentsPage> {
  // Controllers for adding students
  final studentNameController = TextEditingController();
  final studentPasswordController = TextEditingController();
  final studentRollNumberController = TextEditingController();
  final studentClassIdController = TextEditingController();
  final studentEmailController = TextEditingController();
  final studentPhoneController = TextEditingController();
  final studentUsernameController = TextEditingController();
  final studentDepartmentController = TextEditingController();
  final studentDriverIdController = TextEditingController();

  // Controller for deleting a student by their username
  final deleteStudentUsernameController = TextEditingController();

  // Add Student to Firestore
  void addStudentToDatabase() async {
    String classId = studentClassIdController.text.trim().toUpperCase();
    String studentId = studentUsernameController.text.trim();
    String phone = studentPhoneController.text.trim();
    String email = studentEmailController.text.trim();

    // Validate required fields
    if (studentNameController.text.isEmpty ||
        studentPasswordController.text.isEmpty ||
        studentRollNumberController.text.isEmpty ||
        classId.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        studentId.isEmpty ||
        studentDepartmentController.text.isEmpty ||
        studentDriverIdController.text.isEmpty) {
      showErrorMessage('All fields are required to add a student');
      return;
    }

    // Validate phone number (10 digits only)
    if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
      showErrorMessage('Phone number must be exactly 10 digits');
      return;
    }

    // Validate email format
    if (!EmailValidator.validate(email)) {
      showErrorMessage('Invalid email format');
      return;
    }

    try {
      DocumentSnapshot classDoc = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .get();

      if (!classDoc.exists) {
        showErrorMessage('Class not found');
        return;
      }

      await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('students')
          .doc(studentId)
          .set({
        'name': studentNameController.text.trim(),
        'username': studentId,
        'password': studentPasswordController.text.trim(),
        'rollNumber': studentRollNumberController.text.trim(),
        'classId': classId,
        'email': email,
        'phone': phone,
        'department': studentDepartmentController.text.trim(),
        'driverId': studentDriverIdController.text.trim(),
        'role': 'Student',
      });

      showSuccessMessage('Student added successfully');
      clearFields();
    } catch (e) {
      showErrorMessage('Failed to add student: $e');
    }
  }

  // Clear all input fields
  void clearFields() {
    studentNameController.clear();
    studentPasswordController.clear();
    studentRollNumberController.clear();
    studentClassIdController.clear();
    studentEmailController.clear();
    studentPhoneController.clear();
    studentUsernameController.clear();
    studentDepartmentController.clear();
    studentDriverIdController.clear();
  }

  // Delete Student from Firestore by Username
  void deleteStudentFromDatabase() async {
    if (deleteStudentUsernameController.text.isEmpty) {
      showErrorMessage('Username is required to delete a student');
      return;
    }

    try {
      QuerySnapshot classDocs =
          await FirebaseFirestore.instance.collection('classes').get();

      bool studentFound = false;

      for (var classDoc in classDocs.docs) {
        QuerySnapshot studentDocs = await FirebaseFirestore.instance
            .collection('classes')
            .doc(classDoc.id)
            .collection('students')
            .where('username',
                isEqualTo: deleteStudentUsernameController.text.trim())
            .get();

        if (studentDocs.docs.isNotEmpty) {
          for (var studentDoc in studentDocs.docs) {
            await studentDoc.reference.delete();
          }

          showSuccessMessage('Student deleted successfully');
          deleteStudentUsernameController.clear();
          studentFound = true;
          break;
        }
      }

      if (!studentFound) {
        showErrorMessage('No student found with the given username');
      }
    } catch (e) {
      showErrorMessage('Failed to delete student: $e');
    }
  }

  void showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
    );
  }

  void showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Students'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add Student Section
            Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add Student',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    textField(studentNameController, 'Student Name'),
                    textField(studentUsernameController, 'Username'),
                    textField(studentPasswordController, 'Password',
                        isPassword: true),
                    textField(studentRollNumberController, 'Roll Number'),
                    textField(studentClassIdController, 'Class ID'),
                    textField(studentEmailController, 'Email'),
                    textField(
                        studentPhoneController, 'Phone Number (10 digits)'),
                    textField(studentDepartmentController, 'Department'),
                    textField(studentDriverIdController, 'Driver ID'),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: addStudentToDatabase,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Student'),
                    ),
                  ],
                ),
              ),
            ),

            // Delete Student Section
            Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Delete Student',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    textField(deleteStudentUsernameController,
                        'Enter Username to Delete'),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: deleteStudentFromDatabase,
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete Student'),
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

  Widget textField(TextEditingController controller, String label,
      {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
