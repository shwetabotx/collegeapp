// ignore_for_file: avoid_print

import 'package:collegeapp/pages/admin_home_page.dart';
import 'package:collegeapp/pages/admin/user_details_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewUsersPage extends StatefulWidget {
  const ViewUsersPage({super.key, required this.adminId});
  final String adminId;

  @override
  ViewUsersPageState createState() => ViewUsersPageState();
}

class ViewUsersPageState extends State<ViewUsersPage> {
  String searchQuery = '';
  List<Map<String, dynamic>> teachers = [];
  List<Map<String, dynamic>> students = [];
  bool showTeachers = true;
  bool isLoading = true;

  List<String> classFilters = [
    'All',
    'FYBA',
    'FYBCOM',
    'FYBS',
    'SYBA',
    'SYBCOM',
    'SYBS',
    'TYBA',
    'TYBCOM',
    'TYBS',
    'LYBA',
    'LYBCOM',
    'LYBS',
  ];
  String selectedClass = 'All'; // Default: Show all classes

  @override
  void initState() {
    super.initState();
    _getAllUsersTeachersAndStudents();
  }

  Future<void> _getAllUsersTeachersAndStudents() async {
    Map<String, List<Map<String, dynamic>>> result = {
      'teachers': [],
      'students': [],
    };

    try {
      final classesSnapshot =
          await FirebaseFirestore.instance.collection('classes').get();
      for (var classDoc in classesSnapshot.docs) {
        final classId = classDoc.id; // Store classId

        final teachersSnapshot =
            await classDoc.reference.collection('teachers').get();
        for (var teacherDoc in teachersSnapshot.docs) {
          result['teachers']!.add({
            'id': teacherDoc.id,
            'classId': classId, // Store classId for fetching later
            'username': teacherDoc['username'],
            'name': teacherDoc['name'],
            'role': 'Teacher',
          });
        }

        final studentsSnapshot =
            await classDoc.reference.collection('students').get();
        for (var studentDoc in studentsSnapshot.docs) {
          result['students']!.add({
            'id': studentDoc.id,
            'classId': classId, // Store classId for filtering
            'username': studentDoc['username'],
            'name': studentDoc['name'],
            'role': 'Student',
          });
        }
      }

      setState(() {
        teachers = result['teachers']!;
        students = result['students']!;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

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
                subtitle: Text('Username: ${item['username']}'),
                title: Text('Name: ${item['name']}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserDetailsPage(
                        userId: item['id'],
                        classId: item['classId'],
                        role: item['role'],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _filterItems(List<Map<String, dynamic>> items) {
    return items.where((item) {
      final matchesSearch =
          item['username'].toLowerCase().contains(searchQuery.toLowerCase());
      final matchesClass =
          selectedClass == 'All' || item['classId'] == selectedClass;
      return matchesSearch && matchesClass;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTeachers = _filterItems(teachers);
    final filteredStudents = _filterItems(students);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'View Users',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => AdminHomePage(
                        adminId: widget.adminId,
                      )),
            );
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            showTeachers = true;
                          });
                        },
                        child: const Text('Teachers'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            showTeachers = false;
                          });
                        },
                        child: const Text('Students'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (!showTeachers)
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: classFilters.map((className) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: Text(className),
                              selected: selectedClass == className,
                              onSelected: (bool selected) {
                                setState(() {
                                  selectedClass = selected ? className : 'All';
                                });
                              },
                              selectedColor: Colors.deepPurple,
                              backgroundColor: Colors.grey[300],
                              labelStyle: TextStyle(
                                color: selectedClass == className
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: [
                        if (showTeachers && filteredTeachers.isNotEmpty)
                          _buildSection('Teachers', filteredTeachers),
                        if (!showTeachers && filteredStudents.isNotEmpty)
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
