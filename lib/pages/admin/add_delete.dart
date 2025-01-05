import 'package:flutter/material.dart';
import 'add_delete_students_page.dart';
import 'add_delete_teachers_page.dart';

class AddDeletePage extends StatelessWidget {
  const AddDeletePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Manage Students Card
            Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 20.0),
              child: ListTile(
                leading: const Icon(
                  Icons.group_add,
                  color: Colors.blue,
                  size: 40,
                ),
                title: const Text(
                  'Manage Students',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text('Add Or Delete Students'),
                onTap: () {
                  // Navigate to the Add/Delete Students page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddDeleteStudentsPage()),
                  );
                },
              ),
            ),
            // Manage Teachers Card
            Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 20.0),
              child: ListTile(
                leading: const Icon(
                  Icons.school,
                  color: Colors.green,
                  size: 40,
                ),
                title: const Text(
                  'Manage Teachers',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text('Add Or Delete Teachers'),
                onTap: () {
                  // Navigate to the Add/Delete Teachers page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddDeleteTeachersPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
