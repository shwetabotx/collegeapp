import 'package:collegeapp/pages/student_home_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceTrackingPage extends StatelessWidget {
  final String classId;
  final String studentId;

  const AttendanceTrackingPage(
      {super.key, required this.classId, required this.studentId});

  Future<List<Map<String, dynamic>>> fetchAttendanceRecords() async {
    final attendanceSnapshot = await FirebaseFirestore.instance
        .collection('classes')
        .doc(classId)
        .collection('students')
        .doc(studentId)
        .collection('attendance')
        .get();

    return attendanceSnapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Attendance Records 🙋🏻‍♀️",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    offset: const Offset(0, 2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Icon(Icons.access_alarm, size: 40, color: Colors.deepPurple),
                  SizedBox(height: 8),
                  Text(
                    "Your Attendance Records",
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Track your attendance history.",
                    style: TextStyle(color: Colors.deepPurple, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Attendance List
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchAttendanceRecords(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final attendanceRecords = snapshot.data!;
                    return ListView.builder(
                      itemCount: attendanceRecords.length,
                      itemBuilder: (context, index) {
                        final record = attendanceRecords[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(
                              "Date: ${record['date']}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text(
                              "Status: ${record['status']}",
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(
                        child: Text("No attendance records found."));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
