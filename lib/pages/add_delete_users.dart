import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddDeleteUsersPage extends StatefulWidget {
  const AddDeleteUsersPage({super.key});

  @override
  State<AddDeleteUsersPage> createState() => _AddDeleteUsersPageState();
}

class _AddDeleteUsersPageState extends State<AddDeleteUsersPage> {
  // Controllers for adding a user
  final addUsernameController = TextEditingController();
  final addPasswordController = TextEditingController();
  final addRoleController = TextEditingController();

  // Controller for deleting a user
  final deleteUsernameController = TextEditingController();

  // Add User to Firestore
  void addUserToDatabase() async {
    if (addUsernameController.text.isEmpty ||
        addPasswordController.text.isEmpty ||
        addRoleController.text.isEmpty) {
      showErrorMessage('All fields are required to add a user');
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('users').add({
        'username': addUsernameController.text.trim(),
        'password': addPasswordController.text.trim(),
        'role': addRoleController.text.trim(),
      });

      showSuccessMessage('User added successfully');
      addUsernameController.clear();
      addPasswordController.clear();
      addRoleController.clear();
    } catch (e) {
      showErrorMessage('Failed to add user: $e');
    }
  }

  // Delete User from Firestore
  void deleteUserFromDatabase() async {
    if (deleteUsernameController.text.isEmpty) {
      showErrorMessage('Username is required to delete a user');
      return;
    }

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: deleteUsernameController.text.trim())
          .get();

      if (querySnapshot.docs.isEmpty) {
        showErrorMessage('No user found with the given username');
        return;
      }

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      showSuccessMessage('User deleted successfully');
      deleteUsernameController.clear();
    } catch (e) {
      showErrorMessage('Failed to delete user: $e');
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
        title: const Text('Admin Panel'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add User Section
            Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add User',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: addUsernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: addPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: addRoleController,
                      decoration: const InputDecoration(
                        labelText: 'Role (e.g., Student, Teacher, Admin)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: addUserToDatabase,
                      icon: const Icon(Icons.add),
                      label: const Text('Add User'),
                    ),
                  ],
                ),
              ),
            ),
            // Delete User Section
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Delete User',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: deleteUsernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username to Delete',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: deleteUserFromDatabase,
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete User'),
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
