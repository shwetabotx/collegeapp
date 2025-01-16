import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Function to fetch attendance records for a specific student
Future<List<Map<String, dynamic>>> getStudentAttendance(
    String classId, String studentId) async {
  // Reference to the attendance subcollection
  CollectionReference attendanceRef = FirebaseFirestore.instance
      .collection('classes') // Root collection
      .doc(classId) // Class document
      .collection('students') // Students subcollection
      .doc(studentId) // Specific student document
      .collection('attendance'); // Attendance subcollection

  // Fetch all attendance records
  QuerySnapshot snapshot = await attendanceRef.get();

  // Map each document to a list of data
  return snapshot.docs
      .map((doc) => doc.data() as Map<String, dynamic>)
      .toList();
}

/// Attendance Screen Widget
class AttendanceScreen extends StatelessWidget {
  final String classId; // Class ID
  final String studentId; // Student ID

  const AttendanceScreen(
      {super.key, required this.classId, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Tracking 👩🏻‍🏫'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getStudentAttendance(classId, studentId), // Fetch attendance
        builder: (context, snapshot) {
          // Show loading spinner while data is being fetched
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // Show error if there's an issue
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Get the attendance data
          final attendanceRecords = snapshot.data ?? [];

          // Show message if no records are found
          if (attendanceRecords.isEmpty) {
            return Center(child: Text('No attendance records found.'));
          }

          // Display attendance records in a ListView
          return ListView.builder(
            itemCount: attendanceRecords.length,
            itemBuilder: (context, index) {
              final record = attendanceRecords[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  leading: Icon(
                    record['status'] == 'Present'
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: record['status'] == 'Present'
                        ? Colors.green
                        : Colors.red,
                  ),
                  title: Text('Date: ${record['date']}'),
                  subtitle: Text('Status: ${record['status']}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
