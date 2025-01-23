import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentAssignmentPage extends StatelessWidget {
  final String classId;

  const StudentAssignmentPage({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Assignments"),
        backgroundColor: Colors.deepOrange,
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
              final assignment = snapshot.data!.docs[index];
              return Card(
                child: ListTile(
                  title: Text(assignment['title']),
                  subtitle: Text(
                    "${assignment['description']}\nDue: ${assignment['dueDate']}",
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
