import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final studentPhoneNumberController = TextEditingController();
  final studentUsernameController = TextEditingController();

  // Controller for deleting a student by their username
  final deleteStudentUsernameController = TextEditingController();

  // Add Student to Firestore
  void addStudentToDatabase() async {
    if (studentNameController.text.isEmpty ||
        studentPasswordController.text.isEmpty ||
        studentRollNumberController.text.isEmpty ||
        studentClassIdController.text.isEmpty ||
        studentEmailController.text.isEmpty ||
        studentPhoneNumberController.text.isEmpty ||
        studentUsernameController.text.isEmpty) {
      showErrorMessage('All fields are required to add a student');
      return;
    }

    try {
      DocumentSnapshot classDoc = await FirebaseFirestore.instance
          .collection('classes')
          .doc(studentClassIdController.text.trim())
          .get();

      if (!classDoc.exists) {
        showErrorMessage('Class not found');
        return;
      }

      await FirebaseFirestore.instance
          .collection('classes')
          .doc(studentClassIdController.text.trim())
          .collection('students')
          .add({
        'name': studentNameController.text.trim(),
        'username': studentUsernameController.text.trim(),
        'password': studentPasswordController.text.trim(),
        'rollNumber': studentRollNumberController.text.trim(),
        'classId': studentClassIdController.text.trim(),
        'email': studentEmailController.text.trim(),
        'phoneNumber': studentPhoneNumberController.text.trim(),
        'role': 'Student',
      });

      showSuccessMessage('Student added successfully');
      studentNameController.clear();
      studentPasswordController.clear();
      studentRollNumberController.clear();
      studentClassIdController.clear();
      studentEmailController.clear();
      studentPhoneNumberController.clear();
      studentUsernameController.clear();
    } catch (e) {
      showErrorMessage('Failed to add student: $e');
    }
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: studentNameController,
                      decoration: const InputDecoration(
                        labelText: 'Student Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: studentUsernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: studentPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: studentRollNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Roll Number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: studentClassIdController,
                      decoration: const InputDecoration(
                        labelText: 'Class ID',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: studentEmailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: studentPhoneNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                    ),
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Delete Student',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: deleteStudentUsernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username to Delete',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: deleteStudentFromDatabase,
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete Student'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
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
}
