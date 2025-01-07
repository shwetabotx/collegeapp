import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewRolesPage extends StatefulWidget {
  const ViewRolesPage({super.key});

  @override
  ViewRolesPageState createState() => ViewRolesPageState();
}

class ViewRolesPageState extends State<ViewRolesPage> {
  String searchQuery = '';
  List<Map<String, dynamic>> teachers = [];
  List<Map<String, dynamic>> students = [];

  @override
  void initState() {
    super.initState();
    _getAllUsersTeachersAndStudents();
  }

  // Function to fetch all teachers and students from classes
  Future<void> _getAllUsersTeachersAndStudents() async {
    Map<String, List<Map<String, dynamic>>> result = {
      'teachers': [],
      'students': [],
    };

    try {
      // Fetch classes from 'classes' collection
      final classesSnapshot =
          await FirebaseFirestore.instance.collection('classes').get();
      for (var classDoc in classesSnapshot.docs) {
        // Fetch teachers from the 'teachers' sub-collection within each class
        final teachersSnapshot =
            await classDoc.reference.collection('teachers').get();
        for (var teacherDoc in teachersSnapshot.docs) {
          result['teachers']!.add({
            'id': teacherDoc.id,
            'username': teacherDoc['username'],
            'role': 'Teacher',
          });
        }

        // Fetch students from the 'students' sub-collection within each class
        final studentsSnapshot =
            await classDoc.reference.collection('students').get();
        for (var studentDoc in studentsSnapshot.docs) {
          result['students']!.add({
            'id': studentDoc.id,
            'username': studentDoc['username'],
            'role': 'Student',
          });
        }
      }

      // Update state with the fetched data
      setState(() {
        teachers = result['teachers']!;
        students = result['students']!;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching data: $e');
    }
  }

  // Helper function to build sections in the list view
  Widget _buildSection(String title, List<Map<String, dynamic>> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(item['username']),
                subtitle: Text('Role: ${item['role']}'),
              );
            },
          ),
        ],
      ),
    );
  }

  // Function to filter items based on the search query
  List<Map<String, dynamic>> _filterItems(List<Map<String, dynamic>> items) {
    return items.where((item) {
      return item['username'].toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTeachers = _filterItems(teachers);
    final filteredStudents = _filterItems(students);

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
                setState(() {
                  searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // User List
            Expanded(
              child: ListView(
                children: [
                  if (filteredTeachers.isNotEmpty)
                    _buildSection('Teachers', filteredTeachers),
                  if (filteredStudents.isNotEmpty)
                    _buildSection('Students', filteredStudents),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
