import 'package:collegeapp/pages/student_home_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class StudentAssignmentPage extends StatelessWidget {
  final String classId;
  final String studentId;

  const StudentAssignmentPage({
    super.key,
    required this.classId,
    required this.studentId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Student Assignments",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => StudentHomePage(
                  classId: classId,
                  studentId: studentId,
                  driverId: '',
                ),
              ),
            );
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('classes')
            .doc(classId)
            .collection('assignments')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No assignments available."));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final assignment =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>?;

              // Ensure assignment is not null
              if (assignment == null) {
                return const SizedBox(); // Skip this entry if it's null
              }

              String title = assignment['title'] ?? "No Title";
              String description =
                  assignment['description'] ?? "No Description";

              // Safely handle the dueDate field
              String formattedDueDate = "No due date";
              if (assignment.containsKey('dueDate') &&
                  assignment['dueDate'] is Timestamp) {
                Timestamp dueDateTimestamp = assignment['dueDate'];
                formattedDueDate =
                    DateFormat('yyyy-MM-dd').format(dueDateTimestamp.toDate());
              }

              return Card(
                child: ListTile(
                  title: Text(title),
                  subtitle: Text(
                    "$description\nDue: $formattedDueDate",
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
