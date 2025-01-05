import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewRolesPage extends StatelessWidget {
  const ViewRolesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Roles'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                labelText: 'Search Users',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                // Implement search functionality if needed
              },
            ),
            const SizedBox(height: 16),

            // User List
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _getAllUsersAndStudents(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final usersAndStudents = snapshot.data!;

                  return ListView.builder(
                    itemCount: usersAndStudents.length,
                    itemBuilder: (context, index) {
                      final user = usersAndStudents[index];
                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(user['username']),
                        subtitle: Text('Role: ${user['role']}'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to fetch all users and students
  Future<List<Map<String, dynamic>>> _getAllUsersAndStudents() async {
    List<Map<String, dynamic>> combinedUsersList = [];

    // Fetch users from 'users' collection
    final usersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    for (var userDoc in usersSnapshot.docs) {
      combinedUsersList.add({
        'id': userDoc.id,
        'username': userDoc['username'],
        'role': userDoc['role'],
      });
    }

    // Fetch students from 'classes' collection (sub-collection 'students')
    final classesSnapshot =
        await FirebaseFirestore.instance.collection('classes').get();
    for (var classDoc in classesSnapshot.docs) {
      final studentsSnapshot =
          await classDoc.reference.collection('students').get();
      for (var studentDoc in studentsSnapshot.docs) {
        combinedUsersList.add({
          'id': studentDoc.id,
          'username': studentDoc['username'],
          'role': 'Student',
        });
      }
    }

    return combinedUsersList;
  }
}
