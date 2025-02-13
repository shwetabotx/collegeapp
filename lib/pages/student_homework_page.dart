import 'package:collegeapp/pages/student_home_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentHomeworkPage extends StatelessWidget {
  final String classId;
  final String studentId;

  const StudentHomeworkPage({
    super.key,
    required this.classId,
    required this.studentId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Student Homework",
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
            .collection('homework')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No homework available."));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final homework = snapshot.data!.docs[index];
              String dueDateFormatted = "No due date";

              if (homework['dueDate'] != null) {
                try {
                  DateTime dueDate = DateTime.parse(homework['dueDate']);
                  dueDateFormatted =
                      "${dueDate.year}-${dueDate.month}-${dueDate.day}";
                } catch (e) {
                  dueDateFormatted = "Invalid date";
                }
              }

              return Card(
                child: ListTile(
                  title: Text(homework['title']),
                  subtitle: Text(
                    "${homework['description']}\nDue: $dueDateFormatted",
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
