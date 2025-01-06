import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final teacherSubjectController = TextEditingController();
  final teacherClassIdController = TextEditingController();
  final teacherDepartmentController = TextEditingController();

  // Controller for deleting teacher by username
  final deleteTeacherUsernameController = TextEditingController();

  // Add Teacher to Firestore
  void addTeacherToDatabase() async {
    if (teacherNameController.text.isEmpty ||
        teacherUsernameController.text.isEmpty ||
        teacherPasswordController.text.isEmpty ||
        teacherSubjectController.text.isEmpty ||
        teacherClassIdController.text.isEmpty ||
        teacherDepartmentController.text.isEmpty) {
      showErrorMessage('All fields are required to add a teacher');
      return;
    }

    try {
      String classId = teacherClassIdController.text.trim();

      // Add teacher to the correct class subcollection
      await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('teachers')
          .add({
        'name': teacherNameController.text.trim(),
        'username': teacherUsernameController.text.trim(),
        'password': teacherPasswordController.text.trim(),
        'subject': teacherSubjectController.text.trim(),
        'classId': classId,
        'department': teacherDepartmentController.text.trim(),
        'role': 'Teacher',
      });

      showSuccessMessage('Teacher added successfully');
      teacherNameController.clear();
      teacherUsernameController.clear();
      teacherPasswordController.clear();
      teacherSubjectController.clear();
      teacherClassIdController.clear();
      teacherDepartmentController.clear();
    } catch (e) {
      showErrorMessage('Failed to add teacher: $e');
    }
  }

  // Delete Teacher from Firestore by username
  void deleteTeacherFromDatabase() async {
    if (deleteTeacherUsernameController.text.isEmpty ||
        teacherClassIdController.text.isEmpty) {
      showErrorMessage(
          'Username and Class ID are required to delete a teacher');
      return;
    }

    try {
      String classId = teacherClassIdController.text.trim();

      // Query the teacher in the correct class subcollection
      QuerySnapshot teacherDocs = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('teachers')
          .where('username',
              isEqualTo: deleteTeacherUsernameController.text.trim())
          .get();

      if (teacherDocs.docs.isEmpty) {
        showErrorMessage(
            'No teacher found with the given username in this class');
        return;
      }

      for (var teacherDoc in teacherDocs.docs) {
        await teacherDoc.reference.delete();
      }

      showSuccessMessage('Teacher deleted successfully');
      deleteTeacherUsernameController.clear();
      teacherClassIdController.clear();
    } catch (e) {
      showErrorMessage('Failed to delete teacher: $e');
    }
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: teacherNameController,
                      decoration: const InputDecoration(
                        labelText: 'Teacher Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: teacherUsernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: teacherPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: teacherSubjectController,
                      decoration: const InputDecoration(
                        labelText: 'Subject',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: teacherClassIdController,
                      decoration: const InputDecoration(
                        labelText: 'Class ID',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: teacherDepartmentController,
                      decoration: const InputDecoration(
                        labelText: 'Department',
                        border: OutlineInputBorder(),
                      ),
                    ),
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: deleteTeacherUsernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username to Delete',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: teacherClassIdController,
                      decoration: const InputDecoration(
                        labelText: 'Class ID',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: deleteTeacherFromDatabase,
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete Teacher'),
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
